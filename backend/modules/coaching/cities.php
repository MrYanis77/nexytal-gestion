<?php
/**
 * modules/coaching/cities.php — CRUD coaching_cities
 */

function registerCoachingCitiesRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/cities', function () {
        Middleware::authenticate();
        $db = getDb();
        $stmt = $db->query('SELECT * FROM coaching_cities ORDER BY name ASC');
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/coaching/cities', function () {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare('INSERT INTO coaching_cities (name, slug) VALUES (:name, :slug)');
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'coaching_city', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/coaching/cities/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_cities WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('City not found'); return; }

        $fields = []; $bind = [];
        foreach (['name', 'slug'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE coaching_cities SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'update', 'coaching_city', $id, $old, $data);
        Response::success(['id' => $id], 'City updated');
    });

    $router->delete('/api/admin/coaching/cities/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_cities WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('City not found'); return; }
        $stmt = $db->prepare('DELETE FROM coaching_cities WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'delete', 'coaching_city', $id, $old, null);
        Response::noContent();
    });
}
