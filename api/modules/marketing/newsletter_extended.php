<?php
/**
 * modules/marketing/newsletter_extended.php — lists, campaigns, subscriptions, admin subscriber create, events read
 */

function registerMarketingNewsletterExtendedRoutes(Router $router): void
{
    // --- Lists ---
    $router->get('/api/admin/marketing/lists', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM newsletter_lists WHERE site_id = :site_id ORDER BY name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/marketing/lists', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO newsletter_lists (site_id, name, slug, description, is_active, created_at, updated_at)
             VALUES (:sid, :name, :slug, :desc, :act, NOW(), NOW())'
        );
        $stmt->execute([
            ':sid' => $siteId, ':name' => $data['name'], ':slug' => $slug,
            ':desc' => $data['description'] ?? null, ':act' => $data['is_active'] ?? 1,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'newsletter_list', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/marketing/lists/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $fields = [];
        $bind = [];
        foreach (['name', 'slug', 'description', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        $fields[] = 'updated_at = NOW()';
        $sql = 'UPDATE newsletter_lists SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $bind[':id'] = $id;
        $bind[':site_id'] = $siteId;
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->execute();
        Audit::log((int) $admin['id'], $siteId, 'update', 'newsletter_list', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/marketing/lists/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM newsletter_lists WHERE id = :id AND site_id = :site_id')->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'newsletter_list', $id, null, null);
        Response::noContent();
    });

    // --- Admin create subscriber ---
    $router->post('/api/admin/marketing/newsletter', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('email', 'Email')->email('email', 'Email')->validate();
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM newsletter_subscribers WHERE site_id = :site_id AND email = :email LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':email' => $data['email']]);
        if ($stmt->fetch()) { Response::badRequest('Subscriber already exists'); return; }

        $stmt = $db->prepare(
            "INSERT INTO newsletter_subscribers (site_id, email, first_name, last_name, status, rgpd_consent_at, source, created_at)
             VALUES (:site_id, :email, :fn, :ln, :status, NOW(), 'import', NOW())"
        );
        $stmt->execute([
            ':site_id' => $siteId, ':email' => $data['email'],
            ':fn' => $data['first_name'] ?? null, ':ln' => $data['last_name'] ?? null,
            ':status' => $data['status'] ?? 'active',
        ]);
        $subId = (int) $db->lastInsertId();

        if (!empty($data['list_ids']) && is_array($data['list_ids'])) {
            $stmtL = $db->prepare('INSERT INTO newsletter_subscriptions (subscriber_id, list_id, subscribed_at) VALUES (:sid, :lid, NOW())');
            foreach ($data['list_ids'] as $lid) {
                $stmtL->execute([':sid' => $subId, ':lid' => (int) $lid]);
            }
        }

        Audit::log((int) $admin['id'], $siteId, 'create', 'newsletter_subscriber', $subId, null, $data);
        Response::created(['id' => $subId]);
    });

    // --- Subscriptions ---
    $router->get('/api/admin/marketing/subscriptions', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT ns.*, s.email, l.name as list_name
             FROM newsletter_subscriptions ns
             INNER JOIN newsletter_subscribers s ON ns.subscriber_id = s.id
             INNER JOIN newsletter_lists l ON ns.list_id = l.id
             WHERE s.site_id = :site_id ORDER BY ns.subscribed_at DESC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/marketing/subscriptions', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('subscriber_id', 'Subscriber')->required('list_id', 'List')->validate();
        $db = getDb();
        try {
            $stmt = $db->prepare('INSERT INTO newsletter_subscriptions (subscriber_id, list_id, subscribed_at) VALUES (:sid, :lid, NOW())');
            $stmt->execute([':sid' => $data['subscriber_id'], ':lid' => $data['list_id']]);
            Audit::log((int) $admin['id'], $siteId, 'create', 'newsletter_subscription', 0, null, $data);
            Response::created(null, 'Subscribed');
        } catch (\PDOException $e) {
            Response::badRequest('Subscription already exists');
        }
    });

    $router->delete('/api/admin/marketing/subscriptions', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $subId = Router::getQueryParam('subscriber_id');
        $listId = Router::getQueryParam('list_id');
        if (!$subId || !$listId) { Response::badRequest('subscriber_id and list_id required'); return; }
        getDb()->prepare('DELETE FROM newsletter_subscriptions WHERE subscriber_id = :sid AND list_id = :lid')
            ->execute([':sid' => (int) $subId, ':lid' => (int) $listId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'newsletter_subscription', 0, null, null);
        Response::noContent();
    });

    // --- Campaigns ---
    $router->get('/api/admin/marketing/campaigns', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM newsletter_campaigns WHERE site_id = :site_id ORDER BY created_at DESC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/marketing/campaigns', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('subject', 'Subject')->required('content_html', 'Content')->validate();
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO newsletter_campaigns (site_id, list_id, created_by, subject, preview_text, content_html, content_text, status, scheduled_at, created_at, updated_at)
             VALUES (:sid, :lid, :cb, :sub, :prev, :html, :txt, :st, :sched, NOW(), NOW())'
        );
        $stmt->execute([
            ':sid' => $siteId, ':lid' => $data['list_id'] ?? null, ':cb' => $admin['id'],
            ':sub' => $data['subject'], ':prev' => $data['preview_text'] ?? null,
            ':html' => $data['content_html'], ':txt' => $data['content_text'] ?? null,
            ':st' => $data['status'] ?? 'draft', ':sched' => $data['scheduled_at'] ?? null,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'newsletter_campaign', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/marketing/campaigns/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $fields = [];
        $bind = [];
        foreach (['list_id', 'subject', 'preview_text', 'content_html', 'content_text', 'status', 'scheduled_at'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        $fields[] = 'updated_at = NOW()';
        $sql = 'UPDATE newsletter_campaigns SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $bind[':id'] = $id;
        $bind[':site_id'] = $siteId;
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->execute();
        Audit::log((int) $admin['id'], $siteId, 'update', 'newsletter_campaign', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/marketing/campaigns/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM newsletter_campaigns WHERE id = :id AND site_id = :site_id')->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'newsletter_campaign', $id, null, null);
        Response::noContent();
    });

    // --- Events (read-only) ---
    $router->get('/api/admin/marketing/events', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT e.*, c.subject as campaign_subject, s.email as subscriber_email
             FROM newsletter_events e
             INNER JOIN newsletter_campaigns c ON e.campaign_id = c.id
             INNER JOIN newsletter_subscribers s ON e.subscriber_id = s.id
             WHERE c.site_id = :site_id ORDER BY e.created_at DESC LIMIT 500'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    // --- Admin create email log (for testing/seeding) ---
    $router->post('/api/admin/marketing/emails', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('recipient_email', 'Recipient')->required('subject', 'Subject')->validate();
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO marketing_email_logs (site_id, recipient_email, subject, template_used, status, created_at)
             VALUES (:sid, :email, :sub, :tpl, :st, NOW())'
        );
        $stmt->execute([
            ':sid' => $siteId, ':email' => $data['recipient_email'], ':sub' => $data['subject'],
            ':tpl' => $data['template_used'] ?? null, ':st' => $data['status'] ?? 'sent',
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'marketing_email_log', $newId, null, $data);
        Response::created(['id' => $newId]);
    });
}
