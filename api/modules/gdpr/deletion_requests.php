<?php
/**
 * modules/gdpr/deletion_requests.php — CRUD gdpr_deletion_requests
 */

function registerGdprDeletionRequestsRoutes(Router $router): void
{
    $router->get('/api/admin/gdpr/deletion-requests', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM gdpr_deletion_requests $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT * FROM gdpr_deletion_requests 
             $whereClause 
             ORDER BY created_at DESC 
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->put('/api/admin/gdpr/deletion-requests/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        Validator::make($data)->required('status', 'Status')->in('status', ['pending', 'processed', 'rejected'], 'Status')->validate();

        $stmt = $db->prepare('SELECT * FROM gdpr_deletion_requests WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Request not found'); return; }

        $stmt = $db->prepare('UPDATE gdpr_deletion_requests SET status = :status, resolved_at = :resolved, updated_at = NOW() WHERE id = :id');
        $stmt->bindParam(':status', $data['status'], PDO::PARAM_STR);
        $resolved = in_array($data['status'], ['processed', 'rejected']) ? date('Y-m-d H:i:s') : null;
        $stmt->bindParam(':resolved', $resolved, PDO::PARAM_STR);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'gdpr_deletion_request', $id, $old, $data);
        Response::success(['id' => $id], 'Deletion request updated');
    });

    $router->post('/api/public/{site_slug}/gdpr/deletion-request', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('request_type', 'Request type')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO gdpr_deletion_requests (site_id, email, first_name, last_name, request_type, details, status, created_at)
             VALUES (:site_id, :email, :fn, :ln, :rtype, :details, :status, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $fn = $data['first_name'] ?? null;
        $stmt->bindParam(':fn', $fn, PDO::PARAM_STR);
        $ln = $data['last_name'] ?? null;
        $stmt->bindParam(':ln', $ln, PDO::PARAM_STR);
        $stmt->bindParam(':rtype', $data['request_type'], PDO::PARAM_STR);
        $details = $data['details'] ?? null;
        $stmt->bindParam(':details', $details, PDO::PARAM_STR);
        $status = 'pending';
        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Deletion request submitted successfully');
    });
}
