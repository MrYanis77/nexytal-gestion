<?php
/**
 * modules/trainer/reference_data.php — CRUD trainer_skills, trainer_cities, trainer_certifications, trainer_languages, trainer_reviews
 */

function registerTrainerSkillsRoutes(Router $router): void
{
    trainerRefCrud($router, 'skills', 'trainer_skills', 'name', ['name', 'slug']);
}

function registerTrainerCitiesRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/cities', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $stmt = $db->prepare('SELECT * FROM trainer_cities ORDER BY name ASC');
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/trainer/cities', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO trainer_cities (slug, name, region) VALUES (:slug, :name, :region)'
        );
        $stmt->execute([
            ':slug' => $slug,
            ':name' => $data['name'],
            ':region' => $data['region'] ?? null,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 5, 'create', 'trainer_city', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/trainer/cities/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $db = getDb();
        $fields = [];
        $bind = [];
        foreach (['slug', 'name', 'region'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        $sql = 'UPDATE trainer_cities SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();
        Audit::log((int) $admin['id'], 5, 'update', 'trainer_city', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/trainer/cities/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM trainer_cities WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 5, 'delete', 'trainer_city', $id, null, null);
        Response::noContent();
    });
}

function registerTrainerCertificationsRoutes(Router $router): void
{
    trainerRefCrud($router, 'certifications', 'trainer_certifications', 'name', ['name', 'slug']);
}

function registerTrainerLanguagesRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/languages', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $stmt = getDb()->prepare('SELECT * FROM trainer_languages ORDER BY name ASC');
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/trainer/languages', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('code', 'Code')->required('name', 'Name')->validate();
        $stmt = getDb()->prepare('INSERT INTO trainer_languages (code, name) VALUES (:code, :name)');
        $stmt->execute([':code' => $data['code'], ':name' => $data['name']]);
        $newId = (int) getDb()->lastInsertId();
        Audit::log((int) $admin['id'], 5, 'create', 'trainer_language', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/trainer/languages/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $fields = [];
        $bind = [];
        foreach (['code', 'name'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        $sql = 'UPDATE trainer_languages SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();
        Audit::log((int) $admin['id'], 5, 'update', 'trainer_language', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/trainer/languages/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM trainer_languages WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 5, 'delete', 'trainer_language', $id, null, null);
        Response::noContent();
    });
}

function registerTrainerReviewsRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/reviews', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $trainerId = Router::getQueryParam('trainer_id');
        $sql = 'SELECT r.*, CONCAT(t.first_name, " ", t.last_name) as trainer_name FROM trainer_reviews r INNER JOIN trainers t ON r.trainer_id = t.id';
        if ($trainerId) $sql .= ' WHERE r.trainer_id = ' . (int) $trainerId;
        $sql .= ' ORDER BY r.created_at DESC';
        $stmt = $db->prepare($sql);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/trainer/reviews', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('trainer_id', 'Trainer')->required('author_name', 'Author')->required('rating', 'Rating')->required('comment', 'Comment')->validate();
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO trainer_reviews (trainer_id, author_name, company, rating, comment, is_published, created_at)
             VALUES (:tid, :an, :co, :rat, :com, :pub, NOW())'
        );
        $stmt->execute([
            ':tid' => $data['trainer_id'], ':an' => $data['author_name'], ':co' => $data['company'] ?? null,
            ':rat' => $data['rating'], ':com' => $data['comment'], ':pub' => $data['is_published'] ?? 0,
        ]);
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 5, 'create', 'trainer_review', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/trainer/reviews/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $fields = [];
        $bind = [];
        foreach (['author_name', 'company', 'rating', 'comment', 'is_published'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        $sql = 'UPDATE trainer_reviews SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();
        Audit::log((int) $admin['id'], 5, 'update', 'trainer_review', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/trainer/reviews/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM trainer_reviews WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 5, 'delete', 'trainer_review', $id, null, null);
        Response::noContent();
    });
}

function trainerRefCrud(Router $router, string $path, string $table, string $labelField, array $fields): void
{
    $router->get("/api/admin/trainer/{$path}", function () use ($table) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $stmt = $db->prepare("SELECT * FROM {$table} ORDER BY {$table}.id ASC");
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post("/api/admin/trainer/{$path}", function () use ($table, $labelField, $fields, $path) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        Validator::make($data)->required($labelField, 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data[$labelField]);
        $db = getDb();

        $cols = [];
        $vals = [];
        $bind = [];
        foreach ($fields as $f) {
            if ($f === 'slug' && !isset($data['slug'])) {
                $cols[] = 'slug'; $vals[] = ':slug'; $bind[':slug'] = $slug;
            } elseif (array_key_exists($f, $data) || $f === $labelField) {
                $cols[] = $f; $vals[] = ":$f"; $bind[":$f"] = $data[$f] ?? ($f === 'slug' ? $slug : null);
            }
        }
        if (!in_array('slug', $cols, true)) { $cols[] = 'slug'; $vals[] = ':slug'; $bind[':slug'] = $slug; }
        if (!in_array($labelField, $cols, true)) { $cols[] = $labelField; $vals[] = ":$labelField"; $bind[":$labelField"] = $data[$labelField]; }

        $sql = 'INSERT INTO ' . $table . ' (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $vals) . ')';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 5, 'create', $table, $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put("/api/admin/trainer/{$path}/{id}", function (array $params) use ($table, $fields, $path) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $id = (int) $params['id'];
        $updFields = [];
        $bind = [];
        foreach ($fields as $f) {
            if (array_key_exists($f, $data)) { $updFields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($updFields)) { Response::badRequest('No fields'); return; }
        $sql = 'UPDATE ' . $table . ' SET ' . implode(', ', $updFields) . ' WHERE id = :id';
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();
        Audit::log((int) $admin['id'], 5, 'update', $table, $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete("/api/admin/trainer/{$path}/{id}", function (array $params) use ($table, $path) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare("DELETE FROM {$table} WHERE id = :id")->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 5, 'delete', $table, $id, null, null);
        Response::noContent();
    });
}
