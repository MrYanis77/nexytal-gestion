<?php
/**
 * Diagnostic catalogue formation — à exécuter une fois sur Ionos puis supprimer.
 * URL : https://connexion.nexytal.com/run_formation_diag.php?key=VOTRE_INSERT_TEST_KEY
 */
declare(strict_types=1);

require_once __DIR__ . '/api/config/config.php';
require_once __DIR__ . '/api/config/database.php';
require_once __DIR__ . '/api/modules/formation/formation_schema.php';

header('Content-Type: application/json; charset=utf-8');

$key = $_GET['key'] ?? '';
$expected = defined('INSERT_TEST_KEY') ? INSERT_TEST_KEY : env('INSERT_TEST_KEY', '');
if ($expected === '' || !hash_equals((string) $expected, (string) $key)) {
    http_response_code(403);
    echo json_encode(['success' => false, 'error' => 'Forbidden']);
    exit;
}

$siteId = 1;
$db = getDb();
$report = [
    'uses_courses_table' => formationUsesCoursesTable($db),
    'formation_courses_exists' => formationTableExists($db, 'formation_courses'),
    'formations_legacy_exists' => formationTableExists($db, 'formations'),
    'category_label_col' => formationCategoryLabelColumn($db),
    'steps' => [],
];

$run = static function (string $label, callable $fn) use (&$report): void {
    try {
        $result = $fn();
        $report['steps'][] = ['step' => $label, 'ok' => true, 'detail' => $result];
    } catch (Throwable $e) {
        $report['steps'][] = ['step' => $label, 'ok' => false, 'error' => $e->getMessage()];
    }
};

if (formationTableExists($db, 'formation_courses')) {
    $run('count formation_courses site 1', function () use ($db, $siteId) {
        $n = (int) $db->query("SELECT COUNT(*) FROM formation_courses WHERE site_id = {$siteId}")->fetchColumn();
        return "rows={$n}";
    });

    $run('list SQL formation_courses', function () use ($db, $siteId) {
        $cat = formationCategoryLabelSelect($db, 'cat');
        $order = formationCourseOrderBy($db, 'c');
        $sql = "SELECT c.id, c.slug, c.title, {$cat}
                FROM formation_courses c
                LEFT JOIN formation_categories cat ON c.category_id = cat.id
                WHERE c.site_id = :site_id
                ORDER BY {$order}
                LIMIT 3";
        $stmt = $db->prepare($sql);
        $stmt->execute([':site_id' => $siteId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    });
}

if (formationTableExists($db, 'formations')) {
    $run('count formations legacy site 1', function () use ($db, $siteId) {
        $n = (int) $db->query("SELECT COUNT(*) FROM formations WHERE site_id = {$siteId}")->fetchColumn();
        return "rows={$n}";
    });
}

$run('formationListCourses()', function () use ($db, $siteId) {
    [$rows, $total] = formationListCourses($db, ['page' => 1, 'limit' => 5, 'offset' => 0], $siteId);
    return ['total' => $total, 'sample_ids' => array_column(array_slice($rows, 0, 3), 'id')];
});

$failed = array_values(array_filter($report['steps'], static fn ($s) => !$s['ok']));
$report['success'] = $failed === [];
if ($failed !== []) {
    http_response_code(500);
}

echo json_encode($report, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
