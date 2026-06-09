<?php
/**
 * modules/recrutement/contract_types.php — CRUD recrutement_contract_types
 */

function registerRecrutementContractTypesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/contract-types', function () {
        Middleware::authenticate();
        $db = getDb();
        $stmt = $db->query('SELECT * FROM recrutement_contract_types ORDER BY name ASC');
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/contract-types', function () {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        Validator::make($data)->required('code', 'Code')->required('name', 'Name')->validate();
        $db = getDb();
        $stmt = $db->prepare('INSERT INTO recrutement_contract_types (code, name) VALUES (:code, :name)');
        $stmt->bindParam(':code', $data['code'], PDO::PARAM_STR);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'contract_type', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/contract-types/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_contract_types WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Contract type not found'); return; }
        $fields = []; $bind = [];
        foreach (['code', 'name'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE recrutement_contract_types SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'update', 'contract_type', $id, $old, $data);
        Response::success(['id' => $id], 'Contract type updated');
    });

    $router->delete('/api/admin/recrutement/contract-types/{id}', function (array $params) {
        $admin = Middleware::superadminOnly();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_contract_types WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Contract type not found'); return; }
        $stmt = $db->prepare('DELETE FROM recrutement_contract_types WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'delete', 'contract_type', $id, $old, null);
        Response::noContent();
    });
}
