<?php
/**
 * modules/blog/posts.php — CRUD blog_posts (admin, filtré par site_id)
 * 
 * Gère versions, tags pivot, articles liés, soft delete.
 * Filtres : status, category_id, is_featured, search. Pagination.
 */

require_once __DIR__ . '/blog_helpers.php';

function registerBlogPostsRoutes(Router $router): void
{
    // ===== LISTE =====
    $router->get('/api/admin/blog/posts', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['p.site_id = :site_id', 'p.deleted_at IS NULL'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'p.status = :status';
            $params[':status'] = $status;
        }
        if ($categoryId = Router::getQueryParam('category_id')) {
            $where[] = 'p.category_id = :category_id';
            $params[':category_id'] = (int) $categoryId;
        }
        if (Router::getQueryParam('is_featured') !== null) {
            $where[] = 'p.is_featured = :is_featured';
            $params[':is_featured'] = (int) Router::getQueryParam('is_featured');
        }
        if ($search = Router::getQueryParam('search')) {
            $where[] = '(p.title LIKE :search OR p.excerpt LIKE :search2)';
            $params[':search'] = "%$search%";
            $params[':search2'] = "%$search%";
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        // Count
        $stmt = $db->prepare("SELECT COUNT(*) as total FROM blog_posts p $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        // Fetch
        $stmt = $db->prepare(
            "SELECT p.*, 
                    c.name as category_name,
                    CONCAT(a.first_name, ' ', a.last_name) as author_name
             FROM blog_posts p
             LEFT JOIN blog_categories c ON p.category_id = c.id
             LEFT JOIN blog_authors a ON p.author_id = a.id
             $whereClause
             ORDER BY p.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $posts = $stmt->fetchAll();

        // Ajouter les tags pour chaque post
        foreach ($posts as &$post) {
            $stmt2 = $db->prepare(
                'SELECT t.id, t.name, t.slug 
                 FROM blog_tags t 
                 INNER JOIN blog_post_tags pt ON t.id = pt.tag_id 
                 WHERE pt.post_id = :post_id'
            );
            $stmt2->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
            $stmt2->execute();
            $post['tags'] = $stmt2->fetchAll();
            $post['id'] = (int) $post['id'];
            $post['is_featured'] = (bool) $post['is_featured'];
            $post['views_count'] = (int) $post['views_count'];
        }

        Response::paginated($posts, $total, $pagination['page'], $pagination['limit']);
    });

    // ===== DÉTAIL =====
    $router->get('/api/admin/blog/posts/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            "SELECT p.*, 
                    c.name as category_name,
                    CONCAT(a.first_name, ' ', a.last_name) as author_name
             FROM blog_posts p
             LEFT JOIN blog_categories c ON p.category_id = c.id
             LEFT JOIN blog_authors a ON p.author_id = a.id
             WHERE p.id = :id AND p.site_id = :site_id AND p.deleted_at IS NULL
             LIMIT 1"
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $post = $stmt->fetch();

        if (!$post) { Response::notFound('Post not found'); return; }

        // Tags
        $stmt = $db->prepare(
            'SELECT t.id, t.name, t.slug FROM blog_tags t 
             INNER JOIN blog_post_tags pt ON t.id = pt.tag_id WHERE pt.post_id = :post_id'
        );
        $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $post['tags'] = $stmt->fetchAll();

        // Related posts
        if (blogHasTable($db, 'blog_related_posts')) {
            $stmt = $db->prepare(
                'SELECT rp.id, rp.title, rp.slug, rp.cover_image_url 
                 FROM blog_posts rp 
                 INNER JOIN blog_related_posts brp ON rp.id = brp.related_post_id 
                 WHERE brp.post_id = :post_id AND rp.deleted_at IS NULL'
            );
            $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $post['related_posts'] = $stmt->fetchAll();
        } else {
            $post['related_posts'] = [];
        }

        // Versions
        if (blogHasTable($db, 'blog_posts_versions')) {
            $stmt = $db->prepare(
                'SELECT id, title, status, created_by, created_at 
                 FROM blog_posts_versions WHERE post_id = :post_id ORDER BY created_at DESC'
            );
            $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
            $stmt->execute();
            $post['versions'] = $stmt->fetchAll();
        } else {
            $post['versions'] = [];
        }

        Response::success($post);
    });

    // ===== CRÉER =====
    $router->post('/api/admin/blog/posts', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('title', 'Title')
            ->required('content', 'Content')
            ->in('status', ['draft', 'review', 'published', 'archived'], 'Status')
            ->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['title']);
        if ($slug === '') {
            Response::badRequest('Slug invalide');
            return;
        }

        $db = getDb();

        $slugCheck = $db->prepare(
            'SELECT id FROM blog_posts WHERE site_id = :site_id AND slug = :slug AND deleted_at IS NULL LIMIT 1'
        );
        $slugCheck->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $slugCheck->bindValue(':slug', $slug, PDO::PARAM_STR);
        $slugCheck->execute();
        if ($slugCheck->fetch()) {
            Response::badRequest('Un article avec ce slug existe déjà pour ce site');
            return;
        }

        $db->beginTransaction();
        try {
            $status = $data['status'] ?? 'draft';
            $publishedAt = ($status === 'published') ? date('Y-m-d H:i:s') : ($data['published_at'] ?? null);

            $row = [
                'site_id' => $siteId,
                'category_id' => blogNormalizeOptionalInt($data['category_id'] ?? null),
                'author_id' => blogNormalizeOptionalInt($data['author_id'] ?? null),
                'title' => $data['title'],
                'slug' => $slug,
                'excerpt' => isset($data['excerpt']) ? (string) $data['excerpt'] : null,
                'content' => $data['content'] ?? '',
                'cover_image_url' => isset($data['cover_image_url']) ? (string) $data['cover_image_url'] : null,
                'read_time_mins' => blogNormalizeOptionalInt($data['read_time_mins'] ?? null),
                'status' => $status,
                'is_featured' => (int) ($data['is_featured'] ?? 0),
                'published_at' => $publishedAt !== null ? (string) $publishedAt : null,
                'views_count' => 0,
                'created_at' => date('Y-m-d H:i:s'),
            ];

            if (blogHasColumn($db, 'blog_posts', 'meta_title')) {
                $row['meta_title'] = isset($data['meta_title']) ? (string) $data['meta_title'] : null;
            }
            if (blogHasColumn($db, 'blog_posts', 'meta_description')) {
                $row['meta_description'] = isset($data['meta_description']) ? (string) $data['meta_description'] : null;
            }

            $postId = blogInsert($db, 'blog_posts', $row);

            // Tags pivot
            if (!empty($data['tag_ids']) && is_array($data['tag_ids'])) {
                $stmtTag = $db->prepare('INSERT INTO blog_post_tags (post_id, tag_id) VALUES (:post_id, :tag_id)');
                foreach ($data['tag_ids'] as $tagId) {
                    $stmtTag->bindValue(':post_id', $postId, PDO::PARAM_INT);
                    $stmtTag->bindValue(':tag_id', (int) $tagId, PDO::PARAM_INT);
                    $stmtTag->execute();
                }
            }

            // Related posts pivot
            if (blogHasTable($db, 'blog_related_posts')
                && !empty($data['related_post_ids'])
                && is_array($data['related_post_ids'])) {
                $stmtRel = $db->prepare('INSERT INTO blog_related_posts (post_id, related_post_id) VALUES (:post_id, :related_post_id)');
                foreach ($data['related_post_ids'] as $relId) {
                    $stmtRel->bindValue(':post_id', $postId, PDO::PARAM_INT);
                    $stmtRel->bindValue(':related_post_id', (int) $relId, PDO::PARAM_INT);
                    $stmtRel->execute();
                }
            }

            $db->commit();

            Audit::log((int) $admin['id'], $siteId, 'create', 'blog_post', $postId, null, $data);
            Response::created(['id' => $postId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create post', $e->getMessage());
        }
    });

    // ===== MODIFIER =====
    $router->put('/api/admin/blog/posts/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT * FROM blog_posts WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1'
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Post not found'); return; }

        $db->beginTransaction();
        try {
            if (blogHasTable($db, 'blog_posts_versions')) {
                blogInsert($db, 'blog_posts_versions', [
                    'post_id' => $id,
                    'title' => $old['title'],
                    'content' => $old['content'],
                    'status' => $old['status'],
                    'created_by' => (int) $admin['id'],
                    'created_at' => date('Y-m-d H:i:s'),
                ]);
            }

            $fields = [];
            foreach (['category_id', 'author_id', 'title', 'slug', 'excerpt', 'content',
                'cover_image_url', 'read_time_mins', 'status', 'is_featured', 'published_at'] as $f) {
                if (array_key_exists($f, $data)) {
                    if (in_array($f, ['category_id', 'author_id', 'read_time_mins'], true)) {
                        $fields[$f] = blogNormalizeOptionalInt($data[$f]);
                    } elseif ($f === 'is_featured') {
                        $fields[$f] = (int) $data[$f];
                    } else {
                        $fields[$f] = $data[$f];
                    }
                }
            }

            if (blogHasColumn($db, 'blog_posts', 'meta_title') && array_key_exists('meta_title', $data)) {
                $fields['meta_title'] = $data['meta_title'];
            }
            if (blogHasColumn($db, 'blog_posts', 'meta_description') && array_key_exists('meta_description', $data)) {
                $fields['meta_description'] = $data['meta_description'];
            }

            if (isset($data['status']) && $data['status'] === 'published' && $old['status'] !== 'published') {
                if (!isset($data['published_at'])) {
                    $fields['published_at'] = date('Y-m-d H:i:s');
                }
            }

            if (!empty($fields)) {
                blogUpdate($db, 'blog_posts', $fields, 'WHERE id = :id', [':id' => $id]);
            }

            // MAJ tags pivot
            if (isset($data['tag_ids']) && is_array($data['tag_ids'])) {
                $stmt = $db->prepare('DELETE FROM blog_post_tags WHERE post_id = :post_id');
                $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
                $stmt->execute();

                $stmtTag = $db->prepare('INSERT INTO blog_post_tags (post_id, tag_id) VALUES (:post_id, :tag_id)');
                foreach ($data['tag_ids'] as $tagId) {
                    $stmtTag->bindValue(':post_id', $id, PDO::PARAM_INT);
                    $stmtTag->bindValue(':tag_id', (int) $tagId, PDO::PARAM_INT);
                    $stmtTag->execute();
                }
            }

            // MAJ related posts pivot
            if (blogHasTable($db, 'blog_related_posts') && isset($data['related_post_ids']) && is_array($data['related_post_ids'])) {
                $stmt = $db->prepare('DELETE FROM blog_related_posts WHERE post_id = :post_id');
                $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
                $stmt->execute();

                $stmtRel = $db->prepare('INSERT INTO blog_related_posts (post_id, related_post_id) VALUES (:post_id, :related_post_id)');
                foreach ($data['related_post_ids'] as $relId) {
                    $stmtRel->bindValue(':post_id', $id, PDO::PARAM_INT);
                    $stmtRel->bindValue(':related_post_id', (int) $relId, PDO::PARAM_INT);
                    $stmtRel->execute();
                }
            }

            $db->commit();

            Audit::log((int) $admin['id'], $siteId, 'update', 'blog_post', $id, $old, $data);
            Response::success(['id' => $id], 'Post updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update post', $e->getMessage());
        }
    });

    // ===== SOFT DELETE =====
    $router->delete('/api/admin/blog/posts/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT id, title, status FROM blog_posts WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1'
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Post not found'); return; }

        $stmt = $db->prepare('UPDATE blog_posts SET deleted_at = NOW() WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'soft_delete', 'blog_post', $id, $old, null);
        Response::success(null, 'Post deleted');
    });
}
