<?php
/**
 * core/Auth.php — Génération et vérification JWT sans librairie externe
 * 
 * Implémentation HMAC-SHA256 pure PHP.
 * Fonctions : generateToken(), verifyToken(), base64url encode/decode.
 */

class Auth
{
    /**
     * Génère un JWT pour un admin authentifié
     * 
     * @param array $payload Données à inclure (sub, email, role, etc.)
     * @return string Token JWT
     */
    public static function generateToken(array $payload): string
    {
        $header = [
            'alg' => 'HS256',
            'typ' => 'JWT',
        ];

        // Ajouter les claims standards
        $payload['iss'] = JWT_ISSUER;
        $payload['iat'] = time();
        $payload['exp'] = time() + JWT_EXPIRY;

        // Encoder header et payload
        $headerEncoded = self::base64UrlEncode(json_encode($header));
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));

        // Créer la signature HMAC-SHA256
        $signature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", JWT_SECRET, true);
        $signatureEncoded = self::base64UrlEncode($signature);

        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }

    /**
     * Vérifie et décode un JWT
     * 
     * @param string $token Token JWT
     * @return array|false Payload décodé ou false si invalide
     */
    public static function verifyToken(string $token): array|false
    {
        $parts = explode('.', $token);

        if (count($parts) !== 3) {
            return false;
        }

        [$headerEncoded, $payloadEncoded, $signatureEncoded] = $parts;

        // Vérifier la signature
        $expectedSignature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", JWT_SECRET, true);
        $expectedSignatureEncoded = self::base64UrlEncode($expectedSignature);

        if (!hash_equals($expectedSignatureEncoded, $signatureEncoded)) {
            return false;
        }

        // Décoder le payload
        $payload = json_decode(self::base64UrlDecode($payloadEncoded), true);

        if (!$payload) {
            return false;
        }

        // Vérifier l'expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return false;
        }

        // Vérifier l'issuer
        if (isset($payload['iss']) && $payload['iss'] !== JWT_ISSUER) {
            return false;
        }

        return $payload;
    }

    /**
     * Extrait le token du header Authorization
     * Format attendu : "Bearer <token>"
     * 
     * @return string|null Token ou null si absent
     */
    public static function extractToken(): ?string
    {
        // Essayer Authorization header
        $authHeader = $_SERVER['HTTP_AUTHORIZATION']
            ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
            ?? null;

        // Fallback : Apache peut renommer le header
        if ($authHeader === null && function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? null;
        }

        if ($authHeader === null) {
            return null;
        }

        if (preg_match('/^Bearer\s+(.+)$/i', $authHeader, $matches)) {
            return $matches[1];
        }

        return null;
    }

    /**
     * Encode en base64url (RFC 4648)
     */
    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Décode du base64url (RFC 4648)
     */
    private static function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'));
    }

    /**
     * Génère un token aléatoire sécurisé (pour reset password, unsubscribe, etc.)
     */
    public static function generateRandomToken(int $length = 64): string
    {
        return bin2hex(random_bytes($length / 2));
    }

    /**
     * Hash un mot de passe avec bcrypt
     */
    public static function hashPassword(string $password): string
    {
        return password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    /**
     * Vérifie un mot de passe contre son hash
     */
    public static function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }
}
