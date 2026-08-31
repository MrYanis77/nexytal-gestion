<?php
/**
 * scoring_config.php — Configuration des poids de scoring
 */

require_once __DIR__ . '/scoring.php';

function recrutementScoringConfigHandler(?int $siteId = null): void
{
    Middleware::requireRole(['superadmin', 'admin']);
    $db = getDb();
    $config = recrutementGetScoringConfig($db, $siteId);
    Response::success([
        'site_id' => $siteId,
        'weights' => [
            'competences' => $config['poids_competences'],
            'experience' => $config['poids_experience'],
            'localisation' => $config['poids_localisation'],
            'diplome' => $config['poids_diplome'],
            'langues' => $config['poids_langues'],
            'bonus_champs_site' => $config['bonus_champs_site'],
        ],
        'total_main' => $config['poids_competences'] + $config['poids_experience']
            + $config['poids_localisation'] + $config['poids_diplome'] + $config['poids_langues'],
    ]);
}

function recrutementScoringConfigUpdateHandler(?int $siteId = null): void
{
    $admin = Middleware::requireRole(['superadmin', 'admin']);
    $data = Router::getJsonBody();
    $weights = $data['weights'] ?? $data;

    $comp = (int) ($weights['competences'] ?? $weights['poids_competences'] ?? 40);
    $exp = (int) ($weights['experience'] ?? $weights['poids_experience'] ?? 25);
    $loc = (int) ($weights['localisation'] ?? $weights['poids_localisation'] ?? 15);
    $dipl = (int) ($weights['diplome'] ?? $weights['poids_diplome'] ?? 12);
    $lang = (int) ($weights['langues'] ?? $weights['poids_langues'] ?? 8);
    $bonus = (int) ($weights['bonus_champs_site'] ?? 10);

    $total = $comp + $exp + $loc + $dipl + $lang;
    if ($total !== 100) {
        Response::badRequest("La somme des poids principaux doit être 100 (actuel: $total)");
        return;
    }

    foreach ([$comp, $exp, $loc, $dipl, $lang, $bonus] as $w) {
        if ($w < 0 || $w > 100) {
            Response::badRequest('Chaque poids doit être entre 0 et 100');
            return;
        }
    }

    $db = getDb();
    $adminId = (int) ($admin['id'] ?? 0);

    if ($siteId === null) {
        $stmt = $db->query('SELECT id FROM recrutement_scoring_config WHERE site_id IS NULL LIMIT 1');
        $existing = $stmt->fetch();
        if ($existing) {
            $db->prepare(
                'UPDATE recrutement_scoring_config SET
                 poids_competences = :c, poids_experience = :e, poids_localisation = :l,
                 poids_diplome = :d, poids_langues = :g, bonus_champs_site = :b,
                 updated_by_admin_id = :aid WHERE id = :id'
            )->execute([
                ':c' => $comp, ':e' => $exp, ':l' => $loc, ':d' => $dipl, ':g' => $lang, ':b' => $bonus,
                ':aid' => $adminId, ':id' => $existing['id'],
            ]);
        } else {
            $db->prepare(
                'INSERT INTO recrutement_scoring_config
                 (site_id, poids_competences, poids_experience, poids_localisation, poids_diplome, poids_langues, bonus_champs_site, updated_by_admin_id)
                 VALUES (NULL, :c, :e, :l, :d, :g, :b, :aid)'
            )->execute([
                ':c' => $comp, ':e' => $exp, ':l' => $loc, ':d' => $dipl, ':g' => $lang, ':b' => $bonus, ':aid' => $adminId,
            ]);
        }
    } else {
        $stmt = $db->prepare('SELECT id FROM recrutement_scoring_config WHERE site_id = :sid LIMIT 1');
        $stmt->execute([':sid' => $siteId]);
        $existing = $stmt->fetch();
        if ($existing) {
            $db->prepare(
                'UPDATE recrutement_scoring_config SET
                 poids_competences = :c, poids_experience = :e, poids_localisation = :l,
                 poids_diplome = :d, poids_langues = :g, bonus_champs_site = :b,
                 updated_by_admin_id = :aid WHERE id = :id'
            )->execute([
                ':c' => $comp, ':e' => $exp, ':l' => $loc, ':d' => $dipl, ':g' => $lang, ':b' => $bonus,
                ':aid' => $adminId, ':id' => $existing['id'],
            ]);
        } else {
            $db->prepare(
                'INSERT INTO recrutement_scoring_config
                 (site_id, poids_competences, poids_experience, poids_localisation, poids_diplome, poids_langues, bonus_champs_site, updated_by_admin_id)
                 VALUES (:sid, :c, :e, :l, :d, :g, :b, :aid)'
            )->execute([
                ':sid' => $siteId, ':c' => $comp, ':e' => $exp, ':l' => $loc, ':d' => $dipl, ':g' => $lang, ':b' => $bonus, ':aid' => $adminId,
            ]);
        }
    }

    $configJson = json_encode([
        'poids_competences' => $comp, 'poids_experience' => $exp, 'poids_localisation' => $loc,
        'poids_diplome' => $dipl, 'poids_langues' => $lang, 'bonus_champs_site' => $bonus,
    ], JSON_UNESCAPED_UNICODE);

    $db->prepare(
        'INSERT INTO recrutement_scoring_history (site_id, config_json, auteur_admin_id) VALUES (:sid, :cfg, :aid)'
    )->execute([':sid' => $siteId, ':cfg' => $configJson, ':aid' => $adminId]);

    recrutementScoringConfigHandler($siteId);
}

function registerRecrutementScoringConfigRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/config/scoring', function () {
        $siteId = Router::getQueryParam('site_id');
        recrutementScoringConfigHandler($siteId !== null && $siteId !== '' ? (int) $siteId : null);
    });

    $router->put('/api/admin/recrutement/config/scoring', function () {
        $siteId = Router::getQueryParam('site_id');
        recrutementScoringConfigUpdateHandler($siteId !== null && $siteId !== '' ? (int) $siteId : null);
    });

    $router->get('/api/config/scoring', function () {
        $siteId = Router::getQueryParam('site_id');
        recrutementScoringConfigHandler($siteId !== null && $siteId !== '' ? (int) $siteId : null);
    });

    $router->put('/api/config/scoring', function () {
        $siteId = Router::getQueryParam('site_id');
        recrutementScoringConfigUpdateHandler($siteId !== null && $siteId !== '' ? (int) $siteId : null);
    });
}
