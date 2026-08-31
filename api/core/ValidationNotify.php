<?php
/**
 * Emails envoyés après validation admin (recruteur, coach, formateur).
 * Crée les comptes portail + tokens d'activation si nécessaire.
 */

require_once __DIR__ . '/Mail.php';

function validationNotifySiteDomain(PDO $db, int $siteId): string
{
    $stmt = $db->prepare('SELECT domain FROM core_sites WHERE id = :id AND is_active = 1 LIMIT 1');
    $stmt->execute([':id' => $siteId]);
    $domain = trim((string) ($stmt->fetchColumn() ?: ''));

    return $domain !== '' ? $domain : 'nexytal.com';
}

function validationNotifySiteDomainByCode(PDO $db, string $siteCode): string
{
    $stmt = $db->prepare('SELECT domain FROM core_sites WHERE site_code = :code AND is_active = 1 LIMIT 1');
    $stmt->execute([':code' => $siteCode]);
    $domain = trim((string) ($stmt->fetchColumn() ?: ''));

    return $domain !== '' ? $domain : 'nexytal.com';
}

function validationNotifyPortalUrl(string $domain, string $path, string $token): string
{
    $path = '/' . ltrim($path, '/');
    return 'https://' . $domain . $path . '?token=' . rawurlencode($token);
}

function validationNotifyCreateToken(int $hours = 72): array
{
    $raw = bin2hex(random_bytes(32));
    return [
        'raw' => $raw,
        'hash' => hash('sha256', $raw),
        'expires' => date('Y-m-d H:i:s', time() + ($hours * 3600)),
    ];
}

function validationNotifyRecruteur(PDO $db, array $recruteur, string $rawToken, array $siteCodes = []): bool
{
    $email = trim((string) ($recruteur['email'] ?? ''));
    if ($email === '') {
        return false;
    }

    $siteCode = !empty($siteCodes) ? (string) $siteCodes[0] : 'recrutement';
    $domain = validationNotifySiteDomainByCode($db, $siteCode);
    $path = (string) env('PORTAL_PATH_RECRUTEUR_ACTIVATE', '/recruteur/activer');
    $url = validationNotifyPortalUrl($domain, $path, $rawToken);

    $prenom = trim((string) ($recruteur['prenom'] ?? ''));
    $greeting = $prenom !== '' ? "Bonjour {$prenom}," : 'Bonjour,';

    $body = "{$greeting}\n\n"
        . "Votre compte recruteur Nexytal a été validé par notre équipe.\n\n"
        . "Pour définir votre mot de passe et accéder à votre espace recruteur, cliquez sur le lien ci-dessous (valable 72 h) :\n\n"
        . "{$url}\n\n"
        . "Si le lien ne fonctionne pas, copiez-le dans votre navigateur.\n\n"
        . "Cordialement,\nL'équipe Nexytal\n";

    return Mail::send(
        $email,
        '[Nexytal] Votre compte recruteur est validé',
        $body,
        ['from_name' => 'Nexytal Recrutement']
    );
}

