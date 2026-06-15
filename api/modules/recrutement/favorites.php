<?php
/**
 * modules/recrutement/favorites.php — CRUD offres_favorites
 */

function registerRecrutementFavoritesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/favorites', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT f.*, c.prenom, c.nom, o.titre as offre_titre
             FROM offres_favorites f
             INNER JOIN candidats c ON f.candidat_id = c.id
             INNER JOIN offres_emploi o ON f.offre_id = o.id
             ORDER BY f.created_at DESC'
        );
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/favorites', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('candidat_id', 'Candidat')->required('offre_id', 'Offre')->validate();

        $db = getDb();
        try {
            $stmt = $db->prepare('INSERT INTO offres_favorites (candidat_id, offre_id, created_at) VALUES (:cid, :oid, NOW())');
            $stmt->execute([':cid' => $data['candidat_id'], ':oid' => $data['offre_id']]);
            Audit::log((int) $admin['id'], 1, 'create', 'offre_favorite', 0, null, $data);
            Response::created(null, 'Favorite created');
        } catch (\PDOException $e) {
            Response::badRequest('Favorite already exists');
        }
    });

    $router->delete('/api/admin/recrutement/favorites', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $candidatId = Router::getQueryParam('candidat_id');
        $offreId = Router::getQueryParam('offre_id');
        if (!$candidatId || !$offreId) { Response::badRequest('candidat_id and offre_id required'); return; }

        $db = getDb();
        $stmt = $db->prepare('DELETE FROM offres_favorites WHERE candidat_id = :cid AND offre_id = :oid');
        $stmt->execute([':cid' => (int) $candidatId, ':oid' => (int) $offreId]);
        Audit::log((int) $admin['id'], 1, 'delete', 'offre_favorite', 0, null, null);
        Response::noContent();
    });
}
