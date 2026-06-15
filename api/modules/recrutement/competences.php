<?php
/**
 * modules/recrutement/competences.php — CRUD competences
 */

function registerRecrutementCompetencesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/competences', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM competences ORDER BY label ASC');
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/recrutement/competences/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM competences WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $row = $stmt->fetch();
        if (!$row) { Response::notFound('Competence not found'); return; }
        Response::success($row);
    });

    $router->post('/api/admin/recrutement/competences', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('label', 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['label']);

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM competences WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Competence slug already exists'); return; }

        $stmt = $db->prepare('INSERT INTO competences (slug, label, categorie) VALUES (:slug, :label, :cat)');
        $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
        $stmt->bindValue(':label', $data['label'], PDO::PARAM_STR);
        $stmt->bindValue(':cat', $data['categorie'] ?? 'technique', PDO::PARAM_STR);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 1, 'create', 'competence', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/competences/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM competences WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Competence not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['slug', 'label', 'categorie'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if (!empty($fields)) {
            $sql = 'UPDATE competences SET ' . implode(', ', $fields) . ' WHERE id = :id';
            $stmtU = $db->prepare($sql);
            foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
            $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
            $stmtU->execute();
        }

        Audit::log((int) $admin['id'], 1, 'update', 'competence', $id, $old, $data);
        Response::success(['id' => $id], 'Competence updated');
    });

    $router->delete('/api/admin/recrutement/competences/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM competences WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Competence not found'); return; }

        $stmt = $db->prepare('DELETE FROM competences WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], 1, 'delete', 'competence', $id, $old, null);
        Response::noContent();
    });
}
