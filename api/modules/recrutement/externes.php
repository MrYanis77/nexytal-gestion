<?php
/**
 * modules/recrutement/externes.php — CRUD candidatures_externes
 */

function registerRecrutementExternesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/externes', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT ce.*, o.titre as offre_titre FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON ce.offre_id = o.id
             WHERE ce.site_id = :site_id ORDER BY ce.created_at DESC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/externes', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('offre_id', 'Offre')->required('prenom', 'Prénom')->required('nom', 'Nom')->required('email', 'Email')->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO candidatures_externes (offre_id, site_id, prenom, nom, email, telephone, lettre_motivation, linkedin_url, statut, rgpd_consent_at, created_at)
             VALUES (:oid, :sid, :pre, :nom, :email, :tel, :lm, :li, :st, NOW(), NOW())'
        );
        $stmt->execute([
            ':oid' => $data['offre_id'],
            ':sid' => $siteId,
            ':pre' => $data['prenom'],
            ':nom' => $data['nom'],
            ':email' => $data['email'],
            ':tel' => $data['telephone'] ?? null,
            ':lm' => $data['lettre_motivation'] ?? null,
            ':li' => $data['linkedin_url'] ?? null,
            ':st' => $data['statut'] ?? 'recue',
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'candidature_externe', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/externes/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM candidatures_externes WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['prenom', 'nom', 'email', 'telephone', 'lettre_motivation', 'linkedin_url', 'statut'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }

        $sql = 'UPDATE candidatures_externes SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'candidature_externe', $id, $old, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/recrutement/externes/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('DELETE FROM candidatures_externes WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'candidature_externe', $id, null, null);
        Response::noContent();
    });
}
