<?php
/**
 * modules/formation/career_applications.php — Candidatures carrières (candidatures_externes)
 */

require_once __DIR__ . '/formation_career_helpers.php';

function registerFormationCareerApplicationsRoutes(Router $router): void
{
    $router->get('/api/admin/formation/career-applications', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $pagination = Router::getPagination();

        if (!formationCareerEnsureSchema($db)) {
            Response::paginated([], 0, $pagination['page'], $pagination['limit']);
            return;
        }

        $where = ['o.site_id = :site_id', formationCareerWhereClause('o')];
        $params = [':site_id' => $siteId];

        if ($offerId = Router::getQueryParam('offer_id')) {
            $where[] = 'ce.offre_id = :offer_id';
            $params[':offer_id'] = (int) $offerId;
        }
        if ($status = Router::getQueryParam('status')) {
            $where[] = 'ce.statut = :status';
            $params[':status'] = $status;
        }

        $whereClause = 'WHERE ' . implode(' AND ', $where);

        $stmt = $db->prepare(
            "SELECT COUNT(*) AS total
             FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON o.id = ce.offre_id
             $whereClause"
        );
        $stmt->execute($params);
        $total = (int) $stmt->fetch()['total'];

        $stmt = $db->prepare(
            "SELECT ce.*, o.titre AS offer_title, o.department AS offer_department
             FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON o.id = ce.offre_id
             $whereClause
             ORDER BY ce.created_at DESC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->bindValue(':limit', $pagination['limit'], PDO::PARAM_INT);
        $stmt->bindValue(':offset', $pagination['offset'], PDO::PARAM_INT);
        $stmt->execute();

        $rows = array_map('formationCareerApplicationFromRow', $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::paginated($rows, $total, $pagination['page'], $pagination['limit']);
    });

    $router->get('/api/admin/formation/career-applications/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT ce.*, o.titre AS offer_title, o.department AS offer_department
             FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON o.id = ce.offre_id
             WHERE ce.id = :id AND o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            Response::notFound('Candidature introuvable');
            return;
        }
        Response::success(formationCareerApplicationFromRow($row));
    });

    $router->put('/api/admin/formation/career-applications/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT ce.*
             FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON o.id = ce.offre_id
             WHERE ce.id = :id AND o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Candidature introuvable');
            return;
        }

        $newStatus = $data['status'] ?? $data['statut'] ?? null;
        if ($newStatus === null) {
            Response::badRequest('No fields to update');
            return;
        }

        $stmtU = $db->prepare('UPDATE candidatures_externes SET statut = :statut WHERE id = :id');
        $stmtU->execute([':statut' => $newStatus, ':id' => $id]);

        Audit::log((int) $admin['id'], $siteId, 'update', 'candidature_externe', $id, $old, $data);
        Response::success(['id' => $id], 'Candidature mise à jour');
    });

    $router->delete('/api/admin/formation/career-applications/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT ce.*
             FROM candidatures_externes ce
             INNER JOIN offres_emploi o ON o.id = ce.offre_id
             WHERE ce.id = :id AND o.site_id = :site_id AND ' . formationCareerWhereClause('o') . ' LIMIT 1'
        );
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Candidature introuvable');
            return;
        }

        $stmt = $db->prepare('DELETE FROM candidatures_externes WHERE id = :id');
        $stmt->execute([':id' => $id]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'candidature_externe', $id, $old, null);
        Response::noContent();
    });
}
