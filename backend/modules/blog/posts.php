<?php
/**
 * modules/blog/posts.php — CRUD blog_posts (admin, filtré par site_id)
 * 
 * Gère versions, tags pivot, articles liés, soft delete.
 * Filtres : status, category_id, is_featured, search. Pagination.
 */

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
        $stmt = $db->prepare(
            'SELECT rp.id, rp.title, rp.slug, rp.cover_image_url 
             FROM blog_posts rp 
             INNER JOIN blog_related_posts brp ON rp.id = brp.related_post_id 
             WHERE brp.post_id = :post_id AND rp.deleted_at IS NULL'
        );
        $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $post['related_posts'] = $stmt->fetchAll();

        // Versions
        $stmt = $db->prepare(
            'SELECT id, title, status, created_by, created_at 
             FROM blog_posts_versions WHERE post_id = :post_id ORDER BY created_at DESC'
        );
        $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $post['versions'] = $stmt->fetchAll();

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
        $db = getDb();

        $db->beginTransaction();
        try {
            $stmt = $db->prepare(
                'INSERT INTO blog_posts 
                 (site_id, category_id, author_id, title, slug, excerpt, content, cover_image_url, 
                  read_time_mins, status, is_featured, published_at, meta_title, meta_description, views_count, created_at)
                 VALUES 
                 (:site_id, :category_id, :author_id, :title, :slug, :excerpt, :content, :cover_image_url,
                  :read_time_mins, :status, :is_featured, :published_at, :meta_title, :meta_description, 0, NOW())'
            );
            $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
            $catId = $data['category_id'] ?? null;
            $stmt->bindParam(':category_id', $catId, PDO::PARAM_INT);
            $authId = $data['author_id'] ?? null;
            $stmt->bindParam(':author_id', $authId, PDO::PARAM_INT);
            $stmt->bindParam(':title', $data['title'], PDO::PARAM_STR);
            $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
            $excerpt = $data['excerpt'] ?? null;
            $stmt->bindParam(':excerpt', $excerpt, PDO::PARAM_STR);
            $content = $data['content'] ?? '';
            $stmt->bindParam(':content', $content, PDO::PARAM_STR);
            $cover = $data['cover_image_url'] ?? null;
            $stmt->bindParam(':cover_image_url', $cover, PDO::PARAM_STR);
            $readTime = $data['read_time_mins'] ?? null;
            $stmt->bindParam(':read_time_mins', $readTime, PDO::PARAM_INT);
            $status = $data['status'] ?? 'draft';
            $stmt->bindParam(':status', $status, PDO::PARAM_STR);
            $isFeatured = (int) ($data['is_featured'] ?? 0);
            $stmt->bindParam(':is_featured', $isFeatured, PDO::PARAM_INT);
            $publishedAt = ($status === 'published') ? date('Y-m-d H:i:s') : ($data['published_at'] ?? null);
            $stmt->bindParam(':published_at', $publishedAt, PDO::PARAM_STR);
            $metaTitle = $data['meta_title'] ?? null;
            $stmt->bindParam(':meta_title', $metaTitle, PDO::PARAM_STR);
            $metaDesc = $data['meta_description'] ?? null;
            $stmt->bindParam(':meta_description', $metaDesc, PDO::PARAM_STR);
            $stmt->execute();

            $postId = (int) $db->lastInsertId();

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
            if (!empty($data['related_post_ids']) && is_array($data['related_post_ids'])) {
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
            // Créer une version (snapshot)
            $stmt = $db->prepare(
                'INSERT INTO blog_posts_versions (post_id, title, content, status, created_by, created_at) 
                 VALUES (:post_id, :title, :content, :status, :created_by, NOW())'
            );
            $stmt->bindParam(':post_id', $id, PDO::PARAM_INT);
            $stmt->bindParam(':title', $old['title'], PDO::PARAM_STR);
            $stmt->bindParam(':content', $old['content'], PDO::PARAM_STR);
            $stmt->bindParam(':status', $old['status'], PDO::PARAM_STR);
            $stmt->bindParam(':created_by', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();

            // Update fields
            $fields = [];
            $bind = [];
            $updatable = ['category_id', 'author_id', 'title', 'slug', 'excerpt', 'content', 
                          'cover_image_url', 'read_time_mins', 'status', 'is_featured',
                          'published_at', 'meta_title', 'meta_description'];
            
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
            }

            // Auto-set published_at quand status passe à published
            if (isset($data['status']) && $data['status'] === 'published' && $old['status'] !== 'published') {
                if (!isset($data['published_at'])) {
                    $fields[] = "published_at = NOW()";
                }
            }

            if (!empty($fields)) {
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE blog_posts SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
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
            if (isset($data['related_post_ids']) && is_array($data['related_post_ids'])) {
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
