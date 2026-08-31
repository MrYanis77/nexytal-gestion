<?php
/**
 * modules/blog/authors.php — CRUD blog_authors (admin, filtré par site_id)
 */

require_once __DIR__ . '/blog_helpers.php';

function registerBlogAuthorsRoutes(Router $router): void
{
    $router->get('/api/admin/blog/authors', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $cols = blogAuthorsSelectSql($db);

        $stmt = $db->prepare(
            "SELECT {$cols} FROM blog_authors WHERE site_id = :site_id ORDER BY last_name ASC"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/blog/authors', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('first_name', 'First name')
            ->required('last_name', 'Last name')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['first_name'] . ' ' . $data['last_name']);
        $db = getDb();

        $row = [
            'site_id' => $siteId,
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'email' => $data['email'],
            'slug' => $slug,
            'bio' => isset($data['bio']) ? (string) $data['bio'] : null,
            'is_active' => isset($data['is_active']) ? (int) $data['is_active'] : 1,
            'created_at' => date('Y-m-d H:i:s'),
        ];

        if (blogHasColumn($db, 'blog_authors', 'avatar_url')) {
            $row['avatar_url'] = isset($data['avatar_url']) ? (string) $data['avatar_url'] : null;
        }

        try {
            $newId = blogInsert($db, 'blog_authors', $row);
        } catch (\Throwable $e) {
            Response::serverError('Failed to create author', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'create', 'blog_author', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/blog/authors/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_authors WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Author not found'); return; }

        $fields = [];
        foreach (['first_name', 'last_name', 'email', 'slug', 'bio', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[$f] = $f === 'is_active' ? (int) $data[$f] : $data[$f];
            }
        }
        if (blogHasColumn($db, 'blog_authors', 'avatar_url') && array_key_exists('avatar_url', $data)) {
            $fields['avatar_url'] = $data['avatar_url'];
        }

        if ($fields === []) {
            Response::badRequest('No fields to update');
            return;
        }

        try {
            blogUpdate($db, 'blog_authors', $fields, 'WHERE id = :id AND site_id = :site_id', [
                ':id' => $id,
                ':site_id' => $siteId,
            ]);
        } catch (\Throwable $e) {
            Response::serverError('Failed to update author', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'blog_author', $id, $old, $data);
        Response::success(['id' => $id], 'Author updated');
    });

    $router->delete('/api/admin/blog/authors/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_authors WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Author not found'); return; }

        $stmt = $db->prepare('DELETE FROM blog_authors WHERE id = :id AND site_id = :site_id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'blog_author', $id, $old, null);
        Response::noContent();
    });
}
