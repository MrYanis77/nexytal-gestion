<?php
/**
 * modules/recrutement/offers.php — CRUD offres_emploi (v2.1)
 */

require_once __DIR__ . '/site_scope.php';

/** Offre en attente de validation Nexytal Gestion (bdd.sql). */
function offreAwaitingValidation(string $statut): bool
{
    return $statut === 'brouillon';
}

function offrePendingWhereClause(PDO $db): string
{
    return "o.statut = 'brouillon' AND o.recruteur_id IS NOT NULL";
}

function offreNormalizeStatutForDb(PDO $db, string $statut): string
{
    $statut = trim($statut);
    $map = [
        'publie' => 'publiee',
        'published' => 'publiee',
        'draft' => 'brouillon',
        'archived' => 'archivee',
        'en_attente' => 'brouillon',
        'refusee' => 'archivee',
    ];
    if (isset($map[$statut])) {
        $statut = $map[$statut];
    }
    $allowed = ['brouillon', 'publiee', 'pourvue', 'expiree', 'archivee'];
    return in_array($statut, $allowed, true) ? $statut : 'brouillon';
}

function offreFetchById(PDO $db, int $id): ?array
{
    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $id]);
    $row = $stmt->fetch();
    return $row ?: null;
}

function offreAssertAdminSiteAccess(array $admin, array $offer): void
{
    if ($admin['role'] !== 'superadmin') {
        Middleware::requireSiteAccess((int) $offer['site_id']);
    }
}

function offreValidatePublishable(array $offer): array
{
    $errors = [];
    if (trim((string) ($offer['titre'] ?? '')) === '') {
        $errors['titre'] = 'Titre requis';
    }
    if (empty($offer['entreprise_id'])) {
        $errors['entreprise_id'] = 'Entreprise requise';
    }
    $desc = trim((string) ($offer['description'] ?? ''));
    if ($desc === '' || $desc === '—') {
        $errors['description'] = 'Description requise';
    }
    return $errors;
}

/**
 * Copie ville, code postal, département et région depuis l'établissement lié.
 */
