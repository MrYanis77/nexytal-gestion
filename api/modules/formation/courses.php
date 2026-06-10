<?php
/**
 * modules/formation/courses.php — CRUD formation_courses
 */

function registerFormationCoursesRoutes(Router $router): void
{
    $router->get('/api/admin/formation/courses', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['c.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'c.status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM formation_courses c $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.*, cat.name as category_name 
             FROM formation_courses c
             LEFT JOIN formation_categories cat ON c.category_id = cat.id
             $whereClause
             ORDER BY c.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        
        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/formation/courses/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare("SELECT c.*, cat.name as category_name FROM formation_courses c LEFT JOIN formation_categories cat ON c.category_id = cat.id WHERE c.id = :id AND c.site_id = :site_id LIMIT 1");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $course = $stmt->fetch();

        if (!$course) { Response::notFound('Course not found'); return; }

        $stmtM = $db->prepare("SELECT * FROM formation_modules WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtM->execute([':id' => $id]);
        $course['modules'] = $stmtM->fetchAll();

        $stmtS = $db->prepare("SELECT * FROM formation_skills WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtS->execute([':id' => $id]);
        $course['skills'] = $stmtS->fetchAll();

        $stmtJ = $db->prepare("SELECT * FROM formation_jobs WHERE course_id = :id ORDER BY sort_order ASC");
        $stmtJ->execute([':id' => $id]);
        $course['jobs'] = $stmtJ->fetchAll();

        $stmtV = $db->prepare("SELECT id, title, status, created_by, created_at FROM formation_courses_versions WHERE course_id = :id ORDER BY created_at DESC");
        $stmtV->execute([':id' => $id]);
        $course['versions'] = $stmtV->fetchAll();

        Response::success($course);
    });

    $router->post('/api/admin/formation/courses', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('title', 'Title')->required('category_id', 'Category')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['title']);
        $db = getDb();
        $db->beginTransaction();

        try {
            $stmt = $db->prepare(
                'INSERT INTO formation_courses 
                 (site_id, category_id, title, slug, subtitle, video_url, duration, price, is_cpf_eligible, is_alternance, rncp_repertoire, rncp_code, rncp_title, rncp_level, rncp_url, presentation_title, presentation_text, cta_title, cta_subtitle, meta_title, meta_description, status, created_by, updated_by, created_at)
                 VALUES 
                 (:site_id, :cat_id, :title, :slug, :sub, :vid, :dur, :price, :cpf, :alt, :rncp_rep, :rncp_code, :rncp_tit, :rncp_lvl, :rncp_url, :pres_tit, :pres_txt, :cta_tit, :cta_sub, :meta_tit, :meta_desc, :status, :created_by, :updated_by, NOW())'
            );
            $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
            $stmt->bindValue(':cat_id', $data['category_id'], PDO::PARAM_INT);
            $stmt->bindValue(':title', $data['title'], PDO::PARAM_STR);
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':sub', $data['subtitle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':vid', $data['video_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':dur', $data['duration'] ?? null, PDO::PARAM_STR);
            $price = $data['price'] ?? null;
            $stmt->bindValue(':price', $price, $price === null || $price === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmt->bindValue(':cpf', isset($data['is_cpf_eligible']) ? (int)$data['is_cpf_eligible'] : 0, PDO::PARAM_INT);
            $stmt->bindValue(':alt', isset($data['is_alternance']) ? (int)$data['is_alternance'] : 0, PDO::PARAM_INT);
            $stmt->bindValue(':rncp_rep', $data['rncp_repertoire'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':rncp_code', $data['rncp_code'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':rncp_tit', $data['rncp_title'] ?? null, PDO::PARAM_STR);
            $rncpLvl = $data['rncp_level'] ?? null;
            $stmt->bindValue(':rncp_lvl', $rncpLvl, $rncpLvl === null || $rncpLvl === '' ? PDO::PARAM_NULL : PDO::PARAM_INT);
            $stmt->bindValue(':rncp_url', $data['rncp_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pres_tit', $data['presentation_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pres_txt', $data['presentation_text'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cta_tit', $data['cta_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cta_sub', $data['cta_subtitle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':meta_tit', $data['meta_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':meta_desc', $data['meta_description'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':status', $data['status'] ?? 'draft', PDO::PARAM_STR);
            $stmt->bindValue(':created_by', $admin['id'], PDO::PARAM_INT);
            $stmt->bindValue(':updated_by', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $courseId = (int) $db->lastInsertId();

            if (!empty($data['modules']) && is_array($data['modules'])) {
                $stmtM = $db->prepare('INSERT INTO formation_modules (course_id, title, description, duration, sort_order) VALUES (:cid, :tit, :desc, :dur, :sort)');
                foreach ($data['modules'] as $idx => $m) {
                    $stmtM->execute([':cid' => $courseId, ':tit' => $m['title'], ':desc' => $m['description'] ?? null, ':dur' => $m['duration'] ?? null, ':sort' => $m['sort_order'] ?? $idx]);
                }
            }
            if (!empty($data['skills']) && is_array($data['skills'])) {
                $stmtS = $db->prepare('INSERT INTO formation_skills (course_id, name, sort_order) VALUES (:cid, :name, :sort)');
                foreach ($data['skills'] as $idx => $s) {
                    $stmtS->execute([':cid' => $courseId, ':name' => $s['name'], ':sort' => $s['sort_order'] ?? $idx]);
                }
            }
            if (!empty($data['jobs']) && is_array($data['jobs'])) {
                $stmtJ = $db->prepare('INSERT INTO formation_jobs (course_id, title, salary_min, salary_max, sort_order) VALUES (:cid, :tit, :min, :max, :sort)');
                foreach ($data['jobs'] as $idx => $j) {
                    $salMin = $j['salary_min'] ?? null;
                    $salMax = $j['salary_max'] ?? null;
                    $stmtJ->bindValue(':cid', $courseId, PDO::PARAM_INT);
                    $stmtJ->bindValue(':tit', $j['title'], PDO::PARAM_STR);
                    $stmtJ->bindValue(':min', $salMin, $salMin === null || $salMin === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
                    $stmtJ->bindValue(':max', $salMax, $salMax === null || $salMax === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
                    $stmtJ->bindValue(':sort', $j['sort_order'] ?? $idx, PDO::PARAM_INT);
                    $stmtJ->execute();
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'formation_course', $courseId, null, $data);
            Response::created(['id' => $courseId]);

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create course', $e->getMessage());
        }
    });

    $router->put('/api/admin/formation/courses/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formation_courses WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Course not found'); return; }

        $db->beginTransaction();
        try {
            $stmtV = $db->prepare('INSERT INTO formation_courses_versions (course_id, title, presentation_text, status, created_by, created_at) VALUES (:cid, :tit, :txt, :st, :uid, NOW())');
            $stmtV->execute([':cid' => $id, ':tit' => $old['title'], ':txt' => $old['presentation_text'], ':st' => $old['status'], ':uid' => $admin['id']]);

            $fields = []; $bind = [];
            $updatable = ['category_id', 'title', 'slug', 'subtitle', 'video_url', 'duration', 'price', 'is_cpf_eligible', 'is_alternance', 'rncp_repertoire', 'rncp_code', 'rncp_title', 'rncp_level', 'rncp_url', 'presentation_title', 'presentation_text', 'cta_title', 'cta_subtitle', 'meta_title', 'meta_description', 'status'];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }

            if (!empty($fields)) {
                $fields[] = "updated_by = :uid"; $bind[':uid'] = $admin['id'];
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE formation_courses SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->execute();
            }

            if (isset($data['modules']) && is_array($data['modules'])) {
                $db->prepare("DELETE FROM formation_modules WHERE course_id = :id")->execute([':id' => $id]);
                $stmtM = $db->prepare('INSERT INTO formation_modules (course_id, title, description, duration, sort_order) VALUES (:cid, :tit, :desc, :dur, :sort)');
                foreach ($data['modules'] as $idx => $m) {
                    $stmtM->execute([':cid' => $id, ':tit' => $m['title'], ':desc' => $m['description'] ?? null, ':dur' => $m['duration'] ?? null, ':sort' => $m['sort_order'] ?? $idx]);
                }
            }
            if (isset($data['skills']) && is_array($data['skills'])) {
                $db->prepare("DELETE FROM formation_skills WHERE course_id = :id")->execute([':id' => $id]);
                $stmtS = $db->prepare('INSERT INTO formation_skills (course_id, name, sort_order) VALUES (:cid, :name, :sort)');
                foreach ($data['skills'] as $idx => $s) {
                    $stmtS->execute([':cid' => $id, ':name' => $s['name'], ':sort' => $s['sort_order'] ?? $idx]);
                }
            }
            if (isset($data['jobs']) && is_array($data['jobs'])) {
                $db->prepare("DELETE FROM formation_jobs WHERE course_id = :id")->execute([':id' => $id]);
                $stmtJ = $db->prepare('INSERT INTO formation_jobs (course_id, title, salary_min, salary_max, sort_order) VALUES (:cid, :tit, :min, :max, :sort)');
                foreach ($data['jobs'] as $idx => $j) {
                    $salMin = $j['salary_min'] ?? null;
                    $salMax = $j['salary_max'] ?? null;
                    $stmtJ->bindValue(':cid', $id, PDO::PARAM_INT);
                    $stmtJ->bindValue(':tit', $j['title'], PDO::PARAM_STR);
                    $stmtJ->bindValue(':min', $salMin, $salMin === null || $salMin === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
                    $stmtJ->bindValue(':max', $salMax, $salMax === null || $salMax === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
                    $stmtJ->bindValue(':sort', $j['sort_order'] ?? $idx, PDO::PARAM_INT);
                    $stmtJ->execute();
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'formation_course', $id, $old, $data);
            Response::success(['id' => $id], 'Course updated');

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update course', $e->getMessage());
        }
    });

    $router->delete('/api/admin/formation/courses/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT id FROM formation_courses WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Course not found'); return; }

        $stmt = $db->prepare('DELETE FROM formation_courses WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], $siteId, 'delete', 'formation_course', $id, $old, null);
        Response::noContent();
    });
}
