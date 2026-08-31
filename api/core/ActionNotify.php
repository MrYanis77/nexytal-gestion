<?php
/**
 * Notifications email declenchees par les actions admin.
 * Les envois sont non bloquants : l'action metier reste prioritaire.
 */

require_once __DIR__ . '/Mail.php';

class ActionNotify
{
    public static function recruteurSuspended(PDO $db, array $recruteur): bool
    {
        $email = self::email($recruteur, 'email');
        if ($email === null) {
            return false;
        }

        $name = self::personName($recruteur, 'prenom', 'nom', 'recruteur');
        $body = "Bonjour {$name},\n\n"
            . "Votre compte recruteur Nexytal a ete suspendu par notre equipe.\n"
            . "Si vous pensez qu'il s'agit d'une erreur, contactez le support Nexytal.\n\n"
            . "Cordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($recruteur, 2), $email, '[Nexytal] Compte recruteur suspendu', $body, 'recruteur_suspended');
    }

    public static function notifyRecruteurSuspended(PDO $db, array $recruteur): bool
    {
        return self::recruteurSuspended($db, $recruteur);
    }

    public static function candidatureStatusChanged(PDO $db, array $candidature, string $oldStatus, string $newStatus, ?string $comment = null): bool
    {
        $email = self::email($candidature, 'candidat_email') ?? self::email($candidature, 'email');
        if ($email === null) {
            return false;
        }

        $name = self::personName($candidature, 'candidat_prenom', 'candidat_nom', 'candidat');
        $offerTitle = trim((string) ($candidature['offre_titre'] ?? 'votre candidature'));
        $body = "Bonjour {$name},\n\n"
            . "Le statut de votre candidature pour \"{$offerTitle}\" est passe de " . self::statusLabel($oldStatus) . " a " . self::statusLabel($newStatus) . ".\n";
        if ($comment !== null && trim($comment) !== '') {
            $body .= "\nCommentaire : {$comment}\n";
        }
        $body .= "\nCordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($candidature, 2), $email, '[Nexytal] Statut de votre candidature', $body, 'candidature_status_changed');
    }

    public static function notifyCandidatureStatusChanged(PDO $db, array $candidature, string $oldStatus, string $newStatus, ?string $comment = null): bool
    {
        return self::candidatureStatusChanged($db, $candidature, $oldStatus, $newStatus, $comment);
    }

    public static function offerPublished(PDO $db, array $offer): bool
    {
        return self::offerStatusChanged($db, $offer, 'publiee');
    }

    public static function notifyOfferPublished(PDO $db, array $offer): bool
    {
        return self::offerPublished($db, $offer);
    }

    public static function offerRejected(PDO $db, array $offer, ?string $reason = null): bool
    {
        return self::offerStatusChanged($db, $offer, 'archivee', $reason);
    }

    public static function notifyOfferRejected(PDO $db, array $offer, ?string $reason = null): bool
    {
        return self::offerRejected($db, $offer, $reason);
    }

    public static function coachStatusChanged(PDO $db, array $coach, string $newStatus, ?string $reason = null): bool
    {
        $email = self::email($coach, 'email');
        if ($email === null) {
            return false;
        }

        $name = self::personName($coach, 'first_name', 'last_name', 'coach');
        $body = "Bonjour {$name},\n\n"
            . "Le statut de votre profil coach est desormais : " . self::statusLabel($newStatus) . ".\n";
        if ($reason !== null && trim($reason) !== '') {
            $body .= "\nMotif : {$reason}\n";
        }
        $body .= "\nCordialement,\nL'equipe Nexytal Coaching\n";

        return self::sendAction($db, self::siteId($coach, 6), $email, '[Nexytal Coaching] Mise a jour de votre profil', $body, 'coach_status_changed', 'Nexytal Coaching');
    }

    public static function notifyCoachStatusChanged(PDO $db, array $coach, string $newStatus, ?string $reason = null): bool
    {
        return self::coachStatusChanged($db, $coach, $newStatus, $reason);
    }

    public static function trainerStatusChanged(PDO $db, array $trainer, string $newStatus, ?string $reason = null): bool
    {
        $email = self::email($trainer, 'email');
        if ($email === null) {
            return false;
        }

        $name = self::personName($trainer, 'first_name', 'last_name', 'formateur');
        $body = "Bonjour {$name},\n\n"
            . "Le statut de votre profil formateur est desormais : " . self::statusLabel($newStatus) . ".\n";
        if ($reason !== null && trim($reason) !== '') {
            $body .= "\nMotif : {$reason}\n";
        }
        $body .= "\nCordialement,\nL'equipe Nexytal Trainers\n";

        return self::sendAction($db, self::siteId($trainer, 5), $email, '[Nexytal Trainers] Mise a jour de votre profil', $body, 'trainer_status_changed', 'Nexytal Trainers');
    }

    public static function notifyTrainerStatusChanged(PDO $db, array $trainer, string $newStatus, ?string $reason = null): bool
    {
        return self::trainerStatusChanged($db, $trainer, $newStatus, $reason);
    }

    public static function commentModerated(PDO $db, array $comment, string $newStatus): bool
    {
        $email = self::email($comment, 'author_email');
        if ($email === null) {
            return false;
        }

        $name = trim((string) ($comment['author_name'] ?? '')) ?: 'contributeur';
        $postTitle = trim((string) ($comment['post_title'] ?? 'un article Nexytal'));
        $body = "Bonjour {$name},\n\n"
            . "Votre commentaire sur \"{$postTitle}\" a ete modere.\n"
            . "Nouveau statut : " . self::statusLabel($newStatus) . ".\n\n"
            . "Cordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($comment, 0), $email, '[Nexytal] Moderation de votre commentaire', $body, 'comment_moderated');
    }

