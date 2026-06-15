<?php
/**
 * modules/recrutement/jobs.php — CRUD metiers
 */

function registerRecrutementJobsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/jobs', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');
        $sql = 'SELECT m.*, s.label as secteur_label 
                FROM metiers m 
                LEFT JOIN secteurs_activite s ON m.secteur_id = s.id';
        $params = [];
        if ($siteId !== null && $siteId !== '') {
            $sql .= ' WHERE m.site_id = :site_id';
            $params[':site_id'] = (int) $siteId;
        }
        $sql .= ' ORDER BY m.libelle ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, PDO::PARAM_INT);
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/recrutement/jobs/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $job = $stmt->fetch();
        if (!$job) { Response::notFound('Metier not found'); return; }

        $stmt = $db->prepare(
            'SELECT c.*, mc.importance 
             FROM competences c 
             INNER JOIN metier_competences mc ON c.id = mc.competence_id 
             WHERE mc.metier_id = :id'
        );
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $job['competences'] = $stmt->fetchAll();

        Response::success($job);
    });

    $router->post('/api/admin/recrutement/jobs', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        
        Validator::make($data)->required('libelle', 'Libelle')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['libelle']);
        
        $db = getDb();
        $db->beginTransaction();
        try {
            $stmt = $db->prepare('SELECT id FROM metiers WHERE slug = :slug LIMIT 1');
            $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
            $stmt->execute();
            if ($stmt->fetch()) { Response::badRequest('Metier slug already exists'); return; }

            $stmt = $db->prepare(
                'INSERT INTO metiers (site_id, code_rome, slug, libelle, description, famille_metier, secteur_id, niveau_etudes, perspectives, actif, created_at, updated_at)
                 VALUES (:site_id, :code_rome, :slug, :libelle, :description, :famille_metier, :secteur_id, :niveau_etudes, :perspectives, :actif, NOW(), NOW())'
            );
            $siteIdVal = isset($data['site_id']) ? (int) $data['site_id'] : null;
            if ($siteIdVal === null) {
                $headerSite = $_SERVER['HTTP_X_SITE_ID'] ?? null;
                $siteIdVal = $headerSite ? (int) $headerSite : null;
            }
            $stmt->bindValue(':site_id', $siteIdVal, PDO::PARAM_INT);
            $stmt->bindValue(':code_rome', $data['code_rome'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':libelle', $data['libelle'], PDO::PARAM_STR);
            $stmt->bindValue(':description', $data['description'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':famille_metier', $data['famille_metier'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':secteur_id', $data['secteur_id'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':niveau_etudes', $data['niveau_etudes'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':perspectives', $data['perspectives'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':actif', $data['actif'] ?? 1, PDO::PARAM_INT);
            $stmt->execute();
            
            $newId = (int) $db->lastInsertId();

            if (isset($data['competences']) && is_array($data['competences'])) {
                $stmtC = $db->prepare('INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:mid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([
                        ':mid' => $newId, 
                        ':cid' => $c['competence_id'], 
                        ':imp' => $c['importance'] ?? 'essentielle'
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'create', 'metier', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create metier', $e->getMessage());
        }
    });

    $router->put('/api/admin/recrutement/jobs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Metier not found'); return; }

        $db->beginTransaction();
        try {
            $fields = []; $bind = [];
            foreach (['site_id', 'code_rome', 'slug', 'libelle', 'description', 'famille_metier', 'secteur_id', 'niveau_etudes', 'perspectives', 'actif'] as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }
            if (!empty($fields)) {
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE metiers SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
            }

            if (isset($data['competences']) && is_array($data['competences'])) {
                $db->prepare("DELETE FROM metier_competences WHERE metier_id = :id")->execute([':id' => $id]);
                $stmtC = $db->prepare('INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:mid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([
                        ':mid' => $id, 
                        ':cid' => $c['competence_id'], 
                        ':imp' => $c['importance'] ?? 'essentielle'
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'update', 'metier', $id, $old, $data);
            Response::success(['id' => $id], 'Metier updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update metier', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/jobs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Metier not found'); return; }
        
        $db->beginTransaction();
        try {
            $stmtCheck = $db->prepare('SELECT COUNT(*) as count FROM offres_emploi WHERE metier_id = :id');
            $stmtCheck->execute([':id' => $id]);
            if ($stmtCheck->fetch()['count'] > 0) {
                $db->rollBack();
                Response::badRequest('Impossible de supprimer ce métier car il est lié à des offres d\'emploi.');
                return;
            }

            $db->prepare('DELETE FROM metier_competences WHERE metier_id = :id')->execute([':id' => $id]);

            $stmt = $db->prepare('DELETE FROM metiers WHERE id = :id');
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
            
            $db->commit();
            Audit::log((int) $admin['id'], 1, 'delete', 'metier', $id, $old, null);
            Response::noContent();
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to delete metier', $e->getMessage());
        }
    });
}
