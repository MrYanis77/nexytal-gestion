<?php
/**
 * modules/recrutement/public_recrutement.php — Routes publiques recrutement IT (legacy secteurs)
 * Offres / apply / métiers : voir public_offers.php
 */

function registerPublicRecrutementRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/recrutement/secteurs', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->query('SELECT id, slug, label FROM secteurs_activite ORDER BY label ASC');
        Response::success($stmt->fetchAll());
    });
}
