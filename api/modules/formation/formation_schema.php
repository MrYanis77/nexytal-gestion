<?php
/**
 * formation_schema.php — Schéma formation (formation_courses + tables liées)
 */

require_once __DIR__ . '/../recrutement/site_scope.php';

const FORMATION_EXTRA_JSON_KEYS = [
    'type', 'hero_image_url', 'card_image_url', 'presentation_image',
    'methodology', 'cta_button_label', 'cta_button_url', 'cta_secondary_label', 'cta_secondary_url',
    'ctaFinal', 'avantages_visiplus', 'financement', 'modalites_catalogue', 'published_at',
];

const FORMATION_INFO_BLOCK_TYPES = ['modalites', 'prerequis', 'pour_qui', 'evaluation_etapes'];

function formationTableExists(PDO $db, string $table): bool
{
    static $tables = [];
    if (!isset($tables[$table])) {
        $safe = recrutementSqlName($table);
        if ($safe === null) {
            $tables[$table] = false;
        } else {
            // MariaDB / PDO natif : pas de placeholder dans SHOW TABLES LIKE
            $stmt = $db->query('SHOW TABLES LIKE ' . $db->quote($safe));
            $tables[$table] = (bool) $stmt->fetchColumn();
        }
    }

    return $tables[$table];
}

function formationCourseHasColumn(PDO $db, string $column, bool $refresh = false): bool
{
    return recrutementTableHasColumn($db, 'formation_courses', $column, $refresh);
}

function formationUsesCoursesTable(PDO $db): bool
{
    static $cache = null;
    if ($cache !== null) {
        return $cache;
    }

    // Schéma Ionos : formation_courses prime sur l'ancienne table formations (legacy).
    if (formationTableExists($db, 'formation_courses')
        && (formationCourseHasColumn($db, 'title') || formationCourseHasColumn($db, 'hero_title'))) {
        $cache = true;
        return true;
    }

    if (formationTableExists($db, 'formations') && recrutementTableHasColumn($db, 'formations', 'hero_title')) {
        $cache = false;
        return false;
    }

    $cache = false;
    return false;
}

function formationChildForeignKey(PDO $db, string $table): string
{
    if (recrutementTableHasColumn($db, $table, 'course_id')) {
        return 'course_id';
    }
    if (recrutementTableHasColumn($db, $table, 'formation_id')) {
        return 'formation_id';
    }

    return formationUsesCoursesTable($db) ? 'course_id' : 'formation_id';
}

function formationCourseOrderBy(PDO $db, string $alias = 'c'): string
{
    $parts = [];
    if (formationCourseHasColumn($db, 'sort_order')) {
        $parts[] = "{$alias}.sort_order ASC";
    }
    if (formationCourseHasColumn($db, 'created_at')) {
        $parts[] = "{$alias}.created_at DESC";
    } elseif (formationCourseHasColumn($db, 'published_at')) {
        $parts[] = "{$alias}.published_at DESC";
    } else {
        $parts[] = "{$alias}.id DESC";
    }

    return implode(', ', $parts);
}

function formationLegacyOrderBy(PDO $db, string $alias = 'f'): string
{
    $parts = [];
    if (recrutementTableHasColumn($db, 'formations', 'sort_order')) {
        $parts[] = "{$alias}.sort_order ASC";
    }
    if (recrutementTableHasColumn($db, 'formations', 'created_at')) {
        $parts[] = "{$alias}.created_at DESC";
    } elseif (recrutementTableHasColumn($db, 'formations', 'published_at')) {
        $parts[] = "{$alias}.published_at DESC";
    } else {
        $parts[] = "{$alias}.id DESC";
    }

    return implode(', ', $parts);
}

/** Colonnes SELECT pour la liste publique (compat schémas Ionos / bdd.sql). */
function formationPublicCourseSelectColumns(PDO $db): string
{
    $parts = ['c.id', 'c.slug'];

    if (formationCourseHasColumn($db, 'title')) {
        $parts[] = 'c.title';
    } elseif (formationCourseHasColumn($db, 'hero_title')) {
        $parts[] = 'c.hero_title AS title';
    }

    if (formationCourseHasColumn($db, 'subtitle')) {
        $parts[] = 'c.subtitle';
    } elseif (formationCourseHasColumn($db, 'hero_subtitle')) {
        $parts[] = 'c.hero_subtitle AS subtitle';
    }

    if (formationCourseHasColumn($db, 'duration')) {
        $parts[] = 'c.duration';
    } elseif (formationCourseHasColumn($db, 'programme_duration_label')) {
        $parts[] = 'c.programme_duration_label AS duration';
    }

    if (formationCourseHasColumn($db, 'price')) {
        $parts[] = 'c.price';
    }
    if (formationCourseHasColumn($db, 'is_cpf_eligible')) {
        $parts[] = 'c.is_cpf_eligible';
    }
    if (formationCourseHasColumn($db, 'is_alternance')) {
        $parts[] = 'c.is_alternance';
    }

    return implode(', ', $parts);
}

function formationEnsureCourseColumn(PDO $db, string $column, string $definition): void
{
    // No runtime schema changes: production DB structure is managed outside API requests.
}

function formationPaginatedLimitOffset(array $pagination): string
{
    $limit = max(1, (int) ($pagination['limit'] ?? 20));
    $offset = max(0, (int) ($pagination['offset'] ?? 0));

    return " LIMIT {$limit} OFFSET {$offset}";
}

/** Vérifie la disponibilité du schéma formation sans modifier la base. */
function formationEnsureSchema(PDO $db, bool $force = false): bool
{
    // No runtime schema changes: keep API writes aligned with the existing database.
    return formationUsesCoursesTable($db);
}

