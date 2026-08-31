<?php
/**
 * formation_career_helpers.php — Carrières Alt RH via offres_emploi (department)
 */

require_once __DIR__ . '/../recrutement/site_scope.php';
require_once __DIR__ . '/../recrutement/offers.php';

function formationCareerUsesOffresEmploi(PDO $db, bool $refresh = false): bool
{
    static $cache = null;
    if (!$refresh && $cache !== null) {
        return $cache;
    }
    $cache = recrutementTableHasColumn($db, 'offres_emploi', 'department', $refresh);
    return $cache;
}

/** Ajoute department + sort_order si absents (schéma Alt RH sur offres_emploi existante). */
function formationCareerEnsureSchema(PDO $db): bool
{
    if (formationCareerUsesOffresEmploi($db)) {
        return true;
    }

    try {
        $db->exec(
            "ALTER TABLE `offres_emploi`
             ADD COLUMN IF NOT EXISTS `department` ENUM('collaborateur','formateur') DEFAULT NULL
             COMMENT 'Alt RH carrières ; NULL = offre classique' AFTER `site_id`"
        );
        $db->exec(
            "ALTER TABLE `offres_emploi`
             ADD COLUMN IF NOT EXISTS `sort_order` INT NOT NULL DEFAULT 0
             COMMENT 'Ordre carrières Alt Formation' AFTER `vues`"
        );
    } catch (\Throwable $e) {
        error_log('formationCareerEnsureSchema: ' . $e->getMessage());
        return false;
    }

    return formationCareerUsesOffresEmploi($db, true);
}

function formationCareerRequireSchema(PDO $db): bool
{
    if (formationCareerEnsureSchema($db)) {
        return true;
    }
    Response::serverError(
        'Schéma carrières Alt RH incomplet : exécutez api/sql/migrate_offres_emploi_department.sql sur la base de données.'
    );
    return false;
}

function formationCareerWhereClause(string $alias = 'o'): string
{
    return "{$alias}.department IS NOT NULL AND {$alias}.department IN ('collaborateur', 'formateur')";
}

function formationCareerResolveEntrepriseId(PDO $db): ?int
{
    $stmt = $db->prepare("SELECT id FROM entreprises WHERE slug = 'alt-rh-formations' LIMIT 1");
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        return (int) $row['id'];
    }

    $stmt = $db->prepare('SELECT id FROM entreprises WHERE id = 0 LIMIT 1');
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        return (int) $row['id'];
    }

    return null;
}

function formationCareerStatutForFront(string $statut): string
{
    $map = [
        'publiee' => 'publie',
        'archivee' => 'archivee',
        'pourvue' => 'pourvue',
        'expiree' => 'expiree',
    ];
    return $map[$statut] ?? $statut;
}

function formationCareerNormalizeDateTime(mixed $value, string $timeSuffix = '00:00:00'): ?string
{
    if ($value === null || $value === '') {
        return null;
    }
    $s = trim((string) $value);
    if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $s)) {
        return $s . ' ' . $timeSuffix;
    }
    return $s;
}

function formationCareerOfferFromOffreRow(array $row): array
{
    $statutDb = (string) ($row['statut'] ?? 'brouillon');

    return [
        'id' => (int) $row['id'],
        'site_id' => (int) $row['site_id'],
        'department' => $row['department'],
        'metier_id' => $row['metier_id'] ?? null,
        'reference' => $row['reference'] ?? null,
        'slug' => $row['slug'],
        'title' => $row['titre'],
        'titre' => $row['titre'],
        'contract_type' => $row['type_contrat'],
        'type_contrat' => $row['type_contrat'],
        'experience_min' => $row['experience_min'] ?? null,
        'location' => $row['ville'],
        'ville' => $row['ville'],
        'code_postal' => $row['code_postal'] ?? null,
        'departement' => $row['departement'] ?? null,
        'region' => $row['region'] ?? null,
        'short_description' => $row['profil_recherche'],
        'profil_recherche' => $row['profil_recherche'],
        'full_description' => $row['description'],
        'description' => $row['description'],
        'avantages' => $row['avantages'] ?? null,
        'competences_text' => $row['competences_text'] ?? null,
        'salaire_min' => $row['salaire_min'] ?? null,
        'salaire_max' => $row['salaire_max'] ?? null,
        'salaire_afficher' => (int) ($row['salaire_afficher'] ?? 1),
        'teletravail' => $row['teletravail'] ?? 'non',
        'temps_travail' => $row['temps_travail'] ?? 'temps_plein',
        'is_featured' => (int) ($row['is_featured'] ?? 0),
        'is_urgent' => (int) ($row['is_urgent'] ?? 0),
        'urgent' => (int) ($row['is_urgent'] ?? 0),
        'statut' => formationCareerStatutForFront($statutDb),
        'published_at' => $row['date_publication'] ?? null,
        'date_publication' => $row['date_publication'] ?? null,
        'expires_at' => $row['date_expiration'] ?? null,
        'date_expiration' => $row['date_expiration'] ?? null,
        'sort_order' => (int) ($row['sort_order'] ?? 0),
        'meta_title' => $row['meta_title'] ?? null,
        'meta_description' => $row['meta_description'] ?? null,
        'vues' => (int) ($row['vues'] ?? 0),
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
    ];
}

