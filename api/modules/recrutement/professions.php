<?php
/**
 * modules/recrutement/professions.php — CRUD recrutement_professions (pages métiers SEO, site 3 médical)
 */

function registerRecrutementProfessionsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/professions', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT * FROM recrutement_professions WHERE site_id = :site_id ORDER BY name ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/professions', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO recrutement_professions (site_id, slug, name, sector, description, image_url, color, is_active, created_at)
             VALUES (:site_id, :slug, :name, :sector, :description, :image_url, :color, :is_active, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $sector = $data['sector'] ?? null;
        $stmt->bindParam(':sector', $sector, PDO::PARAM_STR);
        $desc = $data['description'] ?? null;
        $stmt->bindParam(':description', $desc, PDO::PARAM_STR);
        $img = $data['image_url'] ?? null;
        $stmt->bindParam(':image_url', $img, PDO::PARAM_STR);
        $color = $data['color'] ?? null;
        $stmt->bindParam(':color', $color, PDO::PARAM_STR);
        $isActive = isset($data['is_active']) ? (int) $data['is_active'] : 1;
        $stmt->bindParam(':is_active', $isActive, PDO::PARAM_INT);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'recrutement_profession', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/professions/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_professions WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Profession not found'); return; }
        $fields = []; $bind = [];
        foreach (['slug', 'name', 'sector', 'description', 'image_url', 'color', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE recrutement_professions SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], $siteId, 'update', 'recrutement_profession', $id, $old, $data);
        Response::success(['id' => $id], 'Profession updated');
    });

    $router->delete('/api/admin/recrutement/professions/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_professions WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Profession not found'); return; }
        $stmt = $db->prepare('DELETE FROM recrutement_professions WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], $siteId, 'delete', 'recrutement_profession', $id, $old, null);
        Response::noContent();
    });
}
