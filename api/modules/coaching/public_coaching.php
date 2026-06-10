<?php
/**
 * modules/coaching/public_coaching.php — Routes publiques pour site Coaching (site_id = 4)
 */

function registerPublicCoachingRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/coaching/coaches', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id', "c.status = 'active'"];
        $bindParams = [':site_id' => $siteId];

        if ($cityId = Router::getQueryParam('city_id')) {
            $where[] = 'c.city_id = :city_id';
            $bindParams[':city_id'] = (int) $cityId;
        }
        if ($specialtyId = Router::getQueryParam('specialty_id')) {
            $where[] = 'EXISTS (SELECT 1 FROM coaching_coach_specialties cs WHERE cs.coach_id = c.id AND cs.specialty_id = :specialty_id)';
            $bindParams[':specialty_id'] = (int) $specialtyId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM coaching_coaches c $whereClause");
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.id, c.first_name, c.last_name, c.slug, c.avatar_url, c.title, c.short_bio, c.rating_avg, c.reviews_count, city.name as city_name
             FROM coaching_coaches c
             LEFT JOIN coaching_cities city ON c.city_id = city.id
             $whereClause
             ORDER BY c.rating_avg DESC, c.reviews_count DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $coaches = $stmt->fetchAll();

        foreach ($coaches as &$c) {
            $stmtS = $db->prepare('SELECT s.name FROM coaching_specialties s INNER JOIN coaching_coach_specialties cs ON s.id = cs.specialty_id WHERE cs.coach_id = :id');
            $stmtS->execute([':id' => $c['id']]);
            $c['specialties'] = array_column($stmtS->fetchAll(), 'name');
        }

        Response::paginated($coaches, $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/public/{site_slug}/coaching/coaches/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            "SELECT c.*, city.name as city_name 
             FROM coaching_coaches c 
             LEFT JOIN coaching_cities city ON c.city_id = city.id 
             WHERE c.site_id = :site_id AND c.slug = :slug AND c.status = 'active' LIMIT 1"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $coach = $stmt->fetch();
        if (!$coach) { Response::notFound('Coach not found'); return; }

        $coach['languages'] = $coach['languages'] ? json_decode($coach['languages'], true) : [];
        
        $stmtS = $db->prepare('SELECT s.name FROM coaching_specialties s INNER JOIN coaching_coach_specialties cs ON s.id = cs.specialty_id WHERE cs.coach_id = :id');
        $stmtS->execute([':id' => $coach['id']]);
        $coach['specialties'] = array_column($stmtS->fetchAll(), 'name');

        $stmtC = $db->prepare('SELECT c.organization, c.level, cc.year_obtained FROM coaching_certifications c INNER JOIN coaching_coach_certifications cc ON c.id = cc.certification_id WHERE cc.coach_id = :id');
        $stmtC->execute([':id' => $coach['id']]);
        $coach['certifications'] = $stmtC->fetchAll();

        $stmtR = $db->prepare("SELECT author_name, content, rating, created_at FROM coaching_reviews WHERE coach_id = :id AND is_published = 1 ORDER BY created_at DESC LIMIT 10");
        $stmtR->execute([':id' => $coach['id']]);
        $coach['recent_reviews'] = $stmtR->fetchAll();

        Response::success($coach);
    });

    $router->get('/api/public/{site_slug}/coaching/filters', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $res = [];
        $res['cities'] = $db->query('SELECT id, name FROM coaching_cities ORDER BY name ASC')->fetchAll();
        $res['specialties'] = $db->query('SELECT id, name FROM coaching_specialties ORDER BY name ASC')->fetchAll();
        Response::success($res);
    });

    $router->post('/api/public/{site_slug}/coaching/diagnostics', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('first_name', 'First name')
            ->required('last_name', 'Last name')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('request_type', 'Request type')
            ->required('gdpr_consent', 'GDPR Consent')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO coaching_diagnostic_requests (coach_id, first_name, last_name, email, phone, company, coaching_type, message, status, created_at)
             VALUES (:cid, :fn, :ln, :email, :phone, :comp, :ctype, :msg, :status, NOW())'
        );
        $cid = isset($data['coach_id']) && $data['coach_id'] !== '' ? (int) $data['coach_id'] : null;
        $stmt->bindValue(':cid', $cid, $cid === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $fn = Validator::sanitizeString($data['first_name']);
        $stmt->bindValue(':fn', $fn, PDO::PARAM_STR);
        $ln = Validator::sanitizeString($data['last_name']);
        $stmt->bindValue(':ln', $ln, PDO::PARAM_STR);
        $stmt->bindValue(':email', $data['email'], PDO::PARAM_STR);
        $phone = $data['phone'] ?? null;
        $stmt->bindValue(':phone', $phone, PDO::PARAM_STR);
        $comp = $data['company'] ?? null;
        $stmt->bindValue(':comp', $comp, PDO::PARAM_STR);
        $ctype = $data['request_type'] ?? $data['coaching_type'] ?? 'general';
        $stmt->bindValue(':ctype', $ctype, PDO::PARAM_STR);
        $msg = isset($data['message']) ? Validator::sanitizeString($data['message']) : null;
        $stmt->bindValue(':msg', $msg, PDO::PARAM_STR);
        $status = 'new';
        $stmt->bindValue(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Diagnostic request submitted');
    });

    $router->post('/api/public/{site_slug}/coaching/bookings', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('coach_id', 'Coach ID')
            ->required('client_first_name', 'First name')
            ->required('client_last_name', 'Last name')
            ->required('client_email', 'Email')
            ->email('client_email', 'Email')
            ->required('requested_date', 'Date')
            ->required('gdpr_consent', 'GDPR Consent')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM coaching_coaches WHERE id = :id AND site_id = :site_id AND status = \'active\' LIMIT 1');
        $stmt->bindParam(':id', $data['coach_id'], PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) { Response::notFound('Coach not found or unavailable'); return; }

        $stmt = $db->prepare(
            'INSERT INTO coaching_bookings (coach_id, first_name, last_name, email, phone, booked_for, notes, status, created_at)
             VALUES (:cid, :fn, :ln, :email, :phone, :booked, :notes, :status, NOW())'
        );
        $stmt->bindValue(':cid', (int) $data['coach_id'], PDO::PARAM_INT);
        $fn = Validator::sanitizeString($data['client_first_name']);
        $stmt->bindValue(':fn', $fn, PDO::PARAM_STR);
        $ln = Validator::sanitizeString($data['client_last_name']);
        $stmt->bindValue(':ln', $ln, PDO::PARAM_STR);
        $stmt->bindValue(':email', $data['client_email'], PDO::PARAM_STR);
        $phone = $data['client_phone'] ?? null;
        $stmt->bindValue(':phone', $phone, PDO::PARAM_STR);
        $stmt->bindValue(':booked', $data['requested_date'], PDO::PARAM_STR);
        $msg = isset($data['message']) ? Validator::sanitizeString($data['message']) : null;
        $stmt->bindValue(':notes', $msg, PDO::PARAM_STR);
        $status = 'pending';
        $stmt->bindValue(':status', $status, PDO::PARAM_STR);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Booking request submitted');
    });
}
