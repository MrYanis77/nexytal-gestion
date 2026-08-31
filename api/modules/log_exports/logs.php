<?php
/**
 * modules/logs/logs.php � Journaux consultables et export serveur CSV/JSON.
 */

function nexytalLogsDefinitions(): array
{
    return [
        'audit' => [
            'label' => 'Actions admin',
            'table' => 'core_audit_logs',
            'date_column' => 'created_at',
            'site_column' => 'site_id',
            'order' => 'created_at DESC, id DESC',
            'filters' => ['action', 'entity_type', 'admin_id'],
            'columns' => ['id', 'admin_id', 'site_id', 'action', 'entity_type', 'entity_id', 'old_data', 'new_data', 'ip_address', 'created_at'],
        ],
        'emails' => [
            'label' => 'Emails envoyes',
            'table' => 'marketing_email_logs',
            'date_column' => 'created_at',
            'site_column' => 'site_id',
            'order' => 'created_at DESC, id DESC',
            'filters' => ['status', 'recipient_email', 'template_used'],
            'columns' => ['id', 'site_id', 'recipient_email', 'subject', 'template_used', 'status', 'error_message', 'created_at'],
        ],
        'gdpr-consents' => [
            'label' => 'Consentements RGPD',
            'table' => 'gdpr_consents_log',
            'date_column' => 'created_at',
            'site_column' => 'site_id',
            'order' => 'created_at DESC, id DESC',
            'filters' => ['consent_type', 'user_email', 'granted'],
            'columns' => ['id', 'site_id', 'user_email', 'consent_type', 'granted', 'ip_address', 'created_at'],
        ],
        'gdpr-deletions' => [
            'label' => 'Demandes de suppression RGPD',
            'table' => 'gdpr_deletion_requests',
            'date_column' => 'requested_at',
            'site_column' => 'site_id',
            'order' => 'requested_at DESC, id DESC',
            'filters' => ['status', 'user_email', 'processed_by'],
            'columns' => ['id', 'site_id', 'user_email', 'status', 'requested_at', 'processed_at', 'processed_by', 'notes'],
        ],
        'candidature-history' => [
            'label' => 'Historique candidatures',
            'table' => 'candidature_historique',
            'date_column' => 'created_at',
            'site_column' => null,
            'site_scope_sql' => "(EXISTS (SELECT 1 FROM candidatures c INNER JOIN offres_emploi o ON o.id = c.offre_id WHERE c.id = candidature_historique.candidature_id AND o.site_id IN ({sites})) OR EXISTS (SELECT 1 FROM candidatures_externes ce WHERE ce.id = candidature_historique.candidature_id AND ce.site_id IN ({sites})))",
            'order' => 'created_at DESC, id DESC',
            'filters' => ['candidature_id', 'auteur_type', 'auteur_id'],
            'columns' => ['id', 'candidature_id', 'ancien_statut', 'nouveau_statut', 'commentaire', 'auteur_type', 'auteur_id', 'created_at'],
        ],
        'admin-sessions' => [
            'label' => 'Sessions admin',
            'table' => 'core_admin_sessions',
            'date_column' => 'created_at',
            'site_column' => null,
            'order' => 'created_at DESC',
            'filters' => ['admin_id'],
            'columns' => ['id', 'admin_id', 'ip_address', 'user_agent', 'expires_at', 'created_at'],
        ],
    ];
}

function nexytalLogsGetDefinition(string $type): ?array
{
    $definitions = nexytalLogsDefinitions();
    return $definitions[$type] ?? null;
}

function nexytalLogsRedactValue($value)
{
    if (is_array($value)) {
        foreach ($value as $key => $child) {
            if (preg_match('/password|token|secret|session|authorization/i', (string) $key)) {
                $value[$key] = '[redacted]';
                continue;
            }
            $value[$key] = nexytalLogsRedactValue($child);
        }
        return $value;
    }

    return $value;
}

