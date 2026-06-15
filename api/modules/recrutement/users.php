<?php
/**
 * modules/recrutement/users.php — CRUD users (front office)
 */

function registerRecrutementUsersRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/users', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $role = Router::getQueryParam('role');
        $sql = 'SELECT id, email, role, email_verifie, actif, created_at FROM users WHERE deleted_at IS NULL';
        $params = [];
        if ($role) {
            $sql .= ' AND role = :role';
            $params[':role'] = $role;
        }
        $sql .= ' ORDER BY email ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/users', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('email', 'Email')->email('email', 'Email')->required('role', 'Role')->validate();

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
        $stmt->bindParam(':email', $data['email'], PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('Email already exists'); return; }

        $hash = !empty($data['password']) ? password_hash($data['password'], PASSWORD_DEFAULT) : null;
        $stmt = $db->prepare(
            'INSERT INTO users (email, password_hash, role, email_verifie, actif, created_at, updated_at)
             VALUES (:email, :hash, :role, :ev, :actif, NOW(), NOW())'
        );
        $stmt->bindValue(':email', $data['email'], PDO::PARAM_STR);
        $stmt->bindValue(':hash', $hash, PDO::PARAM_STR);
        $stmt->bindValue(':role', $data['role'] ?? 'candidat', PDO::PARAM_STR);
        $stmt->bindValue(':ev', $data['email_verifie'] ?? 1, PDO::PARAM_INT);
        $stmt->bindValue(':actif', $data['actif'] ?? 1, PDO::PARAM_INT);
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 1, 'create', 'user', $newId, null, ['email' => $data['email'], 'role' => $data['role']]);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/users/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM users WHERE id = :id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('User not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['email', 'role', 'email_verifie', 'actif'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (!empty($data['password'])) {
            $fields[] = 'password_hash = :hash';
            $bind[':hash'] = password_hash($data['password'], PASSWORD_DEFAULT);
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = 'updated_at = NOW()';
        $sql = 'UPDATE users SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        Audit::log((int) $admin['id'], 1, 'update', 'user', $id, $old, $data);
        Response::success(['id' => $id], 'User updated');
    });

    $router->delete('/api/admin/recrutement/users/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('User not found'); return; }

        $stmt = $db->prepare('UPDATE users SET deleted_at = NOW(), actif = 0 WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], 1, 'delete', 'user', $id, $old, null);
        Response::noContent();
    });
}
