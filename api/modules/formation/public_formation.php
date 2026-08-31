<?php
/**
 * modules/formation/public_formation.php — Routes publiques Alt Formation
 */

require_once __DIR__ . '/formation_career_helpers.php';
require_once __DIR__ . '/formation_schema.php';
require_once __DIR__ . '/pricing.php';

function registerPublicFormationRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/formation/courses', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        $pagination = Router::getPagination();
        $catLabelSelect = formationCategoryLabelSelect($db, 'cat');
        $limitSql = formationPaginatedLimitOffset($pagination);

        if (formationUsesCoursesTable($db)) {
            $where = ['c.site_id = :site_id', "c.status = 'published'"];
            $bindParams = [':site_id' => $siteId];

            if ($categoryId = Router::getQueryParam('category_id')) {
                $where[] = 'c.category_id = :cat_id';
                $bindParams[':cat_id'] = (int) $categoryId;
            }

            $whereClause = 'WHERE ' . implode(' AND ', $where);
            $selectCols = formationPublicCourseSelectColumns($db);
            $orderBy = formationCourseOrderBy($db, 'c');

            $stmt = $db->prepare("SELECT COUNT(*) as total FROM formation_courses c $whereClause");
            foreach ($bindParams as $k => $v) {
                $stmt->bindValue($k, $v);
            }
            $stmt->execute();
            $total = (int) $stmt->fetch()['total'];

            $stmt = $db->prepare(
                "SELECT {$selectCols}, {$catLabelSelect}, cat.slug as category_slug
                 FROM formation_courses c
                 LEFT JOIN formation_categories cat ON c.category_id = cat.id
                 $whereClause
                 ORDER BY $orderBy{$limitSql}"
            );
            foreach ($bindParams as $k => $v) {
                $stmt->bindValue($k, $v);
            }
            $stmt->execute();

            Response::paginated($stmt->fetchAll(PDO::FETCH_ASSOC), $total, $pagination['page'], $pagination['limit']);
            return;
        }

        if (!formationTableExists($db, 'formations')) {
            Response::success([]);
            return;
        }

        $where = ['f.site_id = :site_id', "f.status = 'published'"];
        $bindParams = [':site_id' => $siteId];

        if ($categoryId = Router::getQueryParam('category_id')) {
            $where[] = 'f.category_id = :cat_id';
            $bindParams[':cat_id'] = (int) $categoryId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);
        $orderBy = formationLegacyOrderBy($db, 'f');

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM formations f $whereClause");
        foreach ($bindParams as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT f.id, f.slug, f.hero_title AS title, f.hero_subtitle AS subtitle,
                    f.programme_duration_label AS duration, NULL AS price,
                    0 AS is_cpf_eligible, 0 AS is_alternance,
                    {$catLabelSelect}, cat.slug as category_slug
             FROM formations f
             LEFT JOIN formation_categories cat ON f.category_id = cat.id
             $whereClause
             ORDER BY $orderBy{$limitSql}"
        );
        foreach ($bindParams as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();

        Response::paginated($stmt->fetchAll(PDO::FETCH_ASSOC), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/public/{site_slug}/formation/courses/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        $catLabelSelect = formationCategoryLabelSelect($db, 'cat');

        if (formationUsesCoursesTable($db)) {
            $orderBy = formationCourseOrderBy($db, 'c');
            $stmt = $db->prepare(
                "SELECT c.*, {$catLabelSelect}, cat.slug as category_slug
                 FROM formation_courses c
                 LEFT JOIN formation_categories cat ON c.category_id = cat.id
                 WHERE c.site_id = :site_id AND c.slug = :slug AND c.status = 'published'
                 ORDER BY $orderBy
                 LIMIT 1"
            );
            $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        } elseif (formationTableExists($db, 'formations')) {
            $stmt = $db->prepare(
                "SELECT f.*, {$catLabelSelect}, cat.slug as category_slug
                 FROM formations f
                 LEFT JOIN formation_categories cat ON f.category_id = cat.id
                 WHERE f.site_id = :site_id AND f.slug = :slug AND f.status = 'published'
                 LIMIT 1"
            );
            $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        } else {
            Response::notFound('Formation not found');
            return;
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            Response::notFound('Formation not found');
            return;
        }

        $course = formationCourseRowToApi($row, $db);
        formationAttachCourseChildren($db, $course, (int) $row['id']);
        Response::success($course);
    });

    $router->get('/api/public/{site_slug}/formation/categories', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        $labelCol = formationCategoryLabelColumn($db);
        $stmt = $db->prepare(
            "SELECT id, slug, {$labelCol} AS label, description
             FROM formation_categories
             WHERE site_id = :site_id AND is_active = 1 ORDER BY sort_order ASC"
        );
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll(PDO::FETCH_ASSOC));
    });

    $router->get('/api/public/{site_slug}/formation/pricing', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, site_id, amount_eur
             FROM site_pricing
             WHERE site_id = :site_id
             ORDER BY id ASC'
        );
        $stmt->execute([':site_id' => $siteId]);
        $rows = array_map('formationPricingRowToApi', $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::success($rows);
    });

    $router->get('/api/public/{site_slug}/formation/career-offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        if (!formationCareerEnsureSchema($db)) {
            Response::success([]);
            return;
        }

        $where = ['o.site_id = :site_id', "o.statut = 'publiee'", formationCareerWhereClause('o')];
        $bind = [':site_id' => $siteId];

        if ($dept = Router::getQueryParam('department')) {
            $where[] = 'o.department = :department';
            $bind[':department'] = $dept;
        }

        $sql = 'SELECT o.id, o.department, o.titre AS title, o.slug, o.type_contrat AS contract_type,
                       o.ville AS location, o.profil_recherche AS short_description, o.date_publication AS published_at
                FROM offres_emploi o WHERE ' . implode(' AND ', $where)
            . ' ORDER BY o.sort_order ASC, o.date_publication DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute($bind);
        Response::success($stmt->fetchAll(PDO::FETCH_ASSOC));
    });

    $router->get('/api/public/{site_slug}/formation/career-offers/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        if (!formationCareerEnsureSchema($db)) {
            Response::notFound('Offre introuvable');
            return;
        }
        $stmt = $db->prepare(
            "SELECT o.*, o.titre AS title, o.type_contrat AS contract_type, o.ville AS location,
                    o.profil_recherche AS short_description, o.description AS full_description
             FROM offres_emploi o
             WHERE o.site_id = :site_id AND o.slug = :slug AND o.statut = 'publiee'
               AND " . formationCareerWhereClause('o') . ' LIMIT 1'
        );
        $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            Response::notFound('Offre introuvable');
            return;
        }
        Response::success(formationCareerOfferFromOffreRow($row));
    });

    $router->post('/api/public/{site_slug}/formation/career-applications', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('first_name', 'Prénom')
            ->required('last_name', 'Nom')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('phone', 'Téléphone')
            ->required('cv_filename', 'CV')
            ->required('gdpr_consent', 'Consentement RGPD')
            ->validate();

        if (empty($data['gdpr_consent'])) {
            Response::badRequest('Consentement RGPD requis');
            return;
        }

        $db = getDb();
        if (!formationCareerEnsureSchema($db)) {
            Response::badRequest('Carrières Alt RH non disponibles');
            return;
        }
        $offerId = !empty($data['offer_id']) ? (int) $data['offer_id'] : null;

        if ($offerId) {
            $stmt = $db->prepare(
                "SELECT o.id FROM offres_emploi o
                 WHERE o.id = :id AND o.site_id = :site_id AND o.statut = 'publiee'
                   AND " . formationCareerWhereClause('o') . ' LIMIT 1'
            );
            $stmt->execute([':id' => $offerId, ':site_id' => $siteId]);
            if (!$stmt->fetch()) {
                Response::notFound('Offre introuvable');
                return;
            }
        } else {
            Response::badRequest('offer_id requis');
            return;
        }

        require_once __DIR__ . '/../recrutement/candidature_externe_helpers.php';

        $db->prepare(
            'INSERT INTO gdpr_consents_log (site_id, user_email, consent_type, granted, ip_address, user_agent)
             VALUES (:site_id, :email, :type, 1, :ip, :ua)'
        )->execute([
            ':site_id' => $siteId,
            ':email' => $data['email'],
            ':type' => 'career_application',
            ':ip' => $_SERVER['REMOTE_ADDR'] ?? null,
            ':ua' => isset($_SERVER['HTTP_USER_AGENT']) ? substr((string) $_SERVER['HTTP_USER_AGENT'], 0, 255) : null,
        ]);

        $insertData = [
            'prenom' => $data['first_name'],
            'nom' => $data['last_name'],
            'email' => $data['email'],
            'telephone' => $data['phone'],
            'lettre_motivation' => $data['cover_letter_text'] ?? $data['message'] ?? null,
            'cv_filename' => $data['cv_filename'],
            'experience_candidat' => $data['contract_or_expertise'] ?? $data['experience_candidat'] ?? null,
            'gdpr_consent' => true,
        ];
        $newId = candidatureExterneInsert($db, $offerId, $siteId, $insertData, ['score' => null]);

        Response::created(['id' => $newId], 'Candidature enregistrée');
    });
}
