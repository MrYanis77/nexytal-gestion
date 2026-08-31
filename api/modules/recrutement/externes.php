<?php
/**
 * modules/recrutement/externes.php — CRUD candidatures_externes (aligné bdd.sql)
 *
 * Chaque candidature est liée à une offre (offre_id obligatoire).
 * Champs profil : cv_filename, experience_candidat, competences_reponses, disponibilite.
 */

require_once __DIR__ . '/candidature_externe_helpers.php';
require_once __DIR__ . '/gestion_candidatures.php';

function registerRecrutementExternesRoutes(Router $router): void
{
    // ── Liste des candidatures externes ──
    $router->get('/api/admin/recrutement/externes', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();

        $where = [];
        $params = [];

        // Vue globale (_all=1) : pas de filtre site implicite via header
        $allSites = Router::getQueryParam('_all') === '1' || Router::getQueryParam('all') === '1';
        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            $where[] = '(COALESCE(ce.site_id, o.site_id) = :site_id)';
            $params[':site_id'] = (int) $siteId;
        } elseif (!$allSites) {
            $headerSite = $_SERVER['HTTP_X_SITE_ID'] ?? null;
            if ($headerSite !== null && $headerSite !== '' && (int) $headerSite > 0) {
                $where[] = '(COALESCE(ce.site_id, o.site_id) = :site_id)';
                $params[':site_id'] = (int) $headerSite;
            }
        }

        // Filtre par offre
        if ($offreId = Router::getQueryParam('offre_id')) {
            $where[] = 'ce.offre_id = :offre_id';
            $params[':offre_id'] = (int) $offreId;
        }

        $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $orderBy = 'ce.created_at DESC';

        $stmt = $db->prepare(
            "SELECT ce.*, o.titre AS offre_titre, COALESCE(ce.site_id, o.site_id) AS site_id,
                    s.name AS site_name
             FROM candidatures_externes ce
             LEFT JOIN offres_emploi o ON ce.offre_id = o.id
             LEFT JOIN core_sites s ON s.id = COALESCE(ce.site_id, o.site_id)
             $whereClause
             ORDER BY {$orderBy}"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    // ── Liste unifiée (vue v_gestion_candidatures — prod Ionos) ──
    $router->get('/api/admin/recrutement/candidatures', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();

        $allSites = Router::getQueryParam('_all') === '1' || Router::getQueryParam('all') === '1';
        $siteId = Router::getQueryParam('site_id');
        if (!$siteId && !$allSites) {
            $headerSite = $_SERVER['HTTP_X_SITE_ID'] ?? null;
            if ($headerSite !== null && $headerSite !== '' && (int) $headerSite > 0) {
                $siteId = (int) $headerSite;
            }
        }

        $filters = [
            'site_id' => $siteId ? (int) $siteId : null,
            'offre_id' => Router::getQueryParam('offre_id') ? (int) Router::getQueryParam('offre_id') : null,
            'type' => Router::getQueryParam('type'),
            'limit' => Router::getQueryParam('limit') ? (int) Router::getQueryParam('limit') : 500,
        ];

        Response::success(gestionCandidaturesList($db, $filters));
    });



    // ── Création d'une candidature externe (par admin) ──
    $router->post('/api/admin/recrutement/externes', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('offre_id', 'Offre')
            ->required('prenom', 'Prénom')
            ->required('nom', 'Nom')
            ->required('email', 'Email')
            ->validate();

        $db = getDb();
        $offreId = (int) $data['offre_id'];
        $siteId = candidatureExterneResolveSiteId($db, $offreId, $siteId);

        $newId = candidatureExterneInsert($db, $offreId, $siteId, $data);
        Audit::log((int) $admin['id'], $siteId, 'create', 'candidature_externe', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    // ── Mise à jour d'une candidature externe ──
    $router->put('/api/admin/recrutement/externes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM candidatures_externes WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Not found'); return; }

        $fields = [];
        $bind = [];
        $updatable = candidatureExterneUpdatableFields($db);
        foreach ($updatable as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = candidatureExternePrepareUpdateValue($f, $data[$f]);
            }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }

        $sql = 'UPDATE candidatures_externes SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        // Historiser le changement de statut si applicable
        if (isset($data['statut']) && $data['statut'] !== $old['statut']) {
            $auteurType = in_array($admin['role'], ['superadmin', 'admin']) ? 'admin' : 'recruteur';
            try {
                $stmtH = $db->prepare(
                    'INSERT INTO candidature_historique (candidature_id, ancien_statut, nouveau_statut, commentaire, auteur_type, auteur_id, created_at)
                     VALUES (:cid, :as, :ns, :com, :at, :aid, NOW())'
                );
                $stmtH->execute([
                    ':cid' => $id,
                    ':as'  => $old['statut'],
                    ':ns'  => $data['statut'],
                    ':com' => $data['commentaire'] ?? 'Statut mis à jour',
                    ':at'  => $auteurType,
                    ':aid' => $admin['id'],
                ]);
            } catch (\Throwable $e) {
                // candidature_historique may not have auteur_type column yet — try legacy
                try {
                    $stmtH = $db->prepare(
                        'INSERT INTO candidature_historique (candidature_id, ancien_statut, nouveau_statut, commentaire, auteur_id, created_at)
                         VALUES (:cid, :as, :ns, :com, :aid, NOW())'
                    );
                    $stmtH->execute([
                        ':cid' => $id,
                        ':as'  => $old['statut'],
                        ':ns'  => $data['statut'],
                        ':com' => $data['commentaire'] ?? 'Statut mis à jour',
                        ':aid' => $admin['id'],
                    ]);
                } catch (\Throwable $ignored) {}
            }
        }

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'update', 'candidature_externe', $id, $old, $data);
        Response::success(['id' => $id]);
    });



    // ── Changement de statut pipeline (par recruteur ou admin) ──
    $router->post('/api/admin/recrutement/externes/{id}/status', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        if (empty($data['statut'])) {
            Response::badRequest('statut requis');
            return;
        }

        $validStatuts = ['recue', 'vue', 'shortlist', 'entretien', 'offre', 'refusee'];
        if (!in_array($data['statut'], $validStatuts, true)) {
            Response::badRequest('Statut invalide');
            return;
        }

        $stmt = $db->prepare('SELECT * FROM candidatures_externes WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Not found'); return; }

        $db->prepare('UPDATE candidatures_externes SET statut = :st WHERE id = :id')
            ->execute([':st' => $data['statut'], ':id' => $id]);

        // Historiser
        $auteurType = in_array($admin['role'], ['superadmin', 'admin']) ? 'admin' : 'recruteur';
        try {
            $db->prepare(
                'INSERT INTO candidature_historique (candidature_id, ancien_statut, nouveau_statut, commentaire, auteur_type, auteur_id, created_at)
                 VALUES (:cid, :as, :ns, :com, :at, :aid, NOW())'
            )->execute([
                ':cid' => $id,
                ':as'  => $old['statut'],
                ':ns'  => $data['statut'],
                ':com' => $data['commentaire'] ?? null,
                ':at'  => $auteurType,
                ':aid' => $admin['id'],
            ]);
        } catch (\Throwable $ignored) {}

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'status_change', 'candidature_externe', $id, $old, $data);
        Response::success(['id' => $id, 'statut' => $data['statut']]);
    });

    // ── Suppression ──
    $router->delete('/api/admin/recrutement/externes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM candidatures_externes WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Not found'); return; }

        $db->prepare('DELETE FROM candidatures_externes WHERE id = :id')
            ->execute([':id' => $id]);

        Audit::log((int) $admin['id'], (int) ($old['site_id'] ?? 0), 'delete', 'candidature_externe', $id, $old, null);
        Response::noContent();
    });
}
