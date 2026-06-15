<?php
/**
 * modules/trainer/expertises.php — CRUD expertises
 */

function registerTrainerExpertisesRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/expertises', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM expertises ORDER BY label ASC');
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/trainer/expertises', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        
        Validator::make($data)->required('label', 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['label']);
        
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM expertises WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Expertise slug already exists'); return; }

        $stmt = $db->prepare('INSERT INTO expertises (label, slug) VALUES (:label, :slug)');
        $stmt->bindParam(':label', $data['label'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 1, 'create', 'expertise', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/trainer/expertises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM expertises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Expertise not found'); return; }

        $fields = []; $bind = [];
        foreach (['label', 'slug'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $sql = 'UPDATE expertises SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'update', 'expertise', $id, $old, $data);
        Response::success(['id' => $id], 'Expertise updated');
    });

    $router->delete('/api/admin/trainer/expertises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM expertises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Expertise not found'); return; }
        
        $stmt = $db->prepare('DELETE FROM expertises WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'delete', 'expertise', $id, $old, null);
        Response::noContent();
    });
}
