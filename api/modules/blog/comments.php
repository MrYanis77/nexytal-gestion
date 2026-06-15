<?php
/**
 * modules/blog/comments.php — CRUD blog_comments (admin modération)
 */

function registerBlogCommentsRoutes(Router $router): void
{
    // Liste des commentaires par post ou par site
    $router->get('/api/admin/blog/comments', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        $postId = Router::getQueryParam('post_id');
        $status = Router::getQueryParam('status');

        $where = ['p.site_id = :site_id', 'p.deleted_at IS NULL'];
        $params = [':site_id' => $siteId];

        if ($postId) {
            $where[] = 'c.post_id = :post_id';
            $params[':post_id'] = (int) $postId;
        }
        if ($status) {
            $where[] = 'c.status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM blog_comments c INNER JOIN blog_posts p ON c.post_id = p.id $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.*, p.title as post_title 
             FROM blog_comments c 
             INNER JOIN blog_posts p ON c.post_id = p.id 
             $whereClause 
             ORDER BY c.created_at DESC 
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->post('/api/admin/blog/comments', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor', 'moderator']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('post_id', 'Post')->required('author_name', 'Author')->required('author_email', 'Email')->required('content', 'Content')->validate();

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM blog_posts WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->execute([':id' => $data['post_id'], ':site_id' => $siteId]);
        if (!$stmt->fetch()) { Response::badRequest('Invalid post'); return; }

        $stmt = $db->prepare(
            'INSERT INTO blog_comments (post_id, author_name, author_email, content, status, created_at, updated_at)
             VALUES (:pid, :an, :ae, :content, :st, NOW(), NOW())'
        );
        $stmt->execute([
            ':pid' => $data['post_id'], ':an' => $data['author_name'],
            ':ae' => $data['author_email'], ':content' => $data['content'],
            ':st' => $data['status'] ?? 'pending',
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'blog_comment', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    // Modérer un commentaire (changer statut)
    $router->put('/api/admin/blog/comments/{id}', function (array $params) {
        Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor', 'moderator']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        Validator::make($data)
            ->required('status', 'Status')
            ->in('status', ['pending', 'approved', 'spam'], 'Status')
            ->validate();

        $stmt = $db->prepare('SELECT * FROM blog_comments WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Comment not found'); return; }

        $stmt = $db->prepare('UPDATE blog_comments SET status = :status, updated_at = NOW() WHERE id = :id');
        $stmt->bindParam(':status', $data['status'], PDO::PARAM_STR);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], null, 'moderate', 'blog_comment', $id, $old, $data);
        Response::success(['id' => $id], 'Comment moderated');
    });

    // Supprimer un commentaire
    $router->delete('/api/admin/blog/comments/{id}', function (array $params) {
        Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'moderator']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM blog_comments WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Comment not found'); return; }

        $stmt = $db->prepare('DELETE FROM blog_comments WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], null, 'delete', 'blog_comment', $id, $old, null);
        Response::noContent();
    });
}