function formationCategoryLabelColumn(PDO $db): string
{
    return recrutementTableHasColumn($db, 'formation_categories', 'label') ? 'label' : 'name';
}

/** Expression SQL sûre pour le libellé catégorie (schémas label / name / mixte). */
function formationCategoryLabelSelect(PDO $db, string $alias = 'cat'): string
{
    $hasLabel = recrutementTableHasColumn($db, 'formation_categories', 'label');
    $hasName = recrutementTableHasColumn($db, 'formation_categories', 'name');
    if ($hasLabel && $hasName) {
        return "COALESCE({$alias}.label, {$alias}.name) AS category_label";
    }

    $col = formationCategoryLabelColumn($db);

    return "{$alias}.{$col} AS category_label";
}

function formationModuleForeignKey(PDO $db): string
{
    return formationChildForeignKey($db, 'formation_modules');
}

function formationDecodeExtraJson(?string $json): array
{
    if ($json === null || $json === '') {
        return [];
    }
    $decoded = json_decode($json, true);
    return is_array($decoded) ? $decoded : [];
}

function formationMergeExtraIntoCourse(array $row): array
{
    $extra = formationDecodeExtraJson($row['extra_json'] ?? null);
    foreach (FORMATION_EXTRA_JSON_KEYS as $key) {
        if (array_key_exists($key, $extra)) {
            $row[$key] = $extra[$key];
        }
    }
    return $row;
}

function formationBuildExtraJsonFromApi(array $data, ?array $existingExtra = null): ?string
{
    $extra = $existingExtra ?? [];

    if (!empty($data['cta_button_label']) || !empty($data['cta_button_url'])) {
        $extra['ctaFinal'] = [
            'boutons' => [[
                'label' => $data['cta_button_label'] ?? 'Contact',
                'url' => $data['cta_button_url'] ?? '/contact',
            ]],
        ];
    } elseif (isset($data['ctaFinal']) && is_array($data['ctaFinal'])) {
        $extra['ctaFinal'] = $data['ctaFinal'];
    }

    foreach (FORMATION_EXTRA_JSON_KEYS as $key) {
        if ($key === 'ctaFinal') {
            continue;
        }
        if (array_key_exists($key, $data)) {
            $extra[$key] = $data[$key];
        }
    }

    if (isset($data['extra_json']) && is_array($data['extra_json'])) {
        $extra = array_merge($extra, $data['extra_json']);
    }

    if ($extra === []) {
        return null;
    }

    return json_encode($extra, JSON_UNESCAPED_UNICODE);
}

function formationOfficialCertFromApi(array $data): array
{
    $oc = $data['official_certification'] ?? null;
    if (is_array($oc) && !empty($oc['code'])) {
        return [
            'rncp_repertoire' => $oc['repertoire'] ?? 'RNCP',
            'rncp_code' => $oc['code'],
            'rncp_title' => $oc['official_title'] ?? ($data['hero_title'] ?? ''),
            'rncp_level' => $oc['level'] ?? null,
            'rncp_url' => $oc['france_competences_url'] ?? null,
        ];
    }

    return [
        'rncp_repertoire' => $data['rncp_repertoire'] ?? null,
        'rncp_code' => $data['rncp_code'] ?? null,
        'rncp_title' => $data['rncp_title'] ?? null,
        'rncp_level' => $data['rncp_level'] ?? null,
        'rncp_url' => $data['rncp_url'] ?? null,
    ];
}

function formationCtaFromExtra(array $extra): array
{
    $ctaFinal = $extra['ctaFinal'] ?? null;
    if (is_array($ctaFinal) && !empty($ctaFinal['boutons'][0])) {
        $btn = $ctaFinal['boutons'][0];
        return [
            'cta_button_label' => $btn['label'] ?? null,
            'cta_button_url' => $btn['url'] ?? '/contact',
        ];
    }

    return [
        'cta_button_label' => $extra['cta_button_label'] ?? null,
        'cta_button_url' => $extra['cta_button_url'] ?? null,
    ];
}

