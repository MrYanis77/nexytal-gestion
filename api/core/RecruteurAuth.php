<?php
/**
 * RecruteurAuth — Authentification espace recruteur (JWT admin ou token recruteur).
 */

class RecruteurAuth
{
    /**
     * Authentifie un recruteur via token brut (table recruteur_tokens).
     *
     * @return array{id: int, email: string, nom_entreprise: string, status: string}|null
     */
    public static function authenticateRecruteurToken(PDO $db, string $token): ?array
    {
        if ($token === '') {
            return null;
        }

        $hash = hash('sha256', $token);
        $stmt = $db->prepare(
            'SELECT r.id, r.email, r.nom_entreprise, r.prenom, r.nom, r.status
             FROM recruteur_tokens rt
             INNER JOIN recruteurs r ON r.id = rt.recruteur_id
             WHERE rt.token_hash = :hash
               AND rt.expires_at > NOW()
               AND r.status = :status
             LIMIT 1'
        );
        $stmt->execute([':hash' => $hash, ':status' => 'actif']);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        return $row ?: null;
    }

    /**
     * Contexte d'accès portail : admin JWT ou recruteur satellite.
     *
     * @return array{
     *   mode: string,
     *   admin?: array,
     *   recruteur?: array,
     *   recruteur_ids: int[]
     * }
     */
    public static function authenticatePortal(PDO $db): array
    {
        $token = Auth::extractToken();
        if ($token === null) {
            Response::unauthorized('Missing authentication token');
            exit;
        }

        if (str_contains($token, '.')) {
            $payload = Auth::verifyToken($token);
            if ($payload !== false) {
                $stmt = $db->prepare(
                    'SELECT id, email, first_name, last_name, role, is_active
                     FROM core_admin_users
                     WHERE id = :id AND is_active = 1
                     LIMIT 1'
                );
                $stmt->execute([':id' => (int) ($payload['sub'] ?? 0)]);
                $admin = $stmt->fetch(PDO::FETCH_ASSOC);
                if (!$admin) {
                    Response::unauthorized('Account not found or deactivated');
                    exit;
                }

                if (isset($payload['session_id'])) {
                    $sessionToken = (string) $payload['session_id'];
                    if (!AdminSession::isValid($db, $sessionToken, (int) $admin['id'])) {
                        Response::unauthorized('Session expired or revoked');
                        exit;
                    }
                }

                if (!in_array($admin['role'], ['superadmin', 'admin', 'recruiter'], true)) {
                    Response::forbidden('Insufficient permissions');
                    exit;
                }

                $recruteurIds = [];
                if ($admin['role'] === 'recruiter') {
                    $scopeStmt = $db->prepare('SELECT id FROM recruteurs WHERE email = :email');
                    $scopeStmt->execute([':email' => $admin['email']]);
                    foreach ($scopeStmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
                        $recruteurIds[] = (int) $row['id'];
                    }
                }

                return [
                    'mode' => 'admin',
                    'admin' => $admin,
                    'recruteur_ids' => $recruteurIds,
                ];
            }
        }

        $recruteur = self::authenticateRecruteurToken($db, $token);
        if ($recruteur === null) {
            Response::unauthorized('Invalid or expired token');
            exit;
        }

        return [
            'mode' => 'recruiter',
            'recruteur' => $recruteur,
            'recruteur_ids' => [(int) $recruteur['id']],
        ];
    }

    public static function assertOfferAccess(PDO $db, array $auth, array $offer): void
    {
        if ($auth['mode'] === 'admin' && ($auth['admin']['role'] ?? '') !== 'recruiter') {
            return;
        }

        $recruteurId = (int) ($offer['recruteur_id'] ?? 0);
        if ($recruteurId <= 0 || !in_array($recruteurId, $auth['recruteur_ids'], true)) {
            Response::forbidden('Accès refusé à cette candidature');
            exit;
        }
    }
}
