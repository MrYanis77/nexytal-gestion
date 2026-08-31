<?php
/**
 * modules/marketing/newsletter.php — CRUD newsletter_subscribers (v2.1)
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

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM newsletter_subscribers $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT id, site_id, email, first_name, last_name, status, confirmed_at, unsubscribed_at, created_at
             FROM newsletter_subscribers
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
        $stmt = $db->prepare('SELECT id, status FROM newsletter_subscribers WHERE email = :email AND site_id = :site_id LIMIT 1');
        $stmt->execute([':email' => $data['email'], ':site_id' => $siteId]);
        $existing = $stmt->fetch();

        if ($existing) {
            if ($existing['status'] === 'active') {
                Response::success(null, 'Already subscribed');
                return;
            }
            $resubFields = ["status = 'active'", 'rgpd_consent_at = NOW()'];
            if (dbTableHasColumn($db, 'newsletter_subscribers', 'unsubscribed_at')) {
                $resubFields[] = 'unsubscribed_at = NULL';
            }
            $db->prepare('UPDATE newsletter_subscribers SET ' . implode(', ', $resubFields) . ' WHERE id = :id')
                ->execute([':id' => $existing['id']]);
            Response::success(null, 'Resubscribed successfully');
            return;
        }

        $cols = ['site_id', 'email', 'first_name', 'status', 'rgpd_consent_at', 'created_at'];
        $vals = [':site_id', ':email', ':fn', "'active'", 'NOW()', 'NOW()'];
        $bind = [
            ':site_id' => $siteId,
            ':email' => $data['email'],
            ':fn' => $data['first_name'] ?? null,
        ];
        if (dbTableHasColumn($db, 'newsletter_subscribers', 'last_name')) {
            $cols[] = 'last_name';
            $vals[] = ':ln';
            $bind[':ln'] = $data['last_name'] ?? null;
        }
        if (dbTableHasColumn($db, 'newsletter_subscribers', 'rgpd_consent_ip')) {
            $cols[] = 'rgpd_consent_ip';
            $vals[] = ':ip';
            $bind[':ip'] = $_SERVER['REMOTE_ADDR'] ?? null;
        }
        if (dbTableHasColumn($db, 'newsletter_subscribers', 'source')) {
            $cols[] = 'source';
            $vals[] = "'form'";
        }

        $stmt = $db->prepare('INSERT INTO newsletter_subscribers (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $vals) . ')');
        $stmt->execute($bind);

        Response::created(['id' => (int) $db->lastInsertId()], 'Subscribed successfully');
    });

    $router->post('/api/public/{site_slug}/newsletter/unsubscribe', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)->required('email', 'Email')->email('email', 'Email')->validate();

        $db = getDb();
        $stmt = $db->prepare(
            "UPDATE newsletter_subscribers SET status = 'unsubscribed' WHERE email = :email AND site_id = :site_id"
        );
        $stmt->execute([':email' => $data['email'], ':site_id' => $siteId]);

        Response::success(null, 'Unsubscribed successfully');
    });

    $router->delete('/api/admin/marketing/newsletter/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM newsletter_subscribers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Subscriber not found'); return; }

        $stmt = $db->prepare('DELETE FROM newsletter_subscribers WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $siteId, 'delete', 'newsletter_subscriber', $id, $old, null);
        Response::noContent();
    });
}