function formationCourseRowToApi(array $row, PDO $db): array
{
    if (!formationUsesCoursesTable($db)) {
        if (isset($row['modalites_catalogue']) && is_string($row['modalites_catalogue'])) {
            $row['modalites_catalogue'] = json_decode($row['modalites_catalogue'], true);
        }
        return $row;
    }

    $row = formationMergeExtraIntoCourse($row);
    $cta = formationCtaFromExtra($row);

    $oc = null;
    if (!empty($row['rncp_code'])) {
        $oc = [
            'repertoire' => $row['rncp_repertoire'] ?? 'RNCP',
            'code' => $row['rncp_code'],
            'official_title' => $row['rncp_title'] ?? ($row['title'] ?? ''),
            'level' => $row['rncp_level'] ?? null,
            'france_competences_url' => $row['rncp_url'] ?? 'https://www.francecompetences.fr',
            'show_on_certification_page' => 1,
        ];
    }

    $presentationImage = $row['presentation_image_url']
        ?? $row['presentation_image']
        ?? null;

    return [
        'id' => $row['id'],
        'site_id' => $row['site_id'] ?? 1,
        'slug' => $row['slug'],
        'course_type' => $row['course_type'] ?? ($row['type'] ?? 'diplomante'),
        'type' => $row['course_type'] ?? ($row['type'] ?? 'diplomante'),
        'category_id' => $row['category_id'] ?? null,
        'category_label' => $row['category_label'] ?? null,
        'status' => $row['status'] ?? 'draft',
        'published_at' => $row['published_at'] ?? null,
        'sort_order' => (int) ($row['sort_order'] ?? 0),
        'hero_title' => $row['title'] ?? ($row['hero_title'] ?? ''),
        'hero_subtitle' => $row['subtitle'] ?? null,
        'hero_video_url' => $row['video_url'] ?? null,
        'hero_image_url' => $row['hero_image_url'] ?? null,
        'card_image_url' => $row['card_image_url'] ?? null,
        'presentation_image' => $presentationImage,
        'presentation_image_url' => $presentationImage,
        'seo_title' => $row['meta_title'] ?? null,
        'seo_description' => $row['meta_description'] ?? null,
        'presentation_title' => $row['presentation_title'] ?? 'Le métier',
        'presentation_content' => $row['presentation_text'] ?? null,
        'programme_duration_label' => $row['duration'] ?? null,
        'programme_duration_total' => $row['programme_duration_total'] ?? null,
        'modality_label' => $row['modality_label'] ?? null,
        'methodology' => $row['methodology'] ?? null,
        'certification_label' => $row['certification_label'] ?? null,
        'reference_code' => $row['reference_code'] ?? ($row['internal_reference'] ?? null),
        'internal_reference' => $row['reference_code'] ?? ($row['internal_reference'] ?? null),
        'evaluation_title' => $row['evaluation_title'] ?? null,
        'evaluation_description' => $row['evaluation_description'] ?? null,
        'debouches_title' => $row['debouches_title'] ?? null,
        'debouches_subtitle' => $row['debouches_subtitle'] ?? null,
        'debouches_sectors' => $row['debouches_sectors'] ?? null,
        'info_modalities_title' => $row['info_modalities_title'] ?? 'Modalités pratiques',
        'info_prerequisites_title' => $row['info_prerequisites_title'] ?? 'Prérequis',
        'cta_title' => $row['cta_title'] ?? null,
        'cta_subtitle' => $row['cta_subtitle'] ?? null,
        'cta_button_label' => $cta['cta_button_label'],
        'cta_button_url' => $cta['cta_button_url'],
        'cta_secondary_label' => $row['cta_secondary_label'] ?? null,
        'cta_secondary_url' => $row['cta_secondary_url'] ?? null,
        'price' => $row['price'] ?? null,
        'is_cpf_eligible' => (int) ($row['is_cpf_eligible'] ?? 0),
        'is_alternance' => (int) ($row['is_alternance'] ?? 0),
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
        'official_certification' => $oc,
        'extra_json' => formationDecodeExtraJson($row['extra_json'] ?? null),
        'modules' => $row['modules'] ?? [],
        'stats' => $row['stats'] ?? [],
        'objectives' => $row['objectives'] ?? [],
        'job_outcomes' => $row['job_outcomes'] ?? [],
        'skills' => $row['skills'] ?? [],
        'info_blocks' => $row['info_blocks'] ?? [],
        'list_items' => $row['list_items'] ?? [],
    ];
}

function formationListCourses(PDO $db, array $pagination, int $siteId, ?string $status = null, ?string $type = null): array
{
    $useCourses = formationUsesCoursesTable($db);

    try {
        return formationListCoursesFromSource($db, $pagination, $siteId, $status, $type, $useCourses);
    } catch (\Throwable $e) {
        if ($useCourses && formationTableExists($db, 'formations')) {
            error_log('formationListCourses fallback legacy: ' . $e->getMessage());
            return formationListCoursesFromSource($db, $pagination, $siteId, $status, $type, false);
        }
        throw $e;
    }
}

