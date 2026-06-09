<?php
/**
 * modules/coaching/bookings.php — CRUD coaching_bookings
 */

function registerCoachingBookingsRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/bookings', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($coachId = Router::getQueryParam('coach_id')) {
            $where[] = 'b.coach_id = :coach_id';
            $params[':coach_id'] = (int) $coachId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM coaching_bookings b JOIN coaching_coaches c ON b.coach_id = c.id $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT b.*, c.first_name as coach_first_name, c.last_name as coach_last_name 
             FROM coaching_bookings b 
             JOIN coaching_coaches c ON b.coach_id = c.id 
             $whereClause 
             ORDER BY b.created_at DESC 
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->put('/api/admin/coaching/bookings/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT b.* FROM coaching_bookings b JOIN coaching_coaches c ON b.coach_id = c.id WHERE b.id = :id AND c.site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Booking not found'); return; }

        $fields = []; $bind = [];
        foreach (['status', 'internal_notes'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE coaching_bookings SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_booking', $id, $old, $data);
        Response::success(['id' => $id], 'Booking updated');
    });

    $router->delete('/api/admin/coaching/bookings/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT b.* FROM coaching_bookings b JOIN coaching_coaches c ON b.coach_id = c.id WHERE b.id = :id AND c.site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Booking not found'); return; }

        $stmt = $db->prepare('DELETE FROM coaching_bookings WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_booking', $id, $old, null);
        Response::noContent();
    });
}
