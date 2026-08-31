<?php
/**
 * site_scope.php — Filtrage par site (recrutement IT = 2, médical = 3).
 */

function recrutementRequireSiteIdFromRequest(): int
{
    $raw = $_GET['site_id'] ?? $_SERVER['HTTP_X_SITE_ID'] ?? null;

    if ($raw === null || $raw === '') {
        Response::badRequest('site_id est requis (paramètre ?site_id= ou header X-Site-Id)');
        exit;
    }

    $siteId = (int) $raw;
    if ($siteId <= 0) {
        Response::badRequest('site_id invalide');
        exit;
    }

    Middleware::requireSiteAccess($siteId);

    return $siteId;
}

function recrutementSqlName(string $name): ?string
{
    $name = str_replace('`', '', trim($name));

    return preg_match('/^[A-Za-z0-9_]+$/', $name) ? $name : null;
}

function recrutementTableHasColumn(PDO $db, string $table, string $column, bool $refresh = false): bool
{
    static $cache = [];

    $key = $table . '.' . $column;
    if (!$refresh && isset($cache[$key])) {
        return $cache[$key];
    }

    $safeTable = recrutementSqlName($table);
    $safeColumn = recrutementSqlName($column);
    if ($safeTable === null || $safeColumn === null) {
        $cache[$key] = false;
        return false;
    }

    try {
        $stmt = $db->prepare(
            'SELECT COUNT(*) FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table AND COLUMN_NAME = :col'
        );
        $stmt->bindValue(':table', $safeTable, PDO::PARAM_STR);
        $stmt->bindValue(':col', $safeColumn, PDO::PARAM_STR);
        $stmt->execute();
        $cache[$key] = ((int) $stmt->fetchColumn()) > 0;
    } catch (\Throwable $e) {
        try {
            // MariaDB / PDO natif : pas de placeholder dans SHOW COLUMNS … LIKE
            $stmt = $db->query(
                'SHOW COLUMNS FROM `' . $safeTable . '` LIKE ' . $db->quote($safeColumn)
            );
            $cache[$key] = (bool) $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (\Throwable $e2) {
            $cache[$key] = false;
        }
    }

    return $cache[$key];
}

function recrutementBindNullableInt(PDOStatement $stmt, string $param, ?int $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value, PDO::PARAM_INT);
}

function recrutementNormalizeOptionalInt(mixed $value): ?int
{
    if ($value === null || $value === '' || $value === false) {
        return null;
    }

    $int = (int) $value;
    return $int > 0 ? $int : null;
}

function recrutementResolveSiteIdFromBody(array $data, array $admin): ?int
{
    $raw = $data['site_id'] ?? $_SERVER['HTTP_X_SITE_ID'] ?? null;
    if ($raw === null || $raw === '') {
        return null;
    }

    $siteId = (int) $raw;
    if ($siteId <= 0) {
        return null;
    }

    if ($admin['role'] !== 'superadmin') {
        Middleware::requireSiteAccess($siteId);
    }

    return $siteId;
}

/** Lie un recruteur à un site (inscription ou validation admin). */
function recrutementLinkRecruteurToSite(PDO $db, int $recruteurId, int $siteId, ?int $grantedBy = null): void
{
    $stmt = $db->prepare('SELECT site_code FROM core_sites WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $siteId]);
    $code = $stmt->fetchColumn();
    if (!$code) {
        return;
    }

    $db->prepare(
        'INSERT INTO recruteur_sites (recruteur_id, site, granted_by, granted_at)
         VALUES (:rid, :site, :gby, NOW())
         ON DUPLICATE KEY UPDATE granted_at = granted_at'
    )->execute([
        ':rid' => $recruteurId,
        ':site' => $code,
        ':gby' => $grantedBy,
    ]);
}

/** Filtre SQL : recruteur lié au site via recruteur_sites ou offres publiées. */
function recrutementRecruteurMatchesSiteSql(string $recruteurAlias = 'r'): string
{
    return "(
        EXISTS (
            SELECT 1 FROM recruteur_sites rs_f
            WHERE rs_f.recruteur_id = {$recruteurAlias}.id
            AND rs_f.site = (SELECT site_code FROM core_sites WHERE id = :filter_site_id)
        )
        OR EXISTS (
            SELECT 1 FROM offres_emploi o_f
            WHERE o_f.recruteur_id = {$recruteurAlias}.id AND o_f.site_id = :filter_site_id2
        )
    )";
}
