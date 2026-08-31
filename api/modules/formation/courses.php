<?php
/**
 * modules/formation/courses.php — CRUD formation_courses (site Alt Formation)
 */

require_once __DIR__ . '/formation_schema.php';

function registerFormationCoursesRoutes(Router $router): void
{
    $router->get('/api/admin/formation/courses', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        try {
            [$results, $total] = formationListCourses(
                $db,
                $pagination,
                $siteId,
                Router::getQueryParam('status'),
                Router::getQueryParam('type'),
            );
            header('X-Formation-Api: v4');
            Response::paginated($results, $total, $pagination['page'], $pagination['limit']);
        } catch (\Throwable $e) {
            error_log('formation/courses GET: ' . $e->getMessage());
            Response::json([
                'success' => false,
                'error'   => 'Impossible de charger les formations',
                'detail'  => $e->getMessage(),
            ], 500);
        }
    });

    $router->get('/api/admin/formation/courses/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        try {
            $course = formationFetchCourseById($db, $id, $siteId);
            if (!$course) {
                Response::notFound('Formation not found');
                return;
            }
            formationAttachCourseChildren($db, $course, $id);
            Response::success($course);
        } catch (\Throwable $e) {
            error_log('formation/courses GET id: ' . $e->getMessage());
            Response::serverError('Impossible de charger la formation', $e->getMessage());
        }
    });

    $router->post('/api/admin/formation/courses', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        if (!isset($data['hero_title']) && isset($data['title'])) {
            $data['hero_title'] = $data['title'];
        }
        if (!isset($data['presentation_content']) && isset($data['presentation_text'])) {
            $data['presentation_content'] = $data['presentation_text'];
        }
        if (!isset($data['programme_duration_label']) && isset($data['duration'])) {
            $data['programme_duration_label'] = $data['duration'];
        }
        if (!isset($data['job_outcomes']) && isset($data['jobs']) && is_array($data['jobs'])) {
            $data['job_outcomes'] = array_map(static function ($job) {
                if (is_array($job) && !isset($job['job_title']) && isset($job['title'])) {
                    $job['job_title'] = $job['title'];
                }
                return $job;
            }, $data['jobs']);
        }

        Validator::make($data)->required('hero_title', 'Hero Title')->validate();
        if (!formationUsesCoursesTable(getDb())) {
            Response::serverError('Table formation_courses indisponible');
            return;
        }
        if (empty($data['category_id'])) {
            Response::badRequest('Type de formation requis (category_id)');
            return;
        }

        $db = getDb();
        $db->beginTransaction();
        try {
            $courseId = formationInsertCourse($db, $data, $siteId, (int) $admin['id']);
            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'formation_course', $courseId, null, $data);
            Response::created(['id' => $courseId]);
        } catch (InvalidArgumentException $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            Response::badRequest($e->getMessage());
        } catch (\Exception $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            Response::serverError('Failed to create formation', $e->getMessage());
        }
    });

    $router->put('/api/admin/formation/courses/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        if (!formationUsesCoursesTable($db)) {
            Response::serverError('Table formation_courses indisponible');
            return;
        }

        $stmt = $db->prepare('SELECT * FROM formation_courses WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Formation not found');
            return;
        }

        $db->beginTransaction();
        try {
            formationUpdateCourse($db, $id, $data, $siteId, (int) $admin['id']);
            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'formation_course', $id, $old, $data);
            Response::success(['id' => $id], 'Formation updated');
        } catch (\Exception $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            Response::serverError('Failed to update formation', $e->getMessage());
        }
    });

    $router->delete('/api/admin/formation/courses/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT id FROM formation_courses WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Formation not found');
            return;
        }

        $stmt = $db->prepare('DELETE FROM formation_courses WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'formation_course', $id, $old, null);
        Response::noContent();
    });
}
