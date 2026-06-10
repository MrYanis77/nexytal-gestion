<?php
/**
 * modules/coaching/diagnostics.php — CRUD coaching_diagnostic_requests
 */

function registerCoachingDiagnosticsRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/diagnostics', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'd.status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM coaching_diagnostic_requests d LEFT JOIN coaching_coaches c ON d.coach_id = c.id $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT d.*, c.first_name as coach_first_name, c.last_name as coach_last_name 
             FROM coaching_diagnostic_requests d 
             LEFT JOIN coaching_coaches c ON d.coach_id = c.id 
             $whereClause 
             ORDER BY d.created_at DESC 
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->put('/api/admin/coaching/diagnostics/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT d.* FROM coaching_diagnostic_requests d LEFT JOIN coaching_coaches c ON d.coach_id = c.id WHERE d.id = :id AND (d.coach_id IS NULL OR c.site_id = :site_id) LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Diagnostic request not found'); return; }

        $fields = []; $bind = [];
        foreach (['status', 'internal_notes'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE coaching_diagnostic_requests SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_diagnostic', $id, $old, $data);
        Response::success(['id' => $id], 'Diagnostic request updated');
    });

    $router->delete('/api/admin/coaching/diagnostics/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT d.* FROM coaching_diagnostic_requests d LEFT JOIN coaching_coaches c ON d.coach_id = c.id WHERE d.id = :id AND (d.coach_id IS NULL OR c.site_id = :site_id) LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Diagnostic request not found'); return; }

        $stmt = $db->prepare('DELETE FROM coaching_diagnostic_requests WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_diagnostic', $id, $old, null);
        Response::noContent();
    });
}
