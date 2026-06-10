<?php
/**
 * modules/recrutement/offers.php — CRUD recrutement_offers
 * 
 * Gestion en cascade de : missions, profils, avantages, tags.
 */

function registerRecrutementOffersRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/offers', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['o.site_id = :site_id', 'o.deleted_at IS NULL'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'o.status = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM recrutement_offers o $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.*, j.name as job_name, c.name as contract_type_name
             FROM recrutement_offers o
             LEFT JOIN recrutement_jobs j ON o.job_id = j.id
             LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id
             $whereClause
             ORDER BY o.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $offers = $stmt->fetchAll();

        Response::paginated($offers, $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/recrutement/offers/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            "SELECT o.*, j.name as job_name, c.name as contract_type_name
             FROM recrutement_offers o
             LEFT JOIN recrutement_jobs j ON o.job_id = j.id
             LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id
             WHERE o.id = :id AND o.site_id = :site_id AND o.deleted_at IS NULL LIMIT 1"
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $offer = $stmt->fetch();

        if (!$offer) { Response::notFound('Offer not found'); return; }

        // Fetch cascaded entities
        foreach (['missions' => 'recrutement_offer_missions', 'profiles' => 'recrutement_offer_profiles', 'advantages' => 'recrutement_offer_advantages'] as $key => $table) {
            $stmtList = $db->prepare("SELECT content FROM $table WHERE offer_id = :offer_id ORDER BY sort_order ASC");
            $stmtList->bindParam(':offer_id', $id, PDO::PARAM_INT);
            $stmtList->execute();
            $offer[$key] = array_column($stmtList->fetchAll(), 'content');
        }

        // Fetch Tags
        $stmtTag = $db->prepare('SELECT t.id, t.name, t.slug FROM recrutement_tags t INNER JOIN recrutement_offer_tags ot ON t.id = ot.tag_id WHERE ot.offer_id = :offer_id');
        $stmtTag->bindParam(':offer_id', $id, PDO::PARAM_INT);
        $stmtTag->execute();
        $offer['tags'] = $stmtTag->fetchAll();

        Response::success($offer);
    });

    $router->post('/api/admin/recrutement/offers', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('title', 'Title')
            ->required('job_id', 'Job')
            ->required('contract_type_id', 'Contract Type')
            ->validate();

        $slug = $data['slug'] ?? Validator::slugify($data['title']);
        $db = getDb();
        $db->beginTransaction();

        try {
            $stmt = $db->prepare(
                'INSERT INTO recrutement_offers 
                 (site_id, job_id, contract_type_id, profession_id, title, slug, company_name, location, postal_code, salary_range, experience_level, duration, is_urgent, short_desc, full_desc, status, published_at, expires_at, created_by, created_at)
                 VALUES 
                 (:site_id, :job_id, :contract_type_id, :profession_id, :title, :slug, :company_name, :location, :postal_code, :salary_range, :experience_level, :duration, :is_urgent, :short_desc, :full_desc, :status, :published_at, :expires_at, :created_by, NOW())'
            );
            $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
            $stmt->bindParam(':job_id', $data['job_id'], PDO::PARAM_INT);
            $stmt->bindParam(':contract_type_id', $data['contract_type_id'], PDO::PARAM_INT);
            $profId = $data['profession_id'] ?? null;
            $stmt->bindParam(':profession_id', $profId, PDO::PARAM_INT);
            $stmt->bindParam(':title', $data['title'], PDO::PARAM_STR);
            $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
            $compName = $data['company_name'] ?? null;
            $stmt->bindParam(':company_name', $compName, PDO::PARAM_STR);
            $loc = $data['location'] ?? null;
            $stmt->bindParam(':location', $loc, PDO::PARAM_STR);
            $pc = $data['postal_code'] ?? null;
            $stmt->bindParam(':postal_code', $pc, PDO::PARAM_STR);
            $sal = $data['salary_range'] ?? null;
            $stmt->bindParam(':salary_range', $sal, PDO::PARAM_STR);
            $exp = $data['experience_level'] ?? null;
            $stmt->bindParam(':experience_level', $exp, PDO::PARAM_STR);
            $dur = $data['duration'] ?? null;
            $stmt->bindParam(':duration', $dur, PDO::PARAM_STR);
            $urgent = isset($data['is_urgent']) ? (int) $data['is_urgent'] : 0;
            $stmt->bindParam(':is_urgent', $urgent, PDO::PARAM_INT);
            $short = $data['short_desc'] ?? null;
            $stmt->bindParam(':short_desc', $short, PDO::PARAM_STR);
            $full = $data['full_desc'] ?? null;
            $stmt->bindParam(':full_desc', $full, PDO::PARAM_STR);
            $status = $data['status'] ?? 'draft';
            $stmt->bindParam(':status', $status, PDO::PARAM_STR);
            $pubAt = ($status === 'published') ? date('Y-m-d H:i:s') : ($data['published_at'] ?? null);
            $stmt->bindParam(':published_at', $pubAt, PDO::PARAM_STR);
            $expAt = $data['expires_at'] ?? null;
            $stmt->bindParam(':expires_at', $expAt, PDO::PARAM_STR);
            $stmt->bindParam(':created_by', $admin['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $offerId = (int) $db->lastInsertId();

            foreach (['missions' => 'recrutement_offer_missions', 'profiles' => 'recrutement_offer_profiles', 'advantages' => 'recrutement_offer_advantages'] as $key => $table) {
                if (!empty($data[$key]) && is_array($data[$key])) {
                    $stmtList = $db->prepare("INSERT INTO $table (offer_id, content, sort_order) VALUES (:offer_id, :content, :sort_order)");
                    foreach ($data[$key] as $idx => $content) {
                        $stmtList->bindValue(':offer_id', $offerId, PDO::PARAM_INT);
                        $stmtList->bindValue(':content', $content, PDO::PARAM_STR);
                        $stmtList->bindValue(':sort_order', $idx, PDO::PARAM_INT);
                        $stmtList->execute();
                    }
                }
            }

            if (!empty($data['tag_ids']) && is_array($data['tag_ids'])) {
                $stmtTag = $db->prepare('INSERT INTO recrutement_offer_tags (offer_id, tag_id) VALUES (:offer_id, :tag_id)');
                foreach ($data['tag_ids'] as $tagId) {
                    $stmtTag->bindValue(':offer_id', $offerId, PDO::PARAM_INT);
                    $stmtTag->bindValue(':tag_id', (int) $tagId, PDO::PARAM_INT);
                    $stmtTag->execute();
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'recrutement_offer', $offerId, null, $data);
            Response::created(['id' => $offerId]);

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create offer', $e->getMessage());
        }
    });

    $router->put('/api/admin/recrutement/offers/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM recrutement_offers WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();

        if (!$old) { Response::notFound('Offer not found'); return; }

        $db->beginTransaction();
        try {
            $fields = []; $bind = [];
            $updatable = ['job_id', 'contract_type_id', 'profession_id', 'title', 'slug', 'company_name', 'location', 'postal_code', 'salary_range', 'experience_level', 'duration', 'is_urgent', 'short_desc', 'full_desc', 'status', 'published_at', 'expires_at'];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
            }

            if (isset($data['status']) && $data['status'] === 'published' && $old['status'] !== 'published' && !isset($data['published_at'])) {
                $fields[] = "published_at = NOW()";
            }

            if (!empty($fields)) {
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE recrutement_offers SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
            }

            foreach (['missions' => 'recrutement_offer_missions', 'profiles' => 'recrutement_offer_profiles', 'advantages' => 'recrutement_offer_advantages'] as $key => $table) {
                if (isset($data[$key]) && is_array($data[$key])) {
                    $db->prepare("DELETE FROM $table WHERE offer_id = :id")->execute([':id' => $id]);
                    $stmtList = $db->prepare("INSERT INTO $table (offer_id, content, sort_order) VALUES (:offer_id, :content, :sort_order)");
                    foreach ($data[$key] as $idx => $content) {
                        $stmtList->bindValue(':offer_id', $id, PDO::PARAM_INT);
                        $stmtList->bindValue(':content', $content, PDO::PARAM_STR);
                        $stmtList->bindValue(':sort_order', $idx, PDO::PARAM_INT);
                        $stmtList->execute();
                    }
                }
            }

            if (isset($data['tag_ids']) && is_array($data['tag_ids'])) {
                $db->prepare("DELETE FROM recrutement_offer_tags WHERE offer_id = :id")->execute([':id' => $id]);
                $stmtTag = $db->prepare('INSERT INTO recrutement_offer_tags (offer_id, tag_id) VALUES (:offer_id, :tag_id)');
                foreach ($data['tag_ids'] as $tagId) {
                    $stmtTag->bindValue(':offer_id', $id, PDO::PARAM_INT);
                    $stmtTag->bindValue(':tag_id', (int) $tagId, PDO::PARAM_INT);
                    $stmtTag->execute();
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'recrutement_offer', $id, $old, $data);
            Response::success(['id' => $id], 'Offer updated');

        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update offer', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/offers/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT id FROM recrutement_offers WHERE id = :id AND site_id = :site_id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Offer not found'); return; }

        $stmt = $db->prepare('UPDATE recrutement_offers SET deleted_at = NOW() WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], $siteId, 'soft_delete', 'recrutement_offer', $id, $old, null);
        Response::success(null, 'Offer deleted');
    });
}
