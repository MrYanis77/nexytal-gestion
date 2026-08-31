<?php
/**
 * modules/coaching/requests.php
 */

function registerCoachingRequestsRoutes(Router $router): void {
    
    // ===== CONTACT REQUESTS =====
    $router->get('/api/admin/coaching/contact-requests', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM coaching_contact_requests WHERE site_id = :site_id ORDER BY created_at DESC');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->put('/api/admin/coaching/contact-requests/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $data = Router::getJsonBody();
        $db = getDb();

        if (isset($data['statut'])) {
            $stmt = $db->prepare('UPDATE coaching_contact_requests SET statut = :statut, updated_at = NOW() WHERE id = :id AND site_id = :site_id');
            $stmt->execute([':statut' => $data['statut'], ':id' => $id, ':site_id' => $siteId]);
            Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_contact_requests', $id, null, ['statut' => $data['statut']]);
        }
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/coaching/contact-requests/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM coaching_contact_requests WHERE id = :id AND site_id = :site_id')->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_contact_requests', $id, null, null);
        Response::noContent();
    });


    // ===== DIAGNOSTIC REQUESTS =====
    $router->get('/api/admin/coaching/diagnostic-requests', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('
            SELECT d.*, c.first_name as coach_first_name, c.last_name as coach_last_name 
            FROM coaching_diagnostic_requests d
            LEFT JOIN coaching_appointment_slots a ON d.appointment_slot_id = a.id
            LEFT JOIN coaches c ON a.coach_id = c.id
            WHERE d.site_id = :site_id 
            ORDER BY d.created_at DESC
        ');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->put('/api/admin/coaching/diagnostic-requests/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $data = Router::getJsonBody();
        $db = getDb();

        if (isset($data['statut'])) {
            $stmt = $db->prepare('UPDATE coaching_diagnostic_requests SET statut = :statut WHERE id = :id AND site_id = :site_id');
            $stmt->execute([':statut' => $data['statut'], ':id' => $id, ':site_id' => $siteId]);
            Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_diagnostic_requests', $id, null, ['statut' => $data['statut']]);
        }
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/coaching/diagnostic-requests/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM coaching_diagnostic_requests WHERE id = :id AND site_id = :site_id')->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_diagnostic_requests', $id, null, null);
        Response::noContent();
    });
}
