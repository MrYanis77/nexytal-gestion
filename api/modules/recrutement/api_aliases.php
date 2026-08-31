<?php
/**
 * api_aliases.php — Façade REST spec (/api/offres, /api/candidatures)
 */

require_once __DIR__ . '/spec_mappers.php';
require_once __DIR__ . '/public_offers.php';
require_once __DIR__ . '/scoring.php';
require_once __DIR__ . '/site_fields.php';

function specAliasesListOffers(): void
{
    $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
    $db = getDb();
    $pagination = Router::getPagination();

    $where = ['1=1'];
    $bind = [];

    if ($status = Router::getQueryParam('status')) {
        $where[] = 'o.statut = :statut';
        $bind[':statut'] = specOfferStatusToFr($status);
    }
    if ($siteId = Router::getQueryParam('site_id')) {
        $where[] = 'o.site_id = :site_id';
        $bind[':site_id'] = (int) $siteId;
    }

    if ($admin['role'] === 'recruiter') {
        $where[] = 'o.recruteur_id IN (SELECT r.id FROM recruteurs r WHERE r.email = :admin_email)';
        $bind[':admin_email'] = $admin['email'];
    }

    $whereClause = 'WHERE ' . implode(' AND ', $where);
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM offres_emploi o $whereClause");
    foreach ($bind as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->execute();
    $total = (int) $stmt->fetch()['total'];

    $stmt = $db->prepare(
        "SELECT o.*, e.nom as entreprise_nom FROM offres_emploi o
         LEFT JOIN entreprises e ON o.entreprise_id = e.id
         $whereClause ORDER BY o.created_at DESC LIMIT :limit OFFSET :offset"
    );
    foreach ($bind as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
    $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
    $stmt->execute();

    $items = array_map('specOfferToSpec', $stmt->fetchAll());
    Response::paginated($items, $total, $pagination['page'], $pagination['limit']);
}

function specAliasesPatchOfferStatus(int $id): void
{
    Middleware::requireRole(['superadmin', 'admin']);
    $data = Router::getJsonBody();
    $status = $data['status'] ?? null;
    if (!$status) {
        Response::badRequest('status requis');
        return;
    }

    $fr = specOfferStatusToFr($status);
    $db = getDb();
    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $id]);
    $offer = $stmt->fetch();
    if (!$offer) {
        Response::notFound('Offer not found');
        return;
    }

    require_once __DIR__ . '/notifications.php';

    if ($fr === 'publiee') {
        $db->prepare("UPDATE offres_emploi SET statut = 'publiee', date_publication = COALESCE(date_publication, NOW()), updated_at = NOW() WHERE id = :id")
            ->execute([':id' => $id]);
        recrutementNotifyRecruiterOfferStatus($db, $offer, 'publiee');
    } elseif ($fr === 'archivee') {
        $db->prepare("UPDATE offres_emploi SET statut = 'archivee', updated_at = NOW() WHERE id = :id")
            ->execute([':id' => $id]);
        recrutementNotifyRecruiterOfferStatus($db, $offer, 'archivee', $data['reason'] ?? $data['motif_refus'] ?? null);
    } elseif ($fr === 'brouillon') {
        $db->prepare("UPDATE offres_emploi SET statut = 'brouillon', updated_at = NOW() WHERE id = :id")
            ->execute([':id' => $id]);
    } else {
        Response::badRequest('Statut non supporté');
        return;
    }

    Response::success(['id' => $id, 'status' => specOfferStatusFromFr($fr)]);
}

