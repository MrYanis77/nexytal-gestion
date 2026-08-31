<?php
/**
 * recruteur_portal.php — Espace recruteur scopé (aligné bdd.sql)
 */

require_once __DIR__ . '/spec_mappers.php';
require_once __DIR__ . '/../../core/RecruteurAuth.php';

function recrutementResolveRecruteurScope(PDO $db, array $admin): array
{
    $email = $admin['email'] ?? '';
    $recruteurIds = [];

    $stmt = $db->prepare('SELECT id FROM recruteurs WHERE email = :email');
    $stmt->execute([':email' => $email]);
    foreach ($stmt->fetchAll() as $row) {
        $recruteurIds[] = (int) $row['id'];
    }

    return [
        'recruteur_ids' => $recruteurIds,
        'email' => $email,
    ];
}

function recruteurPortalMapCandidature(array $row, string $type = 'external'): array
{
    $base = specCandidatureToSpec($row, $type);

    if ($type === 'internal') {
        $base['prenom'] = $row['candidat_prenom'] ?? '';
        $base['nom'] = $row['candidat_nom'] ?? '';
        $base['telephone'] = $row['telephone'] ?? null;
        $base['lettre_motivation'] = $row['message_motivation'] ?? null;
        $base['cv_filename'] = $row['cv_filename'] ?? null;
        $base['statut'] = (string) ($row['statut'] ?? 'recue');

        $base['date_candidature'] = $row['date_candidature'] ?? null;
    } else {
        $base['prenom'] = $row['prenom'] ?? '';
        $base['nom'] = $row['nom'] ?? '';
        $base['telephone'] = $row['telephone'] ?? null;
        $base['lettre_motivation'] = $row['lettre_motivation'] ?? null;
        $base['cv_filename'] = $row['cv_filename'] ?? null;
        $base['statut'] = (string) ($row['statut'] ?? 'recue');

        $base['date_candidature'] = $row['created_at'] ?? null;
    }

    $candidatureId = (int) $row['id'];
    $typeParam = $type === 'internal' ? 'interne' : 'externe';
    $base['has_cv'] = !empty($base['cv_filename']);
    $base['has_lettre'] = !empty($base['lettre_motivation']);
    $base['cv_download_url'] = $base['has_cv']
        ? '/api/recruteur/candidatures/' . $candidatureId . '/cv?type=' . $typeParam
        : null;
    $base['lettre_download_url'] = $base['has_lettre']
        ? '/api/recruteur/candidatures/' . $candidatureId . '/lettre?type=' . $typeParam
        : null;

    return $base;
}

function recruteurPortalNormalizeCandidatureType(?string $type): string
{
    $type = strtolower(trim((string) $type));
    if (in_array($type, ['interne', 'internal', 'intern'], true)) {
        return 'internal';
    }

    return 'external';
}

function recruteurPortalFetchCandidature(PDO $db, int $candidatureId, string $type): ?array
{
    if ($type === 'internal') {
        $stmt = $db->prepare(
            'SELECT c.*, cand.prenom as candidat_prenom, cand.nom as candidat_nom, cand.telephone,
                    cand.cv_filename, u.email as candidat_email
             FROM candidatures c
             INNER JOIN candidats cand ON c.candidat_id = cand.id
             LEFT JOIN users u ON cand.user_id = u.id
             WHERE c.id = :id
             LIMIT 1'
        );
    } else {
        $stmt = $db->prepare('SELECT * FROM candidatures_externes WHERE id = :id LIMIT 1');
    }

    $stmt->execute([':id' => $candidatureId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row ?: null;
}

function recruteurPortalAssertCandidatureAccess(PDO $db, array $auth, array $candidature, string $type): void
{
    $offreId = (int) ($candidature['offre_id'] ?? 0);
    if ($offreId <= 0) {
        Response::notFound('Offer not found');
        exit;
    }

    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $offreId]);
    $offer = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$offer) {
        Response::notFound('Offer not found');
        exit;
    }

    RecruteurAuth::assertOfferAccess($db, $auth, $offer);
}

