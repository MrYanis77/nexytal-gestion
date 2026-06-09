<?php
/**
 * modules/recrutement/public_recrutement.php — Routes publiques pour site IT (site_id = 2)
 */

function registerPublicRecrutementRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/recrutement/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();
        
        $where = ['o.site_id = :site_id', "o.status = 'published'", 'o.deleted_at IS NULL'];
        $bindParams = [':site_id' => $siteId];

        if ($sectorId = Router::getQueryParam('sector_id')) {
            $where[] = 'j.sector_id = :sector_id';
            $bindParams[':sector_id'] = (int) $sectorId;
        }
        if ($contractCode = Router::getQueryParam('contract_type')) {
            $where[] = 'c.code = :contract';
            $bindParams[':contract'] = $contractCode;
        }
        if ($tagSlug = Router::getQueryParam('tag')) {
            $where[] = 'EXISTS (SELECT 1 FROM recrutement_offer_tags ot INNER JOIN recrutement_tags t ON ot.tag_id = t.id WHERE ot.offer_id = o.id AND t.slug = :tag)';
            $bindParams[':tag'] = $tagSlug;
        }
        if ($search = Router::getQueryParam('search')) {
            $where[] = '(o.title LIKE :s OR o.company_name LIKE :s2 OR o.location LIKE :s3)';
            $bindParams[':s'] = "%$search%";
            $bindParams[':s2'] = "%$search%";
            $bindParams[':s3'] = "%$search%";
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM recrutement_offers o LEFT JOIN recrutement_jobs j ON o.job_id = j.id LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id $whereClause");
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.id, o.title, o.slug, o.company_name, o.location, o.salary_range, o.experience_level, o.is_urgent, o.short_desc, o.published_at, j.name as job_name, c.name as contract_type_name
             FROM recrutement_offers o
             LEFT JOIN recrutement_jobs j ON o.job_id = j.id
             LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id
             $whereClause
             ORDER BY o.is_urgent DESC, o.published_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();
        $offers = $stmt->fetchAll();

        foreach ($offers as &$offer) {
            $stmtTag = $db->prepare('SELECT t.name, t.slug FROM recrutement_tags t INNER JOIN recrutement_offer_tags ot ON t.id = ot.tag_id WHERE ot.offer_id = :id');
            $stmtTag->bindParam(':id', $offer['id'], PDO::PARAM_INT);
            $stmtTag->execute();
            $offer['tags'] = $stmtTag->fetchAll();
        }

        Response::paginated($offers, $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/public/{site_slug}/recrutement/offers/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            "SELECT o.*, j.name as job_name, c.name as contract_type_name
             FROM recrutement_offers o
             LEFT JOIN recrutement_jobs j ON o.job_id = j.id
             LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id
             WHERE o.site_id = :site_id AND o.slug = :slug AND o.status = 'published' AND o.deleted_at IS NULL LIMIT 1"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $offer = $stmt->fetch();

        if (!$offer) { Response::notFound('Offer not found'); return; }

        foreach (['missions' => 'recrutement_offer_missions', 'profiles' => 'recrutement_offer_profiles', 'advantages' => 'recrutement_offer_advantages'] as $key => $table) {
            $stmtList = $db->prepare("SELECT content FROM $table WHERE offer_id = :id ORDER BY sort_order ASC");
            $stmtList->bindParam(':id', $offer['id'], PDO::PARAM_INT);
            $stmtList->execute();
            $offer[$key] = array_column($stmtList->fetchAll(), 'content');
        }

        $stmtTag = $db->prepare('SELECT t.name, t.slug FROM recrutement_tags t INNER JOIN recrutement_offer_tags ot ON t.id = ot.tag_id WHERE ot.offer_id = :id');
        $stmtTag->bindParam(':id', $offer['id'], PDO::PARAM_INT);
        $stmtTag->execute();
        $offer['tags'] = $stmtTag->fetchAll();

        Response::success($offer);
    });

    $router->post('/api/public/{site_slug}/recrutement/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        // Here we handle form-data because of file upload
        $data = $_POST;
        Validator::make($data)
            ->required('offer_id', 'Offer ID')
            ->required('first_name', 'First name')
            ->required('last_name', 'Last name')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('gdpr_consent', 'GDPR Consent')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare("SELECT id FROM recrutement_offers WHERE id = :id AND site_id = :site_id AND status = 'published' AND deleted_at IS NULL LIMIT 1");
        $stmt->bindParam(':id', $data['offer_id'], PDO::PARAM_INT);
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) { Response::notFound('Offer not found or unavailable'); return; }

        $cvUrl = null;
        if (isset($_FILES['cv']) && $_FILES['cv']['error'] === UPLOAD_ERR_OK) {
            $uploadResult = Upload::handleUpload('cv', Upload::ALLOWED_DOCUMENTS, 5 * 1024 * 1024, 'cv');
            $cvUrl = $uploadResult['file_url'];
        }

        $stmt = $db->prepare(
            'INSERT INTO recrutement_applications (offer_id, first_name, last_name, email, phone, cv_url, cover_letter, linkedin_url, status, gdpr_consent, created_at)
             VALUES (:offer_id, :fn, :ln, :email, :phone, :cv, :cl, :linkedin, :status, :gdpr, NOW())'
        );
        $stmt->bindParam(':offer_id', $data['offer_id'], PDO::PARAM_INT);
        $fn = Validator::sanitizeString($data['first_name']);
        $stmt->bindParam(':fn', $fn, PDO::PARAM_STR);
        $ln = Validator::sanitizeString($data['last_name']);
        $stmt->bindParam(':ln', $ln, PDO::PARAM_STR);
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $phone = $data['phone'] ?? null;
        $stmt->bindParam(':phone', $phone, PDO::PARAM_STR);
        $stmt->bindParam(':cv', $cvUrl, PDO::PARAM_STR);
        $cl = isset($data['cover_letter']) ? Validator::sanitizeString($data['cover_letter']) : null;
        $stmt->bindParam(':cl', $cl, PDO::PARAM_STR);
        $linkedin = $data['linkedin_url'] ?? null;
        $stmt->bindParam(':linkedin', $linkedin, PDO::PARAM_STR);
        $status = 'new';
        $stmt->bindParam(':status', $status, PDO::PARAM_STR);
        $gdpr = (int) $data['gdpr_consent'];
        $stmt->bindParam(':gdpr', $gdpr, PDO::PARAM_INT);
        $stmt->execute();

        Response::created(['id' => (int) $db->lastInsertId()], 'Application submitted successfully');
    });

    $router->get('/api/public/{site_slug}/recrutement/filters', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $res = [];

        $stmt = $db->prepare('SELECT id, name, slug FROM recrutement_sectors WHERE site_id = :site_id ORDER BY name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $res['sectors'] = $stmt->fetchAll();

        $stmt = $db->prepare('SELECT id, name, slug FROM recrutement_tags WHERE site_id = :site_id ORDER BY name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $res['tags'] = $stmt->fetchAll();

        $stmt = $db->query('SELECT code, name FROM recrutement_contract_types ORDER BY name ASC');
        $res['contract_types'] = $stmt->fetchAll();

        Response::success($res);
    });
}
