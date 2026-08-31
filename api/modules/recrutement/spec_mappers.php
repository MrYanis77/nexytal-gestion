<?php
/**
 * spec_mappers.php — Traduction statuts spec EN ↔ FR interne
 */

function specOfferStatusToFr(string $status): string
{
    $map = [
        'pending' => 'brouillon',
        'published' => 'publiee',
        'rejected' => 'archivee',
        'draft' => 'brouillon',
    ];
    return $map[strtolower($status)] ?? $status;
}

function specOfferStatusFromFr(string $statut): string
{
    $map = [
        'brouillon' => 'draft',
        'publiee' => 'published',
        'archivee' => 'rejected',
        'pourvue' => 'filled',
        'expiree' => 'expired',
    ];
    return $map[$statut] ?? $statut;
}

function specCandidatureStatusToFr(string $status): string
{
    $map = [
        'new' => 'recue',
        'viewed' => 'vue',
        'shortlisted' => 'shortlist',
        'rejected' => 'refusee',
        'interview' => 'entretien',
        'offer' => 'offre',
    ];
    return $map[strtolower($status)] ?? $status;
}

function specCandidatureStatusFromFr(string $statut): string
{
    $map = [
        'recue' => 'new',
        'vue' => 'viewed',
        'shortlist' => 'shortlisted',
        'entretien' => 'interview',
        'offre' => 'offer',
        'refusee' => 'rejected',
        'retiree' => 'withdrawn',
    ];
    return $map[$statut] ?? $statut;
}

function specSiteSlugFromId(int $siteId): string
{
    $map = [
        1 => 'alt-formation',
        2 => 'nexytal-recrutement',
        3 => 'nexytal-medical',
        4 => 'nexytal-carriere',
        5 => 'nexytal-trainer',
        6 => 'nexytal-coaching',
    ];
    return $map[$siteId] ?? 'unknown';
}

function specOfferToSpec(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'title' => $row['titre'] ?? '',
        'company' => $row['entreprise_nom'] ?? '',
        'site_origin' => specSiteSlugFromId((int) ($row['site_id'] ?? 0)),
        'contract_type' => $row['type_contrat'] ?? null,
        'location' => $row['ville'] ?? null,
        'salary_min' => isset($row['salaire_min']) ? (int) $row['salaire_min'] : null,
        'salary_max' => isset($row['salaire_max']) ? (int) $row['salaire_max'] : null,
        'availability' => $row['disponibilite'] ?? null,
        'description' => $row['description'] ?? '',
        'status' => specOfferStatusFromFr((string) ($row['statut'] ?? 'brouillon')),
        'created_at' => $row['created_at'] ?? null,
        'published_at' => $row['date_publication'] ?? null,
        'recruiter_id' => isset($row['recruteur_id']) ? (int) $row['recruteur_id'] : null,
        'criteria' => specDecodeJson($row['criteres_json'] ?? null),
    ];
}

function specCandidatureToSpec(array $row, string $type = 'external'): array
{
    $name = $type === 'internal'
        ? trim(($row['candidat_prenom'] ?? '') . ' ' . ($row['candidat_nom'] ?? ''))
        : trim(($row['prenom'] ?? '') . ' ' . ($row['nom'] ?? ''));

    return [
        'id' => (int) $row['id'],
        'offer_id' => (int) ($row['offre_id'] ?? 0),
        'candidate_name' => $name,
        'email' => $row['email'] ?? $row['candidat_email'] ?? null,
        'affinity_score' => isset($row['score_nexytal']) ? (int) $row['score_nexytal'] : (isset($row['score_affinite']) ? (int) $row['score_affinite'] : null),
        'score_detail' => specDecodeJson($row['score_detail_json'] ?? null),
        'status' => specCandidatureStatusFromFr((string) ($row['statut'] ?? 'recue')),
        'created_at' => $row['date_candidature'] ?? $row['created_at'] ?? null,
        'type' => $type,
    ];
}

function specDecodeJson(mixed $value): ?array
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_array($value)) {
        return $value;
    }
    $decoded = json_decode((string) $value, true);
    return is_array($decoded) ? $decoded : null;
}

function specEncodeJson(?array $data): ?string
{
    return $data === null ? null : json_encode($data, JSON_UNESCAPED_UNICODE);
}
