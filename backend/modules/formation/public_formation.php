<?php
/**
 * modules/formation/public_formation.php — Routes publiques pour site Formation (site_id = 1)
 */

function registerPublicFormationRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/formation/courses', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id', "c.status = 'published'"];
        $bindParams = [':site_id' => $siteId];

        if ($categoryId = Router::getQueryParam('category_id')) {
            $where[] = 'c.category_id = :cat_id';
            $bindParams[':cat_id'] = (int) $categoryId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM formation_courses c $whereClause");
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.id, c.title, c.slug, c.subtitle, c.duration, c.price, c.is_cpf_eligible, c.is_alternance,
                    cat.name as category_name, cat.slug as category_slug
             FROM formation_courses c
             LEFT JOIN formation_categories cat ON c.category_id = cat.id
             $whereClause
             ORDER BY c.created_at DESC
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
            "SELECT c.*, cat.name as category_name, cat.slug as category_slug
             FROM formation_courses c
             LEFT JOIN formation_categories cat ON c.category_id = cat.id
             WHERE c.site_id = :site_id AND c.slug = :slug AND c.status = 'published' LIMIT 1"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $course = $stmt->fetch();

        if (!$course) { Response::notFound('Course not found'); return; }

        $stmtM = $db->prepare("SELECT title, description, duration FROM formation_modules WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtM->execute([':id' => $course['id']]);
        $course['modules'] = $stmtM->fetchAll();

        $stmtS = $db->prepare("SELECT name FROM formation_skills WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtS->execute([':id' => $course['id']]);
        $course['skills'] = array_column($stmtS->fetchAll(), 'name');

        $stmtJ = $db->prepare("SELECT title, salary_min, salary_max FROM formation_jobs WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtJ->execute([':id' => $course['id']]);
        $course['jobs'] = $stmtJ->fetchAll();

        Response::success($course);
    });
}
