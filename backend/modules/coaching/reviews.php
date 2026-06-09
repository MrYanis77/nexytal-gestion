<?php
/**
 * modules/coaching/reviews.php — CRUD coaching_reviews
 */

function registerCoachingReviewsRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/reviews', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($coachId = Router::getQueryParam('coach_id')) {
            $where[] = 'r.coach_id = :coach_id';
            $params[':coach_id'] = (int) $coachId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM coaching_reviews r JOIN coaching_coaches c ON r.coach_id = c.id $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT r.*, c.first_name as coach_first_name, c.last_name as coach_last_name 
             FROM coaching_reviews r 
             JOIN coaching_coaches c ON r.coach_id = c.id 
             $whereClause 
             ORDER BY r.created_at DESC 
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->put('/api/admin/coaching/reviews/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'moderator']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT r.* FROM coaching_reviews r JOIN coaching_coaches c ON r.coach_id = c.id WHERE r.id = :id AND c.site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Review not found'); return; }

        $fields = []; $bind = [];
        foreach (['is_published', 'is_verified'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = (int)$data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE coaching_reviews SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        // Update coach stats
        $stmtStat = $db->prepare("UPDATE coaching_coaches SET rating_avg = (SELECT AVG(rating) FROM coaching_reviews WHERE coach_id = :cid AND is_published = 1), reviews_count = (SELECT COUNT(*) FROM coaching_reviews WHERE coach_id = :cid AND is_published = 1) WHERE id = :cid");
        $stmtStat->execute([':cid' => $old['coach_id']]);

        Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_review', $id, $old, $data);
        Response::success(['id' => $id], 'Review updated');
    });

    $router->delete('/api/admin/coaching/reviews/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT r.* FROM coaching_reviews r JOIN coaching_coaches c ON r.coach_id = c.id WHERE r.id = :id AND c.site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Review not found'); return; }

        $stmt = $db->prepare('DELETE FROM coaching_reviews WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        // Update coach stats
        $stmtStat = $db->prepare("UPDATE coaching_coaches SET rating_avg = (SELECT AVG(rating) FROM coaching_reviews WHERE coach_id = :cid AND is_published = 1), reviews_count = (SELECT COUNT(*) FROM coaching_reviews WHERE coach_id = :cid AND is_published = 1) WHERE id = :cid");
        $stmtStat->execute([':cid' => $old['coach_id']]);

        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_review', $id, $old, null);
        Response::noContent();
    });
}
