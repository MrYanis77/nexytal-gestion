<?php
/**
 * modules/recrutement/public_medical.php — Routes publiques médical (site_id = 3)
 */

function registerPublicMedicalRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/medical/metiers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, slug, libelle, description, perspectives FROM metiers
             WHERE actif = 1 AND (site_id IS NULL OR site_id = :site_id)
             ORDER BY libelle ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/public/{site_slug}/medical/metiers/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT * FROM metiers
             WHERE slug = :slug AND actif = 1 AND (site_id IS NULL OR site_id = :site_id) LIMIT 1'
        );
        $stmt->execute([':slug' => $params['slug'], ':site_id' => $siteId]);
        $metier = $stmt->fetch();
        if (!$metier) { Response::notFound('Métier not found'); return; }

        $stmt = $db->prepare(
            "SELECT o.id, o.slug, o.titre, o.ville, o.type_contrat, o.date_publication, e.nom as entreprise_nom
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             WHERE o.site_id = :site_id AND o.metier_id = :mid AND o.statut = 'publiee'
             ORDER BY o.date_publication DESC LIMIT 10"
        );
        $stmt->execute([':site_id' => $siteId, ':mid' => $metier['id']]);
        $metier['offres'] = $stmt->fetchAll();

        Response::success($metier);
    });

    $router->get('/api/public/{site_slug}/medical/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();
        $where = ['o.site_id = :site_id', "o.statut = 'publiee'"];
        $bind = [':site_id' => $siteId];

        if ($mid = Router::getQueryParam('metier_id')) {
            $where[] = 'o.metier_id = :mid';
            $bind[':mid'] = (int) $mid;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM offres_emploi o $whereClause");
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.id, o.slug, o.titre, o.ville, o.type_contrat, o.date_publication,
                    e.nom as entreprise_nom, m.libelle as metier_libelle
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             $whereClause ORDER BY o.date_publication DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });
}
