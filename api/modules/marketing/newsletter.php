<?php
/**
 * modules/marketing/newsletter.php — CRUD marketing_newsletter_subscribers
 */

function registerMarketingNewsletterRoutes(Router $router): void
{
    $router->get('/api/admin/marketing/newsletter', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM marketing_newsletter_subscribers $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT * FROM marketing_newsletter_subscribers 
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

    $router->post('/api/public/{site_slug}/newsletter/subscribe', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('gdpr_consent', 'GDPR Consent')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare('SELECT id, status FROM marketing_newsletter_subscribers WHERE email = :email AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $existing = $stmt->fetch();

        if ($existing) {
            if ($existing['status'] === 'subscribed') {
                Response::success(null, 'Already subscribed');
                return;
            } else {
                $stmtU = $db->prepare("UPDATE marketing_newsletter_subscribers SET status = 'subscribed', unsubscribed_at = NULL WHERE id = :id");
                $stmtU->execute([':id' => $existing['id']]);
                Response::success(null, 'Resubscribed successfully');
                return;
            }
        }

        $stmt = $db->prepare(
            'INSERT INTO marketing_newsletter_subscribers (site_id, email, first_name, last_name, source, gdpr_consent, status, created_at)
             VALUES (:site_id, :email, :fn, :ln, :src, :gdpr, :status, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $fn = $data['first_name'] ?? null;
        $stmt->bindParam(':fn', $fn, PDO::PARAM_STR);
        $ln = $data['last_name'] ?? null;
        $stmt->bindParam(':ln', $ln, PDO::PARAM_STR);
        $src = $data['source'] ?? 'website';
        $stmt->bindParam(':src', $src, PDO::PARAM_STR);
        $gdpr = (int) $data['gdpr_consent'];
        $stmt->bindParam(':gdpr', $gdpr, PDO::PARAM_INT);
        $status = 'subscribed';
        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Subscribed successfully');
    });

    $router->post('/api/public/{site_slug}/newsletter/unsubscribe', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)->required('email', 'Email')->email('email', 'Email')->validate();

        $db = getDb();
        $stmt = $db->prepare('UPDATE marketing_newsletter_subscribers SET status = \'unsubscribed\', unsubscribed_at = NOW() WHERE email = :email AND site_id = :site_id');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        Response::success(null, 'Unsubscribed successfully');
    });

    $router->delete('/api/admin/marketing/newsletter/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM marketing_newsletter_subscribers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Subscriber not found'); return; }

        $stmt = $db->prepare('DELETE FROM marketing_newsletter_subscribers WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'marketing_newsletter_subscriber', $id, $old, null);
        Response::noContent();
    });
}
