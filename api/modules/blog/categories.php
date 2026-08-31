<?php
/**
 * modules/blog/categories.php — CRUD blog_categories (admin, filtré par site_id)
 */

require_once __DIR__ . '/blog_helpers.php';

function registerBlogCategoriesRoutes(Router $router): void
{
    $router->get('/api/admin/blog/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $cols = blogCategoriesSelectSql($db);

        $stmt = $db->prepare(
            "SELECT {$cols} FROM blog_categories
             WHERE site_id = :site_id
             ORDER BY sort_order ASC, name ASC"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/blog/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('name', 'Name')
            ->maxLength('name', 255, 'Name')
            ->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        if ($slug === '') {
            Response::badRequest('Slug invalide — renseignez un nom de catégorie valide');
            return;
        }
        $db = getDb();

        $stmt = $db->prepare('SELECT id FROM blog_categories WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) {
            Response::badRequest('A category with this slug already exists for this site');
            return;
        }

        $row = [
            'site_id' => $siteId,
            'name' => $data['name'],
            'slug' => $slug,
            'description' => $data['description'] ?? null,
            'is_active' => isset($data['is_active']) ? (int) $data['is_active'] : 1,
            'sort_order' => (int) ($data['sort_order'] ?? 0),
            'created_at' => date('Y-m-d H:i:s'),
        ];

        if (blogHasColumn($db, 'blog_categories', 'color')) {
            $row['color'] = $data['color'] ?? null;
        }

        try {
            $newId = blogInsert($db, 'blog_categories', $row);
        } catch (\Throwable $e) {
            Response::serverError('Failed to create category', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'create', 'blog_category', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/blog/categories/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) {
            Response::notFound('Category not found');
            return;
        }

        $fields = [];
        foreach (['name', 'slug', 'description', 'is_active', 'sort_order'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[$f] = in_array($f, ['is_active', 'sort_order'], true) ? (int) $data[$f] : $data[$f];
            }
        }
        if (blogHasColumn($db, 'blog_categories', 'color') && array_key_exists('color', $data)) {
            $fields['color'] = $data['color'];
        }

        if ($fields === []) {
            Response::badRequest('No fields to update');
            return;
        }

        try {
            blogUpdate($db, 'blog_categories', $fields, 'WHERE id = :id AND site_id = :site_id', [
                ':id' => $id,
                ':site_id' => $siteId,
            ]);
        } catch (\Throwable $e) {
            Response::serverError('Failed to update category', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'blog_category', $id, $old, $data);
        Response::success(['id' => $id], 'Category updated');
    });

    $router->delete('/api/admin/blog/categories/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_categories WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) {
            Response::notFound('Category not found');
            return;
        }

        $stmt = $db->prepare('DELETE FROM blog_categories WHERE id = :id AND site_id = :site_id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'blog_category', $id, $old, null);
        Response::noContent();
    });
}
