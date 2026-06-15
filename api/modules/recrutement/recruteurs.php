<?php
/**
 * modules/recrutement/recruteurs.php — CRUD recruteurs
 */

function registerRecrutementRecruteursRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/recruteurs', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        $sql = 'SELECT r.*, e.nom as entreprise_nom, u.email
                FROM recruteurs r
                LEFT JOIN entreprises e ON r.entreprise_id = e.id
                LEFT JOIN users u ON r.user_id = u.id';
        $params = [];
        if ($siteId !== null && $siteId !== '') {
            $sql .= ' WHERE e.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $sql .= ' ORDER BY r.nom ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, PDO::PARAM_INT);
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/recruteurs', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        
        Validator::make($data)->required('entreprise_id', 'Entreprise')->required('prenom', 'Prénom')->required('nom', 'Nom')->validate();
        
        $db = getDb();
        $userId = isset($data['user_id']) ? (int) $data['user_id'] : null;
        if ($userId) {
            $stmt = $db->prepare('SELECT id FROM recruteurs WHERE user_id = :user_id LIMIT 1');
            $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
            $stmt->execute();
            if ($stmt->fetch()) { Response::badRequest('User already has a recruteur profile'); return; }
        }

        $stmt = $db->prepare(
            'INSERT INTO recruteurs (user_id, entreprise_id, prenom, nom, fonction, telephone, principal, created_at, updated_at)
             VALUES (:user_id, :entreprise_id, :prenom, :nom, :fonction, :telephone, :principal, NOW(), NOW())'
        );
        if ($userId) {
            $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        } else {
            $stmt->bindValue(':user_id', null, PDO::PARAM_NULL);
        }
        $stmt->bindParam(':entreprise_id', $data['entreprise_id'], PDO::PARAM_INT);
        $stmt->bindParam(':prenom', $data['prenom'], PDO::PARAM_STR);
        $stmt->bindParam(':nom', $data['nom'], PDO::PARAM_STR);
        $func = $data['fonction'] ?? null;
        $stmt->bindParam(':fonction', $func, PDO::PARAM_STR);
        $tel = $data['telephone'] ?? null;
        $stmt->bindParam(':telephone', $tel, PDO::PARAM_STR);
        $prin = $data['principal'] ?? 0;
        $stmt->bindParam(':principal', $prin, PDO::PARAM_INT);
        $stmt->execute();
        
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 1, 'create', 'recruteur', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/recruteurs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }

        $fields = []; $bind = [];
        foreach (['user_id', 'entreprise_id', 'prenom', 'nom', 'fonction', 'telephone', 'principal'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE recruteurs SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'update', 'recruteur', $id, $old, $data);
        Response::success(['id' => $id], 'Recruteur updated');
    });

    $router->delete('/api/admin/recrutement/recruteurs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }
        
        $stmt = $db->prepare('DELETE FROM recruteurs WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'delete', 'recruteur', $id, $old, null);
        Response::noContent();
    });
}
