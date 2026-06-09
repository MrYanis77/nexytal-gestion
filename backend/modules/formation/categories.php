<?php
/**
 * modules/formation/categories.php — CRUD formation_categories
 */

function registerFormationCategoriesRoutes(Router $router): void
{
    $router->get('/api/admin/formation/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM formation_categories WHERE site_id = :site_id ORDER BY sort_order ASC, name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/formation/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM formation_categories WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Category slug already exists for this site'); return; }

        $stmt = $db->prepare(
            'INSERT INTO formation_categories (site_id, name, slug, description, sort_order, is_active, created_at)
             VALUES (:site_id, :name, :slug, :description, :sort_order, :is_active, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $desc = $data['description'] ?? null;
        $stmt->bindParam(':description', $desc, PDO::PARAM_STR);
        $sort = (int) ($data['sort_order'] ?? 0);
        $stmt->bindParam(':sort_order', $sort, PDO::PARAM_INT);
        $active = isset($data['is_active']) ? (int) $data['is_active'] : 1;
        $stmt->bindParam(':is_active', $active, PDO::PARAM_INT);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'formation_category', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/formation/categories/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formation_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Category not found'); return; }

        $fields = []; $bind = [];
        foreach (['name', 'slug', 'description', 'sort_order', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE formation_categories SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'formation_category', $id, $old, $data);
        Response::success(['id' => $id], 'Category updated');
    });

    $router->delete('/api/admin/formation/categories/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formation_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Category not found'); return; }

        $stmt = $db->prepare('DELETE FROM formation_categories WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'formation_category', $id, $old, null);
        Response::noContent();
    });
}
