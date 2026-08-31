<?php
/**
 * gestion_candidatures.php — Vue v_gestion_candidatures (prod Ionos)
 */

function gestionCandidaturesViewExists(PDO $db): bool
{
    static $exists = null;
    if ($exists !== null) {
        return $exists;
    }

    try {
        $db->query('SELECT 1 FROM v_gestion_candidatures LIMIT 1');
        $exists = true;
    } catch (\Throwable $e) {
        $exists = false;
    }

    return $exists;
}

function gestionCandidaturesNormalizeRow(array $row): array
{
    $id = (int) ($row['candidature_id'] ?? $row['id'] ?? 0);

    return [
        'id' => $id,
        'candidature_id' => $id,
        'type' => (string) ($row['type'] ?? 'externe'),
        'site_id' => isset($row['site_id']) ? (int) $row['site_id'] : null,
        'site_code' => $row['site_code'] ?? null,
        'site_name' => $row['site_name'] ?? null,
        'offre_id' => isset($row['offre_id']) ? (int) $row['offre_id'] : null,
        'offre_titre' => $row['offre_titre'] ?? null,
        'offre_statut' => $row['offre_statut'] ?? null,
        'recruteur_id' => isset($row['recruteur_id']) ? (int) $row['recruteur_id'] : null,
        'entreprise_nom' => $row['entreprise_nom'] ?? null,
        'recruteur_email' => $row['recruteur_email'] ?? null,
        'prenom' => $row['prenom'] ?? '',
        'nom' => $row['nom'] ?? '',
        'email' => $row['candidat_email'] ?? $row['email'] ?? '',
        'telephone' => $row['telephone'] ?? null,
        'lettre_motivation' => $row['message'] ?? $row['lettre_motivation'] ?? null,
        'cv_filename' => $row['cv_filename'] ?? null,
        'experience_candidat' => $row['experience_candidat'] ?? null,
        'competences_reponses' => $row['competences_reponses'] ?? null,
        'disponibilite' => $row['disponibilite'] ?? null,
        'statut' => $row['statut'] ?? 'recue',

        'date_candidature' => $row['date_candidature'] ?? $row['created_at'] ?? null,
        'created_at' => $row['date_candidature'] ?? $row['created_at'] ?? null,
    ];
}

function gestionCandidaturesList(PDO $db, array $filters = []): array
{
    if (!gestionCandidaturesViewExists($db)) {
        return gestionCandidaturesListFallback($db, $filters);
    }

    $where = [];
    $params = [];

    if (!empty($filters['site_id'])) {
        $where[] = 'site_id = :site_id';
        $params[':site_id'] = (int) $filters['site_id'];
    }

    if (!empty($filters['offre_id'])) {
        $where[] = 'offre_id = :offre_id';
        $params[':offre_id'] = (int) $filters['offre_id'];
    }



    if (!empty($filters['type'])) {
        $where[] = 'type = :type';
        $params[':type'] = $filters['type'] === 'interne' ? 'interne' : 'externe';
    }

    $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';
    $limit = min(500, max(1, (int) ($filters['limit'] ?? 500)));

    $stmt = $db->prepare(
        "SELECT * FROM v_gestion_candidatures $whereClause ORDER BY date_candidature DESC LIMIT $limit"
    );
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->execute();

    return array_map('gestionCandidaturesNormalizeRow', $stmt->fetchAll(PDO::FETCH_ASSOC));
}

function gestionCandidaturesListFallback(PDO $db, array $filters = []): array
{
    $rows = [];

    $where = [];
    $params = [];
    if (!empty($filters['site_id'])) {
        $where[] = '(COALESCE(ce.site_id, o.site_id) = :site_id)';
        $params[':site_id'] = (int) $filters['site_id'];
    }
    if (!empty($filters['offre_id'])) {
        $where[] = 'ce.offre_id = :offre_id';
        $params[':offre_id'] = (int) $filters['offre_id'];
    }

    $whereClause = $where ? 'WHERE ' . implode(' AND ', $where) : '';

    $stmt = $db->prepare(
        "SELECT 'externe' AS type, ce.id AS candidature_id, ce.*, o.titre AS offre_titre,
                s.name AS site_name, ce.lettre_motivation AS message, ce.created_at AS date_candidature
         FROM candidatures_externes ce
         LEFT JOIN offres_emploi o ON o.id = ce.offre_id
         LEFT JOIN core_sites s ON s.id = COALESCE(ce.site_id, o.site_id)
         $whereClause ORDER BY ce.created_at DESC LIMIT 500"
    );
    foreach ($params as $k => $v) {
        $stmt->bindValue($k, $v);
    }
    $stmt->execute();
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $row['candidat_email'] = $row['email'] ?? '';
        $rows[] = gestionCandidaturesNormalizeRow($row);
    }

    if (empty($filters['type']) || $filters['type'] === 'interne') {
        $whereInt = [];
        $paramsInt = [];
        if (!empty($filters['site_id'])) {
            $whereInt[] = 'o.site_id = :site_id';
            $paramsInt[':site_id'] = (int) $filters['site_id'];
        }
        if (!empty($filters['offre_id'])) {
            $whereInt[] = 'c.offre_id = :offre_id';
            $paramsInt[':offre_id'] = (int) $filters['offre_id'];
        }

        $whereIntClause = $whereInt ? 'WHERE ' . implode(' AND ', $whereInt) : '';

        $stmt = $db->prepare(
            "SELECT 'interne' AS type, c.id AS candidature_id, c.*, o.titre AS offre_titre, o.site_id,
                    s.name AS site_name, ca.prenom, ca.nom, u.email AS candidat_email, ca.telephone,
                    ca.cv_filename, c.message_motivation AS message, c.date_candidature
             FROM candidatures c
             INNER JOIN candidats ca ON ca.id = c.candidat_id
             LEFT JOIN users u ON u.id = ca.user_id
             INNER JOIN offres_emploi o ON o.id = c.offre_id
             LEFT JOIN core_sites s ON s.id = o.site_id
             $whereIntClause ORDER BY c.date_candidature DESC LIMIT 500"
        );
        foreach ($paramsInt as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        $stmt->execute();
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $rows[] = gestionCandidaturesNormalizeRow($row);
        }
    }

    usort($rows, fn ($a, $b) => strcmp((string) ($b['date_candidature'] ?? ''), (string) ($a['date_candidature'] ?? '')));

    return $rows;
}