function validationNotifyEnsureCoachPortalAccount(PDO $db, array $coach): ?int
{
    $siteId = (int) ($coach['site_id'] ?? 0);
    $coachId = (int) ($coach['id'] ?? 0);
    $email = trim((string) ($coach['email'] ?? ''));

    if ($siteId <= 0 || $coachId <= 0 || $email === '') {
        return null;
    }

    $stmt = $db->prepare(
        'SELECT id FROM coaching_portal_accounts
         WHERE site_id = :site_id AND email = :email AND role = \'coach\'
         LIMIT 1'
    );
    $stmt->execute([':site_id' => $siteId, ':email' => $email]);
    $existing = $stmt->fetchColumn();
    if ($existing) {
        return (int) $existing;
    }

    $placeholderHash = password_hash(bin2hex(random_bytes(32)), PASSWORD_BCRYPT);
    $db->prepare(
        'INSERT INTO coaching_portal_accounts (site_id, role, email, password_hash, coach_id, is_active, created_at)
         VALUES (:site_id, \'coach\', :email, :hash, :coach_id, 1, NOW())'
    )->execute([
        ':site_id' => $siteId,
        ':email' => $email,
        ':hash' => $placeholderHash,
        ':coach_id' => $coachId,
    ]);

    return (int) $db->lastInsertId();
}

function validationNotifyEnsureTrainerPortalAccount(PDO $db, array $trainer): ?int
{
    $siteId = (int) ($trainer['site_id'] ?? 5);
    $trainerId = (int) ($trainer['id'] ?? 0);
    $email = trim((string) ($trainer['email'] ?? ''));

    if ($trainerId <= 0 || $email === '') {
        return null;
    }

    $stmt = $db->prepare(
        'SELECT id FROM trainer_portal_accounts
         WHERE site_id = :site_id AND email = :email AND role = \'trainer\'
         LIMIT 1'
    );
    $stmt->execute([':site_id' => $siteId, ':email' => $email]);
    $existing = $stmt->fetchColumn();
    if ($existing) {
        return (int) $existing;
    }

    $placeholderHash = password_hash(bin2hex(random_bytes(32)), PASSWORD_BCRYPT);
    $db->prepare(
        'INSERT INTO trainer_portal_accounts (site_id, role, email, password_hash, trainer_id, is_active, created_at)
         VALUES (:site_id, \'trainer\', :email, :hash, :trainer_id, 1, NOW())'
    )->execute([
        ':site_id' => $siteId,
        ':email' => $email,
        ':hash' => $placeholderHash,
        ':trainer_id' => $trainerId,
    ]);

    return (int) $db->lastInsertId();
}

function validationNotifyCoachPortalReset(PDO $db, int $accountId): ?string
{
    $token = validationNotifyCreateToken();
    $db->prepare(
        'INSERT INTO coaching_portal_password_resets (account_id, role, token_hash, expires_at, created_at)
         VALUES (:account_id, \'coach\', :hash, :expires, NOW())'
    )->execute([
        ':account_id' => $accountId,
        ':hash' => $token['hash'],
        ':expires' => $token['expires'],
    ]);

    return $token['raw'];
}

function validationNotifyTrainerPortalReset(PDO $db, int $accountId): ?string
{
    $token = validationNotifyCreateToken();
    $db->prepare(
        'INSERT INTO trainer_portal_password_resets (account_id, role, token_hash, expires_at, created_at)
         VALUES (:account_id, \'trainer\', :hash, :expires, NOW())'
    )->execute([
        ':account_id' => $accountId,
        ':hash' => $token['hash'],
        ':expires' => $token['expires'],
    ]);

    return $token['raw'];
}

function validationNotifyCoach(PDO $db, array $coach): bool
{
    $email = trim((string) ($coach['email'] ?? ''));
    if ($email === '') {
        error_log('[ValidationNotify] Coach sans email (id ' . ($coach['id'] ?? '?') . ')');
        return false;
    }

    $accountId = validationNotifyEnsureCoachPortalAccount($db, $coach);
    if (!$accountId) {
        return false;
    }

    $rawToken = validationNotifyCoachPortalReset($db, $accountId);
    if (!$rawToken) {
        return false;
    }

    $siteId = (int) ($coach['site_id'] ?? 6);
    $domain = validationNotifySiteDomain($db, $siteId);
    $path = (string) env('PORTAL_PATH_COACH_ACTIVATE', '/espace-coach/activer');
    $url = validationNotifyPortalUrl($domain, $path, $rawToken);

    $firstName = trim((string) ($coach['first_name'] ?? ''));
    $greeting = $firstName !== '' ? "Bonjour {$firstName}," : 'Bonjour,';

    $body = "{$greeting}\n\n"
        . "Félicitations ! Votre profil coach sur Nexytal Coaching a été validé.\n\n"
        . "Pour activer votre espace coach et choisir votre mot de passe, utilisez ce lien (valable 72 h) :\n\n"
        . "{$url}\n\n"
        . "Une fois connecté(e), vous pourrez gérer vos créneaux et vos clients.\n\n"
        . "Cordialement,\nL'équipe Nexytal Coaching\n";

    return Mail::send(
        $email,
        '[Nexytal Coaching] Votre profil coach est validé',
        $body,
        ['from_name' => 'Nexytal Coaching']
    );
}

function validationNotifyTrainer(PDO $db, array $trainer): bool
{
    $email = trim((string) ($trainer['email'] ?? ''));
    if ($email === '') {
        error_log('[ValidationNotify] Formateur sans email (id ' . ($trainer['id'] ?? '?') . ')');
        return false;
    }

    $accountId = validationNotifyEnsureTrainerPortalAccount($db, $trainer);
    if (!$accountId) {
        return false;
    }

    $rawToken = validationNotifyTrainerPortalReset($db, $accountId);
    if (!$rawToken) {
        return false;
    }

    $siteId = (int) ($trainer['site_id'] ?? 5);
    $domain = validationNotifySiteDomain($db, $siteId);
    $path = (string) env('PORTAL_PATH_TRAINER_ACTIVATE', '/espace-formateur/activer');
    $url = validationNotifyPortalUrl($domain, $path, $rawToken);

    $firstName = trim((string) ($trainer['first_name'] ?? ''));
    $greeting = $firstName !== '' ? "Bonjour {$firstName}," : 'Bonjour,';

    $body = "{$greeting}\n\n"
        . "Félicitations ! Votre profil formateur sur Nexytal Trainers a été validé.\n\n"
        . "Pour activer votre espace formateur et choisir votre mot de passe, utilisez ce lien (valable 72 h) :\n\n"
        . "{$url}\n\n"
        . "Vous pourrez ensuite compléter votre catalogue et gérer vos sessions.\n\n"
        . "Cordialement,\nL'équipe Nexytal Trainers\n";

    return Mail::send(
        $email,
        '[Nexytal Trainers] Votre profil formateur est validé',
        $body,
        ['from_name' => env('MAIL_FROM_NAME', 'Nexytal Trainers')]
    );
}