function recruteurPortalDownloadCvHandler(int $candidatureId, ?string $type = null): void
{
    $db = getDb();
    $auth = RecruteurAuth::authenticatePortal($db);
    $normalizedType = recruteurPortalNormalizeCandidatureType($type);

    $candidature = recruteurPortalFetchCandidature($db, $candidatureId, $normalizedType);
    if (!$candidature) {
        Response::notFound('Candidature not found');
        return;
    }

    recruteurPortalAssertCandidatureAccess($db, $auth, $candidature, $normalizedType);

    $cvPath = trim((string) ($candidature['cv_filename'] ?? ''));
    if ($cvPath === '') {
        Response::notFound('CV not found');
        return;
    }

    $absolutePath = Upload::resolveSafePath($cvPath);
    if ($absolutePath === null) {
        Response::notFound('CV file missing on server');
        return;
    }

    if ($normalizedType === 'internal') {
        $prenom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['candidat_prenom'] ?? 'candidat')) ?: 'candidat';
        $nom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['candidat_nom'] ?? '')) ?: '';
    } else {
        $prenom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['prenom'] ?? 'candidat')) ?: 'candidat';
        $nom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['nom'] ?? '')) ?: '';
    }

    $ext = strtolower(pathinfo($absolutePath, PATHINFO_EXTENSION)) ?: 'pdf';
    $downloadName = trim("CV_{$prenom}_{$nom}.{$ext}", '_');

    $mime = mime_content_type($absolutePath) ?: 'application/pdf';
    Response::downloadFile($absolutePath, $downloadName, $mime);
}

function recruteurPortalDownloadLettreHandler(int $candidatureId, ?string $type = null): void
{
    $db = getDb();
    $auth = RecruteurAuth::authenticatePortal($db);
    $normalizedType = recruteurPortalNormalizeCandidatureType($type);

    $candidature = recruteurPortalFetchCandidature($db, $candidatureId, $normalizedType);
    if (!$candidature) {
        Response::notFound('Candidature not found');
        return;
    }

    recruteurPortalAssertCandidatureAccess($db, $auth, $candidature, $normalizedType);

    $lettre = $normalizedType === 'internal'
        ? trim((string) ($candidature['message_motivation'] ?? ''))
        : trim((string) ($candidature['lettre_motivation'] ?? ''));

    if ($lettre === '') {
        Response::notFound('Cover letter not found');
        return;
    }

    if ($normalizedType === 'internal') {
        $prenom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['candidat_prenom'] ?? 'candidat')) ?: 'candidat';
        $nom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['candidat_nom'] ?? '')) ?: '';
    } else {
        $prenom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['prenom'] ?? 'candidat')) ?: 'candidat';
        $nom = preg_replace('/[^A-Za-z0-9_-]+/', '_', (string) ($candidature['nom'] ?? '')) ?: '';
    }

    $downloadName = trim("Lettre_{$prenom}_{$nom}.txt", '_');
    Response::downloadContent($lettre, $downloadName);
}

