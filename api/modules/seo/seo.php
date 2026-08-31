<?php
/**
 * modules/seo/seo.php — CRUD seo_metadata (bdd.sql : site_id + path)
 */

function registerSeoRoutes(Router $router): void
{
    $router->get('/api/admin/seo', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $db = getDb();

        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($path = Router::getQueryParam('path')) {
            $where[] = 'path = :path';
            $params[':path'] = $path;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);
        $stmt = $db->prepare("SELECT * FROM seo_metadata $whereClause ORDER BY updated_at DESC");
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();

        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/seo', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();

        $path = trim((string) ($data['path'] ?? $data['canonical_url'] ?? ''));
        if ($path === '') {
            Response::badRequest('path requis');
            return;
        }
        if ($path[0] !== '/') {
            $path = '/' . $path;
        }

        $stmt = $db->prepare('SELECT id FROM seo_metadata WHERE site_id = :site_id AND path = :path LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':path' => $path]);
        $existing = $stmt->fetch();

        if ($existing) {
            $stmtU = $db->prepare(
                'UPDATE seo_metadata SET meta_title = :tit, meta_description = :desc, og_image = :ogimg, updated_at = NOW()
                 WHERE id = :id'
            );
            $stmtU->execute([
                ':tit' => $data['meta_title'] ?? null,
                ':desc' => $data['meta_description'] ?? null,
                ':ogimg' => $data['og_image'] ?? null,
                ':id' => $existing['id'],
            ]);
            Audit::log((int) $admin['id'], $siteId, 'update', 'seo_metadata', $existing['id'], null, $data);
            Response::success(['id' => $existing['id']], 'SEO Metadata updated');
            return;
        }

        $stmtI = $db->prepare(
            'INSERT INTO seo_metadata (site_id, path, meta_title, meta_description, og_image)
             VALUES (:site_id, :path, :tit, :desc, :ogimg)'
        );
        $stmtI->execute([
            ':site_id' => $siteId,
            ':path' => $path,
            ':tit' => $data['meta_title'] ?? null,
            ':desc' => $data['meta_description'] ?? null,
            ':ogimg' => $data['og_image'] ?? null,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'seo_metadata', $newId, null, $data);
        Response::created(['id' => $newId], 'SEO Metadata created');
    });
}
