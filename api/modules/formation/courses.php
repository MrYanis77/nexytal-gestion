<?php
/**
 * modules/formation/courses.php — CRUD pour la table `formations`
 */

function registerFormationCoursesRoutes(Router $router): void
{
    // ===== LISTE =====
    $router->get('/api/admin/formation/courses', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['1=1'];
        $params = [];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'f.status = :status';
            $params[':status'] = $status;
        }
        if ($type = Router::getQueryParam('type')) {
            $where[] = 'f.type = :type';
            $params[':type'] = $type;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM formations f $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT f.*, cat.label as category_label 
             FROM formations f
             LEFT JOIN formation_categories cat ON f.category_id = cat.id
             $whereClause
             ORDER BY f.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        
        $results = $stmt->fetchAll();
        // Parse JSON
        foreach ($results as &$r) {
            $r['modalites_catalogue'] = $r['modalites_catalogue'] ? json_decode($r['modalites_catalogue'], true) : null;
        }

        Response::paginated($results, $total, $pagination['page'], $pagination['limit']);
    });

    // ===== DÉTAIL =====
    $router->get('/api/admin/formation/courses/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare("SELECT f.*, cat.label as category_label FROM formations f LEFT JOIN formation_categories cat ON f.category_id = cat.id WHERE f.id = :id LIMIT 1");
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $course = $stmt->fetch();

        if (!$course) { Response::notFound('Formation not found'); return; }
        
        $course['modalites_catalogue'] = $course['modalites_catalogue'] ? json_decode($course['modalites_catalogue'], true) : null;

        // Modules
        $stmtM = $db->prepare("SELECT * FROM formation_modules WHERE formation_id = :id ORDER BY sort_order ASC");
        $stmtM->execute([':id' => $id]);
        $course['modules'] = $stmtM->fetchAll();

        // Stats
        $stmtS = $db->prepare("SELECT * FROM formation_stats WHERE formation_id = :id ORDER BY sort_order ASC");
        $stmtS->execute([':id' => $id]);
        $course['stats'] = $stmtS->fetchAll();

        // Job outcomes
        $stmtJ = $db->prepare("SELECT * FROM formation_job_outcomes WHERE formation_id = :id ORDER BY sort_order ASC");
        $stmtJ->execute([':id' => $id]);
        $course['job_outcomes'] = $stmtJ->fetchAll();

        // List items
        $stmtL = $db->prepare("SELECT * FROM formation_list_items WHERE formation_id = :id ORDER BY list_type ASC, sort_order ASC");
        $stmtL->execute([':id' => $id]);
        $course['list_items'] = $stmtL->fetchAll();

        // Official certifications
        $stmtC = $db->prepare("SELECT * FROM formation_official_certifications WHERE formation_id = :id LIMIT 1");
        $stmtC->execute([':id' => $id]);
        $course['official_certification'] = $stmtC->fetch() ?: null;

        Response::success($course);
    });

    // ===== CRÉER =====
    $router->post('/api/admin/formation/courses', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('hero_title', 'Hero Title')->required('type', 'Type')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['hero_title']);
        $db = getDb();
        $db->beginTransaction();

        try {
            $stmt = $db->prepare(
                'INSERT INTO formations 
                 (slug, type, category_id, status, published_at, hero_title, hero_subtitle, hero_video_url, hero_image_url, card_image_url, 
                  seo_title, seo_description, presentation_title, presentation_content, presentation_image, programme_duration_label, modalites_catalogue, 
                  methodology, certification_label, evaluation_title, evaluation_description, debouches_title, debouches_subtitle, debouches_sectors, 
                  info_modalities_title, info_prerequisites_title, cta_title, cta_subtitle, cta_button_label, cta_button_url, cta_secondary_label, cta_secondary_url, 
                  internal_reference, sort_order, created_by, updated_by, created_at)
                 VALUES 
                 (:slug, :type, :cat_id, :status, :published_at, :ht, :hs, :hv, :hi, :ci, 
                  :seot, :seod, :pt, :pc, :pi, :pdl, :mc, 
                  :meth, :cl, :et, :ed, :dt, :ds, :dsec, 
                  :imt, :ipt, :ct, :csub, :cbl, :cbu, :csl, :csu, 
                  :ir, :so, :created_by, :updated_by, NOW())'
            );
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':type', $data['type'], PDO::PARAM_STR);
            $stmt->bindValue(':cat_id', $data['category_id'] ?? null, PDO::PARAM_INT);
            $status = $data['status'] ?? 'draft';
            $stmt->bindValue(':status', $status, PDO::PARAM_STR);
            $publishedAt = ($status === 'published') ? date('Y-m-d H:i:s') : ($data['published_at'] ?? null);
            $stmt->bindValue(':published_at', $publishedAt, PDO::PARAM_STR);
            
            $stmt->bindValue(':ht', $data['hero_title'], PDO::PARAM_STR);
            $stmt->bindValue(':hs', $data['hero_subtitle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':hv', $data['hero_video_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':hi', $data['hero_image_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':ci', $data['card_image_url'] ?? null, PDO::PARAM_STR);
            
            $stmt->bindValue(':seot', $data['seo_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':seod', $data['seo_description'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pt', $data['presentation_title'] ?? 'Le métier', PDO::PARAM_STR);
            $stmt->bindValue(':pc', $data['presentation_content'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pi', $data['presentation_image'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pdl', $data['programme_duration_label'] ?? null, PDO::PARAM_STR);
            
            $mc = isset($data['modalites_catalogue']) ? json_encode($data['modalites_catalogue']) : null;
            $stmt->bindValue(':mc', $mc, PDO::PARAM_STR);
            
            $stmt->bindValue(':meth', $data['methodology'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cl', $data['certification_label'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':et', $data['evaluation_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':ed', $data['evaluation_description'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':dt', $data['debouches_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':ds', $data['debouches_subtitle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':dsec', $data['debouches_sectors'] ?? null, PDO::PARAM_STR);
            
            $stmt->bindValue(':imt', $data['info_modalities_title'] ?? 'Modalités pratiques', PDO::PARAM_STR);
            $stmt->bindValue(':ipt', $data['info_prerequisites_title'] ?? 'Prérequis', PDO::PARAM_STR);
            $stmt->bindValue(':ct', $data['cta_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':csub', $data['cta_subtitle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cbl', $data['cta_button_label'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cbu', $data['cta_button_url'] ?? '/contact', PDO::PARAM_STR);
            $stmt->bindValue(':csl', $data['cta_secondary_label'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':csu', $data['cta_secondary_url'] ?? null, PDO::PARAM_STR);
            
            $stmt->bindValue(':ir', $data['internal_reference'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':so', $data['sort_order'] ?? 0, PDO::PARAM_INT);
            $stmt->bindValue(':created_by', $admin['id'], PDO::PARAM_INT);
            $stmt->bindValue(':updated_by', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $formationId = (int) $db->lastInsertId();

            if (isset($data['modules']) && is_array($data['modules'])) {
                $stmtM = $db->prepare('INSERT INTO formation_modules (formation_id, title, duration_label, description, sort_order) VALUES (:cid, :tit, :dur, :desc, :sort)');
                foreach ($data['modules'] as $idx => $m) {
                    $stmtM->execute([
                        ':cid' => $formationId,
                        ':tit' => $m['title'],
                        ':dur' => $m['duration_label'] ?? null,
                        ':desc' => $m['description'] ?? null,
                        ':sort' => $m['sort_order'] ?? $idx,
                    ]);
                }
            }

            if (isset($data['stats']) && is_array($data['stats'])) {
                $stmtS = $db->prepare('INSERT INTO formation_stats (formation_id, label, value, icon, sort_order) VALUES (:cid, :label, :value, :icon, :sort)');
                foreach ($data['stats'] as $idx => $s) {
                    $stmtS->execute([
                        ':cid' => $formationId,
                        ':label' => $s['label'],
                        ':value' => $s['value'],
                        ':icon' => $s['icon'] ?? null,
                        ':sort' => $s['sort_order'] ?? $idx,
                    ]);
                }
            }

            if (isset($data['job_outcomes']) && is_array($data['job_outcomes'])) {
                $stmtJ = $db->prepare('INSERT INTO formation_job_outcomes (formation_id, job_title, salary_label, sort_order) VALUES (:cid, :tit, :sal, :sort)');
                foreach ($data['job_outcomes'] as $idx => $j) {
                    $stmtJ->execute([
                        ':cid' => $formationId,
                        ':tit' => $j['job_title'],
                        ':sal' => $j['salary_label'] ?? null,
                        ':sort' => $j['sort_order'] ?? $idx,
                    ]);
                }
            }

            if (isset($data['list_items']) && is_array($data['list_items'])) {
                $stmtL = $db->prepare('INSERT INTO formation_list_items (formation_id, list_type, content, sort_order) VALUES (:cid, :type, :content, :sort)');
                foreach ($data['list_items'] as $idx => $item) {
                    $stmtL->execute([
                        ':cid' => $formationId,
                        ':type' => $item['list_type'],
                        ':content' => $item['content'],
                        ':sort' => $item['sort_order'] ?? $idx,
                    ]);
                }
            }

            if (!empty($data['official_certification'])) {
                $oc = $data['official_certification'];
                $stmtC = $db->prepare('INSERT INTO formation_official_certifications (formation_id, repertoire, code, official_title, level, france_competences_url, show_on_certification_page) VALUES (:cid, :rep, :code, :tit, :lvl, :url, :show)');
                $stmtC->execute([
                    ':cid' => $formationId,
                    ':rep' => $oc['repertoire'] ?? 'RNCP',
                    ':code' => $oc['code'],
                    ':tit' => $oc['official_title'],
                    ':lvl' => $oc['level'] ?? null,
                    ':url' => $oc['france_competences_url'],
                    ':show' => $oc['show_on_certification_page'] ?? 1,
                ]);
            }

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'create', 'formation', $formationId, null, $data);
            Response::created(['id' => $formationId]);

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create formation', $e->getMessage());
        }
    });

    // ===== MODIFIER =====
    $router->put('/api/admin/formation/courses/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM formations WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Formation not found'); return; }

        $db->beginTransaction();
        try {
            $fields = []; $bind = [];
            $updatable = [
                'slug', 'type', 'category_id', 'status', 'published_at', 'hero_title', 'hero_subtitle', 'hero_video_url', 'hero_image_url', 'card_image_url', 
                'seo_title', 'seo_description', 'presentation_title', 'presentation_content', 'presentation_image', 'programme_duration_label', 
                'methodology', 'certification_label', 'evaluation_title', 'evaluation_description', 'debouches_title', 'debouches_subtitle', 'debouches_sectors', 
                'info_modalities_title', 'info_prerequisites_title', 'cta_title', 'cta_subtitle', 'cta_button_label', 'cta_button_url', 'cta_secondary_label', 'cta_secondary_url', 
                'internal_reference', 'sort_order'
            ];
            
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }
            
            if (array_key_exists('modalites_catalogue', $data)) {
                $fields[] = "modalites_catalogue = :mc";
                $bind[':mc'] = is_array($data['modalites_catalogue']) ? json_encode($data['modalites_catalogue']) : $data['modalites_catalogue'];
            }

            if (!empty($fields)) {
                $fields[] = "updated_by = :uid"; $bind[':uid'] = $admin['id'];
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE formations SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->execute();
            }

            // Child updates (simplifiés : on supprime et recrée pour les arrays)
            if (isset($data['modules']) && is_array($data['modules'])) {
                $db->prepare("DELETE FROM formation_modules WHERE formation_id = :id")->execute([':id' => $id]);
                $stmtM = $db->prepare('INSERT INTO formation_modules (formation_id, title, duration_label, description, sort_order) VALUES (:cid, :tit, :dur, :desc, :sort)');
                foreach ($data['modules'] as $idx => $m) {
                    $stmtM->execute([':cid' => $id, ':tit' => $m['title'], ':dur' => $m['duration_label'] ?? null, ':desc' => $m['description'] ?? null, ':sort' => $m['sort_order'] ?? $idx]);
                }
            }

            if (isset($data['stats']) && is_array($data['stats'])) {
                $db->prepare("DELETE FROM formation_stats WHERE formation_id = :id")->execute([':id' => $id]);
                $stmtS = $db->prepare('INSERT INTO formation_stats (formation_id, label, value, icon, sort_order) VALUES (:cid, :label, :value, :icon, :sort)');
                foreach ($data['stats'] as $idx => $s) {
                    $stmtS->execute([':cid' => $id, ':label' => $s['label'], ':value' => $s['value'], ':icon' => $s['icon'] ?? null, ':sort' => $s['sort_order'] ?? $idx]);
                }
            }
            
            if (isset($data['job_outcomes']) && is_array($data['job_outcomes'])) {
                $db->prepare("DELETE FROM formation_job_outcomes WHERE formation_id = :id")->execute([':id' => $id]);
                $stmtS = $db->prepare('INSERT INTO formation_job_outcomes (formation_id, job_title, salary_label, sort_order) VALUES (:cid, :tit, :sal, :sort)');
                foreach ($data['job_outcomes'] as $idx => $s) {
                    $stmtS->execute([':cid' => $id, ':tit' => $s['job_title'], ':sal' => $s['salary_label'] ?? null, ':sort' => $s['sort_order'] ?? $idx]);
                }
            }
            
            if (isset($data['list_items']) && is_array($data['list_items'])) {
                $db->prepare("DELETE FROM formation_list_items WHERE formation_id = :id")->execute([':id' => $id]);
                $stmtS = $db->prepare('INSERT INTO formation_list_items (formation_id, list_type, content, sort_order) VALUES (:cid, :type, :content, :sort)');
                foreach ($data['list_items'] as $idx => $s) {
                    $stmtS->execute([':cid' => $id, ':type' => $s['list_type'], ':content' => $s['content'], ':sort' => $s['sort_order'] ?? $idx]);
                }
            }

            if (isset($data['official_certification'])) {
                $db->prepare("DELETE FROM formation_official_certifications WHERE formation_id = :id")->execute([':id' => $id]);
                if (!empty($data['official_certification'])) {
                    $oc = $data['official_certification'];
                    $stmtC = $db->prepare('INSERT INTO formation_official_certifications (formation_id, repertoire, code, official_title, level, france_competences_url, show_on_certification_page) VALUES (:cid, :rep, :code, :tit, :lvl, :url, :show)');
                    $stmtC->execute([
                        ':cid' => $id,
                        ':rep' => $oc['repertoire'] ?? 'RNCP',
                        ':code' => $oc['code'],
                        ':tit' => $oc['official_title'],
                        ':lvl' => $oc['level'] ?? null,
                        ':url' => $oc['france_competences_url'],
                        ':show' => $oc['show_on_certification_page'] ?? 1
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'update', 'formation', $id, $old, $data);
            Response::success(['id' => $id], 'Formation updated');

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update formation', $e->getMessage());
        }
    });

    // ===== SUPPRIMER =====
    $router->delete('/api/admin/formation/courses/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT id FROM formations WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Formation not found'); return; }

        $stmt = $db->prepare('DELETE FROM formations WHERE id = :id');
        $stmt->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 1, 'delete', 'formation', $id, $old, null);
        Response::noContent();
    });
}