function recruteurPortalOffersHandler(): void
{
    $admin = Middleware::requireRole(['recruiter', 'admin', 'superadmin']);
    $db = getDb();
    $scope = recrutementResolveRecruteurScope($db, $admin);
    $pagination = Router::getPagination();

    if ($admin['role'] === 'recruiter' && $scope['recruteur_ids'] === [] && $scope['email'] === '') {
        Response::success([]);
        return;
    }

    $where = ["o.statut = 'publiee'"];
    $bind = [];

    if ($admin['role'] === 'recruiter') {
        if ($scope['recruteur_ids'] !== []) {
            $in = implode(',', array_map('intval', $scope['recruteur_ids']));
            $where[] = "o.recruteur_id IN ($in)";
        } else {
            $where[] = '1=0';
        }
    }

    $whereClause = 'WHERE ' . implode(' AND ', $where);

    $stmt = $db->prepare(
        "SELECT o.*, e.nom as entreprise_nom,
                (SELECT COUNT(*) FROM candidatures_externes ce WHERE ce.offre_id = o.id) +
                (SELECT COUNT(*) FROM candidatures c WHERE c.offre_id = o.id) as nb_candidatures
         FROM offres_emploi o
         LEFT JOIN entreprises e ON o.entreprise_id = e.id
         $whereClause ORDER BY o.date_publication DESC
         LIMIT :limit OFFSET :offset"
    );
    foreach ($bind as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
    $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
    $stmt->execute();

    $items = array_map(function ($row) {
        $spec = specOfferToSpec($row);
        $spec['applications_count'] = (int) ($row['nb_candidatures'] ?? 0);
        $spec['average_score'] = $row['score_moyen'] !== null ? round((float) $row['score_moyen'], 1) : null;
        return $spec;
    }, $stmt->fetchAll());

    Response::success($items);
}

function recruteurPortalOfferCandidaturesHandler(int $offreId): void
{
    $db = getDb();
    $auth = RecruteurAuth::authenticatePortal($db);

    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $offreId]);
    $offer = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$offer) {
        Response::notFound('Offer not found');
        return;
    }

    RecruteurAuth::assertOfferAccess($db, $auth, $offer);

    $stmtExt = $db->prepare(
        'SELECT * FROM candidatures_externes WHERE offre_id = :oid
         ORDER BY created_at DESC'
    );
    $stmtExt->execute([':oid' => $offreId]);
    $externes = array_map(fn ($r) => recruteurPortalMapCandidature($r, 'external'), $stmtExt->fetchAll(PDO::FETCH_ASSOC));

    $stmtInt = $db->prepare(
        'SELECT c.*, cand.prenom as candidat_prenom, cand.nom as candidat_nom, cand.telephone,
                u.email as candidat_email
         FROM candidatures c
         INNER JOIN candidats cand ON c.candidat_id = cand.id
         LEFT JOIN users u ON cand.user_id = u.id
         WHERE c.offre_id = :oid ORDER BY c.date_candidature DESC'
    );
    $stmtInt->execute([':oid' => $offreId]);
    $internes = array_map(fn ($r) => recruteurPortalMapCandidature($r, 'internal'), $stmtInt->fetchAll(PDO::FETCH_ASSOC));

    Response::success([
        'offer' => specOfferToSpec($offer),
        'candidatures' => array_merge($externes, $internes),
    ]);
}

function recruteurPortalLegacyDispatch(): void
{
    $action = trim((string) ($_GET['action'] ?? ''));
    $candidatureId = (int) ($_GET['candidature_id'] ?? $_GET['id'] ?? 0);
    $type = $_GET['type'] ?? null;

    switch ($action) {
        case 'download_candidature_cv':
            if ($candidatureId <= 0) {
                Response::badRequest('candidature_id requis');
                return;
            }
            recruteurPortalDownloadCvHandler($candidatureId, $type);
            return;

        case 'download_candidature_lettre_motivation':
        case 'download_candidature_lettre':
        case 'download_candidature_lm':
        case 'download_lettre_motivation':
            if ($candidatureId <= 0) {
                Response::badRequest('candidature_id requis');
                return;
            }
            recruteurPortalDownloadLettreHandler($candidatureId, $type);
            return;

        default:
            Response::notFound('Action not found');
    }
}

function registerRecruteurPortalRoutes(Router $router): void
{
    $router->get('/api/admin/recruteur/offres', function () {
        recruteurPortalOffersHandler();
    });

    $router->get('/api/recruteur/offres', function () {
        recruteurPortalOffersHandler();
    });

    $router->get('/api/admin/recruteur/offres/{id}/candidatures', function (array $params) {
        recruteurPortalOfferCandidaturesHandler((int) $params['id']);
    });

    $router->get('/api/recruteur/offres/{id}/candidatures', function (array $params) {
        recruteurPortalOfferCandidaturesHandler((int) $params['id']);
    });

    $router->get('/api/recruteur/candidatures/{id}/cv', function (array $params) {
        recruteurPortalDownloadCvHandler((int) $params['id'], Router::getQueryParam('type'));
    });

    $router->get('/api/admin/recruteur/candidatures/{id}/cv', function (array $params) {
        recruteurPortalDownloadCvHandler((int) $params['id'], Router::getQueryParam('type'));
    });

    $router->get('/api/recruteur/candidatures/{id}/lettre', function (array $params) {
        recruteurPortalDownloadLettreHandler((int) $params['id'], Router::getQueryParam('type'));
    });

    $router->get('/api/admin/recruteur/candidatures/{id}/lettre', function (array $params) {
        recruteurPortalDownloadLettreHandler((int) $params['id'], Router::getQueryParam('type'));
    });
}
