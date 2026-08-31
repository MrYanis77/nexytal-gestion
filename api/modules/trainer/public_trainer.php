<?php
/**
 * modules/trainer/public_trainer.php — API publique site trainer.nexytal.com
 */

require_once __DIR__ . '/expertise_helpers.php';

function trainerLogGdprConsent(PDO $db, int $siteId, string $email, string $consentType): void
{
    $db->prepare(
        'INSERT INTO gdpr_consents_log (site_id, user_email, consent_type, granted, ip_address, user_agent)
         VALUES (:site_id, :email, :type, 1, :ip, :ua)'
    )->execute([
        ':site_id' => $siteId,
        ':email' => $email,
        ':type' => $consentType,
        ':ip' => $_SERVER['REMOTE_ADDR'] ?? null,
        ':ua' => isset($_SERVER['HTTP_USER_AGENT']) ? substr((string) $_SERVER['HTTP_USER_AGENT'], 0, 255) : null,
    ]);
}

function trainerResolveExpertiseIds(PDO $db, array $items, ?int $siteId = null): array
{
    return expertiseResolveIds($db, $items, $siteId);
}

function trainerPublicApplyHandler(int $siteId): void
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
        $stmt = $db->prepare('SELECT id FROM trainers WHERE site_id = :site_id AND slug = :slug LIMIT 1');
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
            'INSERT INTO trainers (site_id, slug, first_name, last_name, title, bio, tagline, avatar_url, avatar_initials,
             city_id, email, phone, linkedin_url, experience_years, tjm_eur, primary_expertise_id, legal_status,
             qualiopi_eligible, status, is_featured, sort_order, created_at)
             VALUES (:site_id, :slug, :fn, :ln, :title, :bio, :tag, :au, :ai, :ci, :em, :ph, :lu, :ey, :tjm, :peid, :ls, :qual, :st, 0, 0, NOW())'
        );
        $stmt->execute([
            ':site_id' => $siteId,
            ':slug' => $slug,
            ':fn' => $data['first_name'],
            ':ln' => $data['last_name'],
            ':title' => $data['title'],
            ':bio' => $data['bio'] ?? null,
            ':tag' => $data['tagline'] ?? null,
            ':au' => $data['avatar_url'] ?? $data['photo'] ?? null,
            ':ai' => $data['avatar_initials'] ?? $initials,
            ':ci' => $data['city_id'] ?? null,
            ':em' => $data['email'],
            ':ph' => $data['phone'] ?? $data['telephone'] ?? null,
            ':lu' => $data['linkedin_url'] ?? null,
            ':ey' => (int) ($data['experience_years'] ?? 0),
            ':tjm' => $data['tjm_eur'] ?? $data['tjm'] ?? null,
            ':peid' => $data['primary_expertise_id'] ?? null,
            ':ls' => $data['legal_status'] ?? null,
            ':qual' => !empty($data['qualiopi_eligible']) ? 1 : 0,
            ':st' => 'pending_review',
        ]);
        $newId = (int) $db->lastInsertId();

        $expertises = $data['expertise_ids'] ?? $data['expertises'] ?? [];
        if (is_array($expertises) && $expertises !== []) {
            $expIds = trainerResolveExpertiseIds($db, $expertises, $siteId);
            $primaryId = (int) ($data['primary_expertise_id'] ?? ($expIds[0] ?? 0));
            if ($primaryId > 0) {
                $db->prepare('UPDATE trainers SET primary_expertise_id = :pid WHERE id = :id')
                    ->execute([':pid' => $primaryId, ':id' => $newId]);
            }
            $stmtLink = $db->prepare('INSERT INTO trainer_expertise_links (trainer_id, expertise_id, is_primary) VALUES (:tid, :eid, :pri)');
            foreach ($expIds as $eid) {
                $stmtLink->execute([':tid' => $newId, ':eid' => $eid, ':pri' => ($eid === $primaryId ? 1 : 0)]);
            }
        }

        foreach (['certification_ids' => 'trainer_certification_links', 'skill_ids' => 'trainer_skill_links'] as $key => $table) {
            $col = $key === 'certification_ids' ? 'certification_id' : 'skill_id';
            $items = $data[$key] ?? [];
            if (!is_array($items)) {
                continue;
            }
            $stmtLink = $db->prepare("INSERT INTO {$table} (trainer_id, {$col}) VALUES (:tid, :sid)");
            foreach ($items as $item) {
                if (is_numeric($item)) {
                    $stmtLink->execute([':tid' => $newId, ':sid' => (int) $item]);
                }
            }
        }

        trainerLogGdprConsent($db, $siteId, (string) $data['email'], 'trainer_registration');
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

function registerPublicTrainerRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/trainer/trainers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM v_trainers_catalog WHERE site_id = :site_id ORDER BY name ASC');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/public/{site_slug}/trainer/trainers/{slug}', function (array $params) {
        if ($params['slug'] === 'apply') {
            return;
        }
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM v_trainers_catalog WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        $trainer = $stmt->fetch();
        if (!$trainer) {
            Response::notFound('Trainer not found');
            return;
        }
        Response::success($trainer);
    });

    $router->post('/api/public/{site_slug}/trainer/trainers/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        trainerPublicApplyHandler($siteId);
    });
}
