<?php
/**
 * modules/coaching/public_coaching.php — API publique site coaching.nexytal.com
 */

function coachingLogGdprConsent(PDO $db, int $siteId, string $email, string $consentType): void
{
    $cols = ['site_id', 'user_email', 'consent_type', 'granted', 'ip_address'];
    $vals = [':site_id', ':email', ':type', '1', ':ip'];
    $bind = [
        ':site_id' => $siteId,
        ':email' => $email,
        ':type' => $consentType,
        ':ip' => $_SERVER['REMOTE_ADDR'] ?? null,
    ];
    if (dbTableHasColumn($db, 'gdpr_consents_log', 'user_agent')) {
        $cols[] = 'user_agent';
        $vals[] = ':ua';
        $bind[':ua'] = isset($_SERVER['HTTP_USER_AGENT']) ? substr((string) $_SERVER['HTTP_USER_AGENT'], 0, 255) : null;
    }
    if (dbTableHasColumn($db, 'gdpr_consents_log', 'created_at')) {
        $cols[] = 'created_at';
        $vals[] = 'NOW()';
    }
    $stmt = $db->prepare('INSERT INTO gdpr_consents_log (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $vals) . ')');
    $stmt->execute($bind);
}

function coachingResolveSpecialtyIds(PDO $db, array $items): array
{
    $ids = [];
    foreach ($items as $item) {
        if (is_numeric($item)) {
            $ids[] = (int) $item;
            continue;
        }
        $label = trim((string) $item);
        if ($label === '') {
            continue;
        }
        $slug = Validator::slugify($label);
        $stmt = $db->prepare('SELECT id FROM coaching_specialties WHERE slug = :slug LIMIT 1');
        $stmt->execute([':slug' => $slug]);
        $row = $stmt->fetch();
        if ($row) {
            $ids[] = (int) $row['id'];
            continue;
        }
        $db->prepare('INSERT INTO coaching_specialties (slug, name, sort_order, is_active, created_at) VALUES (:slug, :name, 0, 1, NOW())')
            ->execute([':slug' => $slug, ':name' => $label]);
        $ids[] = (int) $db->lastInsertId();
    }
    return array_values(array_unique($ids));
}

function coachingPublicApplyHandler(int $siteId): void
{
    $data = Router::getJsonBody();
    Validator::make($data)
        ->required('first_name', 'Prénom')
        ->required('last_name', 'Nom')
        ->required('title', 'Titre')
        ->required('email', 'Email')
        ->email('email', 'Email')
        ->required('gdpr_consent', 'Consentement RGPD')
        ->validate();

    if (empty($data['gdpr_consent'])) {
        Response::badRequest('Consentement RGPD requis');
        return;
    }

    $db = getDb();
    $slugBase = Validator::slugify(($data['first_name'] ?? '') . ' ' . ($data['last_name'] ?? ''));
    $slug = $slugBase;
    $suffix = 0;
    while (true) {
        $stmt = $db->prepare('SELECT id FROM coaches WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
        if (!$stmt->fetch()) {
            break;
        }
        $suffix++;
        $slug = $slugBase . '-' . $suffix;
    }

    $db->beginTransaction();
    try {
        $initials = mb_substr((string) ($data['first_name'] ?? ''), 0, 1) . mb_substr((string) ($data['last_name'] ?? ''), 0, 1);

        $stmt = $db->prepare(
            'INSERT INTO coaches (site_id, slug, first_name, last_name, title, bio_short, bio_full, avatar_url, avatar_initials,
             city_id, email, phone, linkedin_url, experience_years, status, is_featured, sort_order, created_at)
             VALUES (:site_id, :slug, :fn, :ln, :title, :bs, :bf, :au, :ai, :ci, :em, :ph, :lu, :ey, :st, 0, 0, NOW())'
        );
        $stmt->execute([
            ':site_id' => $siteId,
            ':slug' => $slug,
            ':fn' => $data['first_name'],
            ':ln' => $data['last_name'],
            ':title' => $data['title'],
            ':bs' => $data['bio_short'] ?? $data['bio'] ?? null,
            ':bf' => $data['bio_full'] ?? $data['full_bio'] ?? null,
            ':au' => $data['avatar_url'] ?? $data['photo'] ?? null,
            ':ai' => $data['avatar_initials'] ?? $initials,
            ':ci' => $data['city_id'] ?? null,
            ':em' => $data['email'],
            ':ph' => $data['phone'] ?? $data['telephone'] ?? null,
            ':lu' => $data['linkedin_url'] ?? null,
            ':ey' => (int) ($data['experience_years'] ?? 0),
            ':st' => 'pending_review',
        ]);
        $newId = (int) $db->lastInsertId();

        $specialties = $data['specialties'] ?? $data['specialty_ids'] ?? [];
        if (is_array($specialties) && $specialties !== []) {
            $specIds = coachingResolveSpecialtyIds($db, $specialties);
            $stmtLink = $db->prepare('INSERT INTO coach_specialty_links (coach_id, specialty_id) VALUES (:cid, :sid)');
            foreach ($specIds as $sid) {
                $stmtLink->execute([':cid' => $newId, ':sid' => $sid]);
            }
        }

        foreach (['certifications' => 'coach_certification_links', 'languages' => 'coach_language_links'] as $key => $table) {
            $col = $key === 'certifications' ? 'certification_id' : 'language_id';
            $items = $data[$key] ?? $data[rtrim($key, 's') . '_ids'] ?? [];
            if (!is_array($items)) {
                continue;
            }
            $stmtLink = $db->prepare("INSERT INTO {$table} (coach_id, {$col}) VALUES (:cid, :sid)");
            foreach ($items as $item) {
                if (is_numeric($item)) {
                    $stmtLink->execute([':cid' => $newId, ':sid' => (int) $item]);
                }
            }
        }

        coachingLogGdprConsent($db, $siteId, (string) $data['email'], 'coach_application');
        $db->commit();

        Response::created([
            'id' => $newId,
            'slug' => $slug,
            'status' => 'pending_review',
        ], 'Profil soumis — en attente de validation Nexytal');
    } catch (\Exception $e) {
        $db->rollBack();
        Response::serverError('Échec de la soumission', $e->getMessage());
    }
}