function nexytalLogsRedactRow(array $row): array
{
    foreach ($row as $key => $value) {
        if (preg_match('/password|token|secret|authorization/i', (string) $key)) {
            $row[$key] = '[redacted]';
            continue;
        }

        if (is_string($value) && substr(trim($value), 0, 1) === '{') {
            $decoded = json_decode($value, true);
            if (is_array($decoded)) {
                $row[$key] = json_encode(nexytalLogsRedactValue($decoded), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
            }
        }
    }

    return $row;
}

function nexytalLogsBuildQuery(array $definition, array $pagination, bool $forExport = false): array
{
    $where = [];
    $params = [];

    $siteColumn = $definition['site_column'] ?? null;
    $siteId = Router::getQueryParam('site_id');
    if ($siteColumn !== null && $siteId !== null && $siteId !== '') {
        $siteId = (int) $siteId;
        Middleware::requireSiteAccess($siteId);
        $where[] = "`{$siteColumn}` = :site_id";
        $params[':site_id'] = $siteId;
    } elseif ($siteColumn !== null) {
        $accessibleSites = array_map('intval', Middleware::getAccessibleSiteIds());
        if ($accessibleSites === []) {
            $where[] = '1 = 0';
        } else {
            $where[] = "`{$siteColumn}` IN (" . implode(',', $accessibleSites) . ")";
        }
    } elseif (!empty($definition['site_scope_sql'])) {
        if ($siteId !== null && $siteId !== '') {
            $siteId = (int) $siteId;
            Middleware::requireSiteAccess($siteId);
            $accessibleSites = [$siteId];
        } else {
            $accessibleSites = array_map('intval', Middleware::getAccessibleSiteIds());
        }
        $where[] = $accessibleSites === []
            ? '1 = 0'
            : str_replace('{sites}', implode(',', $accessibleSites), $definition['site_scope_sql']);
    }

    $dateColumn = $definition['date_column'];
    if ($from = Router::getQueryParam('from')) {
        $where[] = "`{$dateColumn}` >= :from_date";
        $params[':from_date'] = $from . (strlen($from) === 10 ? ' 00:00:00' : '');
    }
    if ($to = Router::getQueryParam('to')) {
        $where[] = "`{$dateColumn}` <= :to_date";
        $params[':to_date'] = $to . (strlen($to) === 10 ? ' 23:59:59' : '');
    }

    foreach ($definition['filters'] as $filter) {
        $value = Router::getQueryParam($filter);
        if ($value === null || $value === '') {
            continue;
        }
        $where[] = "`{$filter}` = :filter_{$filter}";
        $params[":filter_{$filter}"] = $value;
    }

    $whereSql = $where ? 'WHERE ' . implode(' AND ', $where) : '';
    $columns = implode(', ', array_map(static fn ($col) => "`{$col}`", $definition['columns']));
    $sql = "SELECT {$columns} FROM `{$definition['table']}` {$whereSql} ORDER BY {$definition['order']}";

    if (!$forExport) {
        $sql .= ' LIMIT :limit OFFSET :offset';
        $params[':limit'] = (int) $pagination['limit'];
        $params[':offset'] = (int) $pagination['offset'];
    } else {
        $limit = min(50000, max(1, (int) (Router::getQueryParam('limit', 10000))));
        $sql .= " LIMIT {$limit}";
    }

    $countSql = "SELECT COUNT(*) FROM `{$definition['table']}` {$whereSql}";

    return [$sql, $countSql, $params];
}

function nexytalLogsFetchRows(array $definition, bool $forExport = false): array
{
    $db = getDb();
    $pagination = Router::getPagination();
    [$sql, $countSql, $params] = nexytalLogsBuildQuery($definition, $pagination, $forExport);

    $stmt = $db->prepare($sql);
    foreach ($params as $key => $value) {
        if ($key === ':limit' || $key === ':offset') {
            $stmt->bindValue($key, (int) $value, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $value);
        }
    }
    $stmt->execute();
    $rows = array_map('nexytalLogsRedactRow', $stmt->fetchAll(PDO::FETCH_ASSOC));

    $countParams = array_filter($params, static fn ($key) => !in_array($key, [':limit', ':offset'], true), ARRAY_FILTER_USE_KEY);
    $countStmt = $db->prepare($countSql);
    foreach ($countParams as $key => $value) {
        $countStmt->bindValue($key, $value);
    }
    $countStmt->execute();

    return [$rows, (int) $countStmt->fetchColumn(), $pagination];
}

function nexytalLogsDownloadCsv(array $definition, array $rows, string $type): void
{
    $handle = fopen('php://temp', 'r+');
    fputcsv($handle, $definition['columns'], ';');
    foreach ($rows as $row) {
        $line = [];
        foreach ($definition['columns'] as $column) {
            $line[] = $row[$column] ?? null;
        }
        fputcsv($handle, $line, ';');
    }
    rewind($handle);
    $content = stream_get_contents($handle) ?: '';
    fclose($handle);

    Response::downloadContent($content, $type . '_' . date('Ymd_His') . '.csv', 'text/csv; charset=utf-8');
}

function nexytalLogsDownloadJson(array $rows, string $type): void
{
    Response::downloadContent(
        json_encode($rows, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '[]',
        $type . '_' . date('Ymd_His') . '.json',
        'application/json; charset=utf-8'
    );
}

function nexytalSystemLogAddCandidate(array &$paths, ?string $path): void
{
    $path = trim((string) $path);
    if ($path === '' || strtolower($path) === 'syslog') {
        return;
    }

    $candidates = [$path];
    if (!preg_match('/^(?:[A-Za-z]:[\\\/]|\/)/', $path)) {
        $apiRoot = dirname(__DIR__, 2);
        $projectRoot = dirname(__DIR__, 3);
        $candidates = [
            $apiRoot . DIRECTORY_SEPARATOR . $path,
            $projectRoot . DIRECTORY_SEPARATOR . $path,
        ];
    }

    foreach ($candidates as $candidate) {
        $real = realpath($candidate);
        if ($real !== false && is_file($real) && is_readable($real)) {
            $paths[$real] = $real;
        }
    }
}

function nexytalSystemLogCandidates(): array
{
    $paths = [];
    $configured = defined('SYSTEM_LOG_PATHS') ? (string) SYSTEM_LOG_PATHS : '';
    foreach (array_filter(array_map('trim', explode(',', $configured))) as $path) {
        nexytalSystemLogAddCandidate($paths, $path);
    }

    nexytalSystemLogAddCandidate($paths, ini_get('error_log') ?: null);

    $apiRoot = dirname(__DIR__, 2);
    $projectRoot = dirname(__DIR__, 3);
    foreach ([
        $apiRoot . DIRECTORY_SEPARATOR . 'error_log',
        $projectRoot . DIRECTORY_SEPARATOR . 'error_log',
        $apiRoot . DIRECTORY_SEPARATOR . 'logs' . DIRECTORY_SEPARATOR . 'error.log',
        $projectRoot . DIRECTORY_SEPARATOR . 'logs' . DIRECTORY_SEPARATOR . 'error.log',
        $apiRoot . DIRECTORY_SEPARATOR . 'php_errors.log',
        $projectRoot . DIRECTORY_SEPARATOR . 'php_errors.log',
    ] as $candidate) {
        nexytalSystemLogAddCandidate($paths, $candidate);
    }

    $files = [];
    foreach (array_values($paths) as $path) {
        $files[] = [
            'key' => substr(hash('sha256', $path), 0, 16),
            'name' => basename($path),
            'size_bytes' => filesize($path) ?: 0,
            'modified_at' => date('Y-m-d H:i:s', filemtime($path) ?: time()),
            '_path' => $path,
        ];
    }

    usort($files, static fn ($a, $b) => strcmp($a['name'], $b['name']));
    return $files;
}

function nexytalSystemLogResolveFile(?string $key): ?array
{
    $files = nexytalSystemLogCandidates();
    if ($files === []) {
        return null;
    }

    if ($key !== null && $key !== '') {
        foreach ($files as $file) {
            if (hash_equals($file['key'], (string) $key)) {
                return $file;
            }
        }
    }

    return $files[0];
}

function nexytalSystemLogPublicFiles(?string $selectedKey = null): array
{
    return array_map(static function (array $file) use ($selectedKey) {
        return [
            'key' => $file['key'],
            'name' => $file['name'],
            'size_bytes' => $file['size_bytes'],
            'modified_at' => $file['modified_at'],
            'selected' => $selectedKey !== null && hash_equals($file['key'], $selectedKey),
        ];
    }, nexytalSystemLogCandidates());
}

function nexytalSystemLogLevel(string $line): string
{
    if (preg_match('/\b(fatal|critical)\b/i', $line)) {
        return 'critical';
    }
    if (preg_match('/\b(error|exception|parse error)\b/i', $line)) {
        return 'error';
    }
    if (preg_match('/\b(warning|warn)\b/i', $line)) {
        return 'warning';
    }
    return 'info';
}

function nexytalSystemLogTimestamp(string $line): ?string
{
    if (preg_match('/^\[([^\]]+)\]/', $line, $m)) {
        $ts = strtotime($m[1]);
        return $ts ? date('Y-m-d H:i:s', $ts) : null;
    }
    if (preg_match('/^(\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2})/', $line, $m)) {
        $ts = strtotime($m[1]);
        return $ts ? date('Y-m-d H:i:s', $ts) : null;
    }
    return null;
}

function nexytalSystemLogTailRows(string $path, int $lineLimit): array
{
    $maxBytes = defined('SYSTEM_LOG_TAIL_BYTES') ? max(4096, (int) SYSTEM_LOG_TAIL_BYTES) : 1048576;
    $size = filesize($path) ?: 0;
    $handle = fopen($path, 'rb');
    if (!$handle) {
        return [];
    }

    $start = max(0, $size - $maxBytes);
    if ($start > 0) {
        fseek($handle, $start);
        fgets($handle);
    }
    $content = stream_get_contents($handle) ?: '';
    fclose($handle);

    $lines = preg_split('/\r\n|\r|\n/', trim($content)) ?: [];
    $lines = array_slice(array_values(array_filter($lines, static fn ($line) => trim($line) !== '')), -$lineLimit);

    $rows = [];
    foreach ($lines as $idx => $line) {
        $rows[] = [
            'id' => (string) ($idx + 1),
            'file' => basename($path),
            'level' => nexytalSystemLogLevel($line),
            'created_at' => nexytalSystemLogTimestamp($line),
            'message' => function_exists('mb_substr') ? mb_substr($line, 0, 4000) : substr($line, 0, 4000),
        ];
    }

    return array_reverse($rows);
}
function registerLogsRoutes(Router $router): void
{
    $router->get('/api/admin/logs', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $definitions = nexytalLogsDefinitions();
        Response::success(array_map(static fn ($definition) => [
            'label' => $definition['label'],
            'table' => $definition['table'],
            'date_column' => $definition['date_column'],
            'site_scoped' => ($definition['site_column'] !== null) || !empty($definition['site_scope_sql']),
            'filters' => $definition['filters'],
        ], $definitions));
    });

    $router->get('/api/admin/logs/system', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $pagination = Router::getPagination();
        $limit = min(1000, max(1, (int) $pagination['limit']));
        $selected = nexytalSystemLogResolveFile(Router::getQueryParam('file'));

        if ($selected === null) {
            Response::json([
                'success' => true,
                'data' => [],
                'files' => [],
                'pagination' => [
                    'total' => 0,
                    'page' => 1,
                    'limit' => $limit,
                    'total_pages' => 0,
                ],
            ]);
            return;
        }

        $rows = nexytalSystemLogTailRows($selected['_path'], $limit);
        Response::json([
            'success' => true,
            'data' => $rows,
            'files' => nexytalSystemLogPublicFiles($selected['key']),
            'selected_file' => [
                'key' => $selected['key'],
                'name' => $selected['name'],
                'size_bytes' => $selected['size_bytes'],
                'modified_at' => $selected['modified_at'],
            ],
            'pagination' => [
                'total' => count($rows),
                'page' => 1,
                'limit' => $limit,
                'total_pages' => 1,
            ],
        ]);
    });

    $router->get('/api/admin/logs/system/download', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $selected = nexytalSystemLogResolveFile(Router::getQueryParam('file'));
        if ($selected === null) {
            Response::notFound('System log not found');
            return;
        }

        Response::downloadFile($selected['_path'], 'system_' . $selected['name'], 'text/plain; charset=utf-8');
    });
    $router->get('/api/admin/logs/{type}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $definition = nexytalLogsGetDefinition($params['type']);
        if ($definition === null) {
            Response::notFound('Unknown log type');
            return;
        }

        [$rows, $total, $pagination] = nexytalLogsFetchRows($definition);
        Response::paginated($rows, $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/logs/{type}/export', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $definition = nexytalLogsGetDefinition($params['type']);
        if ($definition === null) {
            Response::notFound('Unknown log type');
            return;
        }

        [$rows] = nexytalLogsFetchRows($definition, true);
        $format = strtolower((string) Router::getQueryParam('format', 'csv'));
        if ($format === 'json') {
            nexytalLogsDownloadJson($rows, $params['type']);
            return;
        }
        if ($format !== 'csv') {
            Response::badRequest('Unsupported export format');
            return;
        }
        nexytalLogsDownloadCsv($definition, $rows, $params['type']);
    });
}