<?php
/**
 * jobs.php — CRUD metiers (filtré par site_id)
 */

require_once __DIR__ . '/site_scope.php';

function metierNullableString(mixed $value): ?string
{
    if ($value === null || $value === '') {
        return null;
    }
    return (string) $value;
}

function metierBindNullableString(PDOStatement $stmt, string $param, ?string $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }
    $stmt->bindValue($param, $value, PDO::PARAM_STR);
}

function metierNormalizeInputAliases(array $data): array
{
    if (!isset($data['libelle'])) {
        foreach (['name', 'label', 'title'] as $field) {
            if (isset($data[$field])) {
                $data['libelle'] = $data[$field];
                break;
            }
        }
    }
    if (!isset($data['titre']) && isset($data['libelle'])) {
        $data['titre'] = $data['libelle'];
    }
    if (!isset($data['secteur_id']) && isset($data['sector_id'])) {
        $data['secteur_id'] = $data['sector_id'];
    }
    if (!isset($data['famille_metier']) && isset($data['sector'])) {
        $data['famille_metier'] = $data['sector'];
    }
    if (!isset($data['description_courte'])) {
        $data['description_courte'] = $data['short_description'] ?? $data['short_desc'] ?? null;
    }
    if (!isset($data['description'])) {
        $data['description'] = $data['full_description'] ?? $data['description_complete'] ?? null;
    }
    if (!isset($data['actif']) && isset($data['status'])) {
        $data['actif'] = in_array((string) $data['status'], ['active', 'published', 'publie', 'publiee'], true) ? 1 : 0;
    }
    if (!isset($data['competences']) && isset($data['competence_ids']) && is_array($data['competence_ids'])) {
        $data['competences'] = array_map(static fn ($id) => ['competence_id' => (int) $id], $data['competence_ids']);
    }

    return $data;
}
function metierResolveSiteIdForInsert(PDO $db, array $data, array $admin): ?int
{
    $siteId = recrutementResolveSiteIdFromBody($data, $admin);
    if ($siteId !== null) {
        return $siteId;
    }

    $secteurId = recrutementNormalizeOptionalInt($data['secteur_id'] ?? null);
    if ($secteurId === null) {
        return null;
    }

    $stmt = $db->prepare('SELECT slug, label FROM secteurs_activite WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $secteurId]);
    $sector = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$sector) {
        return null;
    }

    $needle = strtolower((string) (($sector['slug'] ?? '') . ' ' . ($sector['label'] ?? '')));
    if (str_contains($needle, 'med') || str_contains($needle, 'medical') || str_contains($needle, 'medical')) {
        return 3;
    }
    if (str_contains($needle, 'it') || str_contains($needle, 'informat') || str_contains($needle, 'tech')) {
        return 2;
    }

    return null;
}
function registerRecrutementJobsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/jobs', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT m.*, s.label as secteur_label
             FROM metiers m
             LEFT JOIN secteurs_activite s ON m.secteur_id = s.id
             WHERE m.site_id = :site_id
             ORDER BY m.libelle ASC'
        );
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/recrutement/jobs/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $job = $stmt->fetch();
        if (!$job) {
            Response::notFound('Metier not found');
            return;
        }

        $stmt = $db->prepare(
            'SELECT c.*, mc.importance
             FROM competences c
             INNER JOIN metier_competences mc ON c.id = mc.competence_id
             WHERE mc.metier_id = :id'
        );
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $job['competences'] = $stmt->fetchAll();

        Response::success($job);
    });

    $router->get('/api/admin/recrutement/professions', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT m.*, s.label as secteur_label
             FROM metiers m
             LEFT JOIN secteurs_activite s ON m.secteur_id = s.id
             WHERE m.site_id = :site_id
             ORDER BY m.libelle ASC'
        );
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/professions', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = metierNormalizeInputAliases(Router::getJsonBody());

        Validator::make($data)->required('libelle', 'Libelle')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['libelle']);

        $db = getDb();
        $db->beginTransaction();
        try {
            $siteIdVal = metierResolveSiteIdForInsert($db, $data, $admin);

            $slugCheck = $db->prepare('SELECT id FROM metiers WHERE slug = :slug AND site_id = :site_id LIMIT 1');
            $slugCheck->bindValue(':slug', $slug, PDO::PARAM_STR);
            recrutementBindNullableInt($slugCheck, ':site_id', $siteIdVal);
            $slugCheck->execute();
            if ($slugCheck->fetch()) {
                $db->rollBack();
                Response::badRequest('Profession slug already exists for this site');
                return;
            }

            $stmt = $db->prepare(
                'INSERT INTO metiers (
                    site_id, code_rome, slug, libelle, titre, description_courte, description,
                    presentation, journee_type, famille_metier, secteur_id, niveau_etudes, perspectives,
                    actif, image_url, salaire_fourchette, salaire_debutant, salaire_confirme,
                    salaire_liberal, salaire_details, created_at, updated_at
                 ) VALUES (
                    :site_id, :code_rome, :slug, :libelle, :titre, :description_courte, :description,
                    :presentation, :journee_type, :famille_metier, :secteur_id, :niveau_etudes, :perspectives,
                    :actif, :image_url, :salaire_fourchette, :salaire_debutant, :salaire_confirme,
                    :salaire_liberal, :salaire_details, NOW(), NOW()
                 )'
            );

            recrutementBindNullableInt($stmt, ':site_id', $siteIdVal);
            metierBindNullableString($stmt, ':code_rome', metierNullableString($data['code_rome'] ?? null));
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':libelle', $data['libelle'], PDO::PARAM_STR);
            metierBindNullableString($stmt, ':titre', metierNullableString($data['titre'] ?? null));
            metierBindNullableString($stmt, ':description_courte', metierNullableString($data['description_courte'] ?? null));
            metierBindNullableString($stmt, ':description', metierNullableString($data['description'] ?? null));
            metierBindNullableString($stmt, ':presentation', metierNullableString($data['presentation'] ?? null));
            metierBindNullableString($stmt, ':journee_type', metierNullableString($data['journee_type'] ?? null));
            metierBindNullableString($stmt, ':famille_metier', metierNullableString($data['famille_metier'] ?? null));
            recrutementBindNullableInt($stmt, ':secteur_id', recrutementNormalizeOptionalInt($data['secteur_id'] ?? null));
            metierBindNullableString($stmt, ':niveau_etudes', metierNullableString($data['niveau_etudes'] ?? null));
            metierBindNullableString($stmt, ':perspectives', metierNullableString($data['perspectives'] ?? null));
            $stmt->bindValue(':actif', (int) ($data['actif'] ?? 1), PDO::PARAM_INT);
            metierBindNullableString($stmt, ':image_url', metierNullableString($data['image_url'] ?? null));
            metierBindNullableString($stmt, ':salaire_fourchette', metierNullableString($data['salaire_fourchette'] ?? null));
            metierBindNullableString($stmt, ':salaire_debutant', metierNullableString($data['salaire_debutant'] ?? null));
            metierBindNullableString($stmt, ':salaire_confirme', metierNullableString($data['salaire_confirme'] ?? null));
            metierBindNullableString($stmt, ':salaire_liberal', metierNullableString($data['salaire_liberal'] ?? null));
            metierBindNullableString($stmt, ':salaire_details', metierNullableString($data['salaire_details'] ?? null));
            $stmt->execute();

            $newId = (int) $db->lastInsertId();

            if (isset($data['competences']) && is_array($data['competences'])) {
                $stmtC = $db->prepare('INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:mid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([
                        ':mid' => $newId,
                        ':cid' => $c['competence_id'],
                        ':imp' => $c['importance'] ?? 'essentielle',
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteIdVal, 'create', 'metier', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create profession', $e->getMessage());
        }
    });
    $router->post('/api/admin/recrutement/jobs', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = metierNormalizeInputAliases(Router::getJsonBody());

        Validator::make($data)->required('libelle', 'Libelle')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['libelle']);

        $db = getDb();
        $db->beginTransaction();
        try {
            $siteIdVal = metierResolveSiteIdForInsert($db, $data, $admin);

            $slugCheck = $db->prepare('SELECT id FROM metiers WHERE slug = :slug AND site_id = :site_id LIMIT 1');
            $slugCheck->bindValue(':slug', $slug, PDO::PARAM_STR);
            recrutementBindNullableInt($slugCheck, ':site_id', $siteIdVal);
            $slugCheck->execute();
            if ($slugCheck->fetch()) {
                $db->rollBack();
                Response::badRequest('Metier slug already exists for this site');
                return;
            }

            $stmt = $db->prepare(
                'INSERT INTO metiers (
                    site_id, code_rome, slug, libelle, titre, description_courte, description,
                    presentation, journee_type, famille_metier, secteur_id, niveau_etudes, perspectives,
                    actif, image_url, salaire_fourchette, salaire_debutant, salaire_confirme,
                    salaire_liberal, salaire_details, created_at, updated_at
                 ) VALUES (
                    :site_id, :code_rome, :slug, :libelle, :titre, :description_courte, :description,
                    :presentation, :journee_type, :famille_metier, :secteur_id, :niveau_etudes, :perspectives,
                    :actif, :image_url, :salaire_fourchette, :salaire_debutant, :salaire_confirme,
                    :salaire_liberal, :salaire_details, NOW(), NOW()
                 )'
            );

            recrutementBindNullableInt($stmt, ':site_id', $siteIdVal);
            metierBindNullableString($stmt, ':code_rome', metierNullableString($data['code_rome'] ?? null));
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            $stmt->bindValue(':libelle', $data['libelle'], PDO::PARAM_STR);
            metierBindNullableString($stmt, ':titre', metierNullableString($data['titre'] ?? null));
            metierBindNullableString($stmt, ':description_courte', metierNullableString($data['description_courte'] ?? null));
            metierBindNullableString($stmt, ':description', metierNullableString($data['description'] ?? null));
            metierBindNullableString($stmt, ':presentation', metierNullableString($data['presentation'] ?? null));
            metierBindNullableString($stmt, ':journee_type', metierNullableString($data['journee_type'] ?? null));
            metierBindNullableString($stmt, ':famille_metier', metierNullableString($data['famille_metier'] ?? null));
            recrutementBindNullableInt($stmt, ':secteur_id', recrutementNormalizeOptionalInt($data['secteur_id'] ?? null));
            metierBindNullableString($stmt, ':niveau_etudes', metierNullableString($data['niveau_etudes'] ?? null));
            metierBindNullableString($stmt, ':perspectives', metierNullableString($data['perspectives'] ?? null));
            $stmt->bindValue(':actif', (int) ($data['actif'] ?? 1), PDO::PARAM_INT);
            metierBindNullableString($stmt, ':image_url', metierNullableString($data['image_url'] ?? null));
            metierBindNullableString($stmt, ':salaire_fourchette', metierNullableString($data['salaire_fourchette'] ?? null));
            metierBindNullableString($stmt, ':salaire_debutant', metierNullableString($data['salaire_debutant'] ?? null));
            metierBindNullableString($stmt, ':salaire_confirme', metierNullableString($data['salaire_confirme'] ?? null));
            metierBindNullableString($stmt, ':salaire_liberal', metierNullableString($data['salaire_liberal'] ?? null));
            metierBindNullableString($stmt, ':salaire_details', metierNullableString($data['salaire_details'] ?? null));
            $stmt->execute();

            $newId = (int) $db->lastInsertId();

            if (isset($data['competences']) && is_array($data['competences'])) {
                $stmtC = $db->prepare('INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:mid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([
                        ':mid' => $newId,
                        ':cid' => $c['competence_id'],
                        ':imp' => $c['importance'] ?? 'essentielle',
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteIdVal, 'create', 'metier', $newId, null, $data);
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
        $siteId = recrutementRequireSiteIdFromRequest();

        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Metier not found');
            return;
        }

        $db->beginTransaction();
        try {
            $stringFields = [
                'code_rome', 'slug', 'libelle', 'titre', 'description_courte', 'description',
                'presentation', 'journee_type', 'famille_metier', 'niveau_etudes', 'perspectives',
                'image_url', 'salaire_fourchette', 'salaire_debutant', 'salaire_confirme',
                'salaire_liberal', 'salaire_details',
            ];
            $intNullFields = ['secteur_id', 'site_id'];
            $intFields = ['actif'];

            $fields = [];
            $bind = [];

            foreach ($stringFields as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = metierNullableString($data[$f]);
                }
            }
            foreach ($intNullFields as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = recrutementNormalizeOptionalInt($data[$f]);
                }
            }
            foreach ($intFields as $f) {
                if (array_key_exists($f, $data)) {
                    $fields[] = "$f = :$f";
                    $bind[":$f"] = (int) $data[$f];
                }
            }

            if (!empty($fields)) {
                $fields[] = 'updated_at = NOW()';
                $sql = 'UPDATE metiers SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) {
                    if (in_array($k, [':secteur_id', ':site_id'], true)) {
                        recrutementBindNullableInt($stmt, $k, $v);
                    } elseif (str_starts_with($k, ':') && in_array(substr($k, 1), $intFields, true)) {
                        $stmt->bindValue($k, $v, PDO::PARAM_INT);
                    } else {
                        metierBindNullableString($stmt, $k, $v !== null ? (string) $v : null);
                    }
                }
                $stmt->bindValue(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
            }

            if (isset($data['competences']) && is_array($data['competences'])) {
                $db->prepare('DELETE FROM metier_competences WHERE metier_id = :id')->execute([':id' => $id]);
                $stmtC = $db->prepare('INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:mid, :cid, :imp)');
                foreach ($data['competences'] as $c) {
                    $stmtC->execute([
                        ':mid' => $id,
                        ':cid' => $c['competence_id'],
                        ':imp' => $c['importance'] ?? 'essentielle',
                    ]);
                }
            }

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'update', 'metier', $id, $old, $data);
            Response::success(['id' => $id], 'Metier updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update metier', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/jobs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM metiers WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Metier not found');
            return;
        }

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
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            $db->commit();
            Audit::log((int) $admin['id'], $siteId, 'delete', 'metier', $id, $old, null);
            Response::noContent();
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to delete metier', $e->getMessage());
        }
    });
}
