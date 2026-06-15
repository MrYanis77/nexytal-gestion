<?php
/**
 * modules/formation/public_formation.php — Routes publiques formations (site_id = 1)
 */

function registerPublicFormationRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/formation/courses', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['f.site_id = :site_id', "f.status = 'published'"];
        $bindParams = [':site_id' => $siteId];

        if ($categoryId = Router::getQueryParam('category_id')) {
            $where[] = 'f.category_id = :cat_id';
            $bindParams[':cat_id'] = (int) $categoryId;
        }
        if ($type = Router::getQueryParam('type')) {
            $where[] = 'f.type = :type';
            $bindParams[':type'] = $type;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM formations f $whereClause");
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT f.id, f.slug, f.type, f.hero_title, f.hero_subtitle, f.card_image_url,
                    f.programme_duration_label, f.certification_label, cat.label as category_label, cat.slug as category_slug
             FROM formations f
             LEFT JOIN formation_categories cat ON f.category_id = cat.id
             $whereClause
             ORDER BY f.sort_order ASC, f.published_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/public/{site_slug}/formation/courses/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            "SELECT f.*, cat.label as category_label, cat.slug as category_slug
             FROM formations f
             LEFT JOIN formation_categories cat ON f.category_id = cat.id
             WHERE f.site_id = :site_id AND f.slug = :slug AND f.status = 'published' LIMIT 1"
        );
        $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        $course = $stmt->fetch();
        if (!$course) { Response::notFound('Formation not found'); return; }

        if ($course['modalites_catalogue']) {
            $course['modalites_catalogue'] = json_decode($course['modalites_catalogue'], true);
        }

        $id = (int) $course['id'];

        $stmtM = $db->prepare('SELECT title, duration_label, description FROM formation_modules WHERE formation_id = :id ORDER BY sort_order ASC');
        $stmtM->execute([':id' => $id]);
        $course['modules'] = $stmtM->fetchAll();

        $stmtS = $db->prepare('SELECT label, value, icon FROM formation_stats WHERE formation_id = :id ORDER BY sort_order ASC');
        $stmtS->execute([':id' => $id]);
        $course['stats'] = $stmtS->fetchAll();

        $stmtL = $db->prepare('SELECT list_type, content FROM formation_list_items WHERE formation_id = :id ORDER BY list_type, sort_order ASC');
        $stmtL->execute([':id' => $id]);
        $course['list_items'] = $stmtL->fetchAll();

        $stmtJ = $db->prepare('SELECT job_title, salary_label FROM formation_job_outcomes WHERE formation_id = :id ORDER BY sort_order ASC');
        $stmtJ->execute([':id' => $id]);
        $course['job_outcomes'] = $stmtJ->fetchAll();

        $stmtC = $db->prepare('SELECT * FROM formation_official_certifications WHERE formation_id = :id');
        $stmtC->execute([':id' => $id]);
        $course['official_certifications'] = $stmtC->fetchAll();

        Response::success($course);
    });

    $router->get('/api/public/{site_slug}/formation/categories', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, slug, label, description, catalogue_type FROM formation_categories
             WHERE site_id = :site_id AND is_active = 1 ORDER BY sort_order ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });
}
