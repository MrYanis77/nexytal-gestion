<?php
/**
 * modules/recrutement/recruteurs.php — CRUD recruteurs (aligné bdd.sql)
 *
 * Table recruteurs : email, password_hash, nom_entreprise, prenom, nom,
 *   telephone, fonction, status (pending/actif/suspendu),
 *   entreprise_id, validated_at, validated_by.
 *
 * Flux : inscription (pending) → validation admin → actif → recruteur_sites
 */

require_once __DIR__ . '/site_scope.php';
function recrutementSiteCodeFromId(PDO $db, int $siteId): ?string
{
    if ($siteId <= 0) {
        return null;
    }

    $stmt = $db->prepare('SELECT site_code FROM core_sites WHERE id = :id AND is_active = 1 LIMIT 1');
    $stmt->execute([':id' => $siteId]);
    $code = $stmt->fetchColumn();

    return is_string($code) && in_array($code, Validator::VALID_SITE_CODES, true) ? $code : null;
}

function recrutementSiteIdFromCode(PDO $db, string $siteCode): ?int
{
    if (!in_array($siteCode, Validator::VALID_SITE_CODES, true)) {
        return null;
    }

    $stmt = $db->prepare('SELECT id FROM core_sites WHERE site_code = :code AND is_active = 1 LIMIT 1');
    $stmt->execute([':code' => $siteCode]);
    $id = (int) ($stmt->fetchColumn() ?: 0);

    return $id > 0 ? $id : null;
}

function recrutementNormalizeSiteCodes(array $codes): array
{
    $valid = [];
    foreach ($codes as $code) {
        $code = trim((string) $code);
        if (in_array($code, Validator::VALID_SITE_CODES, true) && !in_array($code, $valid, true)) {
            $valid[] = $code;
        }
    }
    return $valid;
}

