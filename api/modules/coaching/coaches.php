<?php
/**
 * modules/coaching/coaches.php — profils coachs (admin + validation type recrutement)
 */

function coachAwaitingValidation(string $status): bool
{
    return in_array($status, ['pending_review', 'draft'], true);
}

function coachFetchById(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM coaches WHERE id = :id AND deleted_at IS NULL LIMIT 1');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function coachPendingWhereClause(): string
{
    return "c.status IN ('pending_review', 'draft') AND c.validated_at IS NULL AND c.deleted_at IS NULL";
}

function registerCoachingCoachesRoutes(Router $router): void {
    $router->get('/api/admin/coaching/coaches/pending-count', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            $stmt = $db->prepare(
                'SELECT COUNT(*) AS total FROM coaches c WHERE ' . coachPendingWhereClause() . ' AND c.site_id = :site_id'
            );
            $stmt->execute([':site_id' => (int) $siteId]);
        } else {
            $stmt = $db->prepare('SELECT COUNT(*) AS total FROM coaches c WHERE ' . coachPendingWhereClause());
            $stmt->execute();
        }
        Response::success(['count' => (int) $stmt->fetch()['total']]);
    });

    $router->get('/api/admin/coaching/coaches/pending', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $pagination = Router::getPagination();
        $siteId = Router::getQueryParam('site_id');

        $where = [coachPendingWhereClause()];
        $params = [];
        if ($siteId) {
            $where[] = 'c.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) AS total FROM coaches c $whereClause");
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT c.*, cc.name AS location, s.name AS site_name, s.slug AS site_slug
             FROM coaches c
             LEFT JOIN coaching_cities cc ON cc.id = c.city_id
             INNER JOIN core_sites s ON s.id = c.site_id
             $whereClause
             ORDER BY c.created_at ASC
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

    $router->get('/api/admin/coaching/coaches', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmtAll = $db->prepare('
            SELECT c.*, cc.name as location
            FROM coaches c
            LEFT JOIN coaching_cities cc ON cc.id = c.city_id
            WHERE c.site_id = :site_id AND c.deleted_at IS NULL
            ORDER BY c.created_at DESC
        ');
        $stmtAll->execute([':site_id' => $siteId]);
        $allCoaches = $stmtAll->fetchAll();

        Response::success($allCoaches);
    });

    $router->get('/api/admin/coaching/coaches/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $db = getDb();
        
        $stmt = $db->prepare('SELECT * FROM coaches WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $coach = $stmt->fetch();
        if (!$coach) { Response::notFound('Coach not found'); return; }

        $stmtLinks = $db->prepare('SELECT specialty_id FROM coach_specialty_links WHERE coach_id = :id');
        $stmtLinks->execute([':id' => $id]);
        $coach['specialties'] = array_column($stmtLinks->fetchAll(), 'specialty_id');

        $stmtLinks = $db->prepare('SELECT certification_id FROM coach_certification_links WHERE coach_id = :id');
        $stmtLinks->execute([':id' => $id]);
        $coach['certifications'] = array_column($stmtLinks->fetchAll(), 'certification_id');

        $stmtLinks = $db->prepare('SELECT language_id FROM coach_language_links WHERE coach_id = :id');
        $stmtLinks->execute([':id' => $id]);
        $coach['languages'] = array_column($stmtLinks->fetchAll(), 'language_id');

        Response::success($coach);
    });

    $router->post('/api/admin/coaching/coaches/{id}/publish', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $old = coachFetchById($db, $id);
        if (!$old) {
            Response::notFound('Coach not found');
            return;
        }

        $status = trim((string) ($old['status'] ?? ''));
        if ($status === 'active') {
            Response::success([
                'id' => $id,
                'status' => 'active',
                'site_id' => (int) $old['site_id'],
                'already_published' => true,
            ], 'Profil déjà publié');
            return;
        }

        if (!coachAwaitingValidation($status)) {
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
                "UPDATE coaches SET
                    status = 'active',
                    validated_at = COALESCE(validated_at, NOW()),
                    validated_by = COALESCE(validated_by, :admin_id),
                    published_at = COALESCE(published_at, NOW()),
                    updated_at = NOW()
                 WHERE id = :id"
            )->execute([':id' => $id, ':admin_id' => (int) $admin['id']]);

            require_once __DIR__ . '/../../core/ValidationNotify.php';
            $fresh = coachFetchById($db, $id) ?: array_merge($old, ['status' => 'active']);
            $emailSent = validationNotifyCoach($db, $fresh);

            $db->commit();

            Audit::log((int) $admin['id'], (int) $old['site_id'], 'publish', 'coaches', $id, $old, [
                'status' => 'active',
                'validated_by' => (int) $admin['id'],
                'email_sent' => $emailSent,
            ]);
            Response::success([
                'id' => $id,
                'status' => 'active',
                'site_id' => (int) $old['site_id'],
                'email_sent' => $emailSent,
            ], 'Profil coach publié');
        } catch (\Throwable $e) {
            $db->rollBack();
            Response::serverError('Échec de la publication', $e->getMessage());
        }
    });

    $router->post('/api/admin/coaching/coaches/{id}/reject', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $old = coachFetchById($db, $id);
        if (!$old) {
            Response::notFound('Coach not found');
            return;
        }

        $status = trim((string) ($old['status'] ?? ''));
        if (!coachAwaitingValidation($status)) {
            Response::badRequest('Ce profil ne peut pas être refusé (statut actuel : ' . $status . ')');
            return;
        }

        $db->prepare("UPDATE coaches SET status = 'inactive', updated_at = NOW() WHERE id = :id")
            ->execute([':id' => $id]);

        require_once __DIR__ . '/../../core/ActionNotify.php';
        $emailSent = ActionNotify::coachStatusChanged($db, $old, 'inactive', $data['motif_refus'] ?? null);

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'reject', 'coaches', $id, $old, array_merge($data, ['email_sent' => $emailSent]));
        Response::success(['id' => $id, 'status' => 'inactive', 'site_id' => (int) $old['site_id'], 'email_sent' => $emailSent], 'Profil coach refusé');
    });

    $router->post('/api/admin/coaching/coaches', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        if (!isset($data['specialties']) && isset($data['specialty_ids'])) {
            $data['specialties'] = $data['specialty_ids'];
        }
        if (!isset($data['languages']) && isset($data['language_ids'])) {
            $data['languages'] = $data['language_ids'];
        }
        Validator::make($data)->required('first_name', 'First Name')->required('last_name', 'Last Name')->required('title', 'Title')->validate();
        
        $db = getDb();
        $db->beginTransaction();
        try {
            $slug = $data['slug'] ?? Validator::slugify($data['first_name'] . ' ' . $data['last_name']);
            
            $stmt = $db->prepare('
                INSERT INTO coaches (site_id, slug, first_name, last_name, title, bio_short, bio_full, avatar_url, avatar_initials, city_id, email, phone, linkedin_url, experience_years, status, is_featured, sort_order, published_at, created_at) 
                VALUES (:site_id, :slug, :fn, :ln, :title, :bs, :bf, :au, :ai, :ci, :em, :ph, :lu, :ey, :st, :if, :so, :pa, NOW())
            ');
            $stmt->execute([
                ':site_id' => $siteId,
                ':slug' => $slug,
                ':fn' => $data['first_name'],
                ':ln' => $data['last_name'],
                ':title' => $data['title'],
                ':bs' => $data['bio_short'] ?? null,
                ':bf' => $data['bio_full'] ?? null,
                ':au' => $data['avatar_url'] ?? null,
                ':ai' => $data['avatar_initials'] ?? substr((string) $data['first_name'], 0, 1) . substr((string) $data['last_name'], 0, 1),
                ':ci' => $data['city_id'] ?? null,
                ':em' => $data['email'] ?? null,
                ':ph' => $data['phone'] ?? null,
                ':lu' => $data['linkedin_url'] ?? null,
                ':ey' => $data['experience_years'] ?? 0,
                ':st' => $data['status'] ?? 'pending_review',
                ':if' => $data['is_featured'] ?? 0,
                ':so' => $data['sort_order'] ?? 0,
                ':pa' => $data['published_at'] ?? null,
            ]);
            $newId = (int) $db->lastInsertId();

            if (!empty($data['specialties']) && is_array($data['specialties'])) {
                $stmtLink = $db->prepare('INSERT INTO coach_specialty_links (coach_id, specialty_id) VALUES (:cid, :sid)');
                foreach ($data['specialties'] as $sid) {
                    $sid = is_array($sid) ? ($sid['id'] ?? $sid['specialty_id'] ?? null) : $sid;
                    if ($sid) $stmtLink->execute([':cid' => $newId, ':sid' => (int) $sid]);
                }
            }
            if (!empty($data['certifications']) && is_array($data['certifications'])) {
                $stmtLink = $db->prepare('INSERT INTO coach_certification_links (coach_id, certification_id) VALUES (:cid, :sid)');
                foreach ($data['certifications'] as $sid) {
                    $sid = is_array($sid) ? ($sid['id'] ?? $sid['certification_id'] ?? null) : $sid;
                    if ($sid) $stmtLink->execute([':cid' => $newId, ':sid' => (int) $sid]);
                }
            }
            if (!empty($data['languages']) && is_array($data['languages'])) {
                $stmtLink = $db->prepare('INSERT INTO coach_language_links (coach_id, language_id) VALUES (:cid, :sid)');
                foreach ($data['languages'] as $sid) {
                    $sid = is_array($sid) ? ($sid['id'] ?? $sid['language_id'] ?? null) : $sid;
                    if ($sid) $stmtLink->execute([':cid' => $newId, ':sid' => (int) $sid]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'coaches', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create coach', $e->getMessage());
        }
    });

    $router->put('/api/admin/coaching/coaches/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $data = Router::getJsonBody();
        
        $db = getDb();
        $db->beginTransaction();
        try {
            $fields = [];
            $bind = [];
            foreach (['slug', 'first_name', 'last_name', 'title', 'bio_short', 'bio_full', 'avatar_url', 'avatar_initials', 'city_id', 'email', 'phone', 'linkedin_url', 'experience_years', 'status', 'is_featured', 'sort_order', 'published_at'] as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }
            
            if (!empty($fields)) {
                $sql = 'UPDATE coaches SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->bindParam(':site_id', $siteId, PDO::PARAM_INT);
                $stmtU->execute();
            }

            if (isset($data['specialties']) && is_array($data['specialties'])) {
                $db->prepare('DELETE FROM coach_specialty_links WHERE coach_id = :id')->execute([':id' => $id]);
                $stmtLink = $db->prepare('INSERT INTO coach_specialty_links (coach_id, specialty_id) VALUES (:cid, :sid)');
                foreach ($data['specialties'] as $sid) $stmtLink->execute([':cid' => $id, ':sid' => $sid]);
            }

            if (isset($data['certifications']) && is_array($data['certifications'])) {
                $db->prepare('DELETE FROM coach_certification_links WHERE coach_id = :id')->execute([':id' => $id]);
                $stmtLink = $db->prepare('INSERT INTO coach_certification_links (coach_id, certification_id) VALUES (:cid, :sid)');
                foreach ($data['certifications'] as $sid) $stmtLink->execute([':cid' => $id, ':sid' => $sid]);
            }

            if (isset($data['languages']) && is_array($data['languages'])) {
                $db->prepare('DELETE FROM coach_language_links WHERE coach_id = :id')->execute([':id' => $id]);
                $stmtLink = $db->prepare('INSERT INTO coach_language_links (coach_id, language_id) VALUES (:cid, :sid)');
                foreach ($data['languages'] as $sid) $stmtLink->execute([':cid' => $id, ':sid' => $sid]);
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'coaches', $id, null, $data);
            Response::success(['id' => $id]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update coach', $e->getMessage());
        }
    });

    $router->delete('/api/admin/coaching/coaches/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        
        getDb()->prepare('UPDATE coaches SET deleted_at = NOW() WHERE id = :id AND site_id = :site_id')->execute([
            ':id' => $id,
            ':site_id' => $siteId
        ]);
        
        Audit::log((int) $admin['id'], $siteId, 'delete', 'coaches', $id, null, null);
        Response::noContent();
    });
}
