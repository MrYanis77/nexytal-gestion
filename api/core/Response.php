<?php
/**
 * core/Response.php — Helper réponses JSON pour l'API Nexytal
 * 
 * Méthodes statiques pour envoyer des réponses HTTP standardisées.
 * Sanitization automatique des chaînes via htmlspecialchars.
 */

class Response
{
    /**
     * Envoie une réponse JSON avec code HTTP
     */
    public static function json(mixed $data, int $statusCode = 200): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(self::sanitize($data), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    /**
     * 200 OK — succès avec données
     */
    public static function success(mixed $data, string $message = 'Success'): void
    {
        self::json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], 200);
    }

    /**
     * 200 OK — liste paginée
     */
    public static function paginated(array $data, int $total, int $page, int $limit): void
    {
        self::json([
            'success'    => true,
            'data'       => $data,
            'pagination' => [
                'total'       => $total,
                'page'        => $page,
                'limit'       => $limit,
                'total_pages' => (int) ceil($total / max(1, $limit)),
            ],
        ], 200);
    }

    /**
     * 201 Created — ressource créée
     */
    public static function created(mixed $data, string $message = 'Created successfully'): void
    {
        self::json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], 201);
    }

    /**
     * 204 No Content — suppression réussie
     */
    public static function noContent(): void
    {
        http_response_code(204);
        exit;
    }

    /**
     * 400 Bad Request
     */
    public static function badRequest(string $message = 'Bad request'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 400);
    }

    /**
     * 401 Unauthorized
     */
    public static function unauthorized(string $message = 'Unauthorized'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 401);
    }

    /**
     * 403 Forbidden
     */
    public static function forbidden(string $message = 'Forbidden'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 403);
    }

    /**
     * 404 Not Found
     */
    public static function notFound(string $message = 'Resource not found'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 404);
    }

    /**
     * 405 Method Not Allowed
     */
    public static function methodNotAllowed(string $message = 'Method not allowed'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 405);
    }

    /**
     * 422 Unprocessable Entity — erreurs de validation
     */
    public static function validationError(array $errors, string $message = 'Validation failed'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
            'errors'  => $errors,
        ], 422);
    }

    /**
     * 429 Too Many Requests — rate limiting
     */
    public static function tooManyRequests(string $message = 'Too many requests. Please try again later.'): void
    {
        self::json([
            'success' => false,
            'error'   => $message,
        ], 429);
    }

    /**
     * 500 Internal Server Error
     */
    public static function serverError(string $message = 'Internal server error', ?string $detail = null): void
    {
        $response = [
            'success' => false,
            'error'   => $message,
        ];

        // Afficher les détails uniquement en dev
        if ($detail !== null && defined('APP_ENV') && APP_ENV === 'development') {
            $response['detail'] = $detail;
        }

        self::json($response, 500);
    }

    /**
     * Sanitize récursif des données de sortie
     * Applique htmlspecialchars sur toutes les chaînes pour prévenir le XSS.
     */
    private static function sanitize(mixed $data): mixed
    {
        if (is_string($data)) {
            return htmlspecialchars($data, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
        }

        if (is_array($data)) {
            $sanitized = [];
            foreach ($data as $key => $value) {
                $sanitized[$key] = self::sanitize($value);
            }
            return $sanitized;
        }

        // int, float, bool, null — retourner tel quel
        return $data;
    }
}
