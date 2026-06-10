<?php
/**
 * modules/coaching/specialties.php — CRUD coaching_specialties
 */

function registerCoachingSpecialtiesRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/specialties', function () {
        Middleware::authenticate();
        $db = getDb();
        $stmt = $db->query('SELECT * FROM coaching_specialties ORDER BY name ASC');
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/coaching/specialties', function () {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare('INSERT INTO coaching_specialties (name, slug, icon) VALUES (:name, :slug, :icon)');
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $icon = $data['icon'] ?? null;
        $stmt->bindParam(':icon', $icon, PDO::PARAM_STR);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'coaching_specialty', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/coaching/specialties/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_specialties WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Specialty not found'); return; }

        $fields = []; $bind = [];
        foreach (['name', 'slug', 'icon'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE coaching_specialties SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'update', 'coaching_specialty', $id, $old, $data);
        Response::success(['id' => $id], 'Specialty updated');
    });

    $router->delete('/api/admin/coaching/specialties/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM coaching_specialties WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Specialty not found'); return; }
        $stmt = $db->prepare('DELETE FROM coaching_specialties WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'delete', 'coaching_specialty', $id, $old, null);
        Response::noContent();
    });
}
