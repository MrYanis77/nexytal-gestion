<?php
/**
 * modules/recrutement/candidats.php — CRUD candidats
 */

require_once __DIR__ . '/site_scope.php';

function registerRecrutementCandidatsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/candidats', function () {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $siteId = recrutementRequireSiteIdFromRequest();
        $db = getDb();
        $stmt = $db->prepare(
            'SELECT DISTINCT c.*, u.email FROM candidats c
             LEFT JOIN users u ON c.user_id = u.id
             WHERE EXISTS (
                SELECT 1 FROM candidatures ca
                INNER JOIN offres_emploi o ON o.id = ca.offre_id
                WHERE ca.candidat_id = c.id AND o.site_id = :site_id
             )
             ORDER BY c.nom ASC'
        );
        $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
        $stmt->execute();
        Response::success($stmt->fetchAll());
    });

    $router->get('/api/admin/recrutement/candidats/{id}', function (array $params) {
        Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT c.*, u.email FROM candidats c LEFT JOIN users u ON c.user_id = u.id WHERE c.id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $candidat = $stmt->fetch();
        if (!$candidat) { Response::notFound('Candidat not found'); return; }

        $stmtC = $db->prepare('SELECT comp.*, cc.niveau FROM competences comp INNER JOIN candidat_competences cc ON comp.id = cc.competence_id WHERE cc.candidat_id = :id');
        $stmtC->execute([':id' => $id]);
        $candidat['competences'] = $stmtC->fetchAll();

        $stmtM = $db->prepare(
            'SELECT cms.*, m.libelle as metier_libelle FROM candidat_metiers_souhaites cms
             INNER JOIN metiers m ON cms.metier_id = m.id WHERE cms.candidat_id = :id'
        );
        $stmtM->execute([':id' => $id]);
        $candidat['metiers_souhaites'] = $stmtM->fetchAll();

        Response::success($candidat);
    });

    $router->post('/api/admin/recrutement/candidats', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();

        Validator::make($data)->required('prenom', 'Prénom')->required('nom', 'Nom')->validate();

        $db = getDb();

        try {
            $userId = candidatResolveUserId($db, $data);
        } catch (\InvalidArgumentException $e) {
            Response::badRequest($e->getMessage());
            return;
        }

        $stmt = $db->prepare('SELECT id FROM candidats WHERE user_id = :user_id LIMIT 1');
        $stmt->bindParam(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        if ($stmt->fetch()) { Response::badRequest('User already has a candidat profile'); return; }

        $db->beginTransaction();
        try {
            $stmt = $db->prepare(
                'INSERT INTO candidats (user_id, prenom, nom, telephone, date_naissance, situation_professionnelle, resume_court, ville, code_postal, region, mobilite_km, teletravail_souhaite, disponibilite, recherche_active, salaire_souhaite_min, type_contrat_souhaite, profil_public, rgpd_consent_at, created_at, updated_at)
                 VALUES (:uid, :pre, :nom, :tel, :dn, :sp, :rc, :v, :cp, :reg, :mkm, :ts, :disp, :ra, :ssm, :tcs, :pp, NOW(), NOW(), NOW())'
            );
            $stmt->bindValue(':uid', $userId, PDO::PARAM_INT);
            $stmt->bindValue(':pre', $data['prenom'], PDO::PARAM_STR);
            $stmt->bindValue(':nom', $data['nom'], PDO::PARAM_STR);
            $stmt->bindValue(':tel', $data['telephone'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':dn', $data['date_naissance'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':sp', $data['situation_professionnelle'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':rc', $data['resume_court'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':v', $data['ville'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':cp', $data['code_postal'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':reg', $data['region'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':mkm', $data['mobilite_km'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':ts', $data['teletravail_souhaite'] ?? 'indifferent', PDO::PARAM_STR);
            $stmt->bindValue(':disp', $data['disponibilite'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':ra', $data['recherche_active'] ?? 1, PDO::PARAM_INT);
            $stmt->bindValue(':ssm', $data['salaire_souhaite_min'] ?? null, PDO::PARAM_INT);
            $stmt->bindValue(':tcs', $data['type_contrat_souhaite'] ?? null, PDO::PARAM_STR);
            $stmt->bindValue(':pp', $data['profil_public'] ?? 0, PDO::PARAM_INT);
            $stmt->execute();
            
            $newId = (int) $db->lastInsertId();

            candidatSyncChildren($db, $newId, $data);

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'create', 'candidat', $newId, null, $data);
            Response::created(['id' => $newId]);
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to create candidat', $e->getMessage());
        }
    });

    $router->put('/api/admin/recrutement/candidats/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'recruiter']);
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM candidats WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Candidat not found'); return; }

        $db->beginTransaction();
        try {
            $fields = []; $bind = [];
            foreach (['prenom', 'nom', 'telephone', 'date_naissance', 'situation_professionnelle', 'resume_court', 'ville', 'code_postal', 'region', 'mobilite_km', 'teletravail_souhaite', 'disponibilite', 'recherche_active', 'salaire_souhaite_min', 'type_contrat_souhaite', 'profil_public'] as $f) {
                if (array_key_exists($f, $data)) { $fields[] = "$f = :$f"; $bind[":$f"] = $data[$f]; }
            }
            if (!empty($fields)) {
                $fields[] = "updated_at = NOW()";
                $sql = 'UPDATE candidats SET ' . implode(', ', $fields) . ' WHERE id = :id';
                $stmt = $db->prepare($sql);
                foreach ($bind as $k => $v) $stmt->bindValue($k, $v);
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
            }

            candidatSyncChildren($db, $id, $data);

            $db->commit();
            Audit::log((int) $admin['id'], 1, 'update', 'candidat', $id, $old, $data);
            Response::success(['id' => $id], 'Candidat updated');
        } catch (\Exception $e) {
            $db->rollBack();
            Response::serverError('Failed to update candidat', $e->getMessage());
        }
    });

    $router->delete('/api/admin/recrutement/candidats/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $db = getDb();
        $id = (int) $params['id'];
        
        $stmt = $db->prepare('SELECT * FROM candidats WHERE id = :id LIMIT 1');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        $old = $stmt->fetch();
        if (!$old) { Response::notFound('Candidat not found'); return; }
        
        $stmt = $db->prepare('DELETE FROM candidats WHERE id = :id');
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        
        Audit::log((int) $admin['id'], 1, 'delete', 'candidat', $id, $old, null);
        Response::noContent();
    });
}

function candidatResolveUserId(PDO $db, array $data): int
{
    if (!empty($data['user_id'])) {
        $userId = (int) $data['user_id'];
        $stmt = $db->prepare('SELECT id FROM users WHERE id = :id AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        if (!$stmt->fetch()) {
            throw new \InvalidArgumentException('User not found');
        }
        return $userId;
    }

    $email = trim((string) ($data['email'] ?? ''));
    if ($email !== '') {
        Validator::make(['email' => $email])->email('email', 'Email')->validate();
        $stmt = $db->prepare('SELECT id FROM users WHERE email = :email AND deleted_at IS NULL LIMIT 1');
        $stmt->bindParam(':email', $email, PDO::PARAM_STR);
        $stmt->execute();
        $existing = $stmt->fetch();
        if ($existing) {
            return (int) $existing['id'];
        }

        $stmt = $db->prepare(
            'INSERT INTO users (email, password_hash, role, email_verifie, actif, created_at, updated_at)
             VALUES (:email, NULL, :role, 1, 1, NOW(), NOW())'
        );
        $stmt->bindValue(':email', $email, PDO::PARAM_STR);
        $role = 'candidat';
        $stmt->bindValue(':role', $role, PDO::PARAM_STR);
        $stmt->execute();
        return (int) $db->lastInsertId();
    }

    $slug = Validator::slugify(trim(($data['prenom'] ?? '') . '-' . ($data['nom'] ?? '')));
    if ($slug === '') {
        $slug = 'candidat';
    }
    $generatedEmail = "candidat.{$slug}." . bin2hex(random_bytes(4)) . '@internal.nexytal.local';

    $stmt = $db->prepare(
        'INSERT INTO users (email, password_hash, role, email_verifie, actif, created_at, updated_at)
         VALUES (:email, NULL, :role, 1, 1, NOW(), NOW())'
    );
    $stmt->bindValue(':email', $generatedEmail, PDO::PARAM_STR);
    $role = 'candidat';
    $stmt->bindValue(':role', $role, PDO::PARAM_STR);
    $stmt->execute();
    return (int) $db->lastInsertId();
}

function candidatSyncChildren(PDO $db, int $candidatId, array $data): void
{
    if (isset($data['competences']) && is_array($data['competences'])) {
        $db->prepare('DELETE FROM candidat_competences WHERE candidat_id = :id')->execute([':id' => $candidatId]);
        $stmtC = $db->prepare('INSERT INTO candidat_competences (candidat_id, competence_id, niveau) VALUES (:cid, :coid, :niv)');
        foreach ($data['competences'] as $c) {
            $stmtC->execute([
                ':cid' => $candidatId, ':coid' => $c['competence_id'],
                ':niv' => $c['niveau'] ?? 'intermediaire',
            ]);
        }
    }

    if (isset($data['metiers_souhaites']) && is_array($data['metiers_souhaites'])) {
        $db->prepare('DELETE FROM candidat_metiers_souhaites WHERE candidat_id = :id')->execute([':id' => $candidatId]);
        $stmtM = $db->prepare('INSERT INTO candidat_metiers_souhaites (candidat_id, metier_id) VALUES (:cid, :mid)');
        foreach ($data['metiers_souhaites'] as $m) {
            $stmtM->execute([
                ':cid' => $candidatId, ':mid' => $m['metier_id'],
            ]);
        }
    }
}
