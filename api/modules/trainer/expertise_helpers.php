<?php
/**
 * Helpers catalogue expertises (trainers site 5)
 */

function expertiseTableColumns(PDO $db): array
{
    static $cache = null;
    if ($cache !== null) {
        return $cache;
    }

    $stmt = $db->query('SHOW COLUMNS FROM expertises');
    $cache = array_column($stmt->fetchAll(PDO::FETCH_ASSOC), 'Field');

    return $cache;
}

function expertiseHasColumn(PDO $db, string $column): bool
{
    return in_array($column, expertiseTableColumns($db), true);
}

function expertiseOrderByClause(PDO $db, string $alias = 'e'): string
{
    if (expertiseHasColumn($db, 'sort_order')) {
        return "{$alias}.sort_order ASC, {$alias}.label ASC";
    }

    return "{$alias}.label ASC";
}

function expertiseSiteIdFromRequest(): ?int
{
    if (isset($_GET['site_id']) && (int) $_GET['site_id'] > 0) {
        return (int) $_GET['site_id'];
    }

    $header = $_SERVER['HTTP_X_SITE_ID'] ?? null;
    if ($header !== null && (int) $header > 0) {
        return (int) $header;
    }

    return null;
}

function expertiseJsonColumns(): array
{
    return ['skills_json', 'certifications_json', 'faq_json'];
}

function expertiseEditableFields(): array
{
    return [
        'site_id', 'slug', 'label', 'name', 'subtitle', 'description', 'icon',
        'sort_order', 'is_active', 'skills_json', 'certifications_json', 'faq_json',
    ];
}

function expertiseEncodeJsonValue(mixed $value): ?string
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_string($value)) {
        $trim = trim($value);
        if ($trim === '') {
            return null;
        }
        json_decode($trim);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $trim;
        }
    }
    if (is_array($value)) {
        if ($value === []) {
            return null;
        }
        return json_encode(array_values($value), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    }

    return null;
}

function expertiseRowToApi(array $row): array
{
    foreach (expertiseJsonColumns() as $col) {
        if (!array_key_exists($col, $row)) {
            $row[$col] = [];
            continue;
        }
        if ($row[$col] === null) {
            $row[$col] = [];
            continue;
        }
        if (is_string($row[$col])) {
            $decoded = json_decode($row[$col], true);
            $row[$col] = is_array($decoded) ? $decoded : [];
        }
    }

    $row['is_active'] = !array_key_exists('is_active', $row) || (int) $row['is_active'] === 1;
    if (array_key_exists('site_id', $row) && $row['site_id'] !== null) {
        $row['site_id'] = (int) $row['site_id'];
    }

    return $row;
}

function expertiseDataFromRequest(PDO $db, array $data, ?array $old = null): array
{
    $out = [];

    if (expertiseHasColumn($db, 'site_id')) {
        if (array_key_exists('site_id', $data)) {
            $out['site_id'] = $data['site_id'] === '' || $data['site_id'] === null ? null : (int) $data['site_id'];
        } elseif ($old === null) {
            $out['site_id'] = expertiseSiteIdFromRequest() ?? 5;
        }
    }

    foreach (['slug', 'label', 'name', 'subtitle', 'description', 'icon'] as $field) {
        if (!expertiseHasColumn($db, $field)) {
            continue;
        }
        if (array_key_exists($field, $data)) {
            $out[$field] = $data[$field] === '' ? null : trim((string) $data[$field]);
        }
    }

    if (isset($out['label']) && empty($out['slug']) && ($old === null || !array_key_exists('slug', $data))) {
        $out['slug'] = Validator::slugify($out['label']);
    }

    if (expertiseHasColumn($db, 'sort_order')) {
        if (array_key_exists('sort_order', $data)) {
            $out['sort_order'] = (int) $data['sort_order'];
        } elseif ($old === null) {
            $out['sort_order'] = 0;
        }
    }

    if (expertiseHasColumn($db, 'is_active')) {
        if (array_key_exists('is_active', $data)) {
            $out['is_active'] = !empty($data['is_active']) ? 1 : 0;
        } elseif ($old === null) {
            $out['is_active'] = 1;
        }
    }

    foreach (expertiseJsonColumns() as $col) {
        if (!expertiseHasColumn($db, $col)) {
            continue;
        }
        if (array_key_exists($col, $data)) {
            $out[$col] = expertiseEncodeJsonValue($data[$col]);
        }
    }

    return $out;
}

