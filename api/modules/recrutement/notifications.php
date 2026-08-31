<?php
/**
 * notifications.php — Emails recrutement (aligné bdd.sql : recruteurs.email)
 */

function recrutementRecruiterEmailForOffer(PDO $db, array $offer): ?string
{
    if (!empty($offer['recruteur_id'])) {
        $stmt = $db->prepare('SELECT email FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => (int) $offer['recruteur_id']]);
        $row = $stmt->fetch();
        if ($row && !empty($row['email'])) {
            return (string) $row['email'];
        }
    }
    return null;
}

function recrutementNotifyAdminNewOffer(PDO $db, array $offer, string $siteName): void
{
    $to = defined('ADMIN_NOTIFICATION_EMAIL')
        ? ADMIN_NOTIFICATION_EMAIL
        : (env('ADMIN_NOTIFICATION_EMAIL') ?: env('MAIL_TO'));
    if (!$to) {
        return;
    }
    $recEmail = recrutementRecruiterEmailForOffer($db, $offer) ?? '—';
    $subject = "[Nexytal] Nouvelle offre en attente — {$siteName}";
    $body = "Une nouvelle offre a été soumise et attend validation.\n\n"
        . "Titre: {$offer['titre']}\n"
        . "Site: {$siteName}\n"
        . "Recruteur: {$recEmail}\n"
        . "ID: {$offer['id']}\n";
    recrutementQueueEmail($db, $to, $subject, $body, 'recrutement_offre_pending', (int) ($offer['site_id'] ?? 2));
}

function recrutementNotifyRecruiterOfferStatus(PDO $db, array $offer, string $status, ?string $motif = null): void
{
    $email = recrutementRecruiterEmailForOffer($db, $offer);
    if (!$email) {
        return;
    }

    $label = match ($status) {
        'publiee' => 'publiée',
        'archivee' => 'archivée (refusée)',
        default => $status,
    };
    $subject = "[Nexytal] Votre offre a été {$label}";
    $body = "Bonjour,\n\nVotre offre « {$offer['titre']} » a été {$label}.\n";
    if ($motif) {
        $body .= "\nMotif: {$motif}\n";
    }
    recrutementQueueEmail($db, $email, $subject, $body, 'recrutement_offre_' . $status, (int) ($offer['site_id'] ?? 2));
}

function recrutementNotifyRecruiterNewApplication(PDO $db, int $offreId, array $application): void
{
    $stmt = $db->prepare(
        'SELECT o.titre, o.recruteur_id, o.site_id, r.email as recruteur_email
         FROM offres_emploi o
         LEFT JOIN recruteurs r ON o.recruteur_id = r.id
         WHERE o.id = :id LIMIT 1'
    );
    $stmt->execute([':id' => $offreId]);
    $offer = $stmt->fetch();
    if (!$offer || empty($offer['recruteur_email'])) {
        return;
    }

    $name = trim(($application['prenom'] ?? '') . ' ' . ($application['nom'] ?? ''));
    $scoreVal = $application['score_nexytal'] ?? $application['score_affinite'] ?? null;
    $score = $scoreVal !== null ? " (score: {$scoreVal}/100)" : '';
    $subject = "[Nexytal] Nouvelle candidature — {$offer['titre']}";
    $body = "Bonjour,\n\nUne nouvelle candidature a été reçue pour « {$offer['titre']} ».\n\n"
        . "Candidat: {$name}\nEmail: " . ($application['email'] ?? '—') . "{$score}\n";
    recrutementQueueEmail($db, (string) $offer['recruteur_email'], $subject, $body, 'recrutement_nouvelle_candidature', (int) ($offer['site_id'] ?? 2));
}

function recrutementQueueEmail(PDO $db, string $to, string $subject, string $body, string $type, int $siteId = 2): void
{
    require_once __DIR__ . '/../../core/Mail.php';

    if (!Mail::send($to, $subject, $body, ['from_name' => 'Nexytal Recrutement'])) {
        error_log("recrutementNotify [{$type}] to {$to}: {$subject}");
    }
}
