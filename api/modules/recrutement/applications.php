<?php
/**
 * modules/recrutement/applications.php — CRUD candidatures (v2.1)
 */

function registerRecrutementApplicationsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/applications', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['o.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('statut')) {
            $where[] = 'c.statut = :statut';
            $params[':statut'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare(
            "SELECT COUNT(*) as total FROM candidatures c
             INNER JOIN offres_emploi o ON c.offre_id = o.id $whereClause"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.*, o.titre as offre_titre, cand.prenom as candidat_prenom, cand.nom as candidat_nom, u.email as candidat_email
             FROM candidatures c
             INNER JOIN offres_emploi o ON c.offre_id = o.id
             INNER JOIN candidats cand ON c.candidat_id = cand.id
             INNER JOIN users u ON cand.user_id = u.id
             $whereClause
             ORDER BY c.date_candidature DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT c.*, o.titre as offre_titre, cand.prenom as candidat_prenom, cand.nom as candidat_nom, u.email as candidat_email
             FROM candidatures c
             INNER JOIN offres_emploi o ON c.offre_id = o.id
             INNER JOIN candidats cand ON c.candidat_id = cand.id
             INNER JOIN users u ON cand.user_id = u.id
             WHERE c.id = :id AND o.site_id = :site_id LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $app = $stmt->fetch();
        if (!$app) { Response::notFound('Candidature not found'); return; }

        $stmtH = $db->prepare(
            'SELECT ch.*, au.email as auteur_admin_email
             FROM candidature_historique ch
             LEFT JOIN core_admin_users au ON ch.auteur_admin_id = au.id
             WHERE ch.candidature_id = :id ORDER BY ch.created_at DESC'
        );
        $stmtH->execute([':id' => $id]);
        $app['historique'] = $stmtH->fetchAll();

        Response::success($app);
    });

    $router->post('/api/admin/recrutement/applications', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('offre_id', 'Offre')->required('candidat_id', 'Candidat')->validate();

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM offres_emploi WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $data['offre_id'], ':site_id' => $siteId]);
        if (!$stmt->fetch()) { Response::badRequest('Invalid offer for this site'); return; }

        try {
            $stmt = $db->prepare(
                'INSERT INTO candidatures (offre_id, candidat_id, message_motivation, notes_recruteur, statut, source, date_candidature, updated_at)
                 VALUES (:oid, :cid, :msg, :notes, :st, :src, NOW(), NOW())'
            );
            $stmt->execute([
                ':oid' => $data['offre_id'], ':cid' => $data['candidat_id'],
                ':msg' => $data['message_motivation'] ?? null, ':notes' => $data['notes_recruteur'] ?? null,
                ':st' => $data['statut'] ?? 'recue', ':src' => $data['source'] ?? 'site',
            ]);
            $newId = (int) $db->lastInsertId();
            Audit::log((int) $admin['id'], $siteId, 'create', 'candidature', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\PDOException $e) {
            Response::badRequest('Candidature already exists for this offer/candidat');
        }
    });

    $router->put('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT c.* FROM candidatures c
             INNER JOIN offres_emploi o ON c.offre_id = o.id
             WHERE c.id = :id AND o.site_id = :site_id LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Candidature not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['statut', 'message_motivation', 'notes_recruteur'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = 'updated_at = NOW()';
        $sql = 'UPDATE candidatures SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        if (isset($data['statut']) && $data['statut'] !== $old['statut']) {
            $stmtH = $db->prepare(
                'INSERT INTO candidature_historique (candidature_id, ancien_statut, nouveau_statut, commentaire, auteur_admin_id, created_at)
                 VALUES (:cid, :as, :ns, :com, :aid, NOW())'
            );
            $stmtH->execute([
                ':cid' => $id,
                ':as' => $old['statut'],
                ':ns' => $data['statut'],
                ':com' => $data['commentaire'] ?? 'Statut mis à jour',
                ':aid' => $admin['id'],
            ]);
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'candidature', $id, $old, $data);
        Response::success(['id' => $id], 'Candidature updated');
    });

    $router->delete('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT c.* FROM candidatures c
             INNER JOIN offres_emploi o ON c.offre_id = o.id
             WHERE c.id = :id AND o.site_id = :site_id LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Candidature not found'); return; }

        $stmt = $db->prepare('DELETE FROM candidatures WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'candidature', $id, $old, null);
        Response::noContent();
    });
}
