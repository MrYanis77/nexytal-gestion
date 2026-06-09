<?php
/**
 * modules/recrutement/public_medical.php — Routes publiques pour site Médical (site_id = 3)
 */

function registerPublicMedicalRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/medical/professions', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare('SELECT slug, name, sector, description, image_url, color FROM recrutement_professions WHERE site_id = :site_id AND is_active = 1 ORDER BY name ASC');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/public/{site_slug}/medical/professions/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM recrutement_professions WHERE site_id = :site_id AND slug = :slug AND is_active = 1 LIMIT 1');
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':slug', $params['slug'], PDO::PARAM_STR);
        $stmt->execute();
        $prof = $stmt->fetch();
        if (!$prof) { Response::notFound('Profession not found'); return; }

        // Associated offers
        $stmt = $db->prepare(
            "SELECT o.id, o.title, o.slug, o.location, c.name as contract_type_name
             FROM recrutement_offers o
             LEFT JOIN recrutement_contract_types c ON o.contract_type_id = c.id
             WHERE o.site_id = :site_id AND o.profession_id = :prof_id AND o.status = 'published' AND o.deleted_at IS NULL
             ORDER BY o.published_at DESC LIMIT 10"
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindParam(':prof_id', $prof['id'], PDO::PARAM_INT);
        $stmt->execute();
        $prof['latest_offers'] = $stmt->fetchAll();

        Response::success($prof);
    });
}
