<?php
/**
 * modules/blog/authors.php — CRUD blog_authors (admin, filtré par site_id)
 */

function registerBlogAuthorsRoutes(Router $router): void
{
    $router->get('/api/admin/blog/authors', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, site_id, first_name, last_name, email, slug, bio, avatar_url, is_active, created_at 
             FROM blog_authors WHERE site_id = :site_id ORDER BY last_name ASC'
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

        $stmt = $db->prepare(
            'INSERT INTO blog_authors (site_id, first_name, last_name, email, slug, bio, avatar_url, is_active, created_at)
             VALUES (:site_id, :first_name, :last_name, :email, :slug, :bio, :avatar_url, :is_active, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':first_name', $data['first_name'], PDO::PARAM_STR);
        $stmt->bindParam(':last_name', $data['last_name'], PDO::PARAM_STR);
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $bio = $data['bio'] ?? null;
        $stmt->bindParam(':bio', $bio, PDO::PARAM_STR);
        $avatar = $data['avatar_url'] ?? null;
        $stmt->bindParam(':avatar_url', $avatar, PDO::PARAM_STR);
        $isActive = isset($data['is_active']) ? (int) $data['is_active'] : 1;
        $stmt->bindParam(':is_active', $isActive, PDO::PARAM_INT);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
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
        $bind = [];
        foreach (['first_name', 'last_name', 'email', 'slug', 'bio', 'avatar_url', 'is_active'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE blog_authors SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

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
