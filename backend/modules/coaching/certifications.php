<?php
/**
 * modules/coaching/certifications.php — CRUD coaching_certifications
 */

function registerCoachingCertificationsRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/certifications', function () {
        Middleware::authenticate();
        $db = getDb();
        $stmt = $db->query('SELECT * FROM coaching_certifications ORDER BY organization ASC, level ASC');
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/coaching/certifications', function () {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        Validator::make($data)->required('code', 'Code')->required('organization', 'Organization')->validate();
        $db = getDb();
        $stmt = $db->prepare('INSERT INTO coaching_certifications (code, organization, level) VALUES (:code, :org, :lvl)');
        $stmt->bindParam(':code', $data['code'], PDO::PARAM_STR);
        $stmt->bindParam(':org', $data['organization'], PDO::PARAM_STR);
        $lvl = $data['level'] ?? null;
        $stmt->bindParam(':lvl', $lvl, PDO::PARAM_STR);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'coaching_certification', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/coaching/certifications/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_certifications WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Certification not found'); return; }

        $fields = []; $bind = [];
        foreach (['code', 'organization', 'level'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE coaching_certifications SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'update', 'coaching_certification', $id, $old, $data);
        Response::success(['id' => $id], 'Certification updated');
    });

    $router->delete('/api/admin/coaching/certifications/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_certifications WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Certification not found'); return; }
        $stmt = $db->prepare('DELETE FROM coaching_certifications WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'delete', 'coaching_certification', $id, $old, null);
        Response::noContent();
    });
}
