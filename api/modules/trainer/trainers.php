<?php
/**
 * modules/trainer/trainers.php — CRUD trainers (v2.1)
 */

function registerTrainerTrainersRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/trainers', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $pagination = Router::getPagination();

        $stmt = $db->prepare('SELECT COUNT(*) as total FROM trainers WHERE deleted_at IS NULL');
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            'SELECT id, slug, first_name, last_name, title, tagline, bio, avatar_url, avatar_initials,
                    tjm_eur, experience_years, availability, legal_status, email, phone, linkedin_url,
                    status, is_featured, qualiopi_eligible, primary_expertise_id, city_id, created_at
             FROM trainers
             WHERE deleted_at IS NULL
             ORDER BY created_at DESC
             LIMIT :limit OFFSET :offset'
        );
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/trainer/trainers/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $trainer = $stmt->fetch();
        if (!$trainer) { Response::notFound('Trainer not found'); return; }

        $stmtE = $db->prepare(
            'SELECT e.*, tel.is_primary FROM expertises e
             INNER JOIN trainer_expertise_links tel ON e.id = tel.expertise_id
             WHERE tel.trainer_id = :id'
        );
        $stmtE->execute([':id' => $id]);
        $trainer['expertises'] = $stmtE->fetchAll();

        $stmtS = $db->prepare(
            'SELECT s.* FROM trainer_skills s
             INNER JOIN trainer_skill_links tsl ON s.id = tsl.skill_id
             WHERE tsl.trainer_id = :id ORDER BY s.name ASC'
        );
        $stmtS->execute([':id' => $id]);
        $trainer['skills'] = $stmtS->fetchAll();

        $stmtCert = $db->prepare(
            'SELECT c.* FROM trainer_certifications c
             INNER JOIN trainer_certification_links tcl ON c.id = tcl.certification_id
             WHERE tcl.trainer_id = :id ORDER BY c.name ASC'
        );
        $stmtCert->execute([':id' => $id]);
        $trainer['certifications'] = $stmtCert->fetchAll();

        $stmtC = $db->prepare('SELECT * FROM trainer_courses WHERE trainer_id = :id ORDER BY sort_order ASC');
        $stmtC->execute([':id' => $id]);
        $trainer['courses'] = $stmtC->fetchAll();

        $stmtM = $db->prepare('SELECT modality FROM trainer_modalities WHERE trainer_id = :id');
        $stmtM->execute([':id' => $id]);
        $trainer['modalities'] = array_column($stmtM->fetchAll(), 'modality');

        Response::success($trainer);
    });

    $router->post('/api/admin/trainer/trainers', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('first_name', 'Prénom')
            ->required('last_name', 'Nom')
            ->required('title', 'Titre')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $db = getDb();
        $slug = $data['slug'] ?? Validator::slugify($data['first_name'] . '-' . $data['last_name']);

        $stmt = $db->prepare('SELECT id FROM trainers WHERE email = :email LIMIT 1');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Email already used'); return; }

        $db->beginTransaction();
        try {
            $status = $data['status'] ?? 'pending_review';
            $stmt = $db->prepare(
                'INSERT INTO trainers
                 (slug, first_name, last_name, title, tagline, bio, avatar_initials, avatar_url, city_id,
                  experience_years, tjm_eur, availability, legal_status, primary_expertise_id, email, phone,
                  linkedin_url, status, is_featured, qualiopi_eligible, published_at, created_at, updated_at)
                 VALUES
                 (:slug, :fn, :ln, :title, :tag, :bio, :ai, :av, :cid, :ey, :tjm, :avail, :ls, :peid, :email, :phone,
                  :li, :status, :feat, :qual, :pub, NOW(), NOW())'
            );
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':fn', $data['first_name'], PDO::PARAM_STR);
            $stmt->bindValue(':ln', $data['last_name'], PDO::PARAM_STR);
            $stmt->bindValue(':title', $data['title'], PDO::PARAM_STR);
            $stmt->bindValue(':tag', $data['tagline'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':bio', $data['bio'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':ai', $data['avatar_initials'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':av', $data['avatar_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cid', $data['city_id'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':ey', $data['experience_years'] ?? 0, PDO::PARAM_INT);
            $stmt->bindValue(':tjm', $data['tjm_eur'] ?? null);
            $stmt->bindValue(':avail', $data['availability'] ?? 'available', PDO::PARAM_STR);
            $stmt->bindValue(':ls', $data['legal_status'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':peid', $data['primary_expertise_id'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':email', $data['email'], PDO::PARAM_STR);
            $stmt->bindValue(':phone', $data['phone'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':li', $data['linkedin_url'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':status', $status, PDO::PARAM_STR);
            $stmt->bindValue(':feat', $data['is_featured'] ?? 0, PDO::PARAM_INT);
            $stmt->bindValue(':qual', $data['qualiopi_eligible'] ?? 0, PDO::PARAM_INT);
            $pubAt = ($status === 'active') ? date('Y-m-d H:i:s') : null;
            $stmt->bindValue(':pub', $pubAt, PDO::PARAM_STR);
            $stmt->execute();

            $newId = (int) $db->lastInsertId();
            trainerSyncLinks($db, $newId, $data);

            $db->commit();
            Audit::log((int) $admin['id'], 5, 'create', 'trainer', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create trainer', $e->getMessage());
        }
    });

    $router->put('/api/admin/trainer/trainers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Trainer not found'); return; }

        $db->beginTransaction();
        try {
            $fields = [];
            $bind = [];
            $updatable = [
                'slug', 'first_name', 'last_name', 'title', 'tagline', 'bio', 'avatar_initials', 'avatar_url',
                'city_id', 'experience_years', 'tjm_eur', 'availability', 'legal_status', 'primary_expertise_id',
                'email', 'phone', 'linkedin_url', 'status', 'is_featured', 'qualiopi_eligible', 'published_at',
            ];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
            }
            if (!empty($fields)) {
                $fields[] = 'updated_at = NOW()';
                $sql = 'UPDATE trainers SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->execute();
            }

            trainerSyncLinks($db, $id, $data);

            $db->commit();
            Audit::log((int) $admin['id'], 5, 'update', 'trainer', $id, $old, $data);
            Response::success(['id' => $id], 'Trainer updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update trainer', $e->getMessage());
        }
    });

    $router->delete('/api/admin/trainer/trainers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Trainer not found'); return; }

        $stmt = $db->prepare('UPDATE trainers SET deleted_at = NOW(), status = :st WHERE id = :id');
        $stmt->execute([':st' => 'inactive', ':id' => $id]);

        Audit::log((int) $admin['id'], 5, 'delete', 'trainer', $id, $old, null);
        Response::noContent();
    });
}

