<?php
/**
 * modules/recrutement/sectors.php — CRUD secteurs_activite
 */

function registerRecrutementSectorsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/sectors', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        $sql = 'SELECT * FROM secteurs_activite';
        $params = [];
        if ($siteId !== null && $siteId !== '') {
            $sql .= ' WHERE site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $sql .= ' ORDER BY label ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, PDO::PARAM_INT);
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/sectors', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        
        Validator::make($data)->required('label', 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['label']);
        
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM secteurs_activite WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Sector slug already exists'); return; }

        $siteId = isset($data['site_id']) ? (int) $data['site_id'] : (int) ($_SERVER['HTTP_X_SITE_ID'] ?? 0);
        $stmt = $db->prepare('INSERT INTO secteurs_activite (site_id, label, slug) VALUES (:site_id, :label, :slug)');
        $stmt->bindValue(':site_id', $siteId > 0 ? $siteId : null, PDO::PARAM_INT);
        $stmt->bindParam(':label', $data['label'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 1, 'create', 'secteur_activite', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/sectors/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM secteurs_activite WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Sector not found'); return; }

        $fields = []; $bind = [];
        foreach (['label', 'slug'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        
        $sql = 'UPDATE secteurs_activite SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'update', 'secteur_activite', $id, $old, $data);
        Response::success(['id' => $id], 'Sector updated');
    });

    $router->delete('/api/admin/recrutement/sectors/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM secteurs_activite WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Sector not found'); return; }
        
        $stmt = $db->prepare('DELETE FROM secteurs_activite WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'delete', 'secteur_activite', $id, $old, null);
        Response::noContent();
    });
}
