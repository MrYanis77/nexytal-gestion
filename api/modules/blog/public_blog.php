<?php
/**
 * modules/blog/public_blog.php — Routes publiques blog
 * 
 * GET /api/public/{site_slug}/blog/posts          — Posts publiés paginés
 * GET /api/public/{site_slug}/blog/posts/{slug}   — Détail post + incr views
 * GET /api/public/{site_slug}/blog/categories      — Catégories actives
 */

function registerPublicBlogRoutes(Router $router): void
{
    // ===== POSTS PUBLIÉS =====
    $router->get('/api/public/{site_slug}/blog/posts', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['p.site_id = :site_id', "p.status = 'published'", 'p.deleted_at IS NULL'];
        $bindParams = [':site_id' => $siteId];

        if ($categorySlug = Router::getQueryParam('category')) {
            $where[] = 'c.slug = :cat_slug';
            $bindParams[':cat_slug'] = $categorySlug;
        }
        if ($tagSlug = Router::getQueryParam('tag')) {
            $where[] = 'EXISTS (SELECT 1 FROM blog_post_tags pt INNER JOIN blog_tags t ON pt.tag_id = t.id WHERE pt.post_id = p.id AND t.slug = :tag_slug)';
            $bindParams[':tag_slug'] = $tagSlug;
        }
        if ($search = Router::getQueryParam('search')) {
            $where[] = '(p.title LIKE :search OR p.excerpt LIKE :search2)';
            $bindParams[':search'] = "%$search%";
            $bindParams[':search2'] = "%$search%";
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        // Count
        $stmt = $db->prepare(
            "SELECT COUNT(*) as total FROM blog_posts p LEFT JOIN blog_categories c ON p.category_id = c.id $whereClause"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        // Fetch
        $stmt = $db->prepare(
            "SELECT p.id, p.title, p.slug, p.excerpt, p.cover_image_url, p.read_time_mins, 
                    p.is_featured, p.published_at, p.views_count, p.meta_title, p.meta_description,
                    c.name as category_name, c.slug as category_slug, c.color as category_color,
                    CONCAT(a.first_name, ' ', a.last_name) as author_name, a.avatar_url as author_avatar
             FROM blog_posts p
             LEFT JOIN blog_categories c ON p.category_id = c.id
             LEFT JOIN blog_authors a ON p.author_id = a.id
             $whereClause
             ORDER BY p.is_featured DESC, p.published_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $posts = $stmt->fetchAll();

        // Tags pour chaque post
        foreach ($posts as &$post) {
            $stmt2 = $db->prepare(
                'SELECT t.name, t.slug FROM blog_tags t 
                 INNER JOIN blog_post_tags pt ON t.id = pt.tag_id WHERE pt.post_id = :post_id'
            );
            $stmt2->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
            $stmt2->execute();
            $post['tags'] = $stmt2->fetchAll();
        }

        Response::paginated($posts, $total, $pagination['page'], $pagination['limit']);
    });

    // ===== DÉTAIL POST =====
    $router->get('/api/public/{site_slug}/blog/posts/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();

        $stmt = $db->prepare(
            "SELECT p.*, 
                    c.name as category_name, c.slug as category_slug, c.color as category_color,
                    CONCAT(a.first_name, ' ', a.last_name) as author_name, a.avatar_url as author_avatar, a.bio as author_bio
             FROM blog_posts p
             LEFT JOIN blog_categories c ON p.category_id = c.id
             LEFT JOIN blog_authors a ON p.author_id = a.id
             WHERE p.site_id = :site_id AND p.slug = :slug AND p.status = 'published' AND p.deleted_at IS NULL
             LIMIT 1"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $post = $stmt->fetch();

        if (!$post) { Response::notFound('Post not found'); return; }

        // Incrémenter views
        $stmt = $db->prepare('UPDATE blog_posts SET views_count = views_count + 1 WHERE id = :id');
        $stmt->bindParam(':id', $post['id'], PDO::PARAM_INT);
        $stmt->execute();

        // Tags
        $stmt = $db->prepare(
            'SELECT t.name, t.slug FROM blog_tags t 
             INNER JOIN blog_post_tags pt ON t.id = pt.tag_id WHERE pt.post_id = :post_id'
        );
        $stmt->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
        $stmt->execute();
        $post['tags'] = $stmt->fetchAll();

        // Related posts
        $stmt = $db->prepare(
            "SELECT rp.id, rp.title, rp.slug, rp.excerpt, rp.cover_image_url, rp.published_at
             FROM blog_posts rp 
             INNER JOIN blog_related_posts brp ON rp.id = brp.related_post_id 
             WHERE brp.post_id = :post_id AND rp.status = 'published' AND rp.deleted_at IS NULL"
        );
        $stmt->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
        $stmt->execute();
        $post['related_posts'] = $stmt->fetchAll();

        // Commentaires approuvés
        $stmt = $db->prepare(
            "SELECT id, parent_id, author_name, content, created_at 
             FROM blog_comments 
             WHERE post_id = :post_id AND status = 'approved' 
             ORDER BY created_at ASC"
        );
        $stmt->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
        $stmt->execute();
        $post['comments'] = $stmt->fetchAll();

        Response::success($post);
    });

    // ===== CATÉGORIES ACTIVES =====
    $router->get('/api/public/{site_slug}/blog/categories', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, name, slug, description, color 
             FROM blog_categories 
             WHERE site_id = :site_id AND is_active = 1 
             ORDER BY sort_order ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    // ===== SOUMETTRE UN COMMENTAIRE (public) =====
    $router->post('/api/public/{site_slug}/blog/posts/{slug}/comments', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('author_name', 'Name')
            ->required('author_email', 'Email')
            ->email('author_email', 'Email')
            ->required('content', 'Comment')
            ->maxLength('content', 2000, 'Comment')
            ->validate();

        $db = getDb();

        // Trouver le post
        $stmt = $db->prepare(
            "SELECT id FROM blog_posts 
             WHERE site_id = :site_id AND slug = :slug AND status = 'published' AND deleted_at IS NULL LIMIT 1"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $post = $stmt->fetch();

        if (!$post) { Response::notFound('Post not found'); return; }

        $stmt = $db->prepare(
            'INSERT INTO blog_comments (post_id, parent_id, author_name, author_email, content, status, created_at) 
             VALUES (:post_id, :parent_id, :author_name, :author_email, :content, :status, NOW())'
        );
        $stmt->bindParam(':post_id', $post['id'], PDO::PARAM_INT);
        $parentId = $data['parent_id'] ?? null;
        $stmt->bindParam(':parent_id', $parentId, PDO::PARAM_INT);
        $authorName = Validator::sanitizeString($data['author_name']);
        $stmt->bindParam(':author_name', $authorName, PDO::PARAM_STR);
        $stmt->bindParam(':author_email', $data['author_email'], PDO::PARAM_STR);
        $content = Validator::sanitizeString($data['content']);
        $stmt->bindParam(':content', $content, PDO::PARAM_STR);
        $status = 'pending';
        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Comment submitted for moderation');
    });
}
