<?php
/**
 * modules/trainer/expertises.php — CRUD catalogue expertises + API publique
 */

require_once __DIR__ . '/expertise_helpers.php';

function registerTrainerExpertisesRoutes(Router $router): void
{
    $router->get('/api/admin/trainer/expertises', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $siteId = expertiseSiteIdFromRequest();
        [$where, $bind] = expertiseListWhereClause($db, $siteId, false);
        $orderBy = expertiseOrderByClause($db, 'e');

        $stmt = $db->prepare(
            "SELECT e.*,
                (SELECT COUNT(*) FROM trainer_expertise_links tel WHERE tel.expertise_id = e.id) AS trainers_count
             FROM expertises e
             WHERE {$where}
             ORDER BY {$orderBy}"
        );
        $stmt->execute($bind);
        $rows = array_map('expertiseRowToApi', $stmt->fetchAll());
        Response::success($rows);
    });

    $router->get('/api/admin/trainer/expertises/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $expertise = expertiseFetchById(getDb(), (int) $params['id']);
        if (!$expertise) {
            Response::notFound('Expertise not found');
            return;
        }
        Response::success($expertise);
    });

    $router->post('/api/admin/trainer/expertises', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $data = Router::getJsonBody();
        Validator::make($data)->required('label', 'Label')->validate();

        $payload = expertiseDataFromRequest($db, $data);
        if (empty($payload['slug']) && !empty($payload['label'])) {
            $payload['slug'] = Validator::slugify($payload['label']);
        }
        if (empty($payload['slug'])) {
            Response::validationError(['slug' => 'Slug requis'], 'Slug invalide');
            return;
        }
        $stmt = $db->prepare('SELECT id FROM expertises WHERE slug = :slug LIMIT 1');
        $stmt->execute([':slug' => $payload['slug']]);
        if ($stmt->fetch()) {
            Response::badRequest('Expertise slug already exists');
            return;
        }

        $cols = array_keys($payload);
        $placeholders = array_map(static fn ($c) => ':' . $c, $cols);
        $sql = 'INSERT INTO expertises (' . implode(', ', $cols) . ') VALUES (' . implode(', ', $placeholders) . ')';
        $stmt = $db->prepare($sql);
        foreach ($payload as $k => $v) {
            $stmt->bindValue(':' . $k, $v);
        }
        $stmt->execute();

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], (int) ($payload['site_id'] ?? 5), 'create', 'expertise', $newId, null, $data);
        Response::created(expertiseFetchById($db, $newId));
    });

    $router->put('/api/admin/trainer/expertises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM expertises WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Expertise not found');
            return;
        }

        $payload = expertiseDataFromRequest($db, $data, $old);
        if (isset($payload['slug']) && $payload['slug'] !== $old['slug']) {
            $stmt = $db->prepare('SELECT id FROM expertises WHERE slug = :slug AND id != :id LIMIT 1');
            $stmt->execute([':slug' => $payload['slug'], ':id' => $id]);
            if ($stmt->fetch()) {
                Response::badRequest('Expertise slug already exists');
                return;
            }
        }

        if ($payload === []) {
            Response::badRequest('No fields to update');
            return;
        }

        $fields = [];
        $bind = [':id' => $id];
        foreach ($payload as $k => $v) {
            $fields[] = "{$k} = :{$k}";
            $bind[":{$k}"] = $v;
        }

        $sql = 'UPDATE expertises SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        $stmt->execute($bind);

        Audit::log((int) $admin['id'], (int) ($old['site_id'] ?? 5), 'update', 'expertise', $id, $old, $data);
        Response::success(expertiseFetchById($db, $id), 'Expertise updated');
    });

    $router->delete('/api/admin/trainer/expertises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM expertises WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Expertise not found');
            return;
        }

        $stmt = $db->prepare('SELECT COUNT(*) FROM trainer_expertise_links WHERE expertise_id = :id');
        $stmt->execute([':id' => $id]);
        if ((int) $stmt->fetchColumn() > 0) {
            Response::badRequest('Impossible de supprimer : des formateurs sont rattachés à cette spécialité');
            return;
        }

        $db->prepare('DELETE FROM expertises WHERE id = :id')->execute([':id' => $id]);
        Audit::log((int) $admin['id'], (int) ($old['site_id'] ?? 5), 'delete', 'expertise', $id, $old, null);
        Response::noContent();
    });

    $router->get('/api/public/{site_slug}/trainer/expertises', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        [$where, $bind] = expertiseListWhereClause($db, $siteId, true);
        $orderBy = expertiseOrderByClause($db, 'e');
        $select = expertisePublicSelectColumns($db);

        $stmt = $db->prepare(
            "SELECT {$select},
                COUNT(DISTINCT CASE
                    WHEN t.id IS NOT NULL AND t.status = 'active' AND t.validated_at IS NOT NULL AND t.deleted_at IS NULL
                    THEN t.id END) AS trainers_count
             FROM expertises e
             LEFT JOIN trainer_expertise_links tel ON tel.expertise_id = e.id
             LEFT JOIN trainers t ON t.id = tel.trainer_id AND t.site_id = :site_id_join
             WHERE {$where}
             GROUP BY e.id
             ORDER BY {$orderBy}"
        );
        $bind[':site_id_join'] = $siteId;
        $stmt->execute($bind);
        $rows = array_map('expertiseRowToApi', $stmt->fetchAll());
        Response::success($rows);
    });

    $router->get('/api/public/{site_slug}/trainer/expertises/{slug}', function (array $params) {
        $siteId = getSiteId($params['site_slug']);
        if (!$siteId) {
            Response::notFound('Site not found');
            return;
        }

        $db = getDb();
        $expertise = expertiseFetchBySlug($db, $params['slug'], $siteId);
        if (!$expertise) {
            Response::notFound('Expertise not found');
            return;
        }

        $expertise['trainers'] = expertiseFetchTrainersForCatalog($db, (int) $expertise['id'], $siteId);
        $expertise['trainers_count'] = count($expertise['trainers']);

        Response::success($expertise);
    });
}
