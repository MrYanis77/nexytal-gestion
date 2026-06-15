<?php
/**
 * modules/recrutement/public_recrutement.php — Routes publiques recrutement IT (site_id = 2)
 */

function registerPublicRecrutementRoutes(Router $router): void
{
    $router->get('/api/public/{site_slug}/recrutement/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['o.site_id = :site_id', "o.statut = 'publiee'"];
        $bindParams = [':site_id' => $siteId];

        if ($contract = Router::getQueryParam('type_contrat')) {
            $where[] = 'o.type_contrat = :tc';
            $bindParams[':tc'] = $contract;
        }
        if ($metierId = Router::getQueryParam('metier_id')) {
            $where[] = 'o.metier_id = :mid';
            $bindParams[':mid'] = (int) $metierId;
        }
        if ($search = Router::getQueryParam('search')) {
            $where[] = '(o.titre LIKE :s OR o.description LIKE :s2 OR e.nom LIKE :s3)';
            $bindParams[':s'] = "%$search%";
            $bindParams[':s2'] = "%$search%";
            $bindParams[':s3'] = "%$search%";
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare(
            "SELECT COUNT(*) as total FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id $whereClause"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.id, o.slug, o.titre, o.type_contrat, o.ville, o.code_postal, o.teletravail,
                    o.salaire_min, o.salaire_max, o.salaire_afficher, o.date_publication, o.is_featured, o.is_urgent,
                    e.nom as entreprise_nom, e.logo_url, m.libelle as metier_libelle
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             $whereClause
             ORDER BY o.date_publication DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($bindParams as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/public/{site_slug}/recrutement/offers/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            "SELECT o.*, e.nom as entreprise_nom, e.logo_url, e.description as entreprise_description,
                    m.libelle as metier_libelle
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             WHERE o.site_id = :site_id AND o.slug = :slug AND o.statut = 'publiee' LIMIT 1"
        );
        $stmt->execute([':site_id' => $siteId, ':slug' => $params['slug']]);
        $offer = $stmt->fetch();
        if (!$offer) { Response::notFound('Offer not found'); return; }

        $db->prepare('UPDATE offres_emploi SET vues = vues + 1 WHERE id = :id')->execute([':id' => $offer['id']]);

        $stmtC = $db->prepare(
            'SELECT c.label, c.slug, oc.importance FROM competences c
             INNER JOIN offre_competences oc ON c.id = oc.competence_id WHERE oc.offre_id = :id'
        );
        $stmtC->execute([':id' => $offer['id']]);
        $offer['competences'] = $stmtC->fetchAll();

        Response::success($offer);
    });

    $router->post('/api/public/{site_slug}/recrutement/offers/{id}/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('first_name', 'Prénom')
            ->required('last_name', 'Nom')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('gdpr_consent', 'Consentement RGPD')
            ->validate();

        $db = getDb();
        $offreId = (int) $params['id'];

        $stmt = $db->prepare(
            "SELECT id FROM offres_emploi WHERE id = :id AND site_id = :site_id AND statut = 'publiee' LIMIT 1"
        );
        $stmt->execute([':id' => $offreId, ':site_id' => $siteId]);
        if (!$stmt->fetch()) { Response::notFound('Offer not found'); return; }

        $stmt = $db->prepare(
            'INSERT INTO candidatures_externes
             (offre_id, site_id, prenom, nom, email, telephone, lettre_motivation, linkedin_url, rgpd_consent_at, created_at)
             VALUES (:oid, :sid, :pre, :nom, :email, :tel, :lm, :li, NOW(), NOW())'
        );
        $stmt->execute([
            ':oid' => $offreId,
            ':sid' => $siteId,
            ':pre' => $data['first_name'],
            ':nom' => $data['last_name'],
            ':email' => $data['email'],
            ':tel' => $data['phone'] ?? null,
            ':lm' => $data['message'] ?? $data['cover_letter'] ?? null,
            ':li' => $data['linkedin_url'] ?? null,
        ]);

        Response::created(['id' => (int) $db->lastInsertId()], 'Candidature enregistrée');
    });

    $router->get('/api/public/{site_slug}/recrutement/metiers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->prepare(
            'SELECT id, slug, libelle, description FROM metiers
             WHERE actif = 1 AND (site_id IS NULL OR site_id = :site_id)
             ORDER BY libelle ASC'
        );
        $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/public/{site_slug}/recrutement/secteurs', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) { Response::notFound('Site not found'); return; }

        $db = getDb();
        $stmt = $db->query('SELECT id, slug, label FROM secteurs_activite ORDER BY label ASC');
        Response::success($stmt->fetchAll());
    });
}
