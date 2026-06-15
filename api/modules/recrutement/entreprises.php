<?php
/**
 * modules/recrutement/entreprises.php — CRUD entreprises
 */

function registerRecrutementEntreprisesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/entreprises', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        $sql = 'SELECT * FROM entreprises';
        $params = [];
        if ($siteId !== null && $siteId !== '') {
            $sql .= ' WHERE site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $sql .= ' ORDER BY nom ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, PDO::PARAM_INT);
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/entreprises', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        
        Validator::make($data)->required('nom', 'Nom')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['nom']);
        
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM entreprises WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Entreprise slug already exists'); return; }

        $siteId = isset($data['site_id']) ? (int) $data['site_id'] : (int) ($_SERVER['HTTP_X_SITE_ID'] ?? 0);
        try {
            $stmt = $db->prepare(
                'INSERT INTO entreprises (site_id, nom, slug, siret, description, logo_url, site_web, taille, secteur_id, adresse, code_postal, ville, validee, created_at, updated_at)
                 VALUES (:site_id, :nom, :slug, :siret, :description, :logo_url, :site_web, :taille, :secteur_id, :adresse, :code_postal, :ville, :validee, NOW(), NOW())'
            );
            $stmt->bindValue(':site_id', $siteId > 0 ? $siteId : null, PDO::PARAM_INT);
            $stmt->bindParam(':nom', $data['nom'], PDO::PARAM_STR);
            $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
            $siret = $data['siret'] ?? null;
            $stmt->bindParam(':siret', $siret, PDO::PARAM_STR);
            $desc = $data['description'] ?? null;
            $stmt->bindParam(':description', $desc, PDO::PARAM_STR);
            $logo = $data['logo_url'] ?? null;
            $stmt->bindParam(':logo_url', $logo, PDO::PARAM_STR);
            $site = $data['site_web'] ?? null;
            $stmt->bindParam(':site_web', $site, PDO::PARAM_STR);
            $taille = $data['taille'] ?? null;
            $stmt->bindParam(':taille', $taille, PDO::PARAM_STR);
            $sec = $data['secteur_id'] ?? null;
            $stmt->bindParam(':secteur_id', $sec, PDO::PARAM_INT);
            $adr = $data['adresse'] ?? null;
            $stmt->bindParam(':adresse', $adr, PDO::PARAM_STR);
            $cp = $data['code_postal'] ?? null;
            $stmt->bindParam(':code_postal', $cp, PDO::PARAM_STR);
            $ville = $data['ville'] ?? null;
            $stmt->bindParam(':ville', $ville, PDO::PARAM_STR);
            $validee = $data['validee'] ?? 0;
            $stmt->bindParam(':validee', $validee, PDO::PARAM_INT);
            $stmt->execute();
            
            $newId = (int) $db->lastInsertId();
            Audit::log((int) $admin['id'], 1, 'create', 'entreprise', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            Response::serverError('Failed to create entreprise', $e->getMessage());
        }
    });

    $router->put('/api/admin/recrutement/entreprises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM entreprises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Entreprise not found'); return; }

        $fields = []; $bind = [];
        foreach (['nom', 'slug', 'siret', 'description', 'logo_url', 'site_web', 'taille', 'secteur_id', 'adresse', 'code_postal', 'ville', 'validee'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        try {
            $fields[] = "updated_at = NOW()";
            $sql = 'UPDATE entreprises SET ' . implode(', ', $fields) . ' WHERE id = :id';
            $stmt = $db->prepare($sql);
            foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            
            Audit::log((int) $admin['id'], 1, 'update', 'entreprise', $id, $old, $data);
            Response::success(['id' => $id], 'Entreprise updated');
        } catch (\Exception $e) {
            Response::serverError('Failed to update entreprise', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/entreprises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM entreprises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Entreprise not found'); return; }
        
        try {
            $stmtCheck = $db->prepare('SELECT COUNT(*) as count FROM offres_emploi WHERE entreprise_id = :id');
            $stmtCheck->execute([':id' => $id]);
            if ($stmtCheck->fetch()['count'] > 0) {
                Response::badRequest('Impossible de supprimer cette entreprise car elle possède des offres d\'emploi liées.');
                return;
            }

            $stmt = $db->prepare('DELETE FROM entreprises WHERE id = :id');
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            
            Audit::log((int) $admin['id'], 1, 'delete', 'entreprise', $id, $old, null);
            Response::noContent();
        } catch (\Exception $e) {
            Response::serverError('Failed to delete entreprise', $e->getMessage());
        }
    });
}
