<?php
/**
 * modules/recrutement/entreprises.php — CRUD entreprises
 */

require_once __DIR__ . '/site_scope.php';

function registerRecrutementEntreprisesRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/entreprises', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = Router::getQueryParam('site_id');
        if ($siteId === null || $siteId === '') {
            $siteId = $_SERVER['HTTP_X_SITE_ID'] ?? null;
        }
        $db = getDb();
        $sql = 'SELECT * FROM entreprises';
        $params = [];

        if ($siteId !== null && $siteId !== '') {
            $siteId = (int) $siteId;
            $sql .= ' WHERE (
                EXISTS (
                    SELECT 1 FROM offres_emploi o
                    WHERE o.entreprise_id = entreprises.id AND o.site_id = :site_id
                )
                OR EXISTS (
                    SELECT 1 FROM recruteurs r
                    INNER JOIN recruteur_sites rs ON rs.recruteur_id = r.id
                    WHERE r.entreprise_id = entreprises.id
                    AND rs.site = (SELECT site_code FROM core_sites WHERE id = :site_id2 LIMIT 1)
                )
                OR EXISTS (
                    SELECT 1 FROM recruteurs r2
                    INNER JOIN offres_emploi o2 ON o2.recruteur_id = r2.id AND o2.site_id = :site_id3
                    WHERE r2.entreprise_id = entreprises.id
                )
            )';
            $params[':site_id'] = $siteId;
            $params[':site_id2'] = $siteId;
            $params[':site_id3'] = $siteId;
        }

        $sql .= ' ORDER BY nom ASC';
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, PDO::PARAM_INT);
        }
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->post('/api/admin/recrutement/entreprises', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('nom', 'Nom')->validate();
        $slug = $data['slug'] ?? Validator::slugify($data['nom']);

        $db = getDb();
        $stmt = $db->prepare('SELECT id FROM entreprises WHERE slug = :slug LIMIT 1');
        $stmt->bindParam(':slug', $slug, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->fetch()) {
            Response::badRequest('Entreprise slug already exists');
            return;
        }

        $siteId = recrutementResolveSiteIdFromBody($data, $admin);
        $secteurId = entrepriseNormalizeOptionalInt($data['secteur_id'] ?? null);
        if ($secteurId !== null) {
            $chk = $db->prepare('SELECT id FROM secteurs_activite WHERE id = :id LIMIT 1');
            $chk->bindValue(':id', $secteurId, PDO::PARAM_INT);
            $chk->execute();
            if (!$chk->fetch()) {
                Response::badRequest('Secteur invalide');
                return;
            }
        }

        $taille = entrepriseNormalizeTaille($data['taille'] ?? null);
        if ($taille === false) {
            Response::badRequest('Taille invalide');
            return;
        }

        $siret = entrepriseNormalizeOptionalString($data['siret'] ?? null);
        $validee = !empty($data['validee']) ? 1 : 0;

        try {
            $sql = 'INSERT INTO entreprises (nom, slug, siret, description, logo_url, site_web, taille, secteur_id, adresse, code_postal, ville, departement, region, validee, created_at, updated_at)
                    VALUES (:nom, :slug, :siret, :description, :logo_url, :site_web, :taille, :secteur_id, :adresse, :code_postal, :ville, :departement, :region, :validee, NOW(), NOW())';

            $stmt = $db->prepare($sql);

            $stmt->bindValue(':nom', (string) $data['nom'], PDO::PARAM_STR);
            $stmt->bindValue(':slug', $slug, PDO::PARAM_STR);
            entrepriseBindNullableString($stmt, ':siret', $siret);
            entrepriseBindNullableString($stmt, ':description', entrepriseNormalizeOptionalString($data['description'] ?? null));
            entrepriseBindNullableString($stmt, ':logo_url', entrepriseNormalizeOptionalString($data['logo_url'] ?? null));
            entrepriseBindNullableString($stmt, ':site_web', entrepriseNormalizeOptionalString($data['site_web'] ?? null));
            entrepriseBindNullableString($stmt, ':taille', $taille);
            entrepriseBindNullableInt($stmt, ':secteur_id', $secteurId);
            entrepriseBindNullableString($stmt, ':adresse', entrepriseNormalizeOptionalString($data['adresse'] ?? null));
            entrepriseBindNullableString($stmt, ':code_postal', entrepriseNormalizeOptionalString($data['code_postal'] ?? null));
            entrepriseBindNullableString($stmt, ':ville', entrepriseNormalizeOptionalString($data['ville'] ?? null));
            entrepriseBindNullableString($stmt, ':departement', entrepriseNormalizeOptionalString($data['departement'] ?? null));
            entrepriseBindNullableString($stmt, ':region', entrepriseNormalizeOptionalString($data['region'] ?? null));
            $stmt->bindValue(':validee', $validee, PDO::PARAM_INT);
            $stmt->execute();

            $newId = (int) $db->lastInsertId();
            Audit::log((int) $admin['id'], $siteId, 'create', 'entreprise', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\PDOException $e) {
            error_log('entreprises POST: ' . $e->getMessage());
            Response::serverError('Failed to create entreprise', APP_ENV === 'development' ? $e->getMessage() : null);
        } catch (\Exception $e) {
            error_log('entreprises POST: ' . $e->getMessage());
            Response::serverError('Failed to create entreprise', APP_ENV === 'development' ? $e->getMessage() : null);
        }
    });

    $router->put('/api/admin/recrutement/entreprises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM entreprises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Entreprise not found');
            return;
        }

        $fields = [];
        $bind = [];
        foreach (['nom', 'slug', 'siret', 'description', 'logo_url', 'site_web', 'taille', 'secteur_id', 'adresse', 'code_postal', 'ville', 'departement', 'region', 'validee'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if (empty($fields)) {
            Response::badRequest('No fields to update');
            return;
        }

        if (array_key_exists('taille', $data)) {
            $taille = entrepriseNormalizeTaille($data['taille']);
            if ($taille === false) {
                Response::badRequest('Taille invalide');
                return;
            }
            $bind[':taille'] = $taille;
        }

        if (array_key_exists('secteur_id', $data)) {
            $secteurId = entrepriseNormalizeOptionalInt($data['secteur_id']);
            if ($secteurId !== null) {
                $chk = $db->prepare('SELECT id FROM secteurs_activite WHERE id = :id LIMIT 1');
                $chk->bindValue(':id', $secteurId, PDO::PARAM_INT);
                $chk->execute();
                if (!$chk->fetch()) {
                    Response::badRequest('Secteur invalide');
                    return;
                }
            }
            $bind[':secteur_id'] = $secteurId;
        }

        try {
            $fields[] = 'updated_at = NOW()';
            $sql = 'UPDATE entreprises SET ' . implode(', ', $fields) . ' WHERE id = :id';
            $stmt = $db->prepare($sql);
            foreach ($bind as $k => $v) {
                entrepriseBindUpdateValue($stmt, $k, $v);
            }
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            $auditSiteId = isset($old['site_id']) ? (int) $old['site_id'] : null;
            Audit::log((int) $admin['id'], $auditSiteId > 0 ? $auditSiteId : null, 'update', 'entreprise', $id, $old, $data);
            Response::success(['id' => $id], 'Entreprise updated');
        } catch (\PDOException $e) {
            error_log('entreprises PUT: ' . $e->getMessage());
            Response::serverError('Failed to update entreprise', APP_ENV === 'development' ? $e->getMessage() : null);
        }
    });

    $router->delete('/api/admin/recrutement/entreprises/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM entreprises WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) {
            Response::notFound('Entreprise not found');
            return;
        }

        try {
            $stmtCheck = $db->prepare('SELECT COUNT(*) as count FROM offres_emploi WHERE entreprise_id = :id');
            $stmtCheck->execute([':id' => $id]);
            if ($stmtCheck->fetch()['count'] > 0) {
                Response::badRequest('Impossible de supprimer cette entreprise car elle possède des offres d\'emploi liées.');
                return;
            }

            $stmt = $db->prepare('DELETE FROM entreprises WHERE id = :id');
            $stmt->bindParam(':id', $id, PDO::PARAM_INT);
            $stmt->execute();

            $auditSiteId = isset($old['site_id']) ? (int) $old['site_id'] : null;
            Audit::log((int) $admin['id'], $auditSiteId > 0 ? $auditSiteId : null, 'delete', 'entreprise', $id, $old, null);
            Response::noContent();
        } catch (\Exception $e) {
            Response::serverError('Failed to delete entreprise', APP_ENV === 'development' ? $e->getMessage() : null);
        }
    });
}

