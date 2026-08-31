<?php
/**
 * candidature_externe_helpers.php — Insert / normalisation candidatures_externes (bdd.sql)
 */

require_once __DIR__ . '/site_scope.php';
require_once __DIR__ . '/spec_mappers.php';
require_once __DIR__ . '/scoring.php';

function candidatureExterneValidExperience(?string $value): ?string
{
    if ($value === null || $value === '') {
        return null;
    }
    $allowed = ['debutant', '1-2', '3-5', '5-10', '10+'];
    $value = trim($value);
    if (in_array($value, $allowed, true)) {
        return $value;
    }
    if (is_numeric($value)) {
        $years = (int) $value;
        if ($years <= 0) {
            return 'debutant';
        }
        if ($years <= 2) {
            return '1-2';
        }
        if ($years <= 5) {
            return '3-5';
        }
        if ($years <= 10) {
            return '5-10';
        }
        return '10+';
    }

    return null;
}

function candidatureExterneNormalizeCompetencesReponses(mixed $value): ?string
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_string($value)) {
        $decoded = json_decode($value, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            $value = $decoded;
        } else {
            $list = array_values(array_filter(array_map('trim', preg_split('/[\n,;]+/', $value))));
            return $list === [] ? null : specEncodeJson($list);
        }
    }
    if (!is_array($value)) {
        return null;
    }

    return specEncodeJson($value);
}

function candidatureExterneResolveCvFilename(array $data): ?string
{
    $cv = $data['cv_filename'] ?? $data['cv_url'] ?? $data['cv_path'] ?? null;
    if ($cv === null || $cv === '') {
        return null;
    }
    $cv = trim((string) $cv);

    return mb_substr($cv, 0, 255);
}

function candidatureExterneResolveSiteId(PDO $db, int $offreId, ?int $fallbackSiteId): int
{
    $stmt = $db->prepare('SELECT site_id FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $offreId]);
    $row = $stmt->fetch();
    if (!$row) {
        Response::badRequest('Offre introuvable');
        exit;
    }

    $siteId = (int) $row['site_id'];
    if ($fallbackSiteId !== null && $fallbackSiteId > 0 && $fallbackSiteId !== $siteId) {
        Response::badRequest('L\'offre n\'appartient pas au site sélectionné');
        exit;
    }

    return $siteId;
}

/**
 * @return array{prenom: string, nom: string, email: string, telephone: ?string, lettre_motivation: ?string, linkedin_url: ?string, cv_filename: ?string, experience_candidat: ?string, competences_reponses: ?string, disponibilite: ?string}
 */
function candidatureExterneFieldsFromPayload(array $data): array
{
    $experience = $data['experience_candidat']
        ?? $data['experience_min']
        ?? (isset($data['experience_annees']) ? candidatureExterneValidExperience((string) $data['experience_annees']) : null);

    $competences = $data['competences_reponses'] ?? $data['competences'] ?? null;

    return [
        'prenom' => trim((string) ($data['prenom'] ?? $data['first_name'] ?? '')),
        'nom' => trim((string) ($data['nom'] ?? $data['last_name'] ?? '')),
        'email' => trim((string) ($data['email'] ?? '')),
        'telephone' => isset($data['telephone']) ? trim((string) $data['telephone']) : (isset($data['phone']) ? trim((string) $data['phone']) : null),
        'lettre_motivation' => $data['lettre_motivation'] ?? $data['message'] ?? $data['cover_letter'] ?? null,
        'linkedin_url' => $data['linkedin_url'] ?? null,
        'cv_filename' => candidatureExterneResolveCvFilename($data),
        'experience_candidat' => candidatureExterneValidExperience(is_string($experience) ? $experience : null),
        'competences_reponses' => candidatureExterneNormalizeCompetencesReponses($competences),
        'disponibilite' => !empty($data['disponibilite']) ? substr((string) $data['disponibilite'], 0, 10) : null,
    ];
}

function candidatureExterneInsert(PDO $db, int $offreId, int $siteId, array $data, ?array $scoreResult = null): int
{
    $fields = candidatureExterneFieldsFromPayload($data);

    $bind = [
        ':oid' => $offreId,
        ':sid' => $siteId,
        ':pre' => $fields['prenom'],
        ':nom' => $fields['nom'],
        ':email' => $fields['email'],
        ':tel' => $fields['telephone'],
        ':lm' => $fields['lettre_motivation'],
        ':li' => $fields['linkedin_url'],
        ':cv' => $fields['cv_filename'],
        ':exp' => $fields['experience_candidat'],
        ':comp' => $fields['competences_reponses'],
        ':dispo' => $fields['disponibilite'],
        ':st' => $data['statut'] ?? 'recue',
    ];

    $columns = [
        'offre_id', 'site_id', 'prenom', 'nom', 'email', 'telephone', 'lettre_motivation', 'linkedin_url',
        'cv_filename', 'experience_candidat', 'competences_reponses', 'disponibilite', 'statut',
    ];
    $placeholders = [
        ':oid', ':sid', ':pre', ':nom', ':email', ':tel', ':lm', ':li',
        ':cv', ':exp', ':comp', ':dispo', ':st',
    ];

    if (recrutementTableHasColumn($db, 'candidatures_externes', 'verifie_nexytal')) {
        $columns[] = 'verifie_nexytal';
        $placeholders[] = '0';
    }
    if (recrutementTableHasColumn($db, 'candidatures_externes', 'score_nexytal')) {
        $columns[] = 'score_nexytal';
        $placeholders[] = ':score';
        $bind[':score'] = $scoreResult !== null ? $scoreResult['score'] : null;
    }

    $columns[] = 'rgpd_consent_at';
    $columns[] = 'created_at';
    $placeholders[] = 'NOW()';
    $placeholders[] = 'NOW()';

    $sql = 'INSERT INTO candidatures_externes (' . implode(', ', $columns) . ') VALUES (' . implode(', ', $placeholders) . ')';

    $stmt = $db->prepare($sql);
    foreach ($bind as $k => $v) {
        if ($k === ':score' && $v === null) {
            $stmt->bindValue($k, null, PDO::PARAM_NULL);
        } else {
            $stmt->bindValue($k, $v);
        }
    }
    $stmt->execute();

    return (int) $db->lastInsertId();
}

function candidatureExterneUpdatableFields(PDO $db): array
{
    $fields = [
        'prenom', 'nom', 'email', 'telephone', 'lettre_motivation', 'linkedin_url',
        'statut',
        'cv_filename', 'experience_candidat', 'competences_reponses', 'disponibilite',
    ];
    foreach (['verifie_nexytal', 'score_nexytal', 'note_nexytal'] as $optional) {
        if (recrutementTableHasColumn($db, 'candidatures_externes', $optional)) {
            $fields[] = $optional;
        }
    }

    return $fields;
}
