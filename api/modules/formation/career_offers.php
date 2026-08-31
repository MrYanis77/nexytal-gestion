<?php
/**
 * modules/formation/career_offers.php — Carrières Alt RH (offres_emploi existante)
 */

require_once __DIR__ . '/formation_career_helpers.php';

function registerFormationCareerOffersRoutes(Router $router): void
{
    $router->get('/api/admin/formation/career-offers', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        if (!formationCareerEnsureSchema($db)) {
            Response::success([]);
            return;
        }

        $where = ['o.site_id = :site_id', formationCareerWhereClause('o')];
        $params = [':site_id' => $siteId];

        if ($dept = Router::getQueryParam('department')) {
            $where[] = 'o.department = :department';
            $params[':department'] = $dept;
        }
        if ($status = Router::getQueryParam('status')) {
            $statut = $status === 'publie' ? 'publiee' : offreNormalizeStatutForDb($db, $status);
            $where[] = 'o.statut = :statut';
            $params[':statut'] = $statut;
        }

        $order = recrutementTableHasColumn($db, 'offres_emploi', 'sort_order')
            ? 'o.sort_order ASC, o.created_at DESC'
            : 'o.created_at DESC';

        $sql = 'SELECT o.* FROM offres_emploi o WHERE ' . implode(' AND ', $where) . " ORDER BY {$order}";
        $stmt = $db->prepare($sql);
        $stmt->execute($params);
        $rows = array_map('formationCareerOfferFromOffreRow', $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::success($rows);
    });

    $router->get('/api/admin/formation/career-offers/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $db = getDb();

        if (!formationCareerEnsureSchema($db)) {
            Response::notFound('Offre introuvable');
            return;
        }

        $stmt = $db->prepare(
            'SELECT o.* FROM offres_emploi o
             WHERE o.id = :id AND o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            Response::notFound('Offre introuvable');
            return;
        }
        Response::success(formationCareerOfferFromOffreRow($row));
    });

    $router->post('/api/admin/formation/career-offers', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();

        if (!formationCareerRequireSchema($db)) {
            return;
        }

        $title = trim((string) ($data['title'] ?? $data['titre'] ?? ''));
        Validator::make(array_merge($data, ['title' => $title]))
            ->required('title', 'Titre')
            ->required('department', 'Département')
            ->validate();

        $entrepriseId = formationCareerResolveEntrepriseId($db);
        if ($entrepriseId === null) {
            Response::badRequest('Entreprise Alt RH Formations introuvable (slug alt-rh-formations).');
            return;
        }

        $cols = formationCareerPayloadToOffreColumns($data, $siteId, $entrepriseId, $db);

        $stmt = $db->prepare('SELECT id FROM offres_emploi WHERE site_id = :site_id AND slug = :slug LIMIT 1');
        $stmt->execute([':site_id' => $siteId, ':slug' => $cols['slug']]);
        if ($stmt->fetch()) {
            Response::badRequest('Ce slug existe déjà pour ce site.');
            return;
        }

        $db->beginTransaction();
        try {
            $newId = formationCareerInsertOffre($db, $cols);
            formationCareerSyncCompetences($db, $newId, $cols);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            Response::serverError('Échec de la création de l\'offre', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'create', 'offre_emploi', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/formation/career-offers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        if (!formationCareerRequireSchema($db)) {
            return;
        }

        $stmt = $db->prepare(
            'SELECT * FROM offres_emploi WHERE id = :id AND site_id = :site_id AND ' . formationCareerWhereClause('offres_emploi') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Offre introuvable');
            return;
        }

        $entrepriseId = formationCareerResolveEntrepriseId($db) ?? (int) $old['entreprise_id'];
        $cols = formationCareerPayloadToOffreColumns(array_merge($old, $data), $siteId, $entrepriseId, $db);

        $db->beginTransaction();
        try {
            formationCareerUpdateOffre($db, $id, $siteId, $cols);
            formationCareerSyncCompetences($db, $id, $cols);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            Response::serverError('Échec de la mise à jour', $e->getMessage());
            return;
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'offre_emploi', $id, $old, $data);
        Response::success(['id' => $id], 'Offre mise à jour');
    });

    $router->delete('/api/admin/formation/career-offers/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT * FROM offres_emploi WHERE id = :id AND site_id = :site_id AND ' . formationCareerWhereClause('offres_emploi') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Offre introuvable');
            return;
        }

        $stmt = $db->prepare('DELETE FROM offres_emploi WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'offre_emploi', $id, $old, null);
        Response::noContent();
    });
}
