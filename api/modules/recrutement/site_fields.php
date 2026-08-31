<?php
/**
 * site_fields.php — Champs spécifiques par site (formulaires employeur / candidat)
 */

function recrutementSiteSpecificOfferFields(int $siteId): array
{
    return match ($siteId) {
        6 => ['specialite_coaching', 'certifications_requises'],
        3 => ['specialite_medicale', 'rpps_requis'],
        2 => ['secteur_recrutement', 'volume_postes'],
        4 => ['type_accompagnement', 'duree_mission'],
        5 => ['domaine_formation', 'certification_formateur'],
        1 => ['type_formation', 'eligibilite_cpf', 'qualiopi'],
        default => [],
    };
}

function recrutementExtractSiteSpecificFields(int $siteId, array $data): array
{
    $keys = recrutementSiteSpecificOfferFields($siteId);
    $out = [];
    foreach ($keys as $key) {
        if (array_key_exists($key, $data) && $data[$key] !== null && $data[$key] !== '') {
            $out[$key] = $data[$key];
        }
    }
    return $out;
}

function recrutementBuildCriteresFromPayload(int $siteId, array $data): array
{
    $criteres = [
        'competences' => $data['competences'] ?? $data['competences_cles'] ?? [],
        'experience_min' => $data['experience_min'] ?? null,
        'niveau_etudes' => $data['niveau_etudes'] ?? $data['niveau_etudes_minimum'] ?? null,
        'langues' => $data['langues'] ?? $data['langues_requises'] ?? [],
        'mode_travail' => $data['teletravail'] ?? $data['mode_travail'] ?? null,
        'mobilite' => $data['mobilite'] ?? null,
        'disponibilite' => $data['disponibilite'] ?? null,
    ];

    if (is_string($criteres['competences'])) {
        $criteres['competences'] = array_values(array_filter(array_map('trim', preg_split('/[,;]+/', $criteres['competences']))));
    }
    if (is_string($criteres['langues'])) {
        $criteres['langues'] = array_values(array_filter(array_map('trim', preg_split('/[,;]+/', $criteres['langues']))));
    }

    $spec = recrutementExtractSiteSpecificFields($siteId, $data);
    if ($spec !== []) {
        $criteres['champs_specifiques'] = $spec;
    }

    return array_filter($criteres, fn ($v) => $v !== null && $v !== '' && $v !== []);
}

function recrutementCandidateProfileFromPayload(array $data): array
{
    $competences = $data['competences'] ?? [];
    if (is_string($competences)) {
        $competences = array_values(array_filter(array_map('trim', preg_split('/[,;]+/', $competences))));
    }
    $langues = $data['langues'] ?? $data['langues_maitrisees'] ?? [];
    if (is_string($langues)) {
        $langues = array_values(array_filter(array_map('trim', preg_split('/[,;]+/', $langues))));
    }

    return [
        'prenom' => $data['first_name'] ?? $data['prenom'] ?? '',
        'nom' => $data['last_name'] ?? $data['nom'] ?? '',
        'email' => $data['email'] ?? '',
        'telephone' => $data['phone'] ?? $data['telephone'] ?? null,
        'ville' => $data['ville'] ?? $data['location'] ?? null,
        'disponibilite' => $data['disponibilite'] ?? $data['availability'] ?? null,
        'experience_candidat' => $data['experience_candidat'] ?? $data['experience_min'] ?? null,
        'experience_annees' => isset($data['experience_annees']) ? (int) $data['experience_annees'] : null,
        'niveau_etudes' => $data['niveau_etudes'] ?? null,
        'competences' => $competences,
        'competences_reponses' => $data['competences_reponses'] ?? null,
        'langues' => $langues,
        'teletravail' => $data['mode_travail_souhaite'] ?? $data['teletravail'] ?? null,
        'mobilite' => $data['mobilite'] ?? null,
        'cv_filename' => $data['cv_filename'] ?? $data['cv_url'] ?? null,
        'cv_url' => $data['cv_url'] ?? $data['cv_filename'] ?? null,
        'champs_specifiques' => $data['champs_specifiques'] ?? $data['champs_specifiques_json'] ?? [],
    ];
}
