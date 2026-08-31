<?php
/**
 * public_offers.php — Routes publiques offres d'emploi (6 sites)
 *
 * Couche 1 — POST /api/public/{site_slug}/offre (dépôt employeur → en_attente)
 * Couche 3 — GET offers, GET offers/{slug}, POST offers/{id}/apply (candidature → candidatures_externes)
 *
 * Alias compatibilité : /recrutement/offers, /medical/offers, POST /api/offre
 */

require_once __DIR__ . '/offers.php';
require_once __DIR__ . '/site_scope.php';
require_once __DIR__ . '/scoring.php';
require_once __DIR__ . '/site_fields.php';
require_once __DIR__ . '/notifications.php';
require_once __DIR__ . '/spec_mappers.php';

/** Clause SQL : offre visible publiquement */
function publicOfferVisibilitySql(string $alias = 'o'): array
{
    return [
        "{$alias}.statut = 'publiee'",
        "({$alias}.date_expiration IS NULL OR {$alias}.date_expiration >= NOW())",
    ];
}

function publicOffersResolveSiteId(?string $slugFromParams = null): ?int
{
    if ($slugFromParams) {
        $id = getSiteId($slugFromParams);
        if ($id) {
            return $id;
        }
    }

    $headerSlug = $_SERVER['HTTP_X_SITE_SLUG'] ?? null;
    if ($headerSlug) {
        $id = getSiteId($headerSlug);
        if ($id) {
            return $id;
        }
    }

    $body = Router::getJsonBody();
    if (!empty($body['site_slug'])) {
        return getSiteId((string) $body['site_slug']);
    }

    return null;
}