function formationListCoursesFromSource(
    PDO $db,
    array $pagination,
    int $siteId,
    ?string $status,
    ?string $type,
    bool $useCourses,
): array {
    $where = ['1=1'];
    $params = [];
    $alias = $useCourses ? 'c' : 'f';

    if ($useCourses) {
        $where[] = "{$alias}.site_id = :site_id";
        $params[':site_id'] = $siteId;
        if ($status) {
            $where[] = "{$alias}.status = :status";
            $params[':status'] = $status;
        }
        if ($type && formationCourseHasColumn($db, 'course_type')) {
            $where[] = "{$alias}.course_type = :course_type";
            $params[':course_type'] = $type;
        } elseif ($type) {
            $where[] = "JSON_UNQUOTE(JSON_EXTRACT({$alias}.extra_json, '$.type')) = :course_type";
            $params[':course_type'] = $type;
        }
    } else {
        if (recrutementTableHasColumn($db, 'formations', 'site_id')) {
            $where[] = "{$alias}.site_id = :site_id";
            $params[':site_id'] = $siteId;
        }
        if ($status) {
            $where[] = "{$alias}.status = :status";
            $params[':status'] = $status;
        }
        if ($type) {
            $where[] = "{$alias}.type = :type";
            $params[':type'] = $type;
        }
    }

    $whereClause = 'WHERE ' . implode(' AND ', $where);
    $catLabelSelect = formationCategoryLabelSelect($db, 'cat');
    $limitSql = formationPaginatedLimitOffset($pagination);

    if ($useCourses) {
        $orderBy = formationCourseOrderBy($db, 'c');
        $countSql = "SELECT COUNT(*) as total FROM formation_courses c $whereClause";
        $listSql = "SELECT c.*, {$catLabelSelect}
                    FROM formation_courses c
                    LEFT JOIN formation_categories cat ON c.category_id = cat.id
                    $whereClause
                    ORDER BY $orderBy{$limitSql}";
    } else {
        $orderBy = formationLegacyOrderBy($db, 'f');
        $countSql = "SELECT COUNT(*) as total FROM formations f $whereClause";
        $listSql = "SELECT f.*, {$catLabelSelect}
                    FROM formations f
                    LEFT JOIN formation_categories cat ON f.category_id = cat.id
                    $whereClause
                    ORDER BY $orderBy{$limitSql}";
    }

    $stmt = $db->prepare($countSql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->execute();
    $total = (int) $stmt->fetch()['total'];

    $stmt = $db->prepare($listSql);
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->execute();

    $rows = array_map(
        static fn ($row) => formationCourseRowToApi(is_array($row) ? $row : [], $db),
        $stmt->fetchAll(PDO::FETCH_ASSOC)
    );

    return [$rows, $total];
}

function formationFetchCourseById(PDO $db, int $id, ?int $siteId = null): ?array
{
    $catLabelSelect = formationCategoryLabelSelect($db, 'cat');

    if (formationUsesCoursesTable($db)) {
        $sql = "SELECT c.*, {$catLabelSelect}
                FROM formation_courses c
                LEFT JOIN formation_categories cat ON c.category_id = cat.id
                WHERE c.id = :id";
        if ($siteId !== null) {
            $sql .= ' AND c.site_id = :site_id';
        }
        $sql .= ' LIMIT 1';
        $stmt = $db->prepare($sql);
        $params = [':id' => $id];
        if ($siteId !== null) {
            $params[':site_id'] = $siteId;
        }
    } else {
        $sql = "SELECT f.*, {$catLabelSelect}
                FROM formations f
                LEFT JOIN formation_categories cat ON f.category_id = cat.id
                WHERE f.id = :id LIMIT 1";
        $stmt = $db->prepare($sql);
        $params = [':id' => $id];
    }
    $stmt->execute($params);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row ? formationCourseRowToApi($row, $db) : null;
}

function formationAttachCourseChildren(PDO $db, array &$course, int $id): void
{
    if (formationUsesCoursesTable($db)) {
        $moduleFk = formationChildForeignKey($db, 'formation_modules');
        $moduleDurationExpr = recrutementTableHasColumn($db, 'formation_modules', 'duration')
            ? 'duration AS duration_label'
            : (recrutementTableHasColumn($db, 'formation_modules', 'duration_label')
                ? 'duration_label'
                : 'NULL AS duration_label');
        $stmtM = $db->prepare(
            "SELECT id, title, description, {$moduleDurationExpr}, sort_order
             FROM formation_modules WHERE {$moduleFk} = :id ORDER BY sort_order ASC"
        );
        $stmtM->execute([':id' => $id]);
        $course['modules'] = $stmtM->fetchAll(PDO::FETCH_ASSOC);

        if (formationTableExists($db, 'formation_jobs')) {
            $jobFk = formationChildForeignKey($db, 'formation_jobs');
            $hasSalaryLabel = recrutementTableHasColumn($db, 'formation_jobs', 'salary_label');
            if ($hasSalaryLabel) {
                $stmtJ = $db->prepare(
                    "SELECT title AS job_title, salary_label, sort_order
                     FROM formation_jobs WHERE {$jobFk} = :id ORDER BY sort_order ASC"
                );
            } else {
                $stmtJ = $db->prepare(
                    "SELECT title AS job_title, salary_min, salary_max, sort_order
                     FROM formation_jobs WHERE {$jobFk} = :id ORDER BY sort_order ASC"
                );
            }
            $stmtJ->execute([':id' => $id]);
            $jobs = $stmtJ->fetchAll(PDO::FETCH_ASSOC);
            $course['job_outcomes'] = array_map(static function (array $j) {
                $salary = trim((string) ($j['salary_label'] ?? ''));
                if ($salary === '' && (!empty($j['salary_min']) || !empty($j['salary_max']))) {
                    $salary = trim(($j['salary_min'] ?? '') . ' - ' . ($j['salary_max'] ?? ''), ' -');
                }
                return [
                    'job_title' => $j['job_title'] ?? '',
                    'salary_label' => $salary ?: 'Selon expérience',
                    'sort_order' => $j['sort_order'] ?? 0,
                ];
            }, $jobs);
        } else {
            $course['job_outcomes'] = [];
        }

        if (formationTableExists($db, 'formation_skills')) {
            $skillFk = formationChildForeignKey($db, 'formation_skills');
            $stmtSk = $db->prepare(
                "SELECT name, sort_order FROM formation_skills WHERE {$skillFk} = :id ORDER BY sort_order ASC"
            );
            $stmtSk->execute([':id' => $id]);
            $course['skills'] = $stmtSk->fetchAll(PDO::FETCH_ASSOC);
        } else {
            $course['skills'] = [];
        }

        if (formationTableExists($db, 'formation_course_stats')) {
            $statFk = formationChildForeignKey($db, 'formation_course_stats');
            $iconCol = recrutementTableHasColumn($db, 'formation_course_stats', 'icon')
                ? 'icon'
                : 'NULL AS icon';
            $stmtSt = $db->prepare(
                "SELECT label, value, {$iconCol}, sort_order FROM formation_course_stats
                 WHERE {$statFk} = :id ORDER BY sort_order ASC"
            );
            $stmtSt->execute([':id' => $id]);
            $course['stats'] = $stmtSt->fetchAll(PDO::FETCH_ASSOC);
        } elseif (!empty($course['stats']) && is_array($course['stats'])) {
            // stats legacy dans extra_json
        } else {
            $course['stats'] = [];
        }

        if (formationTableExists($db, 'formation_objectives')) {
            $objectiveFk = formationChildForeignKey($db, 'formation_objectives');
            $stmtOb = $db->prepare(
                "SELECT content, sort_order FROM formation_objectives
                 WHERE {$objectiveFk} = :id ORDER BY sort_order ASC"
            );
            $stmtOb->execute([':id' => $id]);
            $course['objectives'] = $stmtOb->fetchAll(PDO::FETCH_ASSOC);
        } else {
            $course['objectives'] = [];
        }

        if (formationTableExists($db, 'formation_info_blocks')) {
            $blockFk = formationChildForeignKey($db, 'formation_info_blocks');
            $stmtBl = $db->prepare(
                "SELECT id, block_type, title, sort_order FROM formation_info_blocks
                 WHERE {$blockFk} = :id ORDER BY sort_order ASC"
            );
            $stmtBl->execute([':id' => $id]);
            $blocks = $stmtBl->fetchAll(PDO::FETCH_ASSOC);

            if (formationTableExists($db, 'formation_info_points')) {
                $stmtPt = $db->prepare(
                    'SELECT content, sort_order FROM formation_info_points
                     WHERE block_id = :bid ORDER BY sort_order ASC'
                );
                foreach ($blocks as &$block) {
                    $stmtPt->execute([':bid' => (int) $block['id']]);
                    $block['points'] = $stmtPt->fetchAll(PDO::FETCH_ASSOC);
                    unset($block['id']);
                }
                unset($block);
            } else {
                foreach ($blocks as &$block) {
                    $block['points'] = [];
                    unset($block['id']);
                }
                unset($block);
            }

            $course['info_blocks'] = $blocks;

            foreach ($blocks as $block) {
                $type = $block['block_type'] ?? '';
                if ($type === 'modalites') {
                    $course['info_modalities_title'] = $block['title'] ?? ($course['info_modalities_title'] ?? null);
                } elseif ($type === 'prerequis') {
                    $course['info_prerequisites_title'] = $block['title'] ?? ($course['info_prerequisites_title'] ?? null);
                }
            }
        } else {
            $course['info_blocks'] = [];
        }

        return;
    }

    $stmtM = $db->prepare('SELECT * FROM formation_modules WHERE formation_id = :id ORDER BY sort_order ASC');
    $stmtM->execute([':id' => $id]);
    $course['modules'] = $stmtM->fetchAll(PDO::FETCH_ASSOC);

    $stmtS = $db->prepare('SELECT * FROM formation_stats WHERE formation_id = :id ORDER BY sort_order ASC');
    $stmtS->execute([':id' => $id]);
    $course['stats'] = $stmtS->fetchAll(PDO::FETCH_ASSOC);

    $stmtJ = $db->prepare('SELECT * FROM formation_job_outcomes WHERE formation_id = :id ORDER BY sort_order ASC');
    $stmtJ->execute([':id' => $id]);
    $course['job_outcomes'] = $stmtJ->fetchAll(PDO::FETCH_ASSOC);

    $stmtL = $db->prepare('SELECT * FROM formation_list_items WHERE formation_id = :id ORDER BY list_type ASC, sort_order ASC');
    $stmtL->execute([':id' => $id]);
    $course['list_items'] = $stmtL->fetchAll(PDO::FETCH_ASSOC);

    $stmtC = $db->prepare('SELECT * FROM formation_official_certifications WHERE formation_id = :id LIMIT 1');
    $stmtC->execute([':id' => $id]);
    $course['official_certification'] = $stmtC->fetch(PDO::FETCH_ASSOC) ?: null;
}

function formationCategoryRowToApi(array $row, PDO $db): array
{
    if (formationCategoryLabelColumn($db) === 'name' && !isset($row['label'])) {
        $row['label'] = $row['name'] ?? '';
    }
    return $row;
}

function formationBuildInfoBlocksFromApi(array $data): array
{
    if (isset($data['info_blocks']) && is_array($data['info_blocks'])) {
        return $data['info_blocks'];
    }

    $blocks = [];
    $definitions = [
        'modalites' => [
            'title' => $data['info_modalities_title'] ?? 'Modalités d\'apprentissage',
            'text' => $data['info_modalities_points'] ?? $data['info_modalities_description'] ?? null,
        ],
        'prerequis' => [
            'title' => $data['info_prerequisites_title'] ?? 'Public concerné & Prérequis',
            'text' => $data['info_prerequisites_points'] ?? $data['info_prerequisites_description'] ?? null,
        ],
        'pour_qui' => [
            'title' => $data['pour_qui_title'] ?? 'Public',
            'text' => $data['pour_qui_points'] ?? null,
        ],
        'evaluation_etapes' => [
            'title' => $data['evaluation_steps_title'] ?? 'Étapes d\'évaluation',
            'text' => $data['evaluation_steps_text'] ?? null,
        ],
    ];

    $sort = 0;
    foreach ($definitions as $blockType => $def) {
        $text = trim((string) ($def['text'] ?? ''));
        if ($text === '') {
            continue;
        }
        $lines = array_values(array_filter(array_map('trim', preg_split('/\r\n|\r|\n/', $text))));
        if ($lines === []) {
            continue;
        }
        $blocks[] = [
            'block_type' => $blockType,
            'title' => $def['title'],
            'sort_order' => ++$sort,
            'points' => array_map(static fn ($line, $idx) => [
                'content' => $line,
                'sort_order' => $idx,
            ], $lines, array_keys($lines)),
        ];
    }

    return $blocks;
}

function formationBuildObjectivesFromApi(array $data): array
{
    if (isset($data['objectives']) && is_array($data['objectives'])) {
        return $data['objectives'];
    }

    $text = trim((string) ($data['objectifs_text'] ?? ''));
    if ($text === '') {
        return [];
    }

    $lines = array_values(array_filter(array_map('trim', preg_split('/\r\n|\r|\n/', $text))));
    return array_map(static fn ($line, $idx) => [
        'content' => $line,
        'sort_order' => $idx,
    ], $lines, array_keys($lines));
}

function formationBuildSkillsFromApi(array $data): array
{
    if (isset($data['skills']) && is_array($data['skills'])) {
        return $data['skills'];
    }

    $text = trim((string) ($data['competences_acquises_text'] ?? ''));
    if ($text === '') {
        return [];
    }

    $lines = array_values(array_filter(array_map('trim', preg_split('/\r\n|\r|\n/', $text))));
    return array_map(static fn ($line, $idx) => [
        'name' => $line,
        'sort_order' => $idx,
    ], $lines, array_keys($lines));
}

function parseStatsTextFromApiPayload($text): array
{
    $text = trim((string) ($text ?? ''));
    if ($text === '') {
        return [];
    }

    $lines = array_values(array_filter(array_map('trim', preg_split('/\r\n|\r|\n/', $text))));
    return array_map(static function ($line, $idx) {
        $parts = array_map('trim', explode('|', $line));
        return [
            'label' => $parts[0] ?? '',
            'value' => $parts[1] ?? '—',
            'icon' => $parts[2] ?? null,
            'sort_order' => $idx,
        ];
    }, $lines, array_keys($lines));
}

function formationCourseColumnsFromApi(array $data, int $siteId, int $adminId, ?array $existing = null): array
{
    $title = trim((string) ($data['hero_title'] ?? ''));
    $slug = trim((string) ($data['slug'] ?? Validator::slugify($title)));
    $status = $data['status'] ?? 'draft';
    $cert = formationOfficialCertFromApi($data);

    $existingExtra = null;
    if ($existing !== null) {
        $existingExtra = formationDecodeExtraJson($existing['extra_json'] ?? null);
    }

    $extraPayload = $data;
    if ($status === 'published' && empty($data['published_at']) && empty($existingExtra['published_at'] ?? null)) {
        $extraPayload['published_at'] = date('Y-m-d H:i:s');
    }

    $presentationImage = $data['presentation_image_url']
        ?? $data['presentation_image']
        ?? null;

    return [
        'site_id' => $siteId,
        'category_id' => (int) ($data['category_id'] ?? 0),
        'title' => $title,
        'slug' => $slug,
        'course_type' => $data['course_type'] ?? ($data['type'] ?? 'diplomante'),
        'subtitle' => $data['hero_subtitle'] ?? null,
        'video_url' => $data['hero_video_url'] ?? null,
        'duration' => $data['programme_duration_label'] ?? null,
        'modality_label' => $data['modality_label'] ?? null,
        'price' => isset($data['price']) && $data['price'] !== '' ? (float) $data['price'] : null,
        'certification_label' => $data['certification_label'] ?? null,
        'reference_code' => $data['reference_code'] ?? ($data['internal_reference'] ?? null),
        'is_cpf_eligible' => !empty($data['is_cpf_eligible']) ? 1 : 0,
        'is_alternance' => !empty($data['is_alternance']) ? 1 : 0,
        'rncp_repertoire' => $cert['rncp_repertoire'],
        'rncp_code' => $cert['rncp_code'],
        'rncp_title' => $cert['rncp_title'],
        'rncp_level' => $cert['rncp_level'],
        'rncp_url' => $cert['rncp_url'],
        'presentation_title' => $data['presentation_title'] ?? 'Le métier',
        'presentation_text' => $data['presentation_content'] ?? null,
        'presentation_image_url' => $presentationImage,
        'programme_duration_total' => $data['programme_duration_total'] ?? null,
        'debouches_title' => $data['debouches_title'] ?? null,
        'debouches_subtitle' => $data['debouches_subtitle'] ?? null,
        'debouches_sectors' => $data['debouches_sectors'] ?? null,
        'evaluation_title' => $data['evaluation_title'] ?? null,
        'evaluation_description' => $data['evaluation_description'] ?? null,
        'cta_title' => $data['cta_title'] ?? null,
        'cta_subtitle' => $data['cta_subtitle'] ?? null,
        'meta_title' => $data['seo_title'] ?? null,
        'meta_description' => $data['seo_description'] ?? null,
        'sort_order' => (int) ($data['sort_order'] ?? 0),
        'status' => $status,
        'extra_json' => formationBuildExtraJsonFromApi($extraPayload, $existingExtra),
        'updated_by' => $adminId,
        'created_by' => $existing['created_by'] ?? $adminId,
    ];
}

function formationCourseWritableColumns(PDO $db): array
{
    // Colonnes garanties présentes dans tous les schémas
    $columns = [
        'site_id', 'category_id', 'title', 'slug', 'subtitle', 'video_url', 'duration',
        'price', 'rncp_repertoire', 'rncp_code', 'rncp_title', 'rncp_level', 'rncp_url',
        'presentation_title', 'presentation_text', 'cta_title', 'cta_subtitle',
        'extra_json', 'status',
    ];

    // Colonnes optionnelles : incluses uniquement si elles existent dans la table
    $optional = [
        'course_type', 'modality_label', 'certification_label', 'reference_code',
        'presentation_image_url', 'programme_duration_total',
        'debouches_title', 'debouches_subtitle', 'debouches_sectors',
        'evaluation_title', 'evaluation_description',
        'is_cpf_eligible', 'is_alternance', 'sort_order',
        // Colonnes SEO — absentes sur certains schémas legacy, ajoutées par formationEnsureSchema
        'meta_title', 'meta_description',
        // Colonnes d'audit — absentes sur certains schémas legacy
        'created_by', 'updated_by',
    ];

    foreach ($optional as $col) {
        if (formationCourseHasColumn($db, $col)) {
            $columns[] = $col;
        }
    }

    return array_values(array_unique($columns));
}

function formationInsertCourse(PDO $db, array $data, int $siteId, int $adminId): int
{
    $cols = formationCourseColumnsFromApi($data, $siteId, $adminId);
    if ($cols['category_id'] <= 0) {
        throw new InvalidArgumentException('category_id requis');
    }

    $columns = formationCourseWritableColumns($db);
    $placeholders = array_map(static fn ($c) => ':' . $c, $columns);
    $sql = 'INSERT INTO formation_courses (' . implode(', ', $columns) . ', created_at)
            VALUES (' . implode(', ', $placeholders) . ', NOW())';

    $stmt = $db->prepare($sql);
    foreach ($columns as $col) {
        $stmt->bindValue(':' . $col, $cols[$col] ?? null);
    }
    $stmt->execute();

    $courseId = (int) $db->lastInsertId();
    formationSaveCourseChildren($db, $courseId, $data);

    return $courseId;
}

function formationUpdateCourse(PDO $db, int $id, array $data, int $siteId, int $adminId): void
{
    $stmt = $db->prepare('SELECT * FROM formation_courses WHERE id = :id AND site_id = :site_id LIMIT 1');
    $stmt->execute([':id' => $id, ':site_id' => $siteId]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$existing) {
        throw new RuntimeException('Formation not found');
    }

    if (!isset($data['hero_title'])) {
        $data['hero_title'] = $existing['title'];
    }
    if (!isset($data['slug'])) {
        $data['slug'] = $existing['slug'];
    }

    $cols = formationCourseColumnsFromApi($data, $siteId, $adminId, $existing);
    if (array_key_exists('category_id', $data) && (int) ($data['category_id'] ?? 0) <= 0) {
        $cols['category_id'] = (int) $existing['category_id'];
    }

    $fields = array_values(array_filter(
        formationCourseWritableColumns($db),
        static fn ($c) => !in_array($c, ['site_id', 'created_by'], true)
    ));

    $sets = array_map(static fn ($f) => "$f = :$f", $fields);
    if (formationCourseHasColumn($db, 'updated_at')) {
        $sets[] = 'updated_at = NOW()';
    }

    $sql = 'UPDATE formation_courses SET ' . implode(', ', $sets) . '
            WHERE id = :id AND site_id = :site_id';

    $stmtU = $db->prepare($sql);
    foreach ($fields as $f) {
        $stmtU->bindValue(':' . $f, $cols[$f] ?? null);
    }
    $stmtU->bindValue(':id', $id, PDO::PARAM_INT);
    $stmtU->bindValue(':site_id', $siteId, PDO::PARAM_INT);
    $stmtU->execute();

    formationSaveCourseChildren($db, $id, $data);
}

function formationSaveCourseChildren(PDO $db, int $courseId, array $data): void
{
    if (isset($data['modules']) && is_array($data['modules']) && formationTableExists($db, 'formation_modules')) {
        $moduleFk = formationChildForeignKey($db, 'formation_modules');
        $moduleDurationCol = recrutementTableHasColumn($db, 'formation_modules', 'duration')
            ? 'duration'
            : (recrutementTableHasColumn($db, 'formation_modules', 'duration_label') ? 'duration_label' : null);
        $db->prepare("DELETE FROM formation_modules WHERE {$moduleFk} = :id")->execute([':id' => $courseId]);
        if ($moduleDurationCol !== null) {
            $stmtM = $db->prepare(
                "INSERT INTO formation_modules ({$moduleFk}, title, description, {$moduleDurationCol}, sort_order)
                 VALUES (:cid, :tit, :desc, :dur, :sort)"
            );
        } else {
            $stmtM = $db->prepare(
                "INSERT INTO formation_modules ({$moduleFk}, title, description, sort_order)
                 VALUES (:cid, :tit, :desc, :sort)"
            );
        }
        foreach ($data['modules'] as $idx => $m) {
            if (empty($m['title'])) {
                continue;
            }
            $moduleParams = [
                ':cid' => $courseId,
                ':tit' => $m['title'],
                ':desc' => $m['description'] ?? null,
                ':sort' => $m['sort_order'] ?? $idx,
            ];
            if ($moduleDurationCol !== null) {
                $moduleParams[':dur'] = $m['duration_label'] ?? ($m['duration'] ?? null);
            }
            $stmtM->execute($moduleParams);
        }
    }

    if (isset($data['job_outcomes']) && is_array($data['job_outcomes']) && formationTableExists($db, 'formation_jobs')) {
        $jobFk = formationChildForeignKey($db, 'formation_jobs');
        $db->prepare("DELETE FROM formation_jobs WHERE {$jobFk} = :id")->execute([':id' => $courseId]);
        $hasSalaryLabel = recrutementTableHasColumn($db, 'formation_jobs', 'salary_label');
        if ($hasSalaryLabel) {
            $stmtJ = $db->prepare(
                "INSERT INTO formation_jobs ({$jobFk}, title, salary_label, sort_order)
                 VALUES (:cid, :tit, :sal, :sort)"
            );
            foreach ($data['job_outcomes'] as $idx => $j) {
                if (empty($j['job_title'])) {
                    continue;
                }
                $stmtJ->execute([
                    ':cid' => $courseId,
                    ':tit' => $j['job_title'],
                    ':sal' => $j['salary_label'] ?? null,
                    ':sort' => $j['sort_order'] ?? $idx,
                ]);
            }
        } else {
            $stmtJ = $db->prepare(
                "INSERT INTO formation_jobs ({$jobFk}, title, salary_min, salary_max, sort_order)
                 VALUES (:cid, :tit, :smin, :smax, :sort)"
            );
            foreach ($data['job_outcomes'] as $idx => $j) {
                if (empty($j['job_title'])) {
                    continue;
                }
                $stmtJ->execute([
                    ':cid' => $courseId,
                    ':tit' => $j['job_title'],
                    ':smin' => $j['salary_min'] ?? null,
                    ':smax' => $j['salary_max'] ?? null,
                    ':sort' => $j['sort_order'] ?? $idx,
                ]);
            }
        }
    }

    $shouldSyncSkills = array_key_exists('skills', $data)
        || array_key_exists('competences_acquises_text', $data);
    if ($shouldSyncSkills && formationTableExists($db, 'formation_skills')) {
        $skills = formationBuildSkillsFromApi($data);
        $skillFk = formationChildForeignKey($db, 'formation_skills');
        $db->prepare("DELETE FROM formation_skills WHERE {$skillFk} = :id")->execute([':id' => $courseId]);
        $stmtSk = $db->prepare("INSERT INTO formation_skills ({$skillFk}, name, sort_order) VALUES (:cid, :name, :sort)");
        foreach ($skills as $idx => $skill) {
            $name = is_array($skill) ? ($skill['name'] ?? '') : (string) $skill;
            $name = trim($name);
            if ($name === '') {
                continue;
            }
            $stmtSk->execute([':cid' => $courseId, ':name' => $name, ':sort' => $idx]);
        }
    }

    $shouldSyncStats = array_key_exists('stats', $data) || array_key_exists('stats_text', $data);
    if ($shouldSyncStats && formationTableExists($db, 'formation_course_stats')) {
        $stats = isset($data['stats']) && is_array($data['stats'])
            ? $data['stats']
            : parseStatsTextFromApiPayload($data['stats_text'] ?? '');
        $statFk = formationChildForeignKey($db, 'formation_course_stats');
        $hasStatIcon = recrutementTableHasColumn($db, 'formation_course_stats', 'icon');
        $db->prepare("DELETE FROM formation_course_stats WHERE {$statFk} = :id")->execute([':id' => $courseId]);
        $stmtSt = $db->prepare($hasStatIcon
            ? "INSERT INTO formation_course_stats ({$statFk}, label, value, icon, sort_order)
               VALUES (:cid, :label, :value, :icon, :sort)"
            : "INSERT INTO formation_course_stats ({$statFk}, label, value, sort_order)
               VALUES (:cid, :label, :value, :sort)"
        );
        foreach ($stats as $idx => $stat) {
            $label = trim((string) ($stat['label'] ?? ''));
            if ($label === '') {
                continue;
            }
            $statParams = [
                ':cid' => $courseId,
                ':label' => $label,
                ':value' => trim((string) ($stat['value'] ?? '—')),
                ':sort' => $stat['sort_order'] ?? $idx,
            ];
            if ($hasStatIcon) {
                $statParams[':icon'] = !empty($stat['icon']) ? trim((string) $stat['icon']) : null;
            }
            $stmtSt->execute($statParams);
        }
    }

    $shouldSyncObjectives = array_key_exists('objectives', $data)
        || array_key_exists('objectifs_text', $data);
    if ($shouldSyncObjectives && formationTableExists($db, 'formation_objectives')) {
        $objectives = formationBuildObjectivesFromApi($data);
        $objectiveFk = formationChildForeignKey($db, 'formation_objectives');
        $db->prepare("DELETE FROM formation_objectives WHERE {$objectiveFk} = :id")->execute([':id' => $courseId]);
        $stmtOb = $db->prepare(
            "INSERT INTO formation_objectives ({$objectiveFk}, content, sort_order) VALUES (:cid, :content, :sort)"
        );
        foreach ($objectives as $idx => $objective) {
            $content = trim((string) ($objective['content'] ?? ''));
            if ($content === '') {
                continue;
            }
            $stmtOb->execute([
                ':cid' => $courseId,
                ':content' => $content,
                ':sort' => $idx,
            ]);
        }
    }

    $shouldSyncInfoBlocks = array_key_exists('info_blocks', $data)
        || array_key_exists('info_modalities_points', $data)
        || array_key_exists('info_prerequisites_points', $data)
        || array_key_exists('pour_qui_points', $data)
        || array_key_exists('evaluation_steps_text', $data);
    if ($shouldSyncInfoBlocks && formationTableExists($db, 'formation_info_blocks')) {
        $infoBlocks = formationBuildInfoBlocksFromApi($data);
        $blockFk = formationChildForeignKey($db, 'formation_info_blocks');
        if (formationTableExists($db, 'formation_info_points')) {
            $stmtIds = $db->prepare("SELECT id FROM formation_info_blocks WHERE {$blockFk} = :id");
            $stmtIds->execute([':id' => $courseId]);
            $blockIds = $stmtIds->fetchAll(PDO::FETCH_COLUMN);
            if ($blockIds !== []) {
                $in = implode(',', array_fill(0, count($blockIds), '?'));
                $db->prepare("DELETE FROM formation_info_points WHERE block_id IN ($in)")->execute($blockIds);
            }
        }
        $db->prepare("DELETE FROM formation_info_blocks WHERE {$blockFk} = :id")->execute([':id' => $courseId]);

        $stmtBl = $db->prepare(
            "INSERT INTO formation_info_blocks ({$blockFk}, block_type, title, sort_order)
             VALUES (:cid, :type, :title, :sort)"
        );
        $stmtPt = formationTableExists($db, 'formation_info_points')
            ? $db->prepare(
                'INSERT INTO formation_info_points (block_id, content, sort_order)
                 VALUES (:bid, :content, :sort)'
            )
            : null;

        foreach ($infoBlocks as $idx => $block) {
            $blockType = trim((string) ($block['block_type'] ?? ''));
            $title = trim((string) ($block['title'] ?? ''));
            if ($blockType === '' || $title === '') {
                continue;
            }
            $stmtBl->execute([
                ':cid' => $courseId,
                ':type' => $blockType,
                ':title' => $title,
                ':sort' => $block['sort_order'] ?? $idx,
            ]);
            if ($stmtPt === null) {
                continue;
            }
            $blockId = (int) $db->lastInsertId();
            $points = $block['points'] ?? [];
            foreach ($points as $pIdx => $point) {
                $content = trim((string) ($point['content'] ?? ''));
                if ($content === '') {
                    continue;
                }
                $stmtPt->execute([
                    ':bid' => $blockId,
                    ':content' => $content,
                    ':sort' => $point['sort_order'] ?? $pIdx,
                ]);
            }
        }
    }
}
