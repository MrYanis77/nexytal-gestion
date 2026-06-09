<?php
/**
 * modules/gdpr/consents.php — Liste gdpr_consents_log
 */

function registerGdprConsentsRoutes(Router $router): void
{
    $router->get('/api/admin/gdpr/consents', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($type = Router::getQueryParam('consent_type')) {
            $where[] = 'consent_type = :type';
            $params[':type'] = $type;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM gdpr_consents_log $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT * FROM gdpr_consents_log 
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
}
