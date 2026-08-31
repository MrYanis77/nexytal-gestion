<?php
/**
 * modules/settings/data_portability.php — Export / import JSON par site (superadmin).
 */

require_once __DIR__ . '/../recrutement/site_scope.php';
require_once __DIR__ . '/../formation/formation_career_helpers.php';

function registerDataPortabilityRoutes(Router $router): void
{
    $router->get('/api/admin/settings/export', function () {
        Middleware::superadminOnly();
        $siteId = (int) Router::getQueryParam('site_id');
        if ($siteId <= 0) {
            Response::badRequest('site_id requis');
            return;
        }

        $scope = Router::getQueryParam('scope') ?: 'recrutement';
        $allowedScopes = ['recrutement', 'blog', 'formation', 'full'];
        if (!in_array($scope, $allowedScopes, true)) {
            Response::badRequest('scope invalide (recrutement, blog, formation, full)');
            return;
        }

        Response::success(dataPortabilityExport($siteId, $scope));
    });

    $router->post('/api/admin/settings/import', function () {
        Middleware::superadminOnly();
        $body = Router::getJsonBody();

        if (empty($body['site_id']) || empty($body['tables']) || !is_array($body['tables'])) {
            Response::badRequest('Format invalide : site_id et tables requis');
            return;
        }

        $siteId = (int) $body['site_id'];
        if ($siteId <= 0) {
            Response::badRequest('site_id invalide');
            return;
        }

        $mode = $body['mode'] ?? 'merge';
        if (!in_array($mode, ['merge', 'skip_existing'], true)) {
            Response::badRequest('mode invalide (merge ou skip_existing)');
            return;
        }

        Response::success(dataPortabilityImport($siteId, $body['tables'], $mode));
    });
}