function specAliasesOfferCandidatures(int $id): void
{
    Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
    $db = getDb();

    $stmt = $db->prepare('SELECT id FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $id]);
    if (!$stmt->fetch()) {
        Response::notFound('Offer not found');
        return;
    }

    $orderExt = recrutementTableHasColumn($db, 'candidatures_externes', 'score_nexytal')
        ? 'score_nexytal IS NULL, score_nexytal DESC, created_at DESC'
        : 'created_at DESC';
    $stmtExt = $db->prepare(
        "SELECT * FROM candidatures_externes WHERE offre_id = :oid ORDER BY {$orderExt}"
    );
    $stmtExt->execute([':oid' => $id]);
    $externes = array_map(fn ($r) => specCandidatureToSpec($r, 'external'), $stmtExt->fetchAll());

    $orderInt = recrutementTableHasColumn($db, 'candidatures', 'score_nexytal')
        ? 'c.score_nexytal IS NULL, c.score_nexytal DESC, c.date_candidature DESC'
        : 'c.date_candidature DESC';
    $stmtInt = $db->prepare(
        "SELECT c.*, cand.prenom as candidat_prenom, cand.nom as candidat_nom, u.email as candidat_email
         FROM candidatures c
         INNER JOIN candidats cand ON c.candidat_id = cand.id
         INNER JOIN users u ON cand.user_id = u.id
         WHERE c.offre_id = :oid ORDER BY {$orderInt}"
    );
    $stmtInt->execute([':oid' => $id]);
    $internes = array_map(fn ($r) => specCandidatureToSpec($r, 'internal'), $stmtInt->fetchAll());

    Response::success(array_merge($externes, $internes));
}

function specAliasesCreateCandidature(): void
{
    $data = Router::getJsonBody();
    $offreId = (int) ($data['offer_id'] ?? $data['offre_id'] ?? 0);
    $siteId = (int) ($data['site_id'] ?? 0);

    if (!$offreId) {
        Response::badRequest('offer_id requis');
        return;
    }
    if (!$siteId && !empty($data['site_slug'])) {
        $siteId = (int) (getSiteId((string) $data['site_slug']) ?? 0);
    }
    if (!$siteId) {
        $db = getDb();
        $stmt = $db->prepare('SELECT site_id FROM offres_emploi WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $offreId]);
        $row = $stmt->fetch();
        $siteId = $row ? (int) $row['site_id'] : 0;
    }
    if (!$siteId) {
        Response::badRequest('site_id requis');
        return;
    }

    publicOffersApplyHandler($siteId, $offreId);
}

function specAliasesPatchCandidatureStatus(int $id, string $type = 'external'): void
{
    Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
    $data = Router::getJsonBody();
    $status = $data['status'] ?? null;
    if (!$status) {
        Response::badRequest('status requis');
        return;
    }
    $fr = specCandidatureStatusToFr($status);
    $db = getDb();

    if ($type === 'internal' || ($data['type'] ?? '') === 'internal') {
        $db->prepare('UPDATE candidatures SET statut = :st, updated_at = NOW() WHERE id = :id')
            ->execute([':st' => $fr, ':id' => $id]);
    } else {
        $db->prepare('UPDATE candidatures_externes SET statut = :st WHERE id = :id')
            ->execute([':st' => $fr, ':id' => $id]);
    }

    Response::success(['id' => $id, 'status' => specCandidatureStatusFromFr($fr)]);
}

function registerRecrutementApiAliasesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/contract-types', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        Response::success([
            ['id' => 1, 'code' => 'cdi', 'name' => 'CDI'],
            ['id' => 2, 'code' => 'cdd', 'name' => 'CDD'],
            ['id' => 3, 'code' => 'stage', 'name' => 'Stage'],
            ['id' => 4, 'code' => 'alternance', 'name' => 'Alternance'],
            ['id' => 5, 'code' => 'freelance', 'name' => 'Freelance'],
        ]);
    });

    $router->post('/api/admin/recrutement/contract-types', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $code = strtolower((string) ($data['code'] ?? $data['name'] ?? 'cdi'));
        $map = ['cdi' => 1, 'cdd' => 2, 'stage' => 3, 'alternance' => 4, 'freelance' => 5];
        Response::created(['id' => $map[$code] ?? 1, 'code' => $code]);
    });

    $router->get('/api/admin/recrutement/tags', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        Response::success([]);
    });

    $router->post('/api/admin/recrutement/tags', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Response::created(['id' => 1, 'name' => $data['name'] ?? 'tag']);
    });
    $router->get('/api/offres', function () {
        specAliasesListOffers();
    });

    $router->post('/api/offres', function () {
        $siteId = publicOffersResolveSiteId();
        if (!$siteId) {
            Response::badRequest('site_slug ou site_id requis');
            return;
        }
        publicOffersEmployerSubmitHandler($siteId, Router::getJsonBody());
    });

    $router->patch('/api/offres/{id}/status', function (array $params) {
        specAliasesPatchOfferStatus((int) $params['id']);
    });

    $router->get('/api/offres/{id}/candidatures', function (array $params) {
        specAliasesOfferCandidatures((int) $params['id']);
    });

    $router->post('/api/candidatures', function () {
        specAliasesCreateCandidature();
    });

    $router->patch('/api/candidatures/{id}/status', function (array $params) {
        specAliasesPatchCandidatureStatus((int) $params['id']);
    });
}
