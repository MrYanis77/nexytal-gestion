<?php
/**
 * modules/recrutement/villes.php — CRUD villes
 */

function registerRecrutementVillesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/villes', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        
        if ($siteId) {
            $stmt = $db->prepare('SELECT * FROM villes WHERE site_id = :site_id OR site_id IS NULL ORDER BY nom ASC');
            $stmt->execute([':site_id' => (int) $siteId]);
        } else {
            $stmt = $db->prepare('SELECT * FROM villes ORDER BY nom ASC');
            $stmt->execute();
        }
        
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/recrutement/villes/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM villes WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch();
        if (!$row) { Response::notFound('Ville not found'); return; }
        Response::success($row);
    });

    $router->post('/api/admin/recrutement/villes', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('nom', 'Nom')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['nom']);
        $siteId = isset($data['site_id']) && $data['site_id'] !== '' ? (int)$data['site_id'] : null;

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM villes WHERE slug = :slug AND (site_id = :site_id OR (site_id IS NULL AND :site_id2 IS NULL)) LIMIT 1');
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindValue(':site_id', $siteId, $siteId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':site_id2', $siteId, $siteId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Ville slug already exists for this site'); return; }

        $stmt = $db->prepare('INSERT INTO villes (slug, nom, code_postal, site_id) VALUES (:slug, :nom, :cp, :site_id)');
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindValue(':nom', $data['nom'], PDO::PARAM_STR);
        $stmt->bindValue(':cp', $data['code_postal'] ?? null, PDO::PARAM_STR);
        $stmt->bindValue(':site_id', $siteId, $siteId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId ?? 1, 'create', 'ville', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/villes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM villes WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Ville not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['slug', 'nom', 'code_postal', 'site_id'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f] === '' && ($f === 'site_id' || $f === 'code_postal') ? null : $data[$f];
            }
        }
        if (!empty($fields)) {
            $sql = 'UPDATE villes SET ' . implode(', ', $fields) . ' WHERE id = :id';
            $stmtU = $db->prepare($sql);
            foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
            $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
            $stmtU->execute();
        }

        Audit::log((int) $admin['id'], $old['site_id'] ?? 1, 'update', 'ville', $id, $old, $data);
        Response::success(['id' => $id], 'Ville updated');
    });

    $router->delete('/api/admin/recrutement/villes/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM villes WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Ville not found'); return; }

        $stmt = $db->prepare('DELETE FROM villes WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], $old['site_id'] ?? 1, 'delete', 'ville', $id, $old, null);
        Response::noContent();
    });
}