function dataPortabilityExport(int $siteId, string $scope): array
{
    $db = getDb();
    $tables = [];

    if ($scope === 'recrutement' || $scope === 'full') {
        $tables['secteurs_activite'] = dataPortabilityFetchBySite($db, 'secteurs_activite', $siteId);
        $tables['entreprises'] = dataPortabilityFetchBySite($db, 'entreprises', $siteId);
        $tables['metiers'] = dataPortabilityFetchBySite($db, 'metiers', $siteId);
        $tables['offres_emploi'] = dataPortabilityFetchBySite($db, 'offres_emploi', $siteId);

        $stmt = $db->prepare(
            'SELECT ce.* FROM candidatures_externes ce WHERE ce.site_id = :site_id ORDER BY ce.id'
        );
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $tables['candidatures_externes'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $stmt = $db->prepare(
            'SELECT ca.* FROM candidatures ca
             INNER JOIN offres_emploi o ON o.id = ca.offre_id
             WHERE o.site_id = :site_id ORDER BY ca.id'
        );
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $tables['candidatures'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    if ($scope === 'blog' || $scope === 'full') {
        $tables['blog_categories'] = dataPortabilityFetchBySite($db, 'blog_categories', $siteId);
        $tables['blog_tags'] = dataPortabilityFetchBySite($db, 'blog_tags', $siteId);
        $tables['blog_authors'] = dataPortabilityFetchBySite($db, 'blog_authors', $siteId);
        $tables['blog_posts'] = dataPortabilityFetchBySite($db, 'blog_posts', $siteId);
    }

    if ($scope === 'formation' || $scope === 'full') {
        $tables['formation_categories'] = dataPortabilityFetchBySite($db, 'formation_categories', $siteId);
        $tables['formation_courses'] = dataPortabilityFetchBySite($db, 'formation_courses', $siteId);
        $tables['site_pricing'] = dataPortabilityFetchBySite($db, 'site_pricing', $siteId);
        $tables['formation_career_offers'] = dataPortabilityFetchFormationCareerOffers($db, $siteId);
        $tables['formation_career_applications'] = dataPortabilityFetchFormationCareerApplications($db, $siteId);
        if (dataPortabilityTableExists($db, 'formations')) {
            $tables['formations'] = dataPortabilityFetchBySite($db, 'formations', $siteId);
        }
    }

    if ($scope === 'full') {
        $tables['seo_metadata'] = dataPortabilityFetchBySite($db, 'seo_metadata', $siteId);
        $tables['media_library'] = dataPortabilityFetchBySite($db, 'media_library', $siteId);
    }

    return [
        'version'     => 1,
        'site_id'     => $siteId,
        'scope'       => $scope,
        'exported_at' => date('c'),
        'tables'      => $tables,
    ];
}

function dataPortabilityFetchBySite(PDO $db, string $table, int $siteId): array
{
    if (!dataPortabilityTableExists($db, $table)) {
        return [];
    }

    if (recrutementTableHasColumn($db, $table, 'site_id')) {
        $stmt = $db->prepare("SELECT * FROM `$table` WHERE site_id = :site_id ORDER BY id");
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    return [];
}

function dataPortabilityImport(int $siteId, array $tables, string $mode): array
{
    $db = getDb();
    $results = [];

    $importOrder = [
        'secteurs_activite',
        'entreprises',
        'metiers',
        'offres_emploi',
        'blog_categories',
        'blog_tags',
        'blog_authors',
        'blog_posts',
        'formation_categories',
        'formation_courses',
        'site_pricing',
        'site_pricing_plans',
        'formation_career_offers',
        'formation_career_applications',
        'career_job_offers',
        'career_applications',
        'formations',
    ];

    foreach ($importOrder as $table) {
        if (!isset($tables[$table]) || !is_array($tables[$table])) {
            continue;
        }

        if ($table === 'formation_career_offers') {
            $results[$table] = dataPortabilityImportTable($db, 'offres_emploi', $tables[$table], $siteId, $mode);
            continue;
        }
        if ($table === 'formation_career_applications') {
            $results[$table] = dataPortabilityImportTable($db, 'candidatures_externes', $tables[$table], $siteId, $mode);
            continue;
        }
        if ($table === 'career_job_offers') {
            $mapped = array_map(function (array $row) use ($db) {
                $row['titre'] = $row['title'] ?? $row['titre'] ?? '';
                $row['type_contrat'] = $row['contract_type'] ?? $row['type_contrat'] ?? 'cdi';
                $row['ville'] = $row['location'] ?? $row['ville'] ?? null;
                $row['profil_recherche'] = $row['short_description'] ?? $row['profil_recherche'] ?? null;
                $row['description'] = $row['full_description'] ?? $row['description'] ?? '—';
                $rawStatut = (string) ($row['status'] ?? $row['statut'] ?? 'brouillon');
                if ($rawStatut === 'publie') {
                    $rawStatut = 'publiee';
                }
                $row['statut'] = offreNormalizeStatutForDb($db, $rawStatut);
                $row['date_publication'] = $row['published_at'] ?? $row['date_publication'] ?? null;
                $row['date_expiration'] = $row['expires_at'] ?? $row['date_expiration'] ?? null;
                unset($row['title'], $row['contract_type'], $row['location'], $row['short_description'], $row['full_description'], $row['status'], $row['published_at'], $row['expires_at']);
                return $row;
            }, $tables[$table]);
            $results[$table] = dataPortabilityImportTable($db, 'offres_emploi', $mapped, $siteId, $mode);
            continue;
        }
        if ($table === 'site_pricing_plans') {
            $mapped = array_map(static function (array $row) {
                return [
                    'site_id' => $row['site_id'] ?? null,
                    'amount_eur' => $row['amount_eur'] ?? 0,
                ];
            }, $tables[$table]);
            $results[$table] = dataPortabilityImportTable($db, 'site_pricing', $mapped, $siteId, $mode);
            continue;
        }
        if ($table === 'career_applications') {
            $mapped = array_map(static function (array $row) {
                $row['offre_id'] = $row['offer_id'] ?? $row['offre_id'] ?? null;
                $row['prenom'] = $row['first_name'] ?? $row['prenom'] ?? '';
                $row['nom'] = $row['last_name'] ?? $row['nom'] ?? '';
                $row['telephone'] = $row['phone'] ?? $row['telephone'] ?? null;
                $row['lettre_motivation'] = $row['cover_letter_text'] ?? $row['lettre_motivation'] ?? null;
                $row['experience_candidat'] = $row['contract_or_expertise'] ?? $row['experience_candidat'] ?? null;
                $row['statut'] = $row['status'] ?? $row['statut'] ?? 'recue';
                $row['rgpd_consent_at'] = $row['rgpd_consent_at'] ?? date('Y-m-d H:i:s');
                unset($row['offer_id'], $row['application_type'], $row['first_name'], $row['last_name'], $row['phone'], $row['cover_letter_text'], $row['contract_or_expertise'], $row['cover_letter_filename'], $row['status']);
                return $row;
            }, $tables[$table]);
            $results[$table] = dataPortabilityImportTable($db, 'candidatures_externes', $mapped, $siteId, $mode);
            continue;
        }

        $results[$table] = dataPortabilityImportTable($db, $table, $tables[$table], $siteId, $mode);
    }

    return [
        'site_id' => $siteId,
        'mode'    => $mode,
        'results' => $results,
    ];
}

function dataPortabilityImportTable(
    PDO $db,
    string $table,
    array $rows,
    int $siteId,
    string $mode
): array {
    if (!dataPortabilityTableExists($db, $table) || empty($rows)) {
        return ['inserted' => 0, 'skipped' => 0, 'errors' => 0];
    }

    $inserted = 0;
    $skipped = 0;
    $errors = 0;

    foreach ($rows as $row) {
        if (!is_array($row)) {
            $errors++;
            continue;
        }

        if (recrutementTableHasColumn($db, $table, 'site_id')) {
            $row['site_id'] = $siteId;
        }

        unset($row['id'], $row['created_at'], $row['updated_at']);

        if (isset($row['slug']) && dataPortabilitySlugExists($db, $table, (string) $row['slug'], $siteId)) {
            if ($mode === 'skip_existing') {
                $skipped++;
                continue;
            }
            unset($row['slug']);
        }

        $columns = array_keys($row);
        if (empty($columns)) {
            $skipped++;
            continue;
        }

        $placeholders = array_map(static fn ($c) => ':' . $c, $columns);
        $sql = 'INSERT INTO `' . $table . '` (`' . implode('`, `', $columns) . '`) VALUES ('
            . implode(', ', $placeholders) . ')';

        try {
            $stmt = $db->prepare($sql);
            foreach ($row as $col => $val) {
                if ($val === null) {
                    $stmt->bindValue(':' . $col, null, PDO::PARAM_NULL);
                } else {
                    $stmt->bindValue(':' . $col, $val);
                }
            }
            $stmt->execute();
            $inserted++;
        } catch (\PDOException $e) {
            error_log("data import $table: " . $e->getMessage());
            $errors++;
        }
    }

    return ['inserted' => $inserted, 'skipped' => $skipped, 'errors' => $errors];
}

function dataPortabilityTableExists(PDO $db, string $table): bool
{
    static $cache = [];

    if (isset($cache[$table])) {
        return $cache[$table];
    }

    try {
        $stmt = $db->prepare('SHOW TABLES LIKE :t');
        $stmt->bindValue(':t', $table, PDO::PARAM_STR);
        $stmt->execute();
        $cache[$table] = (bool) $stmt->fetch(PDO::FETCH_NUM);
    } catch (\Throwable $e) {
        $cache[$table] = false;
    }

    return $cache[$table];
}

function dataPortabilitySlugExists(PDO $db, string $table, string $slug, int $siteId): bool
{
    if (recrutementTableHasColumn($db, $table, 'site_id')) {
        $stmt = $db->prepare("SELECT id FROM `$table` WHERE slug = :slug AND site_id = :site_id LIMIT 1");
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
    } else {
        $stmt = $db->prepare("SELECT id FROM `$table` WHERE slug = :slug LIMIT 1");
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
    }
    $stmt->execute();

    return (bool) $stmt->fetch(PDO::FETCH_ASSOC);
}

function dataPortabilityFetchFormationCareerOffers(PDO $db, int $siteId): array
{
    if (!formationCareerEnsureSchema($db)) {
        return [];
    }

    $stmt = $db->prepare(
        'SELECT o.* FROM offres_emploi o
         WHERE o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' ORDER BY o.id'
    );
    $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
    $stmt->execute();

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function dataPortabilityFetchFormationCareerApplications(PDO $db, int $siteId): array
{
    if (!formationCareerEnsureSchema($db)) {
        return [];
    }

    $stmt = $db->prepare(
        'SELECT ce.* FROM candidatures_externes ce
         INNER JOIN offres_emploi o ON o.id = ce.offre_id
         WHERE o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' ORDER BY ce.id'
    );
    $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
    $stmt->execute();

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