function entrepriseNormalizeOptionalInt(mixed $value): ?int
{
    if ($value === null || $value === '' || $value === false) {
        return null;
    }

    $int = (int) $value;

    return $int > 0 ? $int : null;
}

function entrepriseNormalizeOptionalString(mixed $value): ?string
{
    if ($value === null) {
        return null;
    }

    $str = trim((string) $value);

    return $str === '' ? null : $str;
}

/**
 * @return string|null|false null si vide, false si valeur enum invalide
 */
function entrepriseNormalizeTaille(mixed $value): string|null|false
{
    if ($value === null || $value === '') {
        return null;
    }

    $taille = (string) $value;
    $allowed = ['1-10', '11-50', '51-200', '201-500', '500+'];

    return in_array($taille, $allowed, true) ? $taille : false;
}

function entrepriseBindNullableInt(PDOStatement $stmt, string $param, ?int $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value, PDO::PARAM_INT);
}

function entrepriseBindNullableString(PDOStatement $stmt, string $param, ?string $value): void
{
    if ($value === null) {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value, PDO::PARAM_STR);
}

function entrepriseBindUpdateValue(PDOStatement $stmt, string $param, mixed $value): void
{
    if ($param === ':validee') {
        $stmt->bindValue($param, !empty($value) ? 1 : 0, PDO::PARAM_INT);
        return;
    }

    if ($param === ':secteur_id') {
        entrepriseBindNullableInt($stmt, $param, entrepriseNormalizeOptionalInt($value));
        return;
    }

    if ($value === null || $value === '') {
        $stmt->bindValue($param, null, PDO::PARAM_NULL);
        return;
    }

    $stmt->bindValue($param, $value);
}
