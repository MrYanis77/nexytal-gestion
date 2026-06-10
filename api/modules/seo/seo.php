<?php
/**
 * modules/seo/seo.php — CRUD seo_metadata
 */

function registerSeoRoutes(Router $router): void
{
    $router->get('/api/admin/seo', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        Middleware::requireRole(['superadmin', 'admin', 'seo']);
        $db = getDb();

        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($entity = Router::getQueryParam('entity_type')) {
            $where[] = 'entity_type = :entity_type';
            $params[':entity_type'] = $entity;
        }
        if ($entityId = Router::getQueryParam('entity_id')) {
            $where[] = 'entity_id = :entity_id';
            $params[':entity_id'] = (int) $entityId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT * FROM seo_metadata $whereClause ORDER BY updated_at DESC");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/seo', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'seo']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('entity_type', 'Entity Type')
            ->required('entity_id', 'Entity ID')
            ->validate();

        $db = getDb();
        
        // Upsert logic
        $stmt = $db->prepare('SELECT id FROM seo_metadata WHERE site_id = :site_id AND entity_type = :type AND entity_id = :eid LIMIT 1');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':type', $data['entity_type'], PDO::PARAM_STR);
        $stmt->bindParam(':eid', $data['entity_id'], PDO::PARAM_INT);
        $stmt->execute();
        $existing = $stmt->fetch();

        $schemaJson = $data['schema_json'] ?? $data['schema_markup'] ?? null;
        if (is_array($schemaJson)) {
            $schemaJson = json_encode($schemaJson, JSON_UNESCAPED_UNICODE);
        }

        if ($existing) {
            $stmtU = $db->prepare(
                'UPDATE seo_metadata
                 SET meta_title = :tit, meta_description = :desc, canonical_url = :can, og_title = :ogtit, og_description = :ogdesc, og_image = :ogimg, schema_json = :schema, updated_at = NOW()
                 WHERE id = :id'
            );
            $stmtU->bindValue(':tit', $data['meta_title'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':desc', $data['meta_description'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':can', $data['canonical_url'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':ogtit', $data['og_title'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':ogdesc', $data['og_description'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':ogimg', $data['og_image'] ?? null, PDO::PARAM_STR);
            $stmtU->bindValue(':schema', $schemaJson, $schemaJson === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmtU->bindParam(':id', $existing['id'], PDO::PARAM_INT);
            $stmtU->execute();

            Audit::log((int) $admin['id'], $siteId, 'update', 'seo_metadata', $existing['id'], null, $data);
            Response::success(['id' => $existing['id']], 'SEO Metadata updated');
        } else {
            $stmtI = $db->prepare(
                'INSERT INTO seo_metadata (site_id, entity_type, entity_id, meta_title, meta_description, canonical_url, og_title, og_description, og_image, schema_json, created_at)
                 VALUES (:site_id, :type, :eid, :tit, :desc, :can, :ogtit, :ogdesc, :ogimg, :schema, NOW())'
            );
            $stmtI->bindParam(':site_id', $siteId, PDO::PARAM_INT);
            $stmtI->bindParam(':type', $data['entity_type'], PDO::PARAM_STR);
            $stmtI->bindParam(':eid', $data['entity_id'], PDO::PARAM_INT);
            $stmtI->bindValue(':tit', $data['meta_title'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':desc', $data['meta_description'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':can', $data['canonical_url'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':ogtit', $data['og_title'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':ogdesc', $data['og_description'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':ogimg', $data['og_image'] ?? null, PDO::PARAM_STR);
            $stmtI->bindValue(':schema', $schemaJson, $schemaJson === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmtI->execute();

            $newId = (int) $db->lastInsertId();
            Audit::log((int) $admin['id'], $siteId, 'create', 'seo_metadata', $newId, null, $data);
            Response::created(['id' => $newId], 'SEO Metadata created');
        }
    });
}
