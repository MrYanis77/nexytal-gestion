<?php
/**
 * modules/recrutement/demandes_urgentes.php — CRUD demandes urgentes (site_id scoped)
 *
 * Table demandes_urgentes : nom, établissement, email, téléphone, métier, ville,
 *   message, statut (recue/en_cours/traitee/archivee), recruteur_id, site_id.
 */

require_once __DIR__ . '/site_scope.php';

function registerDemandesUrgentesRoutes(Router $router): void
{
    // ── Liste des demandes urgentes ──
    $router->get('/api/admin/recrutement/demandes-urgentes', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();

        $where = [];
        $params = [];

        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            $where[] = 'du.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
            Middleware::requireSiteAccess((int) $siteId);
        }

        $status = Router::getQueryParam('status');
        if ($status) {
            $where[] = 'du.statut = :statut';
            $params[':statut'] = $status;
        }

        $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $sql = "SELECT du.*, cs.name AS site_name
                FROM demandes_urgentes du
                LEFT JOIN core_sites cs ON cs.id = du.site_id
                $whereClause
                ORDER BY du.created_at DESC";
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    // ── Compteur en attente ──
    $router->get('/api/admin/recrutement/demandes-urgentes/pending-count', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();

        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            Middleware::requireSiteAccess((int) $siteId);
            $stmt = $db->prepare("SELECT COUNT(*) as count FROM demandes_urgentes WHERE statut = 'recue' AND site_id = :sid");
            $stmt->execute([':sid' => (int) $siteId]);
        } else {
            $stmt = $db->query("SELECT COUNT(*) as count FROM demandes_urgentes WHERE statut = 'recue'");
        }
        Response::success(['count' => (int) $stmt->fetch()['count']]);
    });

    // ── Détail ──
    $router->get('/api/admin/recrutement/demandes-urgentes/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT du.*, cs.name AS site_name FROM demandes_urgentes du LEFT JOIN core_sites cs ON cs.id = du.site_id WHERE du.id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch();
        if (!$row) { Response::notFound('Demande not found'); return; }
        Middleware::requireSiteAccess((int) $row['site_id']);

        Response::success($row);
    });

    // ── Mise à jour statut ──
    $router->put('/api/admin/recrutement/demandes-urgentes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM demandes_urgentes WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Demande not found'); return; }
        Middleware::requireSiteAccess((int) $old['site_id']);

        $validStatuts = ['recue', 'en_cours', 'traitee', 'archivee'];
        $fields = []; $bind = [];

        foreach (['statut', 'nom', 'email', 'telephone', 'metier', 'ville', 'message', 'etablissement'] as $f) {
            if (array_key_exists($f, $data)) {
                if ($f === 'statut' && !in_array($data[$f], $validStatuts, true)) {
                    Response::badRequest("Statut invalide. Valeurs : " . implode(', ', $validStatuts));
                    return;
                }
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }

        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE demandes_urgentes SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        // Notification email si changement de statut
        if (isset($data['statut']) && $data['statut'] !== $old['statut']) {
            require_once __DIR__ . '/../../core/ActionNotify.php';
            ActionNotify::demandeUrgenteStatusChanged($db, array_merge($old, $data), $old['statut'], $data['statut']);
        }

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'update', 'demande_urgente', $id, $old, $data);
        Response::success(['id' => $id], 'Demande mise à jour');
    });

    // ── Suppression ──
    $router->delete('/api/admin/recrutement/demandes-urgentes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM demandes_urgentes WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Demande not found'); return; }
        Middleware::requireSiteAccess((int) $old['site_id']);

        $db->prepare('DELETE FROM demandes_urgentes WHERE id = :id')->execute([':id' => $id]);

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'delete', 'demande_urgente', $id, $old, null);
        Response::noContent();
    });
}
