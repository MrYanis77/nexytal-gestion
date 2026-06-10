<?php
/**
 * modules/marketing/newsletter.php — CRUD marketing_newsletter_subs (v3)
 */

function registerMarketingNewsletterRoutes(Router $router): void
{
    $router->get('/api/admin/marketing/newsletter', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if (($active = Router::getQueryParam('is_active')) !== null && $active !== '') {
            $where[] = 'is_active = :is_active';
            $params[':is_active'] = (int) $active;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM marketing_newsletter_subs $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT id, site_id, email, first_name, is_active, unsub_token, created_at, unsub_at
             FROM marketing_newsletter_subs
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
        $stmt = $db->prepare('SELECT id, is_active FROM marketing_newsletter_subs WHERE email = :email AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $existing = $stmt->fetch();

        if ($existing) {
            if ((int) $existing['is_active'] === 1) {
                Response::success(null, 'Already subscribed');
                return;
            }
            $stmtU = $db->prepare('UPDATE marketing_newsletter_subs SET is_active = 1, unsub_at = NULL WHERE id = :id');
            $stmtU->execute([':id' => $existing['id']]);
            Response::success(null, 'Resubscribed successfully');
            return;
        }

        $token = bin2hex(random_bytes(32));
        $stmt = $db->prepare(
            'INSERT INTO marketing_newsletter_subs (site_id, email, first_name, is_active, unsub_token, created_at)
             VALUES (:site_id, :email, :fn, 1, :token, NOW())'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $fn = $data['first_name'] ?? null;
        $stmt->bindParam(':fn', $fn, PDO::PARAM_STR);
        $stmt->bindParam(':token', $token, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Subscribed successfully');
    });

    $router->post('/api/public/{site_slug}/newsletter/unsubscribe', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)->required('email', 'Email')->email('email', 'Email')->validate();

        $db = getDb();
        $stmt = $db->prepare('UPDATE marketing_newsletter_subs SET is_active = 0, unsub_at = NOW() WHERE email = :email AND site_id = :site_id');
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

        $stmt = $db->prepare('SELECT * FROM marketing_newsletter_subs WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Subscriber not found'); return; }

        $stmt = $db->prepare('DELETE FROM marketing_newsletter_subs WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'marketing_newsletter_sub', $id, $old, null);
        Response::noContent();
    });
}
