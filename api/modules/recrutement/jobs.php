<?php
/**
 * modules/recrutement/jobs.php — CRUD recrutement_jobs
 */

function registerRecrutementJobsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/jobs', function () {
        Middleware::authenticate();
        $db = getDb();
        $sectorId = Router::getQueryParam('sector_id');

        if ($sectorId) {
            $stmt = $db->prepare(
                'SELECT j.*, s.name as sector_name FROM recrutement_jobs j 
                 LEFT JOIN recrutement_sectors s ON j.sector_id = s.id 
                 WHERE j.sector_id = :sector_id ORDER BY j.name ASC'
            );
            $stmt->bindParam(':sector_id', $sectorId, PDO::PARAM_INT);
        } else {
            $stmt = $db->prepare(
                'SELECT j.*, s.name as sector_name FROM recrutement_jobs j 
                 LEFT JOIN recrutement_sectors s ON j.sector_id = s.id ORDER BY j.name ASC'
            );
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/jobs', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        Validator::make($data)->required('name', 'Name')->required('sector_id', 'Sector')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['name']);
        $db = getDb();
        $stmt = $db->prepare(
            'INSERT INTO recrutement_jobs (sector_id, name, slug, description, created_at) 
             VALUES (:sector_id, :name, :slug, :description, NOW())'
        );
        $stmt->bindParam(':sector_id', $data['sector_id'], PDO::PARAM_INT);
        $stmt->bindParam(':name', $data['name'], PDO::PARAM_STR);
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $desc = $data['description'] ?? null;
        $stmt->bindParam(':description', $desc, PDO::PARAM_STR);
        $stmt->execute();
        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'recrutement_job', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/recrutement/jobs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_jobs WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Job not found'); return; }
        $fields = []; $bind = [];
        foreach (['sector_id', 'name', 'slug', 'description'] as $f) {
            if (isset($data[$f])) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }
        $sql = 'UPDATE recrutement_jobs SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'update', 'recrutement_job', $id, $old, $data);
        Response::success(['id' => $id], 'Job updated');
    });

    $router->delete('/api/admin/recrutement/jobs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        $stmt = $db->prepare('SELECT * FROM recrutement_jobs WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Job not found'); return; }
        $stmt = $db->prepare('DELETE FROM recrutement_jobs WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        Audit::log((int) $admin['id'], null, 'delete', 'recrutement_job', $id, $old, null);
        Response::noContent();
    });
}
