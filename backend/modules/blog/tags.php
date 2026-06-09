<?php
/**
 * modules/blog/tags.php — CRUD blog_tags (admin, filtré par site_id)
 */

function registerBlogTagsRoutes(Router $router): void
{
    $router->get('/api/admin/blog/tags', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, site_id, name, slug, created_at 
             FROM blog_tags WHERE site_id = :site_id ORDER BY name ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/blog/tags', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('name', 'Name')->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();

        $stmt = $db->prepare(
            'INSERT INTO blog_tags (site_id, name, slug, created_at) VALUES (:site_id, :name, :slug, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'blog_tag', $newId, null, $data);

        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/blog/tags/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_tags WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Tag not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['name', 'slug'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $sql = 'UPDATE blog_tags SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'blog_tag', $id, $old, $data);
        Response::success(['id' => $id], 'Tag updated');
    });

    $router->delete('/api/admin/blog/tags/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_tags WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Tag not found'); return; }

        // Supprimer les pivots
        $stmt = $db->prepare('DELETE FROM blog_post_tags WHERE tag_id = :tag_id');
        $stmt->bindParam(':tag_id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $stmt = $db->prepare('DELETE FROM blog_tags WHERE id = :id AND site_id = :site_id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'blog_tag', $id, $old, null);
        Response::noContent();
    });
}
