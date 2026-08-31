<?php
/**
 * modules/trainer/trainers.php — profils formateurs (admin + validation type coach)
 */

function trainerAwaitingValidation(string $status): bool
{
    return in_array($status, ['pending_review', 'draft'], true);
}

function trainerFetchById(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND deleted_at IS NULL LIMIT 1');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function trainerPendingWhereClause(): string
{
    return "t.status IN ('pending_review', 'draft') AND t.validated_at IS NULL AND t.deleted_at IS NULL";
}

function registerTrainerTrainersRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/trainers/pending-count', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            $stmt = $db->prepare(
                'SELECT COUNT(*) AS total FROM trainers t WHERE ' . trainerPendingWhereClause() . ' AND t.site_id = :site_id'
            );
            $stmt->execute([':site_id' => (int) $siteId]);
        } else {
            $stmt = $db->prepare('SELECT COUNT(*) AS total FROM trainers t WHERE ' . trainerPendingWhereClause());
            $stmt->execute();
        }
        Response::success(['count' => (int) $stmt->fetch()['total']]);
    });

    $router->get('/api/admin/trainer/trainers/pending', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $pagination = Router::getPagination();
        $siteId = Router::getQueryParam('site_id');

        $where = [trainerPendingWhereClause()];
        $params = [];
        if ($siteId) {
            $where[] = 't.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) AS total FROM trainers t $whereClause");
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT t.*, tc.name AS city_name, s.name AS site_name, s.slug AS site_slug
             FROM trainers t
             LEFT JOIN trainer_cities tc ON tc.id = t.city_id
             INNER JOIN core_sites s ON s.id = t.site_id
             $whereClause
             ORDER BY t.created_at ASC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/trainer/trainers', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT t.*, tc.name AS city_name,
                GROUP_CONCAT(DISTINCT COALESCE(e.label, e.name) ORDER BY tel.is_primary DESC, e.label SEPARATOR \', \') AS expertise_labels,
                CASE WHEN t.status = \'active\' AND t.validated_at IS NOT NULL THEN 1 ELSE 0 END AS on_catalog
             FROM trainers t
             LEFT JOIN trainer_cities tc ON tc.id = t.city_id
             LEFT JOIN trainer_expertise_links tel ON tel.trainer_id = t.id
             LEFT JOIN expertises e ON e.id = tel.expertise_id
             WHERE t.site_id = :site_id AND t.deleted_at IS NULL
             GROUP BY t.id
             ORDER BY t.created_at DESC'
        );
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/trainer/trainers/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $trainer = $stmt->fetch();
        if (!$trainer) {
            Response::notFound('Trainer not found');
            return;
        }

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

    $router->post('/api/admin/trainer/trainers/{id}/publish', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $old = trainerFetchById($db, $id);
        if (!$old) {
            Response::notFound('Trainer not found');
            return;
        }

        $status = trim((string) ($old['status'] ?? ''));
        if ($status === 'active' && !empty($old['validated_at'])) {
            Response::success([
                'id' => $id,
                'status' => 'active',
                'site_id' => (int) $old['site_id'],
                'already_published' => true,
            ], 'Profil déjà publié');
            return;
        }

        if ($status === 'active' && empty($old['validated_at'])) {
            $db->prepare(
                "UPDATE trainers SET
                    validated_at = NOW(),
                    validated_by = :admin_id,
                    published_at = COALESCE(published_at, NOW()),
                    updated_at = NOW()
                 WHERE id = :id"
            )->execute([':id' => $id, ':admin_id' => (int) $admin['id']]);

            require_once __DIR__ . '/../../core/ValidationNotify.php';
            $fresh = trainerFetchById($db, $id) ?: $old;
            $emailSent = validationNotifyTrainer($db, $fresh);

            Audit::log((int) $admin['id'], (int) $old['site_id'], 'publish', 'trainers', $id, $old, [
                'status' => 'active',
                'validated_by' => (int) $admin['id'],
                'email_sent' => $emailSent,
                'backfill_validated_at' => true,
            ]);
            Response::success([
                'id' => $id,
                'status' => 'active',
                'site_id' => (int) $old['site_id'],
                'email_sent' => $emailSent,
            ], 'Profil publié sur le catalogue');
            return;
        }

        if (!trainerAwaitingValidation($status)) {
            Response::badRequest('Ce profil ne peut pas être publié (statut actuel : ' . $status . ')');
            return;
        }

        if (trim((string) ($old['first_name'] ?? '')) === '' || trim((string) ($old['last_name'] ?? '')) === '' || trim((string) ($old['title'] ?? '')) === '') {
            Response::validationError(['first_name' => 'Identité et titre requis'], 'Complétez le profil avant publication');
            return;
        }

        $db->beginTransaction();
        try {
            $db->prepare(
                "UPDATE trainers SET
                    status = 'active',
                    validated_at = COALESCE(validated_at, NOW()),
                    validated_by = COALESCE(validated_by, :admin_id),
                    published_at = COALESCE(published_at, NOW()),
                    updated_at = NOW()
                 WHERE id = :id"
            )->execute([':id' => $id, ':admin_id' => (int) $admin['id']]);

            require_once __DIR__ . '/../../core/ValidationNotify.php';
            $fresh = trainerFetchById($db, $id) ?: array_merge($old, ['status' => 'active']);
            $emailSent = validationNotifyTrainer($db, $fresh);

            $db->commit();

            Audit::log((int) $admin['id'], (int) $old['site_id'], 'publish', 'trainers', $id, $old, [
                'status' => 'active',
                'validated_by' => (int) $admin['id'],
                'email_sent' => $emailSent,
            ]);
            Response::success([
                'id' => $id,
                'status' => 'active',
                'site_id' => (int) $old['site_id'],
                'email_sent' => $emailSent,
            ], 'Profil formateur publié');
        } catch (\Throwable $e) {
            $db->rollBack();
            Response::serverError('Échec de la publication', $e->getMessage());
        }
    });

    $router->post('/api/admin/trainer/trainers/{id}/reject', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $old = trainerFetchById($db, $id);
        if (!$old) {
            Response::notFound('Trainer not found');
            return;
        }

        $status = trim((string) ($old['status'] ?? ''));
        if (!trainerAwaitingValidation($status)) {
            Response::badRequest('Ce profil ne peut pas être refusé (statut actuel : ' . $status . ')');
            return;
        }

        $db->prepare("UPDATE trainers SET status = 'inactive', updated_at = NOW() WHERE id = :id")
            ->execute([':id' => $id]);

        require_once __DIR__ . '/../../core/ActionNotify.php';
        $emailSent = ActionNotify::trainerStatusChanged($db, $old, 'inactive', $data['motif_refus'] ?? null);

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'reject', 'trainers', $id, $old, array_merge($data, ['email_sent' => $emailSent]));
        Response::success(['id' => $id, 'status' => 'inactive', 'site_id' => (int) $old['site_id'], 'email_sent' => $emailSent], 'Profil formateur refusé');
    });

    $router->post('/api/admin/trainer/trainers', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('first_name', 'Prénom')
            ->required('last_name', 'Nom')
            ->required('title', 'Titre')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $db = getDb();
        $slugBase = $data['slug'] ?? Validator::slugify($data['first_name'] . '-' . $data['last_name']);
        $slug = $slugBase;
        $suffix = 0;
        while (true) {
            $stmt = $db->prepare('SELECT id FROM trainers WHERE site_id = :site_id AND slug = :slug LIMIT 1');
            $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
            if (!$stmt->fetch()) {
                break;
            }
            $suffix++;
            $slug = $slugBase . '-' . $suffix;
        }

        $db->beginTransaction();
        try {
            $status = $data['status'] ?? 'pending_review';
            $validatedAt = null;
            $validatedBy = null;
            if ($status === 'active') {
                $validatedAt = date('Y-m-d H:i:s');
                $validatedBy = (int) $admin['id'];
            }
            $stmt = $db->prepare(
                'INSERT INTO trainers
                 (site_id, slug, first_name, last_name, title, tagline, bio, avatar_initials, avatar_url, city_id,
                  experience_years, tjm_eur, legal_status, primary_expertise_id, email, phone,
                  linkedin_url, status, is_featured, qualiopi_eligible, sort_order, published_at, validated_at, validated_by, created_at)
                 VALUES
                 (:site_id, :slug, :fn, :ln, :title, :tag, :bio, :ai, :av, :cid, :ey, :tjm, :ls, :peid, :email, :phone,
                  :li, :status, :feat, :qual, :so, :pub, :vat, :vby, NOW())'
            );
            $pubAt = ($status === 'active') ? date('Y-m-d H:i:s') : ($data['published_at'] ?? null);
            $stmt->execute([
                ':site_id' => $siteId,
                ':slug' => $slug,
                ':fn' => $data['first_name'],
                ':ln' => $data['last_name'],
                ':title' => $data['title'],
                ':tag' => $data['tagline'] ?? null,
                ':bio' => $data['bio'] ?? null,
                ':ai' => $data['avatar_initials'] ?? null,
                ':av' => $data['avatar_url'] ?? null,
                ':cid' => $data['city_id'] ?? null,
                ':ey' => (int) ($data['experience_years'] ?? 0),
                ':tjm' => $data['tjm_eur'] ?? null,
                ':ls' => $data['legal_status'] ?? null,
                ':peid' => $data['primary_expertise_id'] ?? null,
                ':email' => $data['email'],
                ':phone' => $data['phone'] ?? null,
                ':li' => $data['linkedin_url'] ?? null,
                ':status' => $status,
                ':feat' => (int) ($data['is_featured'] ?? 0),
                ':qual' => (int) ($data['qualiopi_eligible'] ?? 0),
                ':so' => (int) ($data['sort_order'] ?? 0),
                ':pub' => $pubAt,
                ':vat' => $validatedAt,
                ':vby' => $validatedBy,
            ]);

            $newId = (int) $db->lastInsertId();
            trainerSyncLinks($db, $newId, $data);

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'trainers', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create trainer', $e->getMessage());
        }
    });

    $router->put('/api/admin/trainer/trainers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Trainer not found');
            return;
        }

        $db->beginTransaction();
        try {
            $fields = [];
            $bind = [];
            foreach ([
                'slug', 'first_name', 'last_name', 'title', 'tagline', 'bio', 'avatar_initials', 'avatar_url',
                'city_id', 'experience_years', 'tjm_eur', 'legal_status', 'primary_expertise_id',
                'email', 'phone', 'linkedin_url', 'status', 'is_featured', 'qualiopi_eligible', 'sort_order', 'published_at',
            ] as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
            }
            if (array_key_exists('status', $data) && $data['status'] === 'active') {
                $fields[] = 'validated_at = COALESCE(validated_at, NOW())';
                $fields[] = 'validated_by = COALESCE(validated_by, :validated_by)';
                $bind[':validated_by'] = (int) $admin['id'];
                if (!array_key_exists('published_at', $data)) {
                    $fields[] = 'published_at = COALESCE(published_at, NOW())';
                }
            }
            if (!empty($fields)) {
                $fields[] = 'updated_at = NOW()';
                $sql = 'UPDATE trainers SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) {
                    $stmtU->bindValue($k, $v);
                }
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->bindParam(':site_id', $siteId, PDO::PARAM_INT);
                $stmtU->execute();
            }

            trainerSyncLinks($db, $id, $data);

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'trainers', $id, $old, $data);
            Response::success(['id' => $id], 'Trainer updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update trainer', $e->getMessage());
        }
    });

    $router->delete('/api/admin/trainer/trainers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Trainer not found');
            return;
        }

        $db->prepare("UPDATE trainers SET deleted_at = NOW(), status = 'inactive' WHERE id = :id")
            ->execute([':id' => $id]);

        Audit::log((int) $admin['id'], $siteId, 'delete', 'trainers', $id, $old, null);
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
        $stmtCert = $db->prepare('INSERT INTO trainer_certification_links (trainer_id, certification_id) VALUES (:tid, :cid)');
        foreach ($data['certification_ids'] as $cert) {
            $certId = is_array($cert) ? ($cert['certification_id'] ?? $cert['id'] ?? null) : $cert;
            if ($certId) {
                $stmtCert->execute([':tid' => $trainerId, ':cid' => (int) $certId]);
            }
        }
    }

    if (isset($data['language_ids']) && is_array($data['language_ids'])) {
        $db->prepare('DELETE FROM trainer_language_links WHERE trainer_id = :id')->execute([':id' => $trainerId]);
        $stmtL = $db->prepare('INSERT INTO trainer_language_links (trainer_id, language_id, level) VALUES (:tid, :lid, :lvl)');
        foreach ($data['language_ids'] as $lang) {
            $langId = is_array($lang) ? ($lang['language_id'] ?? $lang['id'] ?? null) : $lang;
            if ($langId) {
                $stmtL->execute([
                    ':tid' => $trainerId,
                    ':lid' => (int) $langId,
                    ':lvl' => is_array($lang) ? ($lang['level'] ?? 'Courant') : 'Courant',
                ]);
            }
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