function publicOffersListHandler(int $siteId, bool $includeSearch = true): void
{
    $db = getDb();
    $pagination = Router::getPagination();

    $where = array_merge(['o.site_id = :site_id'], publicOfferVisibilitySql('o'));
    $bindParams = [':site_id' => $siteId];

    if ($contract = Router::getQueryParam('type_contrat')) {
        $where[] = 'o.type_contrat = :tc';
        $bindParams[':tc'] = $contract;
    }
    if ($metierId = Router::getQueryParam('metier_id')) {
        $where[] = 'o.metier_id = :mid';
        $bindParams[':mid'] = (int) $metierId;
    }
    if ($includeSearch && ($search = Router::getQueryParam('search'))) {
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
    foreach ($bindParams as $k => $v) {
        $stmt->bindValue($k, $v);
    }
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
    foreach ($bindParams as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
    $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
    $stmt->execute();

    Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
}

function publicOffersDetailHandler(int $siteId, string $slug): void
{
    $db = getDb();
    $visibility = publicOfferVisibilitySql('o');
    $stmt = $db->prepare(
        "SELECT o.*, e.nom as entreprise_nom, e.logo_url, e.description as entreprise_description,
                m.libelle as metier_libelle
         FROM offres_emploi o
         LEFT JOIN entreprises e ON o.entreprise_id = e.id
         LEFT JOIN metiers m ON o.metier_id = m.id
         WHERE o.site_id = :site_id AND o.slug = :slug
           AND " . implode(' AND ', $visibility) . " LIMIT 1"
    );
    $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
    $offer = $stmt->fetch();
    if (!$offer) {
        Response::notFound('Offer not found');
        return;
    }

    $db->prepare('UPDATE offres_emploi SET vues = vues + 1 WHERE id = :id')->execute([':id' => $offer['id']]);

    $stmtC = $db->prepare(
        'SELECT c.label, c.slug, oc.importance FROM competences c
         INNER JOIN offre_competences oc ON c.id = oc.competence_id WHERE oc.offre_id = :id'
    );
    $stmtC->execute([':id' => $offer['id']]);
    $offer['competences'] = $stmtC->fetchAll();

    Response::success($offer);
}

function publicOffersApplyHandler(int $siteId, int $offreId): void
{
    $data = Router::getJsonBody();
    Validator::make($data)
        ->required('first_name', 'Prénom')
        ->required('last_name', 'Nom')
        ->required('email', 'Email')
        ->email('email', 'Email')
        ->required('gdpr_consent', 'Consentement RGPD')
        ->validate();

    if (empty($data['gdpr_consent'])) {
        Response::badRequest('Consentement RGPD requis');
        return;
    }

    $db = getDb();
    $visibility = publicOfferVisibilitySql('o');
    $stmt = $db->prepare(
        'SELECT o.* FROM offres_emploi o WHERE o.id = :id AND o.site_id = :site_id AND '
        . implode(' AND ', $visibility) . ' LIMIT 1'
    );
    $stmt->execute([':id' => $offreId, ':site_id' => $siteId]);
    $offer = $stmt->fetch();
    if (!$offer) {
        Response::notFound('Offer not found');
        return;
    }

    $profile = recrutementCandidateProfileFromPayload($data);
    $siteSpec = recrutementExtractSiteSpecificFields($siteId, $data);
    if ($siteSpec !== []) {
        $profile['champs_specifiques'] = array_merge($profile['champs_specifiques'] ?? [], $siteSpec);
    }

    $scoreResult = recrutementScoreApplication($db, $offreId, $profile);

    require_once __DIR__ . '/candidature_externe_helpers.php';
    $insertData = array_merge($data, [
        'prenom' => $data['first_name'],
        'nom' => $data['last_name'],
        'telephone' => $data['phone'] ?? null,
        'lettre_motivation' => $data['message'] ?? $data['cover_letter'] ?? null,
        'cv_filename' => $data['cv_filename'] ?? $data['cv_url'] ?? $profile['cv_filename'] ?? null,
        'experience_candidat' => $data['experience_candidat'] ?? $data['experience_min'] ?? null,
        'competences_reponses' => $data['competences_reponses'] ?? $data['competences'] ?? $profile['competences'] ?? null,
        'disponibilite' => $data['disponibilite'] ?? $profile['disponibilite'] ?? null,
    ]);
    $newId = candidatureExterneInsert($db, $offreId, $siteId, $insertData, $scoreResult);
    recrutementNotifyRecruiterNewApplication($db, $offreId, array_merge($profile, [
        'prenom' => $data['first_name'],
        'nom' => $data['last_name'],
        'email' => $data['email'],
        'score_nexytal' => $scoreResult['score'],
    ]));

    Response::created([
        'id' => $newId,
        'affinity_score' => $scoreResult['score'],
    ], 'Candidature enregistrée');
}

function publicOffersMetiersHandler(int $siteId): void
{
    $db = getDb();
    $stmt = $db->prepare(
        'SELECT id, slug, libelle, description FROM metiers
         WHERE actif = 1 AND (site_id IS NULL OR site_id = :site_id)
         ORDER BY libelle ASC'
    );
    $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
    $stmt->execute();
    Response::success($stmt->fetchAll());
}

function publicOffersFindOrCreateEntreprise(PDO $db, int $siteId, array $data): int
{
    $nom = trim((string) ($data['entreprise_nom'] ?? ''));
    $ville = trim((string) ($data['ville'] ?? ''));

    $stmt = $db->prepare('SELECT id FROM entreprises WHERE nom = :nom LIMIT 1');
    $stmt->execute([':nom' => $nom]);
    $existing = $stmt->fetch();
    if ($existing) {
        return (int) $existing['id'];
    }

    $baseSlug = Validator::slugify($nom);
    $slug = $baseSlug;
    $n = 1;
    $stmtSlug = $db->prepare('SELECT id FROM entreprises WHERE slug = :slug LIMIT 1');
    while (true) {
        $stmtSlug->execute([':slug' => $slug]);
        if (!$stmtSlug->fetch()) {
            break;
        }
        $slug = $baseSlug . '-' . $siteId . '-' . $n++;
    }

    $stmt = $db->prepare(
        'INSERT INTO entreprises (nom, slug, ville, validee, created_at, updated_at)
         VALUES (:nom, :slug, :ville, 0, NOW(), NOW())'
    );
    $stmt->execute([
        ':nom' => $nom,
        ':slug' => $slug,
        ':ville' => $ville !== '' ? $ville : null,
    ]);

    return (int) $db->lastInsertId();
}

function publicOffersFindOrCreateRecruteur(PDO $db, int $entrepriseId, array $data): ?int
{
    $prenom = trim((string) ($data['contact_prenom'] ?? ''));
    $nom = trim((string) ($data['contact_nom'] ?? ''));
    $email = trim((string) ($data['contact_email'] ?? ''));
    if ($prenom === '' || $nom === '') {
        return null;
    }

    if ($email !== '') {
        $stmt = $db->prepare('SELECT id FROM recruteurs WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $email]);
        $byEmail = $stmt->fetch();
        if ($byEmail) {
            return (int) $byEmail['id'];
        }
    }

    $stmt = $db->prepare(
        'SELECT id FROM recruteurs WHERE entreprise_id = :eid AND prenom = :pre AND nom = :nom LIMIT 1'
    );
    $stmt->execute([':eid' => $entrepriseId, ':pre' => $prenom, ':nom' => $nom]);
    $existing = $stmt->fetch();
    if ($existing) {
        return (int) $existing['id'];
    }

    $stmtEnt = $db->prepare('SELECT nom FROM entreprises WHERE id = :id LIMIT 1');
    $stmtEnt->execute([':id' => $entrepriseId]);
    $entrepriseNom = $stmtEnt->fetchColumn() ?: trim((string) ($data['entreprise_nom'] ?? 'Entreprise'));

    if ($email === '') {
        $email = strtolower(Validator::slugify($prenom . '.' . $nom)) . '.' . $entrepriseId . '@depot.nexytal.local';
    }

    $stmt = $db->prepare(
        'INSERT INTO recruteurs (entreprise_id, nom_entreprise, prenom, nom, telephone, fonction, email, status, created_at, updated_at)
         VALUES (:eid, :ne, :pre, :nom, :tel, :fonc, :email, :status, NOW(), NOW())'
    );
    $stmt->execute([
        ':eid' => $entrepriseId,
        ':ne' => $entrepriseNom,
        ':pre' => $prenom,
        ':nom' => $nom,
        ':tel' => $data['contact_phone'] ?? $data['phone'] ?? null,
        ':fonc' => $data['contact_fonction'] ?? $data['fonction'] ?? null,
        ':email' => $email,
        ':status' => 'pending',
    ]);

    return (int) $db->lastInsertId();
}

function publicOffersEmployerSubmitHandler(int $siteId, array $data): void
{
    Validator::make($data)
        ->required('entreprise_nom', 'Nom entreprise')
        ->required('contact_email', 'Email contact')
        ->email('contact_email', 'Email contact')
        ->required('contact_prenom', 'Prénom contact')
        ->required('contact_nom', 'Nom contact')
        ->required('ville', 'Ville')
        ->required('titre', 'Titre du poste')
        ->required('description', 'Description')
        ->required('gdpr_consent', 'Consentement RGPD')
        ->validate();

    if (empty($data['gdpr_consent'])) {
        Response::badRequest('Consentement RGPD requis');
        return;
    }

    $db = getDb();
    $db->beginTransaction();
    try {
        $entrepriseId = publicOffersFindOrCreateEntreprise($db, $siteId, $data);
        $recruteurId = publicOffersFindOrCreateRecruteur($db, $entrepriseId, $data);

        if ($recruteurId) {
            recrutementLinkRecruteurToSite($db, $recruteurId, $siteId, null);
        }

        $titre = trim((string) $data['titre']);
        $slug = $data['slug'] ?? Validator::slugify($titre);
        $baseSlug = $slug;
        $n = 1;
        $stmtSlugCheck = $db->prepare('SELECT id FROM offres_emploi WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        while (true) {
            $stmtSlugCheck->execute([':site_id' => $siteId, ':slug' => $slug]);
            if (!$stmtSlugCheck->fetch()) {
                break;
            }
            $slug = $baseSlug . '-' . $n++;
        }

        $offerData = offreApplyEntrepriseLocation($db, [
            'entreprise_id' => $entrepriseId,
            'ville' => $data['ville'] ?? null,
        ]);

        $stmt = $db->prepare(
            'INSERT INTO offres_emploi
             (site_id, entreprise_id, recruteur_id, metier_id, reference, slug, titre, description, profil_recherche,
              avantages, competences_text, type_contrat, experience_min, salaire_min, salaire_max, salaire_afficher, teletravail,
              temps_travail, ville, code_postal, departement, region, is_featured, is_urgent, statut,
              date_publication, date_expiration, created_at, updated_at)
             VALUES
             (:site_id, :eid, :rid, :mid, :ref, :slug, :titre, :desc, :pr, :av, :comp_text, :tc, :exp, :smin, :smax, :saff,
              :tele, :tt, :ville, :cp, :dep, :reg, 0, 0, :statut, NULL, :exp_at, NOW(), NOW())'
        );

        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->bindValue(':eid', $entrepriseId, PDO::PARAM_INT);
        $stmt->bindValue(':rid', $recruteurId, $recruteurId ? PDO::PARAM_INT : PDO::PARAM_NULL);
        $stmt->bindValue(':mid', !empty($data['metier_id']) ? (int) $data['metier_id'] : null, !empty($data['metier_id']) ? PDO::PARAM_INT : PDO::PARAM_NULL);
        $stmt->bindValue(':ref', $data['reference'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindValue(':titre', $titre, PDO::PARAM_STR);
        $stmt->bindValue(':desc', $data['description'], PDO::PARAM_STR);
        $stmt->bindValue(':pr', $data['profil_recherche'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':av', $data['avantages'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':comp_text', $data['competences_text'] ?? $data['competences_cles'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':tc', $data['type_contrat'] ?? 'cdi', PDO::PARAM_STR);
        $stmt->bindValue(':exp', $data['experience_min'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':smin', $data['salaire_min'] ?? null, PDO::PARAM_INT);
        $stmt->bindValue(':smax', $data['salaire_max'] ?? null, PDO::PARAM_INT);
        $stmt->bindValue(':saff', $data['salaire_afficher'] ?? 1, PDO::PARAM_INT);
        $stmt->bindValue(':tele', $data['teletravail'] ?? 'non', PDO::PARAM_STR);
        $stmt->bindValue(':tt', $data['temps_travail'] ?? 'temps_plein', PDO::PARAM_STR);
        $stmt->bindValue(':ville', $offerData['ville'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':cp', $offerData['code_postal'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':dep', $offerData['departement'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':reg', $offerData['region'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':statut', 'brouillon', PDO::PARAM_STR);
        $stmt->bindValue(':exp_at', $data['date_expiration'] ?? null, PDO::PARAM_STR);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();

        if (!empty($data['competences']) || !empty($data['competences_cles'])) {
            $compText = is_array($data['competences'] ?? $data['competences_cles'] ?? null)
                ? implode(', ', $data['competences'] ?? $data['competences_cles'])
                : (string) ($data['competences'] ?? $data['competences_cles'] ?? '');
            if ($compText !== '') {
                offreSyncCompetencesFromText($db, $newId, $compText);
            }
        }

        $db->commit();

        $stmtSite = $db->prepare('SELECT name FROM core_sites WHERE id = :id LIMIT 1');
        $stmtSite->execute([':id' => $siteId]);
        $siteRow = $stmtSite->fetch();
        recrutementNotifyAdminNewOffer($db, [
            'id' => $newId,
            'titre' => $titre,
            'recruteur_email' => $data['contact_email'],
        ], $siteRow['name'] ?? 'Nexytal');

        Response::created([
            'id' => $newId,
            'reference' => $data['reference'] ?? null,
            'slug' => $slug,
        ], 'Offre soumise — en attente de validation');
    } catch (\Exception $e) {
        $db->rollBack();
        Response::serverError('Échec de la soumission', $e->getMessage());
    }
}

function registerPublicOffersRoutes(Router $router): void
{
    // --- Routes génériques (6 sites) ---
    $router->get('/api/public/{site_slug}/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersListHandler($siteId);
    });

    $router->get('/api/public/{site_slug}/offers/metiers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersMetiersHandler($siteId);
    });

    $router->get('/api/public/{site_slug}/offers/{slug}', function (array $params) {
        if ($params['slug'] === 'metiers') {
            return;
        }
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersDetailHandler($siteId, $params['slug']);
    });

    $router->post('/api/public/{site_slug}/offers/{id}/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersApplyHandler($siteId, (int) $params['id']);
    });

    $router->post('/api/public/{site_slug}/offre', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersEmployerSubmitHandler($siteId, Router::getJsonBody());
    });

    // Alias POST /api/offre (site_slug en body ou header X-Site-Slug)
    $router->post('/api/offre', function () {
        $siteId = publicOffersResolveSiteId();
        if (!$siteId) {
            Response::badRequest('site_slug requis (body ou header X-Site-Slug)');
            return;
        }
        publicOffersEmployerSubmitHandler($siteId, Router::getJsonBody());
    });

    // --- Alias IT recrutement (rétrocompatibilité) ---
    $router->get('/api/public/{site_slug}/recrutement/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersListHandler($siteId);
    });

    $router->get('/api/public/{site_slug}/recrutement/offers/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersDetailHandler($siteId, $params['slug']);
    });

    $router->post('/api/public/{site_slug}/recrutement/offers/{id}/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersApplyHandler($siteId, (int) $params['id']);
    });

    $router->post('/api/public/{site_slug}/recrutement/apply', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        $data = Router::getJsonBody();
        $offreId = (int) ($data['offer_id'] ?? $data['offre_id'] ?? 0);
        if ($offreId <= 0) {
            Response::badRequest('offer_id requis');
            return;
        }
        publicOffersApplyHandler($siteId, $offreId);
    });

    $router->get('/api/public/{site_slug}/recrutement/metiers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersMetiersHandler($siteId);
    });

    // --- Alias médical ---
    $router->get('/api/public/{site_slug}/medical/offers', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }
        publicOffersListHandler($siteId, false);
    });
}
