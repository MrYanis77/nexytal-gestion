<?php
/**
 * core/Router.php — Routeur REST pour l'API Nexytal
 * 
 * Gère GET/POST/PUT/DELETE avec support paramètres dynamiques {id}, {slug}.
 * Dispatch vers callbacks. Répond 405 si méthode non supportée, 404 si route inconnue.
 */

class Router
{
    /** @var array Routes enregistrées par méthode HTTP */
    private array $routes = [
        'GET'    => [],
        'POST'   => [],
        'PUT'    => [],
        'DELETE' => [],
    ];

    /**
     * Enregistre une route GET
     */
    public function get(string $path, callable $callback): void
    {
        $this->routes['GET'][] = ['path' => $path, 'callback' => $callback];
    }

    /**
     * Enregistre une route POST
     */
    public function post(string $path, callable $callback): void
    {
        $this->routes['POST'][] = ['path' => $path, 'callback' => $callback];
    }

    /**
     * Enregistre une route PUT
     */
    public function put(string $path, callable $callback): void
    {
        $this->routes['PUT'][] = ['path' => $path, 'callback' => $callback];
    }

    /**
     * Enregistre une route DELETE
     */
    public function delete(string $path, callable $callback): void
    {
        $this->routes['DELETE'][] = ['path' => $path, 'callback' => $callback];
    }

    /**
     * Dispatch la requête courante vers la route correspondante
     */
    public function dispatch(): void
    {
        $method = $_SERVER['REQUEST_METHOD'];
        $uri = $this->getUri();

        // Gestion CORS preflight
        if ($method === 'OPTIONS') {
            http_response_code(204);
            exit;
        }

        // Vérifier si la méthode est supportée
        if (!isset($this->routes[$method])) {
            Response::methodNotAllowed();
            return;
        }

        // Chercher la route correspondante
        foreach ($this->routes[$method] as $route) {
            $params = $this->matchRoute($route['path'], $uri);
            if ($params !== false) {
                call_user_func($route['callback'], $params);
                return;
            }
        }

        // Vérifier si l'URI existe pour une autre méthode (405 vs 404)
        foreach ($this->routes as $routeMethod => $routes) {
            if ($routeMethod === $method) continue;
            foreach ($routes as $route) {
                if ($this->matchRoute($route['path'], $uri) !== false) {
                    Response::methodNotAllowed();
                    return;
                }
            }
        }

        // Aucune route trouvée
        Response::notFound('Route not found');
    }

    /**
     * Extrait l'URI nettoyée (sans query string, sans slashes en trop)
     */
    private function getUri(): string
    {
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        // Supprimer la query string
        $uri = strtok($uri, '?');
        // Normaliser les slashes
        $uri = '/' . trim($uri, '/');
        return $uri;
    }

    /**
     * Tente de matcher une route pattern avec une URI.
     * Retourne un tableau de paramètres si match, false sinon.
     * 
     * Ex: matchRoute('/api/admin/users/{id}', '/api/admin/users/42')
     * → ['id' => '42']
     */
    private function matchRoute(string $pattern, string $uri): array|false
    {
        // Convertir les paramètres {param} en regex named groups
        $regex = preg_replace('/\{([a-zA-Z_]+)\}/', '(?P<$1>[^/]+)', $pattern);
        $regex = '#^' . $regex . '$#';

        if (preg_match($regex, $uri, $matches)) {
            // Ne garder que les captures nommées (pas les numériques)
            $params = [];
            foreach ($matches as $key => $value) {
                if (is_string($key)) {
                    $params[$key] = $value;
                }
            }
            return $params;
        }

        return false;
    }

    /**
     * Récupère le body JSON de la requête POST/PUT
     */
    public static function getJsonBody(): array
    {
        $body = file_get_contents('php://input');
        if (empty($body)) {
            return [];
        }
        $data = json_decode($body, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            Response::badRequest('Invalid JSON body');
            exit;
        }
        return $data ?? [];
    }

    /**
     * Récupère un paramètre GET (query string)
     */
    public static function getQueryParam(string $key, mixed $default = null): mixed
    {
        return $_GET[$key] ?? $default;
    }

    /**
     * Récupère les paramètres de pagination depuis la query string
     * Retourne [page, limit, offset]
     */
    public static function getPagination(): array
    {
        $page = max(1, (int) ($_GET['page'] ?? 1));
        $limit = min(MAX_PAGE_SIZE, max(1, (int) ($_GET['limit'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $limit;

        return ['page' => $page, 'limit' => $limit, 'offset' => $offset];
    }
}
