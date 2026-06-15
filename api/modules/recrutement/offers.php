<?php
/**
 * modules/recrutement/offers.php — CRUD offres_emploi (v2.1)
 */

function registerRecrutementOffersRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/offers', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        $where = ['o.site_id = :site_id'];
        $params = [':site_id' => $siteId];

        if ($status = Router::getQueryParam('statut')) {
            $where[] = 'o.statut = :statut';
            $params[':statut'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare("SELECT COUNT(*) as total FROM offres_emploi o $whereClause");
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT o.*, e.nom as entreprise_nom, m.libelle as metier_libelle
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
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

    $router->get('/api/admin/recrutement/offers/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT o.*, e.nom as entreprise_nom, m.libelle as metier_libelle
             FROM offres_emploi o
             LEFT JOIN entreprises e ON o.entreprise_id = e.id
             LEFT JOIN metiers m ON o.metier_id = m.id
             WHERE o.id = :id AND o.site_id = :site_id LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $offer = $stmt->fetch();
        if (!$offer) { Response::notFound('Offer not found'); return; }

        $stmtC = $db->prepare(
            'SELECT c.*, oc.importance FROM competences c
             INNER JOIN offre_competences oc ON c.id = oc.competence_id
             WHERE oc.offre_id = :id'
        );
        $stmtC->execute([':id' => $id]);
        $offer['competences'] = $stmtC->fetchAll();

        Response::success($offer);
    });

    $router->post('/api/admin/recrutement/offers', function () {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('entreprise_id', 'Entreprise')->required('titre', 'Titre')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['titre']);

        $db = getDb();
        $db->beginTransaction();
        try {
            $stmt = $db->prepare('SELECT id FROM offres_emploi WHERE site_id = :site_id AND slug = :slug LIMIT 1');
            $stmt->execute([':site_id' => $siteId, ':slug' => $slug]);
            if ($stmt->fetch()) { Response::badRequest('Offer slug already exists'); return; }

            $statut = $data['statut'] ?? 'brouillon';
            $pubAt = ($statut === 'publiee') ? date('Y-m-d H:i:s') : ($data['date_publication'] ?? null);

            $stmt = $db->prepare(
                'INSERT INTO offres_emploi
                 (site_id, entreprise_id, recruteur_id, metier_id, reference, slug, titre, description, profil_recherche,
                  avantages, type_contrat, experience_min, salaire_min, salaire_max, salaire_afficher, teletravail,
                  temps_travail, ville, code_postal, departement, region, is_featured, is_urgent, statut,
                  date_publication, date_expiration, meta_title, meta_description, created_at, updated_at)
                 VALUES
                 (:site_id, :eid, :rid, :mid, :ref, :slug, :titre, :desc, :pr, :av, :tc, :exp, :smin, :smax, :saff,
                  :tele, :tt, :ville, :cp, :dep, :reg, :feat, :urg, :statut, :pub_at, :exp_at, :mt, :md, NOW(), NOW())'
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
            $stmt->bindValue(':mt', $data['meta_title'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':md', $data['meta_description'] ?? null, PDO::PARAM_STR);
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
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Offer not found'); return; }

        $db->beginTransaction();
        try {
            $fields = [];
            $bind = [];
            $updatable = [
                'entreprise_id', 'recruteur_id', 'metier_id', 'reference', 'slug', 'titre', 'description',
                'profil_recherche', 'avantages', 'type_contrat', 'experience_min', 'salaire_min', 'salaire_max',
                'salaire_afficher', 'teletravail', 'temps_travail', 'ville', 'code_postal', 'departement',
                'region', 'is_featured', 'is_urgent', 'statut', 'date_publication', 'date_expiration',
                'meta_title', 'meta_description',
            ];
            foreach ($updatable as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = $data[$f];
                }
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

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'offre_emploi', $id, $old, $data);
            Response::success(['id' => $id], 'Offer updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update offer', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/offers/{id}', function (array $params) {
        $siteId = Middleware::requireSiteIdFromRequest();
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Offer not found'); return; }

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
