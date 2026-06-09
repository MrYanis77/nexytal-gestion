<?php
/**
 * modules/recrutement/applications.php — CRUD recrutement_applications
 */

function registerRecrutementApplicationsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/applications', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['o.site_id = :site_id', 'a.deleted_at IS NULL'];
        $params = [':site_id' => $siteId];

        if ($offerId = Router::getQueryParam('offer_id')) {
            $where[] = 'a.offer_id = :offer_id';
            $params[':offer_id'] = (int) $offerId;
        }

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'a.status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM recrutement_applications a JOIN recrutement_offers o ON a.offer_id = o.id $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT a.*, o.title as offer_title 
             FROM recrutement_applications a
             JOIN recrutement_offers o ON a.offer_id = o.id
             $whereClause
             ORDER BY a.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        
        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            "SELECT a.*, o.title as offer_title 
             FROM recrutement_applications a
             JOIN recrutement_offers o ON a.offer_id = o.id
             WHERE a.id = :id AND o.site_id = :site_id AND a.deleted_at IS NULL LIMIT 1"
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $app = $stmt->fetch();

        if (!$app) { Response::notFound('Application not found'); return; }

        $stmtHist = $db->prepare('SELECT h.*, u.first_name, u.last_name FROM recrutement_application_history h LEFT JOIN core_admin_users u ON h.changed_by_id = u.id WHERE h.application_id = :id ORDER BY h.created_at DESC');
        $stmtHist->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtHist->execute();
        $app['history'] = $stmtHist->fetchAll();

        Response::success($app);
    });

    $router->put('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT a.* FROM recrutement_applications a JOIN recrutement_offers o ON a.offer_id = o.id WHERE a.id = :id AND o.site_id = :site_id AND a.deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Application not found'); return; }

        $fields = []; $bind = [];
        $statusChanged = false;
        
        if (isset($data['status']) && $data['status'] !== $old['status']) {
            $fields[] = 'status = :status';
            $bind[':status'] = $data['status'];
            $statusChanged = true;
        }

        if (array_key_exists('internal_notes', $data)) {
            $fields[] = 'internal_notes = :internal_notes';
            $bind[':internal_notes'] = $data['internal_notes'];
        }

        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = "updated_at = NOW()";
        
        $db->beginTransaction();
        try {
            $sql = 'UPDATE recrutement_applications SET ' . implode(', ', $fields) . ' WHERE id = :id';
            $stmt = $db->prepare($sql);
            foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            if ($statusChanged) {
                $stmtHist = $db->prepare('INSERT INTO recrutement_application_history (application_id, old_status, new_status, changed_by_id, note, created_at) VALUES (:app_id, :old, :new, :admin_id, :note, NOW())');
                $stmtHist->bindValue(':app_id', $id, PDO::PARAM_INT);
                $stmtHist->bindValue(':old', $old['status'], PDO::PARAM_STR);
                $stmtHist->bindValue(':new', $data['status'], PDO::PARAM_STR);
                $stmtHist->bindValue(':admin_id', $admin['id'], PDO::PARAM_INT);
                $note = $data['history_note'] ?? null;
                $stmtHist->bindValue(':note', $note, PDO::PARAM_STR);
                $stmtHist->execute();
            }
            $db->commit();

            Audit::log((int) $admin['id'], $siteId, 'update', 'recrutement_application', $id, $old, $data);
            Response::success(['id' => $id], 'Application updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update application', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/applications/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT a.id FROM recrutement_applications a JOIN recrutement_offers o ON a.offer_id = o.id WHERE a.id = :id AND o.site_id = :site_id AND a.deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Application not found'); return; }

        $stmt = $db->prepare('UPDATE recrutement_applications SET deleted_at = NOW() WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], $siteId, 'soft_delete', 'recrutement_application', $id, $old, null);
        Response::success(null, 'Application deleted');
    });
}