function formationCareerPayloadToOffreColumns(array $data, int $siteId, int $entrepriseId, PDO $db): array
{
    $title = trim((string) ($data['title'] ?? $data['titre'] ?? ''));
    $slug = trim((string) ($data['slug'] ?? Validator::slugify($title)));

    $contractType = strtolower(trim((string) ($data['contract_type'] ?? $data['type_contrat'] ?? 'cdi')));
    $allowedContracts = ['cdi', 'cdd', 'interim', 'alternance', 'freelance', 'stage'];
    if (!in_array($contractType, $allowedContracts, true)) {
        $contractType = 'cdi';
    }

    $teletravail = $data['teletravail'] ?? 'non';
    $allowedTele = ['non', 'partiel', 'total'];
    if (!in_array($teletravail, $allowedTele, true)) {
        $teletravail = 'non';
    }

    $tempsTravail = $data['temps_travail'] ?? 'temps_plein';
    $allowedTemps = ['temps_plein', 'temps_partiel', 'variable'];
    if (!in_array($tempsTravail, $allowedTemps, true)) {
        $tempsTravail = 'temps_plein';
    }

    $experienceMin = $data['experience_min'] ?? null;
    $allowedExp = ['debutant', '1-2', '3-5', '5-10', '10+'];
    if ($experienceMin !== null && $experienceMin !== '' && !in_array($experienceMin, $allowedExp, true)) {
        $experienceMin = null;
    }

    $fullDesc = trim((string) ($data['full_description'] ?? $data['description'] ?? ''));
    $shortDesc = trim((string) ($data['short_description'] ?? $data['profil_recherche'] ?? ''));
    if ($fullDesc === '') {
        $fullDesc = $shortDesc !== '' ? $shortDesc : '—';
    }

    $statutRaw = $data['statut'] ?? $data['status'] ?? 'brouillon';
    if ($statutRaw === 'publie') {
        $statutRaw = 'publiee';
    }
    if ($statutRaw === 'ferme') {
        $statutRaw = 'archivee';
    }
    $statut = offreNormalizeStatutForDb($db, (string) $statutRaw);

    $publishedAt = formationCareerNormalizeDateTime(
        $data['published_at'] ?? $data['date_publication'] ?? $data['date'] ?? null
    );
    if ($statut === 'publiee' && empty($publishedAt)) {
        $publishedAt = date('Y-m-d H:i:s');
    }

    $expiresAt = formationCareerNormalizeDateTime(
        $data['expires_at'] ?? $data['date_expiration'] ?? null,
        '23:59:59'
    );

    $ville = trim((string) ($data['location'] ?? $data['ville'] ?? ''));

    return [
        'site_id' => $siteId,
        'entreprise_id' => $entrepriseId,
        'recruteur_id' => null,
        'department' => $data['department'] ?? null,
        'metier_id' => !empty($data['metier_id']) ? (int) $data['metier_id'] : null,
        'reference' => trim((string) ($data['reference'] ?? '')) ?: null,
        'slug' => $slug,
        'titre' => $title,
        'description' => $fullDesc,
        'profil_recherche' => $shortDesc !== '' ? $shortDesc : null,
        'avantages' => trim((string) ($data['avantages'] ?? '')) ?: null,
        'competences_text' => trim((string) ($data['competences_text'] ?? '')) ?: null,
        'type_contrat' => $contractType,
        'experience_min' => $experienceMin ?: null,
        'salaire_min' => isset($data['salaire_min']) && $data['salaire_min'] !== '' ? (int) $data['salaire_min'] : null,
        'salaire_max' => isset($data['salaire_max']) && $data['salaire_max'] !== '' ? (int) $data['salaire_max'] : null,
        'salaire_afficher' => !empty($data['salaire_afficher']) ? 1 : 0,
        'teletravail' => $teletravail,
        'temps_travail' => $tempsTravail,
        'ville' => $ville !== '' ? $ville : null,
        'code_postal' => trim((string) ($data['code_postal'] ?? '')) ?: null,
        'departement' => trim((string) ($data['departement'] ?? '')) ?: null,
        'region' => trim((string) ($data['region'] ?? '')) ?: null,
        'is_featured' => !empty($data['is_featured']) ? 1 : 0,
        'is_urgent' => !empty($data['urgent']) || !empty($data['is_urgent']) ? 1 : 0,
        'statut' => $statut,
        'date_publication' => $publishedAt,
        'date_expiration' => $expiresAt,
        'sort_order' => (int) ($data['sort_order'] ?? 0),
        'meta_title' => trim((string) ($data['meta_title'] ?? '')) ?: null,
        'meta_description' => trim((string) ($data['meta_description'] ?? '')) ?: null,
    ];
}