function offreLocationFromEntreprise(PDO $db, int $entrepriseId): array
{
    $cols = ['ville', 'code_postal'];
    if (recrutementTableHasColumn($db, 'entreprises', 'departement')) {
        $cols[] = 'departement';
    }
    if (recrutementTableHasColumn($db, 'entreprises', 'region')) {
        $cols[] = 'region';
    }

    $stmt = $db->prepare('SELECT ' . implode(', ', $cols) . ' FROM entreprises WHERE id = :id LIMIT 1');
    $stmt->bindValue(':id', $entrepriseId, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch();
    if (!$row) {
        return [
            'ville' => null,
            'code_postal' => null,
            'departement' => null,
            'region' => null,
        ];
    }

    return [
        'ville' => $row['ville'] ?? null,
        'code_postal' => $row['code_postal'] ?? null,
        'departement' => $row['departement'] ?? null,
        'region' => $row['region'] ?? null,
    ];
}

function offreApplyEntrepriseLocation(PDO $db, array $data): array
{
    $entrepriseId = (int) ($data['entreprise_id'] ?? 0);
    if ($entrepriseId <= 0) {
        return $data;
    }

    $location = offreLocationFromEntreprise($db, $entrepriseId);
    foreach ($location as $key => $value) {
        $data[$key] = $value;
    }

    return $data;
}


function offreEnsureEntrepriseForPayload(PDO $db, array &$data, int $siteId): void
{
    if (!empty($data['entreprise_id'])) {
        return;
    }

    $companyName = trim((string) ($data['company_name'] ?? $data['entreprise_nom'] ?? $data['nom_entreprise'] ?? ''));
    if ($companyName === '') {
        return;
    }

    $slug = Validator::slugify($companyName);
    $stmt = $db->prepare('SELECT id FROM entreprises WHERE slug = :slug LIMIT 1');
    $stmt->execute([':slug' => $slug]);
    $existing = $stmt->fetchColumn();
    if ($existing) {
        $data['entreprise_id'] = (int) $existing;
        return;
    }

    $columns = ['nom', 'slug', 'ville', 'validee', 'created_at', 'updated_at'];
    $values = [':nom', ':slug', ':ville', '1', 'NOW()', 'NOW()'];
    $bind = [
        ':nom' => $companyName,
        ':slug' => $slug,
        ':ville' => $data['location'] ?? $data['ville'] ?? null,
    ];

    if (dbTableHasColumn($db, 'entreprises', 'site_id')) {
        array_unshift($columns, 'site_id');
        array_unshift($values, ':site_id');
        $bind[':site_id'] = $siteId;
    }

    $sql = 'INSERT INTO entreprises (' . implode(', ', $columns) . ') VALUES (' . implode(', ', $values) . ')';
    $stmt = $db->prepare($sql);
    foreach ($bind as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->execute();
    $data['entreprise_id'] = (int) $db->lastInsertId();
}

function offreNormalizePayloadAliases(array $data): array
{
    if (!isset($data['titre']) && isset($data['title'])) {
        $data['titre'] = $data['title'];
    }
    if (!isset($data['description'])) {
        $data['description'] = $data['full_desc'] ?? $data['description_complete'] ?? $data['short_desc'] ?? null;
    }
    if (!isset($data['profil_recherche']) && isset($data['profile'])) {
        $data['profil_recherche'] = $data['profile'];
    }
    if (!isset($data['metier_id']) && isset($data['job_id'])) {
        $data['metier_id'] = $data['job_id'];
    }
    if (!isset($data['type_contrat'])) {
        $contractMap = [1 => 'cdi', 2 => 'cdd', 3 => 'stage', 4 => 'alternance', 5 => 'freelance'];
        $contractTypeId = isset($data['contract_type_id']) ? (int) $data['contract_type_id'] : 0;
        $data['type_contrat'] = $data['contract_type'] ?? ($contractMap[$contractTypeId] ?? 'cdi');
    }
    if (!isset($data['statut']) && isset($data['status'])) {
        $data['statut'] = $data['status'];
    }
    if (!isset($data['ville']) && isset($data['location'])) {
        $data['ville'] = $data['location'];
    }
    if (!isset($data['is_urgent']) && isset($data['urgent'])) {
        $data['is_urgent'] = $data['urgent'];
    }
    if (!isset($data['competences']) && isset($data['competence_ids']) && is_array($data['competence_ids'])) {
        $data['competences'] = array_map(static fn ($id) => ['competence_id' => $id], $data['competence_ids']);
    }
    return $data;
}
function registerRecrutementOffersRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/offers', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $pagination = Router::getPagination();

        $siteId = Router::getQueryParam('site_id');
        if ($siteId === null || $siteId === '') {
            $siteId = $_SERVER['HTTP_X_SITE_ID'] ?? null;
        }

        $where = [];
        $params = [];
        if ($siteId !== null && $siteId !== '') {
            $where[] = 'o.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }

        if ($status = Router::getQueryParam('statut')) {
            if ($status === 'en_attente') {
                $where[] = offrePendingWhereClause($db);
            } elseif ($status === 'refusee') {
                $where[] = "o.statut = 'archivee'";
            } else {
                $where[] = 'o.statut = :statut';
                $params[':statut'] = offreNormalizeStatutForDb($db, $status);
            }
        }

        $whereClause = $where !== [] ? 'WHERE ' . implode(' AND ', $where) : '';

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM offres_emploi o $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $extraCols = '';
        if ($status === 'publiee') {
            $extraCols = ",
                (SELECT COUNT(*) FROM candidatures_externes ce WHERE ce.offre_id = o.id) +
                (SELECT COUNT(*) FROM candidatures c WHERE c.offre_id = o.id) as nb_candidatures";
        }

        $siteJoin = ($siteId === null || $siteId === '') ? ' INNER JOIN core_sites s ON s.id = o.site_id' : '';
        $siteCol = ($siteId === null || $siteId === '') ? ', s.name as site_name' : '';

        $stmt = $db->prepare(
            "SELECT o.*, e.nom as entreprise_nom, m.libelle as metier_libelle$siteCol$extraCols
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             $siteJoin
             $whereClause
             ORDER BY o.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/recrutement/offers/pending', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $pagination = Router::getPagination();
        $siteId = Router::getQueryParam('site_id');

        $where = [offrePendingWhereClause($db)];
        $params = [];
        
        if ($siteId) {
            $where[] = "o.site_id = :site_id";
            $params[':site_id'] = $siteId;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM offres_emploi o $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.*, e.nom as entreprise_nom, m.libelle as metier_libelle, s.name as site_name, s.slug as site_slug,
                    r.email as recruteur_email, r.prenom as recruteur_prenom, r.nom as recruteur_nom, r.nom_entreprise
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             LEFT JOIN recruteurs r ON r.id = o.recruteur_id
             INNER JOIN core_sites s ON o.site_id = s.id
             $whereClause
             ORDER BY o.created_at ASC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        Response::paginated($stmt->fetchAll(), $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/recrutement/offers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $offer = offreFetchById($db, $id);
        if (!$offer) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $offer);

        $stmt = $db->prepare(
            'SELECT o.*, e.nom as entreprise_nom, m.libelle as metier_libelle, s.name as site_name,
                    r.email as recruteur_email, r.prenom as recruteur_prenom, r.nom as recruteur_nom
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             LEFT JOIN core_sites s ON o.site_id = s.id
             LEFT JOIN recruteurs r ON r.id = o.recruteur_id
             WHERE o.id = :id LIMIT 1'
        );
        $stmt->execute([':id' => $id]);
        $offer = $stmt->fetch();
        if (!$offer) {
            Response::notFound('Offer not found');
            return;
        }

        $stmtC = $db->prepare(
            'SELECT c.*, oc.importance FROM competences c
             INNER JOIN offre_competences oc ON c.id = oc.competence_id
             WHERE oc.offre_id = :id'
        );
        $stmtC->execute([':id' => $id]);
        $offer['competences'] = $stmtC->fetchAll();

        Response::success($offer);
    });

    $router->get('/api/admin/recrutement/offers/{id}/candidatures', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $offer = offreFetchById($db, $id);
        if (!$offer) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $offer);
        $siteId = (int) $offer['site_id'];

        $stmtExt = $db->prepare(
            'SELECT ce.id, ce.offre_id, ce.statut,
                    ce.created_at as date_candidature, ce.created_at,
                    ce.prenom, ce.nom, ce.email, ce.telephone, ce.lettre_motivation,
                    ce.cv_filename, ce.experience_candidat, ce.competences_reponses, ce.disponibilite
             FROM candidatures_externes ce
             WHERE ce.offre_id = :oid
             ORDER BY ce.created_at DESC'
        );
        $stmtExt->execute([':oid' => $id]);
        $externes = $stmtExt->fetchAll();

        $stmtInt = $db->prepare(
            'SELECT c.id, c.offre_id, c.statut,
                    c.date_candidature, c.message_motivation,
                    cand.prenom, cand.nom, u.email, cand.telephone
             FROM candidatures c
             INNER JOIN candidats cand ON c.candidat_id = cand.id
             LEFT JOIN users u ON cand.user_id = u.id
             WHERE c.offre_id = :oid
             ORDER BY c.date_candidature DESC'
        );
        $stmtInt->execute([':oid' => $id]);
        $internes = $stmtInt->fetchAll();

        Response::success([
            'externes' => $externes,
            'internes' => $internes,
            'total' => count($externes) + count($internes),
        ]);
    });

    $router->post('/api/admin/recrutement/offers/{id}/publish', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];

        $old = offreFetchById($db, $id);
        if (!$old) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $old);

        $statut = trim((string) ($old['statut'] ?? ''));

        if ($statut === 'publiee') {
            Response::success([
                'id' => $id,
                'statut' => 'publiee',
                'site_id' => (int) $old['site_id'],
                'already_published' => true,
            ], 'Offre déjà publiée');
            return;
        }

        if (!offreAwaitingValidation($statut)) {
            Response::badRequest('Cette offre ne peut pas être publiée (statut actuel : ' . $statut . ')');
            return;
        }

        $validationErrors = offreValidatePublishable($old);
        if ($validationErrors !== []) {
            Response::validationError($validationErrors, 'Complétez l\'offre avant publication');
            return;
        }

        try {
            $db->prepare(
                "UPDATE offres_emploi SET statut = 'publiee', date_publication = COALESCE(date_publication, NOW()), updated_at = NOW() WHERE id = :id"
            )->execute([':id' => $id]);
        } catch (\PDOException $e) {
            Response::serverError('Échec de la publication', $e->getMessage());
            return;
        }

        require_once __DIR__ . '/notifications.php';
        try {
            recrutementNotifyRecruiterOfferStatus($db, $old, 'publiee');
        } catch (\Throwable $e) {
            // notification non bloquante
        }

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'publish', 'offre_emploi', $id, $old, ['statut' => 'publiee']);
        Response::success(['id' => $id, 'statut' => 'publiee', 'site_id' => (int) $old['site_id']], 'Offre publiée');
    });

    $router->post('/api/admin/recrutement/offers/{id}/reject', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $old = offreFetchById($db, $id);
        if (!$old) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $old);

        $statut = trim((string) ($old['statut'] ?? ''));

        if (!offreAwaitingValidation($statut)) {
            Response::badRequest('Cette offre ne peut pas être refusée (statut actuel : ' . $statut . ')');
            return;
        }

        $rejectStatut = 'archivee';
        $db->prepare('UPDATE offres_emploi SET statut = :statut, updated_at = NOW() WHERE id = :id')
            ->execute([':statut' => $rejectStatut, ':id' => $id]);

        require_once __DIR__ . '/notifications.php';
        try {
            recrutementNotifyRecruiterOfferStatus($db, $old, $rejectStatut, $data['motif_refus'] ?? null);
        } catch (\Throwable $e) {
            // notification non bloquante
        }

        Audit::log((int) $admin['id'], (int) $old['site_id'], 'reject', 'offre_emploi', $id, $old, $data);
        Response::success(['id' => $id, 'statut' => $rejectStatut, 'site_id' => (int) $old['site_id']], 'Offre archivée');
    });

    $router->post('/api/admin/recrutement/offers', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = offreNormalizePayloadAliases(Router::getJsonBody());
        $db = getDb();
        offreEnsureEntrepriseForPayload($db, $data, $siteId);

        Validator::make($data)->required('entreprise_id', 'Entreprise')->required('titre', 'Titre')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['titre']);
        $db->beginTransaction();
        try {
            $data = offreApplyEntrepriseLocation($db, $data);

            $stmt = $db->prepare('SELECT id FROM offres_emploi WHERE site_id = :site_id AND slug = :slug LIMIT 1');
            $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
            if ($stmt->fetch()) { $db->rollBack(); Response::badRequest('Offer slug already exists'); return; }

            $statut = offreNormalizeStatutForDb($db, (string) ($data['statut'] ?? 'brouillon'));
            $pubAt = ($statut === 'publiee') ? date('Y-m-d H:i:s') : ($data['date_publication'] ?? null);

            $stmt = $db->prepare(
                'INSERT INTO offres_emploi
                 (site_id, entreprise_id, recruteur_id, metier_id, reference, slug, titre, description, profil_recherche,
                  avantages, competences_text, type_contrat, experience_min, salaire_min, salaire_max, salaire_afficher, teletravail,
                  temps_travail, ville, code_postal, departement, region, is_featured, is_urgent, statut,
                  date_publication, date_expiration, created_at, updated_at)
                 VALUES
                 (:site_id, :eid, :rid, :mid, :ref, :slug, :titre, :desc, :pr, :av, :comp_text, :tc, :exp, :smin, :smax, :saff,
                  :tele, :tt, :ville, :cp, :dep, :reg, :feat, :urg, :statut, :pub_at, :exp_at, NOW(), NOW())'
            );
            $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
            $stmt->bindValue(':eid', $data['entreprise_id'], PDO::PARAM_INT);
            $stmt->bindValue(':rid', $data['recruteur_id'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':mid', $data['metier_id'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':ref', $data['reference'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':titre', $data['titre'], PDO::PARAM_STR);
            $stmt->bindValue(':desc', $data['description'] ?? '—', PDO::PARAM_STR);
            $stmt->bindValue(':pr', $data['profil_recherche'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':av', $data['avantages'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':comp_text', $data['competences_text'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':tc', $data['type_contrat'] ?? 'cdi', PDO::PARAM_STR);
            $stmt->bindValue(':exp', $data['experience_min'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':smin', $data['salaire_min'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':smax', $data['salaire_max'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':saff', $data['salaire_afficher'] ?? 1, PDO::PARAM_INT);
            $stmt->bindValue(':tele', $data['teletravail'] ?? 'non', PDO::PARAM_STR);
            $stmt->bindValue(':tt', $data['temps_travail'] ?? 'temps_plein', PDO::PARAM_STR);
            $stmt->bindValue(':ville', $data['ville'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cp', $data['code_postal'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':dep', $data['departement'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':reg', $data['region'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':feat', $data['is_featured'] ?? 0, PDO::PARAM_INT);
            $stmt->bindValue(':urg', $data['is_urgent'] ?? 0, PDO::PARAM_INT);
            $stmt->bindValue(':statut', $statut, PDO::PARAM_STR);
            $stmt->bindValue(':pub_at', $pubAt, PDO::PARAM_STR);
            $stmt->bindValue(':exp_at', $data['date_expiration'] ?? null, PDO::PARAM_STR);
            $stmt->execute();

            $newId = (int) $db->lastInsertId();

            if (!empty($data['competences_text'])) {
                offreSyncCompetencesFromText($db, $newId, (string) $data['competences_text']);
            } elseif (isset($data['competences']) && is_array($data['competences'])) {
                $stmtC = $db->prepare('INSERT INTO offre_competences (offre_id, competence_id, importance) VALUES (:oid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([':oid' => $newId, ':cid' => $c['competence_id'], ':imp' => $c['importance'] ?? 'essentielle']);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'create', 'offre_emploi', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create offer', $e->getMessage());
        }
    });

    $router->put('/api/admin/recrutement/offers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $old = offreFetchById($db, $id);
        if (!$old) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $old);
        $siteId = (int) $old['site_id'];

        if (array_key_exists('statut', $data)) {
            $rawStatut = (string) $data['statut'];
            if ($rawStatut === 'publie') {
                $rawStatut = 'publiee';
            }
            $data['statut'] = offreNormalizeStatutForDb($db, $rawStatut);
        }

        $db->beginTransaction();
        try {
            $entrepriseId = array_key_exists('entreprise_id', $data)
                ? (int) $data['entreprise_id']
                : (int) $old['entreprise_id'];
            if ($entrepriseId > 0) {
                $data = offreApplyEntrepriseLocation($db, array_merge($data, ['entreprise_id' => $entrepriseId]));
            }

            $fields = [];
            $bind = [];
            $updatable = [
                'entreprise_id', 'recruteur_id', 'metier_id', 'reference', 'slug', 'titre', 'description',
                'profil_recherche', 'avantages', 'type_contrat', 'experience_min', 'salaire_min', 'salaire_max',
                'salaire_afficher', 'teletravail', 'temps_travail', 'ville', 'code_postal', 'departement',
                'region', 'is_featured', 'is_urgent', 'statut', 'date_publication', 'date_expiration',
                'competences_text',
            ];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
            }
            if (array_key_exists('criteres_json', $data)) {
                $fields[] = 'criteres_json = :criteres_json';
                $bind[':criteres_json'] = is_array($data['criteres_json'])
                    ? json_encode($data['criteres_json'], JSON_UNESCAPED_UNICODE)
                    : $data['criteres_json'];
            }
            if (!empty($fields)) {
                $fields[] = 'updated_at = NOW()';
                $sql = 'UPDATE offres_emploi SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmtU = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
                $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
                $stmtU->execute();
            }

            if (array_key_exists('competences_text', $data)) {
                offreSyncCompetencesFromText($db, $id, (string) ($data['competences_text'] ?? ''));
            } elseif (isset($data['competences']) && is_array($data['competences'])) {
                $db->prepare('DELETE FROM offre_competences WHERE offre_id = :id')->execute([':id' => $id]);
                $stmtC = $db->prepare('INSERT INTO offre_competences (offre_id, competence_id, importance) VALUES (:oid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([':oid' => $id, ':cid' => $c['competence_id'], ':imp' => $c['importance'] ?? 'essentielle']);
                }
            }

            $shouldRecalc = array_key_exists('criteres_json', $data)
                || array_key_exists('competences_text', $data)
                || isset($data['competences']);
            if ($shouldRecalc && ($old['statut'] ?? '') === 'publiee') {
                require_once __DIR__ . '/scoring.php';
                recrutementRecalculateOfferScores($db, $id);
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'offre_emploi', $id, $old, $data);
            Response::success(['id' => $id], 'Offer updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update offer', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/offers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $old = offreFetchById($db, $id);
        if (!$old) {
            Response::notFound('Offer not found');
            return;
        }
        offreAssertAdminSiteAccess($admin, $old);
        $siteId = (int) $old['site_id'];

        $db->beginTransaction();
        try {
            // Check for existing applications
            $stmtCheck = $db->prepare('SELECT COUNT(*) as count FROM candidatures WHERE offre_id = :id');
            $stmtCheck->execute([':id' => $id]);
            $hasCandidatures = $stmtCheck->fetch()['count'] > 0;
            
            $stmtCheckExt = $db->prepare('SELECT COUNT(*) as count FROM candidatures_externes WHERE offre_id = :id');
            $stmtCheckExt->execute([':id' => $id]);
            $hasCandidaturesExt = $stmtCheckExt->fetch()['count'] > 0;

            if ($hasCandidatures || $hasCandidaturesExt) {
                $db->rollBack();
                Response::badRequest('Impossible de supprimer cette offre car elle possède des candidatures liées.');
                return;
            }

            // Manually delete dependent records
            $db->prepare('DELETE FROM offre_competences WHERE offre_id = :id')->execute([':id' => $id]);
            $db->prepare('DELETE FROM offres_favorites WHERE offre_id = :id')->execute([':id' => $id]);

            $stmt = $db->prepare('DELETE FROM offres_emploi WHERE id = :id');
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'delete', 'offre_emploi', $id, $old, null);
            Response::noContent();
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to delete offer', $e->getMessage());
        }
    });
}

/**
 * Crée ou réutilise des compétences à partir d'un texte libre (une par ligne).
 */
function offreSyncCompetencesFromText(PDO $db, int $offreId, string $text): void
{
    $db->prepare('DELETE FROM offre_competences WHERE offre_id = :id')->execute([':id' => $offreId]);

    $labels = preg_split('/[\r\n,;]+/', $text) ?: [];
    $stmtFind = $db->prepare('SELECT id FROM competences WHERE label = :label LIMIT 1');
    $stmtInsert = $db->prepare('INSERT INTO competences (slug, label, categorie) VALUES (:slug, :label, :cat)');
    $stmtLink = $db->prepare('INSERT INTO offre_competences (offre_id, competence_id, importance) VALUES (:oid, :cid, :imp)');

    foreach ($labels as $label) {
        $label = trim($label);
        if ($label === '') {
            continue;
        }

        $stmtFind->execute([':label' => $label]);
        $existing = $stmtFind->fetch();
        if ($existing) {
            $competenceId = (int) $existing['id'];
        } else {
            $slug = Validator::slugify($label);
            $baseSlug = $slug;
            $n = 1;
            $stmtSlugCheck = $db->prepare('SELECT id FROM competences WHERE slug = :slug LIMIT 1');
            while (true) {
                $stmtSlugCheck->execute([':slug' => $slug]);
                if (!$stmtSlugCheck->fetch()) {
                    break;
                }
                $slug = $baseSlug . '-' . $n++;
            }
            $stmtInsert->execute([':slug' => $slug, ':label' => $label, ':cat' => 'technique']);
            $competenceId = (int) $db->lastInsertId();
        }

        $stmtLink->execute([':oid' => $offreId, ':cid' => $competenceId, ':imp' => 'essentielle']);
    }
}