function trainerSyncLinks(PDO $db, int $trainerId, array $data): void
{
    if (isset($data['expertise_ids']) && is_array($data['expertise_ids'])) {
        $db->prepare('DELETE FROM trainer_expertise_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtE = $db->prepare('INSERT INTO trainer_expertise_links (trainer_id, expertise_id, is_primary) VALUES (:tid, :eid, :pri)');
        foreach ($data['expertise_ids'] as $eId) {
            $isPrimary = ((int) ($data['primary_expertise_id'] ?? 0) === (int) $eId) ? 1 : 0;
            $stmtE->execute([':tid' => $trainerId, ':eid' => (int) $eId, ':pri' => $isPrimary]);
        }
    }

    if (isset($data['skill_ids']) && is_array($data['skill_ids'])) {
        $db->prepare('DELETE FROM trainer_skill_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtS = $db->prepare('INSERT INTO trainer_skill_links (trainer_id, skill_id) VALUES (:tid, :sid)');
        foreach ($data['skill_ids'] as $sId) {
            $stmtS->execute([':tid' => $trainerId, ':sid' => (int) $sId]);
        }
    }

    if (isset($data['modalities']) && is_array($data['modalities'])) {
        $db->prepare('DELETE FROM trainer_modalities WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtM = $db->prepare('INSERT INTO trainer_modalities (trainer_id, modality) VALUES (:tid, :mod)');
        foreach ($data['modalities'] as $mod) {
            $stmtM->execute([':tid' => $trainerId, ':mod' => $mod]);
        }
    }

    if (isset($data['courses']) && is_array($data['courses'])) {
        $db->prepare('DELETE FROM trainer_courses WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtC = $db->prepare(
            'INSERT INTO trainer_courses (trainer_id, title, duration_label, description, is_active, sort_order, created_at)
             VALUES (:tid, :title, :dur, :desc, :act, :so, NOW())'
        );
        foreach ($data['courses'] as $idx => $c) {
            $stmtC->execute([
                ':tid' => $trainerId,
                ':title' => $c['title'],
                ':dur' => $c['duration_label'] ?? null,
                ':desc' => $c['description'] ?? null,
                ':act' => $c['is_active'] ?? 1,
                ':so' => $c['sort_order'] ?? $idx,
            ]);
        }
    }

    if (isset($data['certification_ids']) && is_array($data['certification_ids'])) {
        $db->prepare('DELETE FROM trainer_certification_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtCert = $db->prepare('INSERT INTO trainer_certification_links (trainer_id, certification_id, obtained_at, expires_at) VALUES (:tid, :cid, :obt, :exp)');
        foreach ($data['certification_ids'] as $cert) {
            $certId = is_array($cert) ? $cert['certification_id'] : $cert;
            $stmtCert->execute([
                ':tid' => $trainerId, ':cid' => (int) $certId,
                ':obt' => is_array($cert) ? ($cert['obtained_at'] ?? null) : null,
                ':exp' => is_array($cert) ? ($cert['expires_at'] ?? null) : null,
            ]);
        }
    }

    if (isset($data['language_ids']) && is_array($data['language_ids'])) {
        $db->prepare('DELETE FROM trainer_language_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtL = $db->prepare('INSERT INTO trainer_language_links (trainer_id, language_id, level) VALUES (:tid, :lid, :lvl)');
        foreach ($data['language_ids'] as $lang) {
            $langId = is_array($lang) ? $lang['language_id'] : $lang;
            $stmtL->execute([
                ':tid' => $trainerId, ':lid' => (int) $langId,
                ':lvl' => is_array($lang) ? ($lang['level'] ?? 'native') : 'native',
            ]);
        }
    }

    if (isset($data['city_ids']) && is_array($data['city_ids'])) {
        $db->prepare('DELETE FROM trainer_city_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtCity = $db->prepare('INSERT INTO trainer_city_links (trainer_id, city_id) VALUES (:tid, :cid)');
        foreach ($data['city_ids'] as $cityId) {
            $stmtCity->execute([':tid' => $trainerId, ':cid' => (int) $cityId]);
        }
    }
}