function formationCareerWritableColumns(PDO $db): array
{
    $columns = [
        'site_id', 'entreprise_id', 'recruteur_id', 'metier_id', 'reference', 'slug', 'titre',
        'description', 'profil_recherche', 'avantages', 'competences_text', 'type_contrat',
        'experience_min', 'salaire_min', 'salaire_max', 'salaire_afficher', 'teletravail',
        'temps_travail', 'ville', 'code_postal', 'departement', 'region', 'is_featured', 'is_urgent',
        'statut', 'date_publication', 'date_expiration', 'meta_title', 'meta_description',
    ];

    if (recrutementTableHasColumn($db, 'offres_emploi', 'department')) {
        array_splice($columns, 3, 0, ['department']);
    }
    if (recrutementTableHasColumn($db, 'offres_emploi', 'sort_order')) {
        $columns[] = 'sort_order';
    }

    return $columns;
}

function formationCareerInsertOffre(PDO $db, array $cols): int
{
    $columns = formationCareerWritableColumns($db);
    $placeholders = array_map(static fn ($c) => ':' . $c, $columns);
    $sql = 'INSERT INTO offres_emploi (' . implode(', ', $columns) . ', created_at, updated_at)
            VALUES (' . implode(', ', $placeholders) . ', NOW(), NOW())';

    $stmt = $db->prepare($sql);
    foreach ($columns as $col) {
        $stmt->bindValue(':' . $col, $cols[$col] ?? null);
    }
    $stmt->execute();

    return (int) $db->lastInsertId();
}

function formationCareerUpdateOffre(PDO $db, int $id, int $siteId, array $cols): void
{
    $fields = array_values(array_filter(
        formationCareerWritableColumns($db),
        static fn ($c) => !in_array($c, ['site_id', 'entreprise_id', 'recruteur_id'], true)
    ));

    $sets = array_map(static fn ($f) => "$f = :$f", $fields);
    $sql = 'UPDATE offres_emploi SET ' . implode(', ', $sets) . ', updated_at = NOW()
            WHERE id = :id AND site_id = :site_id';

    $stmt = $db->prepare($sql);
    foreach ($fields as $f) {
        $stmt->bindValue(':' . $f, $cols[$f] ?? null);
    }
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->bindValue(':site_id', $siteId, PDO::PARAM_INT);
    $stmt->execute();
}

function formationCareerSyncCompetences(PDO $db, int $offreId, array $data): void
{
    if (!array_key_exists('competences_text', $data)) {
        return;
    }
    offreSyncCompetencesFromText($db, $offreId, (string) ($data['competences_text'] ?? ''));
}

function formationCareerApplicationFromRow(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'site_id' => (int) ($row['site_id'] ?? 0),
        'offer_id' => $row['offre_id'] ?? $row['offer_id'] ?? null,
        'offer_title' => $row['offer_title'] ?? $row['offre_titre'] ?? null,
        'application_type' => $row['application_type'] ?? $row['offer_department'] ?? null,
        'first_name' => $row['prenom'] ?? $row['first_name'] ?? '',
        'last_name' => $row['nom'] ?? $row['last_name'] ?? '',
        'email' => $row['email'] ?? '',
        'phone' => $row['telephone'] ?? $row['phone'] ?? '',
        'cover_letter_text' => $row['lettre_motivation'] ?? $row['cover_letter_text'] ?? null,
        'cv_filename' => $row['cv_filename'] ?? '',
        'contract_or_expertise' => $row['experience_candidat'] ?? $row['contract_or_expertise'] ?? '',
        'statut' => $row['statut'] ?? $row['status'] ?? 'recue',
        'created_at' => $row['created_at'] ?? null,
    ];
}
