<?php
/**
 * modules/recrutement/alertes.php — CRUD alertes_emploi
 */

function registerRecrutementAlertesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/alertes', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT a.*, c.prenom, c.nom, m.libelle as metier_libelle
             FROM alertes_emploi a
             INNER JOIN candidats c ON a.candidat_id = c.id
             LEFT JOIN metiers m ON a.metier_id = m.id
             ORDER BY a.created_at DESC'
        );
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/alertes', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('candidat_id', 'Candidat')->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO alertes_emploi (candidat_id, site_id, metier_id, mots_cles, ville, rayon_km, type_contrat, frequence, active, created_at)
             VALUES (:cid, :sid, :mid, :mk, :v, :rk, :tc, :freq, :act, NOW())'
        );
        $stmt->execute([
            ':cid' => $data['candidat_id'],
            ':sid' => $data['site_id'] ?? $siteId,
            ':mid' => $data['metier_id'] ?? null,
            ':mk' => $data['mots_cles'] ?? null,
            ':v' => $data['ville'] ?? null,
            ':rk' => $data['rayon_km'] ?? null,
            ':tc' => $data['type_contrat'] ?? null,
            ':freq' => $data['frequence'] ?? 'hebdomadaire',
            ':act' => $data['active'] ?? 1,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'alerte_emploi', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/alertes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $fields = [];
        $bind = [];
        foreach (['candidat_id', 'metier_id', 'mots_cles', 'ville', 'rayon_km', 'type_contrat', 'frequence', 'active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }

        $sql = 'UPDATE alertes_emploi SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        Audit::log((int) $admin['id'], 1, 'update', 'alerte_emploi', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/recrutement/alertes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        $db->prepare('DELETE FROM alertes_emploi WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 1, 'delete', 'alerte_emploi', $id, null, null);
        Response::noContent();
    });
}