function coachingPublicDiagnosticsHandler(int $siteId): void
{
    $data = Router::getJsonBody();
    Validator::make($data)
        ->required('first_name', 'Prénom')
        ->required('email', 'Email')
        ->email('email', 'Email')
        ->required('gdpr_consent', 'Consentement RGPD')
        ->validate();

    if (empty($data['gdpr_consent'])) {
        Response::badRequest('Consentement RGPD requis');
        return;
    }

    $db = getDb();
    $cols = ['site_id', 'appointment_slot_id', 'prenom', 'nom', 'email', 'telephone', 'profil', 'statut', 'rgpd_consent_at', 'created_at'];
    $vals = [':site_id', ':slot_id', ':prenom', ':nom', ':email', ':tel', ':profil', ':statut', 'NOW()', 'NOW()'];
    $bind = [
        ':site_id' => $siteId,
        ':slot_id' => $data['appointment_slot_id'] ?? $data['slot_id'] ?? null,
        ':prenom' => $data['first_name'] ?? $data['prenom'],
        ':nom' => $data['last_name'] ?? $data['nom'] ?? null,
        ':email' => $data['email'],
        ':tel' => $data['phone'] ?? $data['telephone'] ?? null,
        ':profil' => $data['request_type'] ?? $data['profil'] ?? 'general',
        ':statut' => 'nouveau',
    ];
    if (dbTableHasColumn($db, 'coaching_diagnostic_requests', 'slot_label')) {
        $cols[] = 'slot_label';
        $vals[] = ':slot_label';
        $bind[':slot_label'] = $data['slot_label'] ?? null;
    }
    if (dbTableHasColumn($db, 'coaching_diagnostic_requests', 'rgpd_consent_ip')) {
        $cols[] = 'rgpd_consent_ip';
        $vals[] = ':ip';
        $bind[':ip'] = $_SERVER['REMOTE_ADDR'] ?? null;
    }

    $stmt = $db->prepare('INSERT INTO coaching_diagnostic_requests (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $vals) . ')');
    $stmt->execute($bind);
    $newId = (int) $db->lastInsertId();
    coachingLogGdprConsent($db, $siteId, (string) $data['email'], 'coaching_diagnostic');

    Response::created(['id' => $newId], 'Demande de diagnostic enregistrée');
}

