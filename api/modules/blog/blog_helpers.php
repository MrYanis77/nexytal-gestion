<?php
/**
 * blog_helpers.php — Bindings PDO, détection colonnes/tables (schéma Ionos production).
 */

function blogBindNullableInt(PDOStatement $stmt, string $param, ?int $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value, PDO::PARAM_INT);
}

function blogNormalizeOptionalInt(mixed $value): ?int
{
    if ($value === null || $value === '' || $value === false) {
        return null;
    }

    $int = (int) $value;
    return $int > 0 ? $int : null;
}

function blogBindNullableString(PDOStatement $stmt, string $param, ?string $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value, PDO::PARAM_STR);
}

/** @return list<string> */
function blogTableColumns(PDO $db, string $table): array
{
    static $cache = [];

    if (!isset($cache[$table])) {
        $stmt = $db->prepare(
            'SELECT COLUMN_NAME FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = :table
             ORDER BY ORDINAL_POSITION'
        );
        $stmt->execute([':table' => $table]);
        $cache[$table] = array_column($stmt->fetchAll(PDO::FETCH_ASSOC), 'COLUMN_NAME');
    }

    return $cache[$table];
}

function blogHasColumn(PDO $db, string $table, string $column): bool
{
    return in_array($column, blogTableColumns($db, $table), true);
}

function blogHasTable(PDO $db, string $table): bool
{
    static $tables = null;

    if ($tables === null) {
        $stmt = $db->query(
            'SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE()'
        );
        $tables = array_column($stmt->fetchAll(PDO::FETCH_ASSOC), 'TABLE_NAME');
    }

    return in_array($table, $tables, true);
}

/**
 * INSERT dynamique : ne garde que les colonnes présentes en BDD.
 * @param array<string, mixed> $columns column => value
 */
function blogInsert(PDO $db, string $table, array $columns): int
{
    $available = blogTableColumns($db, $table);
    $filtered = [];

    foreach ($columns as $col => $value) {
        if (in_array($col, $available, true)) {
            $filtered[$col] = $value;
        }
    }

    if ($filtered === []) {
        throw new InvalidArgumentException("No insertable columns for {$table}");
    }

    $names = array_keys($filtered);
    $placeholders = array_map(static fn (string $c) => ':' . $c, $names);
    $sql = 'INSERT INTO `' . str_replace('`', '', $table) . '` (`'
        . implode('`, `', $names) . '`) VALUES (' . implode(', ', $placeholders) . ')';

    $stmt = $db->prepare($sql);
    foreach ($filtered as $col => $value) {
        $param = ':' . $col;
        if ($value === null) {
            $stmt->bindValue($param, null, PDO::PARAM_NULL);
        } elseif (is_int($value)) {
            blogBindNullableInt($stmt, $param, $value);
        } else {
            $stmt->bindValue($param, $value);
        }
    }
    $stmt->execute();

    return (int) $db->lastInsertId();
}

/**
 * UPDATE dynamique : $fields ne contient que les colonnes à mettre à jour (déjà filtrées).
 * @param array<string, mixed> $fields
 */
function blogUpdate(PDO $db, string $table, array $fields, string $whereSql, array $whereBind): void
{
    $available = blogTableColumns($db, $table);
    $filtered = [];

    foreach ($fields as $col => $value) {
        if (in_array($col, $available, true)) {
            $filtered[$col] = $value;
        }
    }

    if ($filtered === []) {
        return;
    }

    $sets = [];
    foreach (array_keys($filtered) as $col) {
        $sets[] = "`{$col}` = :{$col}";
    }

    $sql = 'UPDATE `' . str_replace('`', '', $table) . '` SET ' . implode(', ', $sets) . ' ' . $whereSql;
    $stmt = $db->prepare($sql);

    foreach ($filtered as $col => $value) {
        $param = ':' . $col;
        if ($value === null) {
            $stmt->bindValue($param, null, PDO::PARAM_NULL);
        } elseif (is_int($value)) {
            blogBindNullableInt($stmt, $param, $value);
        } else {
            $stmt->bindValue($param, $value);
        }
    }

    foreach ($whereBind as $k => $v) {
        $stmt->bindValue($k, $v);
    }

    $stmt->execute();
}

/** SELECT blog_authors — colonnes selon schéma réel */
function blogAuthorsSelectSql(PDO $db): string
{
    $cols = ['id', 'site_id', 'first_name', 'last_name', 'email', 'slug', 'bio', 'is_active', 'created_at'];
    if (blogHasColumn($db, 'blog_authors', 'avatar_url')) {
        $cols[] = 'avatar_url';
    }
    if (blogHasColumn($db, 'blog_authors', 'updated_at')) {
        $cols[] = 'updated_at';
    }

    return implode(', ', $cols);
}

/** SELECT blog_categories — colonnes selon schéma réel */
function blogCategoriesSelectSql(PDO $db): string
{
    $cols = ['id', 'site_id', 'name', 'slug', 'description', 'is_active', 'sort_order', 'created_at'];
    if (blogHasColumn($db, 'blog_categories', 'color')) {
        $cols[] = 'color';
    }
    if (blogHasColumn($db, 'blog_categories', 'updated_at')) {
        $cols[] = 'updated_at';
    }

    return implode(', ', $cols);
}