function expertiseFetchById(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM expertises WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();

    return $row ? expertiseRowToApi($row) : null;
}

function expertiseFetchBySlug(PDO $db, string $slug, ?int $siteId = null): ?array
{
    $sql = 'SELECT * FROM expertises WHERE slug = :slug';
    $bind = [':slug' => $slug];
    if (expertiseHasColumn($db, 'is_active')) {
        $sql .= ' AND is_active = 1';
    }
    if ($siteId !== null && expertiseHasColumn($db, 'site_id')) {
        $sql .= ' AND (site_id IS NULL OR site_id = :site_id)';
        $bind[':site_id'] = $siteId;
    }
    $sql .= ' LIMIT 1';

    $stmt = $db->prepare($sql);
    $stmt->execute($bind);
    $row = $stmt->fetch();

    return $row ? expertiseRowToApi($row) : null;
}

function expertiseListWhereClause(PDO $db, ?int $siteId, bool $activeOnly): array
{
    $where = ['1=1'];
    $bind = [];

    if ($siteId !== null && $siteId > 0 && expertiseHasColumn($db, 'site_id')) {
        $where[] = '(e.site_id IS NULL OR e.site_id = :site_id)';
        $bind[':site_id'] = $siteId;
    }

    if ($activeOnly && expertiseHasColumn($db, 'is_active')) {
        $where[] = 'e.is_active = 1';
    }

    return [implode(' AND ', $where), $bind];
}

function expertisePublicSelectColumns(PDO $db): string
{
    $cols = ['e.id', 'e.slug', 'e.label', 'e.name'];
    foreach (['site_id', 'subtitle', 'description', 'icon', 'sort_order', 'skills_json', 'certifications_json', 'faq_json'] as $column) {
        if (expertiseHasColumn($db, $column)) {
            $cols[] = "e.{$column}";
        }
    }

    return implode(', ', $cols);
}

function expertiseFetchTrainersForCatalog(PDO $db, int $expertiseId, int $siteId, int $limit = 12): array
{
    $stmt = $db->prepare(
        'SELECT t.id, t.slug, t.first_name, t.last_name, t.title, t.avatar_url, t.rating_avg, t.reviews_count
         FROM trainers t
         INNER JOIN trainer_expertise_links tel ON tel.trainer_id = t.id AND tel.expertise_id = :eid
         WHERE t.site_id = :site_id
           AND t.status = \'active\'
           AND t.validated_at IS NOT NULL
           AND t.deleted_at IS NULL
         ORDER BY t.is_featured DESC, t.rating_avg DESC, t.last_name ASC
         LIMIT ' . (int) $limit
    );
    $stmt->execute([':eid' => $expertiseId, ':site_id' => $siteId]);

    return $stmt->fetchAll();
}

function expertiseResolveIds(PDO $db, array $items, ?int $siteId = null): array
{
    $ids = [];
    foreach ($items as $item) {
        if (is_numeric($item)) {
            $id = (int) $item;
            if ($id > 0) {
                $ids[] = $id;
            }
            continue;
        }

        $raw = trim((string) $item);
        if ($raw === '') {
            continue;
        }

        $slug = Validator::slugify($raw);
        $sql = 'SELECT id FROM expertises WHERE slug = :slug';
        $bind = [':slug' => $slug];
        if (expertiseHasColumn($db, 'is_active')) {
            $sql .= ' AND is_active = 1';
        }
        if ($siteId !== null && $siteId > 0 && expertiseHasColumn($db, 'site_id')) {
            $sql .= ' AND (site_id IS NULL OR site_id = :site_id)';
            $bind[':site_id'] = $siteId;
        }
        $sql .= ' LIMIT 1';

        $stmt = $db->prepare($sql);
        $stmt->execute($bind);
        $row = $stmt->fetch();
        if ($row) {
            $ids[] = (int) $row['id'];
        }
    }

    return array_values(array_unique($ids));
}
