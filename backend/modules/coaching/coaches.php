<?php
/**
 * modules/coaching/coaches.php — CRUD coaching_coaches
 */

function registerCoachingCoachesRoutes(Router $router): void
{
    $router->get('/api/admin/coaching/coaches', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM coaching_coaches WHERE site_id = :site_id ORDER BY last_name ASC, first_name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $coaches = $stmt->fetchAll();

        foreach ($coaches as &$c) {
            $c['languages'] = $c['languages'] ? json_decode($c['languages'], true) : [];
            
            $stmtS = $db->prepare('SELECT s.id, s.name FROM coaching_specialties s INNER JOIN coaching_coach_specialties cs ON s.id = cs.specialty_id WHERE cs.coach_id = :id');
            $stmtS->execute([':id' => $c['id']]);
            $c['specialties'] = $stmtS->fetchAll();

            $stmtC = $db->prepare('SELECT c.id, c.code, c.organization, c.level, cc.year_obtained FROM coaching_certifications c INNER JOIN coaching_coach_certifications cc ON c.id = cc.certification_id WHERE cc.coach_id = :id');
            $stmtC->execute([':id' => $c['id']]);
            $c['certifications'] = $stmtC->fetchAll();
        }

        Response::success($coaches);
    });

    $router->get('/api/admin/coaching/coaches/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT c.*, city.name as city_name FROM coaching_coaches c LEFT JOIN coaching_cities city ON c.city_id = city.id WHERE c.id = :id AND c.site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $coach = $stmt->fetch();
        if (!$coach) { Response::notFound('Coach not found'); return; }

        $coach['languages'] = $coach['languages'] ? json_decode($coach['languages'], true) : [];
        
        $stmtS = $db->prepare('SELECT s.id, s.name FROM coaching_specialties s INNER JOIN coaching_coach_specialties cs ON s.id = cs.specialty_id WHERE cs.coach_id = :id');
        $stmtS->execute([':id' => $coach['id']]);
        $coach['specialties'] = $stmtS->fetchAll();

        $stmtC = $db->prepare('SELECT c.id, c.code, c.organization, c.level, cc.year_obtained FROM coaching_certifications c INNER JOIN coaching_coach_certifications cc ON c.id = cc.certification_id WHERE cc.coach_id = :id');
        $stmtC->execute([':id' => $coach['id']]);
        $coach['certifications'] = $stmtC->fetchAll();

        Response::success($coach);
    });

    $router->post('/api/admin/coaching/coaches', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('first_name', 'First name')->required('last_name', 'Last name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['first_name'] . ' ' . $data['last_name']);
        
        $db = getDb();
        $db->beginTransaction();
        try {
            $stmt = $db->prepare(
                'INSERT INTO coaching_coaches 
                 (site_id, first_name, last_name, slug, email, phone, avatar_url, title, short_bio, full_bio, experience_years, city_id, languages, status, is_available, meta_title, meta_description, created_at)
                 VALUES 
                 (:site_id, :fn, :ln, :slug, :email, :phone, :avatar, :title, :sbio, :fbio, :exp, :city_id, :lang, :status, :avail, :mtit, :mdesc, NOW())'
            );
            $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
            $stmt->bindValue(':fn', $data['first_name'], PDO::PARAM_STR);
            $stmt->bindValue(':ln', $data['last_name'], PDO::PARAM_STR);
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':email', $data['email'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':phone', $data['phone'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':avatar', $data['avatar_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':title', $data['title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':sbio', $data['short_bio'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':fbio', $data['full_bio'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':exp', $data['experience_years'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':city_id', $data['city_id'] ?? null, PDO::PARAM_INT);
            $lang = isset($data['languages']) ? json_encode($data['languages'], JSON_UNESCAPED_UNICODE) : null;
            $stmt->bindValue(':lang', $lang, PDO::PARAM_STR);
            $stmt->bindValue(':status', $data['status'] ?? 'pending', PDO::PARAM_STR);
            $stmt->bindValue(':avail', isset($data['is_available']) ? (int)$data['is_available'] : 1, PDO::PARAM_INT);
            $stmt->bindValue(':mtit', $data['meta_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':mdesc', $data['meta_description'] ?? null, PDO::PARAM_STR);
            $stmt->execute();
            
            $coachId = (int) $db->lastInsertId();

            if (!empty($data['specialty_ids']) && is_array($data['specialty_ids'])) {
                $stmtS = $db->prepare('INSERT INTO coaching_coach_specialties (coach_id, specialty_id) VALUES (:cid, :sid)');
                foreach ($data['specialty_ids'] as $sid) {
                    $stmtS->execute([':cid' => $coachId, ':sid' => $sid]);
                }
            }

            if (!empty($data['certifications']) && is_array($data['certifications'])) {
                $stmtC = $db->prepare('INSERT INTO coaching_coach_certifications (coach_id, certification_id, year_obtained) VALUES (:cid, :certid, :yr)');
                foreach ($data['certifications'] as $cert) {
                    $stmtC->execute([':cid' => $coachId, ':certid' => $cert['id'], ':yr' => $cert['year_obtained'] ?? null]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'coaching_coach', $coachId, null, $data);
            Response::created(['id' => $coachId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create coach', $e->getMessage());
        }
    });

    $router->put('/api/admin/coaching/coaches/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM coaching_coaches WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Coach not found'); return; }

        $db->beginTransaction();
        try {
            $fields = []; $bind = [];
            $updatable = ['first_name', 'last_name', 'slug', 'email', 'phone', 'avatar_url', 'title', 'short_bio', 'full_bio', 'experience_years', 'city_id', 'status', 'is_available', 'meta_title', 'meta_description'];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }
            if (array_key_exists('languages', $data)) {
                $fields[] = 'languages = :lang';
                $bind[':lang'] = isset($data['languages']) ? json_encode($data['languages'], JSON_UNESCAPED_UNICODE) : null;
            }

            if (!empty($fields)) {
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE coaching_coaches SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
            }

            if (isset($data['specialty_ids']) && is_array($data['specialty_ids'])) {
                $db->prepare("DELETE FROM coaching_coach_specialties WHERE coach_id = :id")->execute([':id' => $id]);
                $stmtS = $db->prepare('INSERT INTO coaching_coach_specialties (coach_id, specialty_id) VALUES (:cid, :sid)');
                foreach ($data['specialty_ids'] as $sid) {
                    $stmtS->execute([':cid' => $id, ':sid' => $sid]);
                }
            }

            if (isset($data['certifications']) && is_array($data['certifications'])) {
                $db->prepare("DELETE FROM coaching_coach_certifications WHERE coach_id = :id")->execute([':id' => $id]);
                $stmtC = $db->prepare('INSERT INTO coaching_coach_certifications (coach_id, certification_id, year_obtained) VALUES (:cid, :certid, :yr)');
                foreach ($data['certifications'] as $cert) {
                    $stmtC->execute([':cid' => $id, ':certid' => $cert['id'], ':yr' => $cert['year_obtained'] ?? null]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_coach', $id, $old, $data);
            Response::success(['id' => $id], 'Coach updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update coach', $e->getMessage());
        }
    });

    $router->delete('/api/admin/coaching/coaches/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT id FROM coaching_coaches WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Coach not found'); return; }

        $stmt = $db->prepare('DELETE FROM coaching_coaches WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaching_coach', $id, $old, null);
        Response::noContent();
    });
}