function recrutementDetectRecruteurSiteCodes(PDO $db, array $recruteur, array $fallbackCodes = []): array
{
    $codes = [];
    $recruteurId = (int) ($recruteur['id'] ?? 0);

    if ($recruteurId > 0) {
        $stmt = $db->prepare('SELECT site FROM recruteur_sites WHERE recruteur_id = :id ORDER BY granted_at ASC');
        $stmt->execute([':id' => $recruteurId]);
        $codes = array_merge($codes, array_column($stmt->fetchAll(), 'site'));

        $stmt = $db->prepare(
            'SELECT DISTINCT cs.site_code
             FROM offres_emploi o
             INNER JOIN core_sites cs ON cs.id = o.site_id
             WHERE o.recruteur_id = :id AND cs.is_active = 1
             ORDER BY cs.id ASC'
        );
        $stmt->execute([':id' => $recruteurId]);
        $codes = array_merge($codes, array_column($stmt->fetchAll(), 'site_code'));
    }

    foreach (['registration_site', 'registration_site_code'] as $column) {
        if (recrutementTableHasColumn($db, 'recruteurs', $column) && !empty($recruteur[$column])) {
            $codes[] = (string) $recruteur[$column];
        }
    }

    if (recrutementTableHasColumn($db, 'recruteurs', 'registration_site_id') && !empty($recruteur['registration_site_id'])) {
        $code = recrutementSiteCodeFromId($db, (int) $recruteur['registration_site_id']);
        if ($code !== null) {
            $codes[] = $code;
        }
    }

    if (!empty($recruteur['entreprise_id']) && recrutementTableHasColumn($db, 'entreprises', 'site_id')) {
        $stmt = $db->prepare('SELECT site_id FROM entreprises WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => (int) $recruteur['entreprise_id']]);
        $code = recrutementSiteCodeFromId($db, (int) ($stmt->fetchColumn() ?: 0));
        if ($code !== null) {
            $codes[] = $code;
        }
    }

    $requestSiteId = $_GET['site_id'] ?? $_SERVER['HTTP_X_SITE_ID'] ?? null;
    if ($requestSiteId !== null && $requestSiteId !== '') {
        $code = recrutementSiteCodeFromId($db, (int) $requestSiteId);
        if ($code !== null) {
            $codes[] = $code;
        }
    }

    return recrutementNormalizeSiteCodes(array_merge($codes, $fallbackCodes));
}

function registerRecrutementRecruteursRoutes(Router $router): void
{
    // ── Liste tous les recruteurs (filtre optionnel ?status=) ──
    $router->get('/api/admin/recrutement/recruteurs', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();

        $where = [];
        $params = [];

        if ($status = Router::getQueryParam('status')) {
            $where[] = 'r.status = :status';
            $params[':status'] = $status;
        }

        // Filtre optionnel par site_id (recruteur_sites ou offres sur ce site)
        $siteId = Router::getQueryParam('site_id');
        if ($siteId) {
            $where[] = recrutementRecruteurMatchesSiteSql('r');
            $params[':filter_site_id'] = (int) $siteId;
            $params[':filter_site_id2'] = (int) $siteId;
        }

        $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

        $sql = "SELECT r.*, e.nom AS entreprise_nom_validee
                FROM recruteurs r
                LEFT JOIN entreprises e ON r.entreprise_id = e.id
                $whereClause
                ORDER BY r.created_at DESC";
        $stmt = $db->prepare($sql);
        foreach ($params as $k => $v) $stmt->bindValue($k, $v);
        $stmt->execute();

        $rows = $stmt->fetchAll();

        // Ajouter les sites autorisés pour chaque recruteur
        $stmtSites = $db->prepare('SELECT site, granted_at FROM recruteur_sites WHERE recruteur_id = :rid');
        foreach ($rows as &$row) {
            $stmtSites->execute([':rid' => $row['id']]);
            $row['sites_autorises'] = $stmtSites->fetchAll();
            $row['sites_detectes'] = recrutementDetectRecruteurSiteCodes($db, $row);
        }

        Response::success($rows);
    });

    // ── Compter les recruteurs en attente (AVANT /{id} — sinon « pending-count » est pris pour un id) ──
    $router->get('/api/admin/recrutement/recruteurs/pending-count', function () {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $siteId = Router::getQueryParam('site_id');

        if ($siteId) {
            $stmt = $db->prepare(
                'SELECT COUNT(*) as count FROM recruteurs r
                 WHERE r.status = \'pending\' AND ' . recrutementRecruteurMatchesSiteSql('r')
            );
            $stmt->execute([
                ':filter_site_id' => (int) $siteId,
                ':filter_site_id2' => (int) $siteId,
            ]);
        } else {
            $stmt = $db->query("SELECT COUNT(*) as count FROM recruteurs WHERE status = 'pending'");
        }
        Response::success(['count' => (int) $stmt->fetch()['count']]);
    });

    // ── Détail d'un recruteur ──
    $router->get('/api/admin/recrutement/recruteurs/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        if (!ctype_digit((string) $params['id'])) {
            Response::notFound('Recruteur not found');
            return;
        }
        $id = (int) $params['id'];

        $stmt = $db->prepare(
            'SELECT r.*, e.nom AS entreprise_nom_validee
             FROM recruteurs r
             LEFT JOIN entreprises e ON r.entreprise_id = e.id
             WHERE r.id = :id LIMIT 1'
        );
        $stmt->execute([':id' => $id]);
        $row = $stmt->fetch();
        if (!$row) { Response::notFound('Recruteur not found'); return; }

        // Sites autorisés
        $stmtSites = $db->prepare('SELECT site, granted_at FROM recruteur_sites WHERE recruteur_id = :rid');
        $stmtSites->execute([':rid' => $id]);
        $row['sites_autorises'] = $stmtSites->fetchAll();
        $row['sites_detectes'] = recrutementDetectRecruteurSiteCodes($db, $row);

        Response::success($row);
    });

    // ── Création d'un recruteur (par admin) ──
    $router->post('/api/admin/recrutement/recruteurs', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('email', 'Email')
            ->email('email', 'Email')
            ->required('nom_entreprise', 'Nom entreprise')
            ->validate();

        $db = getDb();

        // Vérifier unicité email
        $stmt = $db->prepare('SELECT id FROM recruteurs WHERE email = :email LIMIT 1');
        $stmt->execute([':email' => $data['email']]);
        if ($stmt->fetch()) {
            Response::badRequest('Un recruteur avec cet email existe déjà');
            return;
        }

        $stmt = $db->prepare(
            'INSERT INTO recruteurs (email, nom_entreprise, prenom, nom, telephone, fonction, entreprise_id, status, created_at, updated_at)
             VALUES (:email, :nom_e, :prenom, :nom, :tel, :fonc, :eid, :status, NOW(), NOW())'
        );
        $stmt->execute([
            ':email'   => $data['email'],
            ':nom_e'   => $data['nom_entreprise'],
            ':prenom'  => $data['prenom'] ?? null,
            ':nom'     => $data['nom'] ?? null,
            ':tel'     => $data['telephone'] ?? null,
            ':fonc'    => $data['fonction'] ?? null,
            ':eid'     => !empty($data['entreprise_id']) ? (int) $data['entreprise_id'] : null,
            ':status'  => $data['status'] ?? 'pending',
        ]);

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], null, 'create', 'recruteur', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    // ── Mise à jour d'un recruteur ──
    $router->put('/api/admin/recrutement/recruteurs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }

        $fields = []; $bind = [];
        foreach (['email', 'nom_entreprise', 'prenom', 'nom', 'telephone', 'fonction', 'entreprise_id', 'status'] as $f) {
            if (array_key_exists($f, $data)) {
                $fields[] = "$f = :$f";
                $bind[":$f"] = $data[$f];
            }
        }
        if (empty($fields)) { Response::badRequest('No fields to update'); return; }

        $fields[] = "updated_at = NOW()";
        $sql = 'UPDATE recruteurs SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], null, 'update', 'recruteur', $id, $old, $data);
        Response::success(['id' => $id], 'Recruteur updated');
    });

    // ── Valider un recruteur (pending → actif) ──
    $router->post('/api/admin/recrutement/recruteurs/{id}/validate', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }
        if ($old['status'] !== 'pending') {
            Response::badRequest('Seuls les recruteurs en attente peuvent être validés');
            return;
        }

        $fallbackSites = isset($data['sites']) && is_array($data['sites']) ? $data['sites'] : [];
        $sites = recrutementDetectRecruteurSiteCodes($db, $old, $fallbackSites);
        if ($sites === []) {
            Response::validationError([
                'site' => 'Impossible de determiner le site du recruteur. Filtrez la page par site ou ajoutez registration_site_id a l\'inscription.',
            ], 'Site recruteur indetermine');
            return;
        }

        foreach ($sites as $siteCode) {
            $detectedSiteId = recrutementSiteIdFromCode($db, $siteCode);
            if ($detectedSiteId !== null) {
                Middleware::requireSiteAccess($detectedSiteId);
            }
        }

        $db->beginTransaction();
        try {
            // 1. Activer le recruteur
            $stmt = $db->prepare(
                "UPDATE recruteurs SET status = 'actif', validated_at = NOW(), validated_by = :admin_id, updated_at = NOW() WHERE id = :id"
            );
            $stmt->execute([':admin_id' => $admin['id'], ':id' => $id]);

            // 2. Attribuer les sites autorises detectes automatiquement
            $stmtSite = $db->prepare(
                'INSERT INTO recruteur_sites (recruteur_id, site, granted_by, granted_at)
                 VALUES (:rid, :site, :gby, NOW())
                 ON DUPLICATE KEY UPDATE granted_by = VALUES(granted_by), granted_at = VALUES(granted_at)'
            );
            foreach ($sites as $siteCode) {
                $stmtSite->execute([
                    ':rid'  => $id,
                    ':site' => $siteCode,
                    ':gby'  => $admin['id'],
                ]);
            }

            // 3. Valider l'entreprise liée si elle existe
            if (!empty($old['entreprise_id'])) {
                $db->prepare(
                    "UPDATE entreprises SET validee = 1, updated_at = NOW() WHERE id = :eid AND validee = 0"
                )->execute([':eid' => $old['entreprise_id']]);
            }

            // 4. Générer un token d'activation (pour que le recruteur définisse son mot de passe)
            $rawToken = bin2hex(random_bytes(32));
            $tokenHash = hash('sha256', $rawToken);
            $db->prepare(
                'INSERT INTO recruteur_activation_tokens (recruteur_id, token_hash, expires_at, created_at)
                 VALUES (:rid, :hash, DATE_ADD(NOW(), INTERVAL 72 HOUR), NOW())'
            )->execute([':rid' => $id, ':hash' => $tokenHash]);

            $db->commit();

            require_once __DIR__ . '/../../core/ValidationNotify.php';
            $emailSent = validationNotifyRecruteur($db, $old, $rawToken, is_array($sites) ? $sites : []);

            Audit::log((int) $admin['id'], null, 'validate', 'recruteur', $id, $old, ['sites' => $sites]);
            Response::success([
                'id' => $id,
                'status' => 'actif',
                'sites' => $sites,
                'email_sent' => $emailSent,
            ], 'Recruteur validé');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Échec de la validation', $e->getMessage());
        }
    });

    // ── Suspendre un recruteur ──
    $router->post('/api/admin/recrutement/recruteurs/{id}/suspend', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }

        $stmt = $db->prepare(
            "UPDATE recruteurs SET status = 'suspendu', updated_at = NOW() WHERE id = :id"
        );
        $stmt->execute([':id' => $id]);

        require_once __DIR__ . '/../../core/ActionNotify.php';
        $emailSent = ActionNotify::recruteurSuspended($db, $old);

        Audit::log((int) $admin['id'], null, 'suspend', 'recruteur', $id, $old, ['status' => 'suspendu', 'email_sent' => $emailSent]);
        Response::success(['id' => $id, 'status' => 'suspendu', 'email_sent' => $emailSent], 'Recruteur suspendu');
    });

    // ── Suppression ──
    $router->delete('/api/admin/recrutement/recruteurs/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM recruteurs WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Recruteur not found'); return; }

        $stmt = $db->prepare('DELETE FROM recruteurs WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Audit::log((int) $admin['id'], null, 'delete', 'recruteur', $id, $old, null);
        Response::noContent();
    });
}
