<?php
/**
 * modules/coaching/reference_data.php — CRUD for coaching reference data
 */

function registerCoachingSpecialtiesRoutes(Router $router): void {
    coachingRefCrud($router, 'specialties', 'coaching_specialties', 'name', ['slug', 'name', 'sort_order', 'is_active']);
}

function registerCoachingCertificationsRoutes(Router $router): void {
    coachingRefCrud($router, 'certifications', 'coaching_certifications', 'name', ['slug', 'name', 'sort_order']);
}

function registerCoachingCitiesRoutes(Router $router): void {
    coachingRefCrud($router, 'cities', 'coaching_cities', 'name', ['slug', 'name', 'region', 'is_active']);
}

function registerCoachingLanguagesRoutes(Router $router): void {
    coachingRefCrud($router, 'languages', 'coaching_languages', 'name', ['code', 'name', 'flag_emoji']);
}

function registerCoachingContactSlotsRoutes(Router $router): void {
    $router->get('/api/admin/coaching/contact-slots', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $stmt = getDb()->prepare('SELECT * FROM coaching_contact_slots WHERE site_id = :site_id ORDER BY sort_order ASC');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/coaching/contact-slots', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        Validator::make($data)->required('label', 'Label')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['label']);
        
        $stmt = getDb()->prepare('INSERT INTO coaching_contact_slots (site_id, slug, label, description, sort_order, is_active) VALUES (:site_id, :slug, :label, :description, :sort_order, :is_active)');
        $stmt->execute([
            ':site_id' => $siteId,
            ':slug' => $slug,
            ':label' => $data['label'],
            ':description' => $data['description'] ?? null,
            ':sort_order' => $data['sort_order'] ?? 0,
            ':is_active' => $data['is_active'] ?? 1,
        ]);
        $newId = (int) getDb()->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'coaching_contact_slots', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/coaching/contact-slots/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $data = Router::getJsonBody();
        
        $fields = [];
        $bind = [];
        foreach (['slug', 'label', 'description', 'sort_order', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        
        $sql = 'UPDATE coaching_contact_slots SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmtU->execute();
        
        Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_contact_slots', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/coaching/contact-slots/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM coaching_contact_slots WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 6, 'delete', 'coaching_contact_slots', $id, null, null);
        Response::noContent();
    });
}

function registerCoachingAppointmentSlotsRoutes(Router $router): void {
    $router->get('/api/admin/coaching/appointment-slots', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $stmt = getDb()->prepare('
            SELECT a.*, CONCAT(c.first_name, " ", c.last_name) as coach_name 
            FROM coaching_appointment_slots a
            LEFT JOIN coaches c ON a.coach_id = c.id
            WHERE a.site_id = :site_id 
            ORDER BY a.slot_date DESC, a.start_time DESC
        ');
        $stmt->execute([':site_id' => $siteId]);
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/coaching/appointment-slots', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        Validator::make($data)->required('slot_date', 'Date')->required('start_time', 'Start Time')->validate();
        
        $stmt = getDb()->prepare('INSERT INTO coaching_appointment_slots (site_id, slot_date, start_time, end_time, coach_id, capacity, booked_count, is_active) VALUES (:site_id, :slot_date, :start_time, :end_time, :coach_id, :capacity, :booked_count, :is_active)');
        $stmt->execute([
            ':site_id' => $siteId,
            ':slot_date' => $data['slot_date'],
            ':start_time' => $data['start_time'],
            ':end_time' => $data['end_time'] ?? null,
            ':coach_id' => $data['coach_id'] ?? null,
            ':capacity' => $data['capacity'] ?? 1,
            ':booked_count' => $data['booked_count'] ?? 0,
            ':is_active' => $data['is_active'] ?? 1,
        ]);
        $newId = (int) getDb()->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'coaching_appointment_slots', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/coaching/appointment-slots/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $id = (int) $params['id'];
        $data = Router::getJsonBody();
        
        $fields = [];
        $bind = [];
        foreach (['slot_date', 'start_time', 'end_time', 'coach_id', 'capacity', 'booked_count', 'is_active'] as $f) {
            if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields'); return; }
        
        $sql = 'UPDATE coaching_appointment_slots SET ' . implode(', ', $fields) . ' WHERE id = :id AND site_id = :site_id';
        $stmtU = getDb()->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->bindParam(':site_id', $siteId, PDO::PARAM_INT);
        $stmtU->execute();
        
        Audit::log((int) $admin['id'], $siteId, 'update', 'coaching_appointment_slots', $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete('/api/admin/coaching/appointment-slots/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare('DELETE FROM coaching_appointment_slots WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 6, 'delete', 'coaching_appointment_slots', $id, null, null);
        Response::noContent();
    });
}

function coachingRefCrud(Router $router, string $path, string $table, string $labelField, array $fields): void {
    $router->get("/api/admin/coaching/{$path}", function () use ($table) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $stmt = $db->prepare("SELECT * FROM {$table} ORDER BY id ASC");
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post("/api/admin/coaching/{$path}", function () use ($table, $labelField, $fields, $path) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        if (!isset($data[$labelField])) {
            $data[$labelField] = $data['label'] ?? $data['name'] ?? $data['code'] ?? $data['organization'] ?? null;
        }
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
        if (!in_array('slug', $cols, true) && in_array('slug', $fields)) { $cols[] = 'slug'; $vals[] = ':slug'; $bind[':slug'] = $slug; }
        if (!in_array($labelField, $cols, true)) { $cols[] = $labelField; $vals[] = ":$labelField"; $bind[":$labelField"] = $data[$labelField]; }

        $sql = 'INSERT INTO ' . $table . ' (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $vals) . ')';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], 6, 'create', $table, $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put("/api/admin/coaching/{$path}/{id}", function (array $params) use ($table, $fields, $path) {
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
        Audit::log((int) $admin['id'], 6, 'update', $table, $id, null, $data);
        Response::success(['id' => $id]);
    });

    $router->delete("/api/admin/coaching/{$path}/{id}", function (array $params) use ($table, $path) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $id = (int) $params['id'];
        getDb()->prepare("DELETE FROM {$table} WHERE id = :id")->execute([':id' => $id]);
        Audit::log((int) $admin['id'], 6, 'delete', $table, $id, null, null);
        Response::noContent();
    });
}
