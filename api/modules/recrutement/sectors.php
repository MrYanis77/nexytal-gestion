<?php
/**
 * modules/recrutement/sectors.php — CRUD secteurs_activite
 */

require_once __DIR__ . '/site_scope.php';

function registerRecrutementSectorsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/sectors', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $sql = 'SELECT sa.*,
            (SELECT COUNT(*) FROM metiers m WHERE m.secteur_id = sa.id AND m.site_id = :site_id) AS metiers_count
        FROM secteurs_activite sa
        ORDER BY sa.label ASC';
        $stmt = $db->prepare($sql);
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/sectors', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        if (!isset($data['label']) && isset($data['name'])) {
            $data['label'] = $data['name'];
        }
        
        Validator::make($data)->required('label', 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['label']);
        
        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM secteurs_activite WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Sector slug already exists'); return; }

        $siteId = recrutementResolveSiteIdFromBody($data, $admin);
        $stmt = $db->prepare('INSERT INTO secteurs_activite (slug, label) VALUES (:slug, :label)');
        $stmt->bindParam(':label', $data['label'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'secteur_activite', $newId, null, $data);
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
        
        Audit::log((int) $admin['id'], null, 'update', 'secteur_activite', $id, $old, $data);
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
        
        Audit::log((int) $admin['id'], null, 'delete', 'secteur_activite', $id, $old, null);
        Response::noContent();
    });
}
