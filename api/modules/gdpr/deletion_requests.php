<?php
/**
 * modules/gdpr/deletion_requests.php — CRUD gdpr_deletion_requests (v2.1)
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
             ORDER BY requested_at DESC
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

        Validator::make($data)
            ->required('status', 'Status')
            ->in('status', ['pending', 'processing', 'completed', 'rejected'], 'Status')
            ->validate();

        $stmt = $db->prepare('SELECT * FROM gdpr_deletion_requests WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Request not found'); return; }

        $processedAt = in_array($data['status'], ['completed', 'rejected'], true) ? date('Y-m-d H:i:s') : null;

        $stmt = $db->prepare(
            'UPDATE gdpr_deletion_requests
             SET status = :status, processed_at = COALESCE(:processed_at, processed_at), processed_by = :processed_by
             WHERE id = :id'
        );
        $stmt->execute([
            ':status' => $data['status'],
            ':processed_at' => $processedAt,
            ':processed_by' => (int) $admin['id'],
            ':id' => $id,
        ]);

        $emailSent = null;
        if (in_array($data['status'], ['completed', 'rejected'], true) && $data['status'] !== $old['status']) {
            require_once __DIR__ . '/../../core/ActionNotify.php';
            $emailSent = ActionNotify::gdprRequestProcessed($db, $old, (string) $data['status']);
        }
        $auditData = $data;
        if ($emailSent !== null) {
            $auditData['email_sent'] = $emailSent;
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'gdpr_deletion_request', $id, $old, $auditData);
        Response::success(['id' => $id, 'email_sent' => $emailSent], 'Deletion request updated');
    });

    $router->post('/api/public/{site_slug}/gdpr/deletion-request', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO gdpr_deletion_requests (site_id, user_email, status, requested_at)
             VALUES (:site_id, :email, :status, NOW())'
        );
        $stmt->execute([
            ':site_id' => $siteId,
            ':email' => $data['email'],
            ':status' => 'pending',
        ]);

        Response::created(['id' => (int) $db->lastInsertId()], 'Deletion request submitted successfully');
    });
}