function coachingPublicBookingsHandler(int $siteId): void
{
    $data = Router::getJsonBody();
    Validator::make($data)
        ->required('coach_id', 'Coach')
        ->required('client_first_name', 'Prenom')
        ->required('client_email', 'Email')
        ->email('client_email', 'Email')
        ->required('gdpr_consent', 'Consentement RGPD')
        ->validate();

    if (empty($data['gdpr_consent'])) {
        Response::badRequest('Consentement RGPD requis');
        return;
    }

    $db = getDb();
    $db->beginTransaction();
    try {
        $coachId = (int) $data['coach_id'];
        $stmtCoach = $db->prepare('SELECT id FROM coaches WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmtCoach->execute([':id' => $coachId, ':site_id' => $siteId]);
        if (!$stmtCoach->fetch()) {
            $db->rollBack();
            Response::notFound('Coach not found');
            return;
        }

        $email = (string) $data['client_email'];
        $stmtClient = $db->prepare('SELECT id FROM coaching_client_profiles WHERE site_id = :site_id AND email = :email LIMIT 1');
        $stmtClient->execute([':site_id' => $siteId, ':email' => $email]);
        $clientId = (int) ($stmtClient->fetchColumn() ?: 0);

        if ($clientId <= 0) {
            $firstName = (string) $data['client_first_name'];
            $lastName = (string) ($data['client_last_name'] ?? '');
            $initials = strtoupper(substr($firstName, 0, 1) . substr($lastName, 0, 1));
            $stmtClientInsert = $db->prepare(
                'INSERT INTO coaching_client_profiles (site_id, first_name, last_name, email, phone, avatar_initials, status, created_at)
                 VALUES (:site_id, :first_name, :last_name, :email, :phone, :initials, :status, NOW())'
            );
            $stmtClientInsert->execute([
                ':site_id' => $siteId,
                ':first_name' => $firstName,
                ':last_name' => $lastName !== '' ? $lastName : 'Client',
                ':email' => $email,
                ':phone' => $data['client_phone'] ?? $data['phone'] ?? null,
                ':initials' => $initials !== '' ? substr($initials, 0, 3) : null,
                ':status' => 'active',
            ]);
            $clientId = (int) $db->lastInsertId();
        }

        $slotId = (int) ($data['slot_id'] ?? 0);
        if ($slotId <= 0) {
            $requested = (string) ($data['requested_date'] ?? date('Y-m-d H:i:s'));
            $date = substr($requested, 0, 10);
            $start = strlen($requested) >= 16 ? substr($requested, 11, 8) : '09:00:00';
            if (strlen($start) === 5) {
                $start .= ':00';
            }
            $endTime = DateTime::createFromFormat('H:i:s', $start) ?: new DateTime('09:00:00');
            $endTime->modify('+1 hour');

            $stmtSlot = $db->prepare(
                'INSERT INTO coaching_appointment_slots (site_id, slot_date, start_time, end_time, coach_id, capacity, booked_count, is_active)
                 VALUES (:site_id, :slot_date, :start_time, :end_time, :coach_id, 1, 1, 1)'
            );
            $stmtSlot->execute([
                ':site_id' => $siteId,
                ':slot_date' => $date,
                ':start_time' => $start,
                ':end_time' => $endTime->format('H:i:s'),
                ':coach_id' => $coachId,
            ]);
            $slotId = (int) $db->lastInsertId();
        }

        $db->prepare(
            'INSERT IGNORE INTO coaching_coach_client_links (site_id, coach_id, client_id, status, created_at)
             VALUES (:site_id, :coach_id, :client_id, :status, NOW())'
        )->execute([
            ':site_id' => $siteId,
            ':coach_id' => $coachId,
            ':client_id' => $clientId,
            ':status' => 'active',
        ]);

        $stmtBooking = $db->prepare(
            'INSERT INTO coaching_session_bookings (site_id, slot_id, client_id, coach_id, status, notes, created_at)
             VALUES (:site_id, :slot_id, :client_id, :coach_id, :status, :notes, NOW())'
        );
        $stmtBooking->execute([
            ':site_id' => $siteId,
            ':slot_id' => $slotId,
            ':client_id' => $clientId,
            ':coach_id' => $coachId,
            ':status' => $data['status'] ?? 'pending',
            ':notes' => $data['message'] ?? $data['notes'] ?? null,
        ]);
        $newId = (int) $db->lastInsertId();

        coachingLogGdprConsent($db, $siteId, $email, 'coaching_booking');
        $db->commit();

        Response::created(['id' => $newId], 'Reservation enregistree');
    } catch (\Exception $e) {
        $db->rollBack();
        Response::serverError('Echec de la reservation', $e->getMessage());
    }
}

function registerPublicCoachingRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/coaching/coaches', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM v_coaches_catalog WHERE site_id = :site_id ORDER BY is_featured DESC, sort_order ASC, name ASC');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/public/{site_slug}/coaching/coaches/{slug}', function (array $params) {
        if ($params['slug'] === 'apply') {
            return;
        }
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM v_coaches_catalog WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        $coach = $stmt->fetch();
        if (!$coach) {
            Response::notFound('Coach not found');
            return;
        }
        Response::success($coach);
    });

    $router->post('/api/public/{site_slug}/coaching/coaches/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        coachingPublicApplyHandler($siteId);
    });

    $router->post('/api/public/{site_slug}/coaching/diagnostics', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        coachingPublicDiagnosticsHandler($siteId);
    });

    $router->post('/api/public/{site_slug}/coaching/bookings', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        coachingPublicBookingsHandler($siteId);
    });
}