    public static function notifyCommentModerated(PDO $db, array $comment, string $newStatus): bool
    {
        return self::commentModerated($db, $comment, $newStatus);
    }

    public static function gdprRequestProcessed(PDO $db, array $request, string $newStatus): bool
    {
        $email = self::email($request, 'user_email');
        if ($email === null) {
            return false;
        }

        $body = "Bonjour,\n\n"
            . "Votre demande relative a vos donnees personnelles a ete mise a jour.\n"
            . "Statut : " . self::statusLabel($newStatus) . ".\n\n"
            . "Cordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($request, 0), $email, '[Nexytal] Suivi de votre demande RGPD', $body, 'gdpr_request_processed');
    }

    public static function notifyGdprRequestProcessed(PDO $db, array $request, string $newStatus): bool
    {
        return self::gdprRequestProcessed($db, $request, $newStatus);
    }

    public static function demandeUrgenteStatusChanged(PDO $db, array $demande, string $oldStatus, string $newStatus): bool
    {
        $email = self::email($demande, 'email');
        if ($email === null) {
            return false;
        }

        $name = trim((string) ($demande['nom'] ?? '')) ?: 'contact';
        $body = "Bonjour {$name},\n\n"
            . "Votre demande urgente a change de statut : " . self::statusLabel($oldStatus) . " -> " . self::statusLabel($newStatus) . ".\n\n"
            . "Cordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($demande, 2), $email, '[Nexytal] Suivi de votre demande urgente', $body, 'demande_urgente_status_changed');
    }

    public static function notifyDemandeUrgenteUpdated(PDO $db, array $demande, string $oldStatus, string $newStatus): bool
    {
        return self::demandeUrgenteStatusChanged($db, $demande, $oldStatus, $newStatus);
    }

    private static function offerStatusChanged(PDO $db, array $offer, string $status, ?string $reason = null): bool
    {
        $email = self::email($offer, 'recruteur_email');
        if ($email === null && !empty($offer['recruteur_id'])) {
            $stmt = $db->prepare('SELECT email FROM recruteurs WHERE id = :id LIMIT 1');
            $stmt->execute([':id' => (int) $offer['recruteur_id']]);
            $email = self::validEmail($stmt->fetchColumn() ?: null);
        }
        if ($email === null) {
            return false;
        }

        $label = self::statusLabel($status);
        $title = trim((string) ($offer['titre'] ?? 'votre offre'));
        $body = "Bonjour,\n\nVotre offre \"{$title}\" est desormais : {$label}.\n";
        if ($reason !== null && trim($reason) !== '') {
            $body .= "\nMotif : {$reason}\n";
        }
        $body .= "\nCordialement,\nL'equipe Nexytal\n";

        return self::sendAction($db, self::siteId($offer, 2), $email, '[Nexytal] Statut de votre offre', $body, 'offer_status_changed');
    }

    private static function sendAction(PDO $db, int $siteId, string $to, string $subject, string $body, string $template, string $fromName = 'Nexytal'): bool
    {
        $sent = false;
        try {
            $sent = Mail::send($to, $subject, $body, ['from_name' => $fromName]);
        } catch (Throwable $e) {
            error_log('[ActionNotify] ' . $e->getMessage());
        }

        self::recordEmail($db, $siteId, $to, $subject, $template, $sent);
        return $sent;
    }

    private static function recordEmail(PDO $db, int $siteId, string $to, string $subject, string $template, bool $sent): void
    {
        try {
            if (!self::tableExists($db, 'marketing_email_logs')) {
                return;
            }
            $stmt = $db->prepare(
                'INSERT INTO marketing_email_logs (site_id, recipient_email, subject, template_used, status, error_message, created_at)
                 VALUES (:site_id, :email, :subject, :template, :status, :error, NOW())'
            );
            $stmt->execute([
                ':site_id' => $siteId > 0 ? $siteId : null,
                ':email' => $to,
                ':subject' => $subject,
                ':template' => $template,
                ':status' => $sent ? 'sent' : 'failed',
                ':error' => $sent ? null : 'SMTP not configured or send failed',
            ]);
        } catch (Throwable $e) {
            error_log('[ActionNotify] Email log skipped: ' . $e->getMessage());
        }
    }

    private static function tableExists(PDO $db, string $table): bool
    {
        try {
            $stmt = $db->prepare('SHOW TABLES LIKE :table_name');
            $stmt->execute([':table_name' => $table]);
            return (bool) $stmt->fetchColumn();
        } catch (Throwable $e) {
            return false;
        }
    }

    private static function email(array $row, string $key): ?string
    {
        return self::validEmail($row[$key] ?? null);
    }

    private static function validEmail(mixed $value): ?string
    {
        $email = trim((string) ($value ?? ''));
        return filter_var($email, FILTER_VALIDATE_EMAIL) ? $email : null;
    }

    private static function siteId(array $row, int $default): int
    {
        $siteId = (int) ($row['site_id'] ?? $default);
        return $siteId > 0 ? $siteId : $default;
    }

    private static function personName(array $row, string $firstKey, string $lastKey, string $fallback): string
    {
        $name = trim((string) ($row[$firstKey] ?? '') . ' ' . (string) ($row[$lastKey] ?? ''));
        return $name !== '' ? $name : $fallback;
    }

    private static function statusLabel(string $status): string
    {
        return match ($status) {
            'pending', 'pending_review', 'recue' => 'en attente',
            'actif', 'active', 'publiee', 'approved' => 'valide',
            'suspendu' => 'suspendu',
            'inactive', 'archivee', 'rejected', 'spam' => 'refuse ou archive',
            'en_cours', 'processing' => 'en cours',
            'traitee', 'completed' => 'traite',
            default => $status,
        };
    }
}