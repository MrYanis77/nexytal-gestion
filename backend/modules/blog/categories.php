<?php
/**
 * modules/blog/categories.php — CRUD blog_categories (admin, filtré par site_id)
 */

function registerBlogCategoriesRoutes(Router $router): void
{
    // ===== LISTE =====
    $router->get('/api/admin/blog/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, site_id, name, slug, description, color, is_active, sort_order, created_at 
             FROM blog_categories 
             WHERE site_id = :site_id 
             ORDER BY sort_order ASC, name ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    // ===== CRÉER =====
    $router->post('/api/admin/blog/categories', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('name', 'Name')
            ->maxLength('name', 255, 'Name')
            ->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();

        // Vérifier unicité slug par site
        $stmt = $db->prepare('SELECT id FROM blog_categories WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) {
            Response::badRequest('A category with this slug already exists for this site');
            return;
        }

        $stmt = $db->prepare(
            'INSERT INTO blog_categories (site_id, name, slug, description, color, is_active, sort_order, created_at) 
             VALUES (:site_id, :name, :slug, :description, :color, :is_active, :sort_order, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $desc = $data['description'] ?? null;
        $stmt->bindParam(':description', $desc, PDO::PARAM_STR);
        $color = $data['color'] ?? null;
        $stmt->bindParam(':color', $color, PDO::PARAM_STR);
        $isActive = isset($data['is_active']) ? (int) $data['is_active'] : 1;
        $stmt->bindParam(':is_active', $isActive, PDO::PARAM_INT);
        $sortOrder = (int) ($data['sort_order'] ?? 0);
        $stmt->bindParam(':sort_order', $sortOrder, PDO::PARAM_INT);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();

        Audit::log((int) $admin['id'], $siteId, 'create', 'blog_category', $newId, null, $data);

        Response::created(['id' => $newId]);
    });

    // ===== MODIFIER =====
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
        $bind = [];
        foreach (['name', 'slug', 'description', 'color', 'is_active', 'sort_order'] as $f) {
            if (isset($data[$f])) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }

        if (empty($fields)) {
            Response::badRequest('No fields to update');
            return;
        }

        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE blog_categories SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'blog_category', $id, $old, $data);

        Response::success(['id' => $id], 'Category updated');
    });

    // ===== SUPPRIMER =====
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
