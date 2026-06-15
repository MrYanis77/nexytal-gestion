<?php
/**
 * modules/trainer/trainer_applications.php — CRUD candidatures formateurs (v2.1)
 */

function registerTrainerApplicationsRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/applications', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT ta.*, e.label as expertise_label, t.first_name as trainer_first_name, t.last_name as trainer_last_name
             FROM trainer_applications ta
             LEFT JOIN expertises e ON ta.primary_expertise_id = e.id
             LEFT JOIN trainers t ON ta.trainer_id = t.id
             ORDER BY ta.created_at DESC'
        );
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/trainer/applications/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT ta.*, e.label as expertise_label FROM trainer_applications ta
             LEFT JOIN expertises e ON ta.primary_expertise_id = e.id
             WHERE ta.id = :id LIMIT 1'
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $app = $stmt->fetch();
        if (!$app) { Response::notFound('Application not found'); return; }

        Response::success($app);
    });

    $router->post('/api/public/nexytal-trainer/applications', function () {
        $data = Router::getJsonBody();
        Validator::make($data)
            ->required('first_name', 'Prénom')
            ->required('last_name', 'Nom')
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->validate();

        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO trainer_applications
             (first_name, last_name, email, phone, linkedin_url, primary_expertise_id, experience_range,
              experience_years, tjm_requested, certifications_text, message, status, created_at)
             VALUES (:fn, :ln, :email, :phone, :li, :peid, :er, :ey, :tjm, :cert, :msg, :st, NOW())'
        );
        $stmt->execute([
            ':fn' => $data['first_name'],
            ':ln' => $data['last_name'],
            ':email' => $data['email'],
            ':phone' => $data['phone'] ?? null,
            ':li' => $data['linkedin_url'] ?? null,
            ':peid' => $data['primary_expertise_id'] ?? null,
            ':er' => $data['experience_range'] ?? null,
            ':ey' => $data['experience_years'] ?? null,
            ':tjm' => $data['tjm_requested'] ?? null,
            ':cert' => $data['certifications_text'] ?? null,
            ':msg' => $data['message'] ?? null,
            ':st' => 'new',
        ]);

        Response::created(['id' => (int) $db->lastInsertId()]);
    });

    $router->put('/api/admin/trainer/applications/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainer_applications WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Application not found'); return; }

        $fields = [];
        $bind = [];
        foreach (['status', 'reviewed_by', 'reviewed_at', 'trainer_id'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        if (!isset($data['reviewed_at']) && isset($data['status'])) {
            $fields[] = 'reviewed_at = NOW()';
            $bind[':reviewed_by'] = $bind[':reviewed_by'] ?? $admin['id'];
            if (!array_key_exists('reviewed_by', $data)) {
                $fields[] = 'reviewed_by = :reviewed_by';
                $bind[':reviewed_by'] = $admin['id'];
            }
        }

        $sql = 'UPDATE trainer_applications SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmtU = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmtU->bindValue($k, $v);
        $stmtU->bindParam(':id', $id, PDO::PARAM_INT);
        $stmtU->execute();

        Audit::log((int) $admin['id'], 5, 'update', 'trainer_application', $id, $old, $data);
        Response::success(['id' => $id], 'Application updated');
    });

    $router->delete('/api/admin/trainer/applications/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM trainer_applications WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Application not found'); return; }

        $stmt = $db->prepare('DELETE FROM trainer_applications WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], 5, 'delete', 'trainer_application', $id, $old, null);
        Response::noContent();
    });
}
