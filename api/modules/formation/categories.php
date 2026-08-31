<?php
/**
 * modules/formation/categories.php — CRUD formation_categories
 */

require_once __DIR__ . '/formation_schema.php';

function registerFormationCategoriesRoutes(Router $router): void
{
    $router->get('/api/admin/formation/categories', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $labelCol = formationCategoryLabelColumn($db);
        $orderCol = $labelCol === 'label' ? 'label' : 'name';
        $stmt = $db->prepare("SELECT * FROM formation_categories WHERE site_id = :site_id ORDER BY sort_order ASC, {$orderCol} ASC");
        $stmt->execute([':site_id' => $siteId]);
        $rows = array_map(fn (array $row) => formationCategoryRowToApi($row, $db), $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::success($rows);
    });

    $router->post('/api/admin/formation/categories', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();

        $name = trim((string) ($data['label'] ?? $data['name'] ?? ''));
        if ($name === '') {
            Response::badRequest('Nom requis');
            return;
        }
        $slug = $data['slug'] ?? Validator::slugify($name);

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM formation_categories WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
        if ($stmt->fetch()) {
            Response::badRequest('Category slug already exists');
            return;
        }

        $labelCol = formationCategoryLabelColumn($db);
        if ($labelCol === 'label') {
            $stmt = $db->prepare(
                'INSERT INTO formation_categories (site_id, slug, label, description, catalogue_type, sort_order, is_active, created_at)
                 VALUES (:site_id, :slug, :label, :description, :catalogue_type, :sort_order, :is_active, NOW())'
            );
            $stmt->execute([
                ':site_id' => $siteId,
                ':slug' => $slug,
                ':label' => $name,
                ':description' => $data['description'] ?? null,
                ':catalogue_type' => $data['catalogue_type'] ?? 'all',
                ':sort_order' => (int) ($data['sort_order'] ?? 0),
                ':is_active' => isset($data['is_active']) ? (int) $data['is_active'] : 1,
            ]);
        } else {
            $stmt = $db->prepare(
                'INSERT INTO formation_categories (site_id, slug, name, description, sort_order, is_active, created_at)
                 VALUES (:site_id, :slug, :name, :description, :sort_order, :is_active, NOW())'
            );
            $stmt->execute([
                ':site_id' => $siteId,
                ':slug' => $slug,
                ':name' => $name,
                ':description' => $data['description'] ?? null,
                ':sort_order' => (int) ($data['sort_order'] ?? 0),
                ':is_active' => isset($data['is_active']) ? (int) $data['is_active'] : 1,
            ]);
        }

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'formation_category', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/formation/categories/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formation_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Category not found');
            return;
        }

        $labelCol = formationCategoryLabelColumn($db);
        $fields = [];
        $bind = [':id' => $id, ':site_id' => $siteId];

        if (isset($data['slug'])) {
            $fields[] = 'slug = :slug';
            $bind[':slug'] = $data['slug'];
        }
        if (isset($data['label']) || isset($data['name'])) {
            $nameVal = $data['label'] ?? $data['name'];
            if ($labelCol === 'label') {
                $fields[] = 'label = :label';
                $bind[':label'] = $nameVal;
            } else {
                $fields[] = 'name = :name';
                $bind[':name'] = $nameVal;
            }
        }
        foreach (['description', 'sort_order', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if ($labelCol === 'label' && array_key_exists('catalogue_type', $data)) {
            $fields[] = 'catalogue_type = :catalogue_type';
            $bind[':catalogue_type'] = $data['catalogue_type'];
        }

        if (empty($fields)) {
            Response::badRequest('No fields to update');
            return;
        }

        $fields[] = 'updated_at = NOW()';
        $sql = 'UPDATE formation_categories SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmt = $db->prepare($sql);
        $stmt->execute($bind);

        Audit::log((int) $admin['id'], $siteId, 'update', 'formation_category', $id, $old, $data);
        Response::success(['id' => $id], 'Category updated');
    });

    $router->delete('/api/admin/formation/categories/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formation_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Category not found');
            return;
        }

        $stmt = $db->prepare('DELETE FROM formation_categories WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);

        Audit::log((int) $admin['id'], $siteId, 'delete', 'formation_category', $id, $old, null);
        Response::noContent();
    });
}
