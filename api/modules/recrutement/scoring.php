<?php
/**
 * scoring.php — Moteur de score d'affinité 0–100
 */

require_once __DIR__ . '/spec_mappers.php';
require_once __DIR__ . '/site_fields.php';
require_once __DIR__ . '/site_scope.php';

function recrutementPersistCandidatureScore(PDO $db, string $table, int $id, int $score, ?array $detail): void
{
    $allowed = ['candidatures_externes', 'candidatures'];
    if (!in_array($table, $allowed, true)) {
        return;
    }
    if (!recrutementTableHasColumn($db, $table, 'score_nexytal')) {
        return;
    }
    $hasDetail = recrutementTableHasColumn($db, $table, 'score_detail_json');
    if ($hasDetail) {
        $db->prepare("UPDATE {$table} SET score_nexytal = :s, score_detail_json = :d WHERE id = :id")
            ->execute([':s' => $score, ':d' => specEncodeJson($detail), ':id' => $id]);
    } else {
        $db->prepare("UPDATE {$table} SET score_nexytal = :s WHERE id = :id")
            ->execute([':s' => $score, ':id' => $id]);
    }
}

function recrutementExperienceMinToYears(?string $exp): ?int
{
    return match ($exp) {
        'debutant' => 0,
        '1-2' => 1,
        '3-5' => 3,
        '5-10' => 5,
        '10+' => 10,
        default => null,
    };
}

function recrutementGetScoringConfig(PDO $db, ?int $siteId = null): array
{
    if ($siteId !== null) {
        $stmt = $db->prepare('SELECT * FROM recrutement_scoring_config WHERE site_id = :sid LIMIT 1');
        $stmt->execute([':sid' => $siteId]);
        $row = $stmt->fetch();
        if ($row) {
            return recrutementNormalizeScoringConfig($row);
        }
    }

    $stmt = $db->query('SELECT * FROM recrutement_scoring_config WHERE site_id IS NULL LIMIT 1');
    $row = $stmt->fetch();
    if ($row) {
        return recrutementNormalizeScoringConfig($row);
    }

    return [
        'poids_competences' => 40,
        'poids_experience' => 25,
        'poids_localisation' => 15,
        'poids_diplome' => 12,
        'poids_langues' => 8,
        'bonus_champs_site' => 10,
    ];
}

function recrutementNormalizeScoringConfig(array $row): array
{
    return [
        'poids_competences' => (int) ($row['poids_competences'] ?? 40),
        'poids_experience' => (int) ($row['poids_experience'] ?? 25),
        'poids_localisation' => (int) ($row['poids_localisation'] ?? 15),
        'poids_diplome' => (int) ($row['poids_diplome'] ?? 12),
        'poids_langues' => (int) ($row['poids_langues'] ?? 8),
        'bonus_champs_site' => (int) ($row['bonus_champs_site'] ?? 10),
    ];
}

function recrutementNormalizeStringList(mixed $value): array
{
    if (is_array($value)) {
        return array_values(array_filter(array_map(fn ($v) => mb_strtolower(trim((string) $v)), $value)));
    }
    if (is_string($value) && $value !== '') {
        return array_values(array_filter(array_map('mb_strtolower', array_map('trim', preg_split('/[,;]+/', $value)))));
    }
    return [];
}

function recrutementListOverlapScore(array $required, array $candidate): float
{
    if ($required === []) {
        return 1.0;
    }
    $required = recrutementNormalizeStringList($required);
    $candidate = recrutementNormalizeStringList($candidate);
    if ($candidate === []) {
        return 0.0;
    }
    $matched = count(array_intersect($required, $candidate));
    return min(1.0, $matched / count($required));
}

function recrutementLoadOfferCompetenceLabels(PDO $db, int $offreId): array
{
    $stmt = $db->prepare(
        'SELECT c.label FROM competences c
         INNER JOIN offre_competences oc ON c.id = oc.competence_id
         WHERE oc.offre_id = :id'
    );
    $stmt->execute([':id' => $offreId]);
    return array_column($stmt->fetchAll(), 'label');
}

function recrutementBuildOfferCriteria(array $offer, PDO $db): array
{
    $criteres = specDecodeJson($offer['criteres_json'] ?? null) ?? [];
    $fromTable = recrutementLoadOfferCompetenceLabels($db, (int) $offer['id']);
    $fromJson = recrutementNormalizeStringList($criteres['competences'] ?? []);
    $competences = array_values(array_unique(array_merge($fromTable, $fromJson)));

    return [
        'competences' => $competences,
        'experience_min' => $criteres['experience_min'] ?? $offer['experience_min'] ?? null,
        'niveau_etudes' => $criteres['niveau_etudes'] ?? null,
        'langues' => $criteres['langues'] ?? [],
        'ville' => $offer['ville'] ?? null,
        'teletravail' => $criteres['mode_travail'] ?? $offer['teletravail'] ?? null,
        'mobilite' => $criteres['mobilite'] ?? null,
        'champs_specifiques' => $criteres['champs_specifiques'] ?? [],
    ];
}

function recrutementComputeAffinityScore(array $offer, array $candidateProfile, array $config): array
{
    $criteria = $offer['_criteria'] ?? $offer;

    $compScore = recrutementListOverlapScore(
        $criteria['competences'] ?? [],
        $candidateProfile['competences'] ?? []
    );
    $compPoints = round($compScore * (int) $config['poids_competences']);

    $expMin = recrutementExperienceMinToYears($criteria['experience_min'] ?? null);
    $candExp = isset($candidateProfile['experience_annees']) ? (int) $candidateProfile['experience_annees'] : null;
    $expScore = 0.0;
    if ($expMin === null) {
        $expScore = 1.0;
    } elseif ($candExp !== null) {
        $expScore = $candExp >= $expMin ? 1.0 : max(0, $candExp / max(1, $expMin));
    }
    $expPoints = round($expScore * (int) $config['poids_experience']);

    $locScore = 0.0;
    $locFactors = 0;
    $offerVille = mb_strtolower(trim((string) ($criteria['ville'] ?? '')));
    $candVille = mb_strtolower(trim((string) ($candidateProfile['ville'] ?? '')));
    if ($offerVille !== '') {
        $locFactors++;
        if ($candVille !== '' && ($offerVille === $candVille || str_contains($candVille, $offerVille) || str_contains($offerVille, $candVille))) {
            $locScore += 1.0;
        }
    }
    $offerRemote = $criteria['teletravail'] ?? null;
    $candRemote = $candidateProfile['teletravail'] ?? null;
    if ($offerRemote !== null && $offerRemote !== '') {
        $locFactors++;
        if ($candRemote === null || $candRemote === '' || $candRemote === $offerRemote || $offerRemote === 'partiel' || $candRemote === 'total') {
            $locScore += 1.0;
        } elseif ($offerRemote === 'total' && $candRemote === 'partiel') {
            $locScore += 0.5;
        }
    }
    if ($locFactors === 0) {
        $locScore = 1.0;
    } else {
        $locScore /= $locFactors;
    }
    $locPoints = round($locScore * (int) $config['poids_localisation']);

    $reqDiplome = mb_strtolower(trim((string) ($criteria['niveau_etudes'] ?? '')));
    $candDiplome = mb_strtolower(trim((string) ($candidateProfile['niveau_etudes'] ?? '')));
    $diplScore = $reqDiplome === '' ? 1.0 : ($candDiplome !== '' && ($reqDiplome === $candDiplome || str_contains($candDiplome, $reqDiplome)) ? 1.0 : 0.0);
    $diplPoints = round($diplScore * (int) $config['poids_diplome']);

    $langScore = recrutementListOverlapScore($criteria['langues'] ?? [], $candidateProfile['langues'] ?? []);
    $langPoints = round($langScore * (int) $config['poids_langues']);

    $bonusMax = (int) $config['bonus_champs_site'];
    $bonusPoints = 0;
    $offerSpec = is_array($criteria['champs_specifiques'] ?? null) ? $criteria['champs_specifiques'] : [];
    $candSpec = is_array($candidateProfile['champs_specifiques'] ?? null) ? $candidateProfile['champs_specifiques'] : [];
    $specMatched = [];
    $specMissing = [];
    if ($offerSpec !== []) {
        $filled = 0;
        foreach ($offerSpec as $key => $expected) {
            $cVal = $candSpec[$key] ?? null;
            if ($cVal !== null && $cVal !== '') {
                $filled++;
                $specMatched[] = $key;
            } else {
                $specMissing[] = $key;
            }
        }
        $bonusPoints = (int) round(($filled / count($offerSpec)) * $bonusMax);
    } else {
        $bonusPoints = min($bonusMax, count(array_filter($candSpec)) > 0 ? $bonusMax : 0);
    }

    $total = min(100, $compPoints + $expPoints + $locPoints + $diplPoints + $langPoints + $bonusPoints);

    return [
        'score' => $total,
        'detail' => [
            'competences' => ['score' => $compPoints, 'max' => (int) $config['poids_competences'], 'matched' => $compScore >= 0.5],
            'experience' => ['score' => $expPoints, 'max' => (int) $config['poids_experience'], 'matched' => $expScore >= 0.5],
            'localisation' => ['score' => $locPoints, 'max' => (int) $config['poids_localisation'], 'matched' => $locScore >= 0.5],
            'diplome' => ['score' => $diplPoints, 'max' => (int) $config['poids_diplome'], 'matched' => $diplScore >= 0.5],
            'langues' => ['score' => $langPoints, 'max' => (int) $config['poids_langues'], 'matched' => $langScore >= 0.5],
            'bonus_site' => ['score' => $bonusPoints, 'max' => $bonusMax, 'matched' => $specMatched, 'missing' => $specMissing],
        ],
    ];
}

function recrutementScoreApplication(PDO $db, int $offreId, array $candidateProfile): array
{
    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $offreId]);
    $offer = $stmt->fetch();
    if (!$offer) {
        return ['score' => 0, 'detail' => []];
    }

    $config = recrutementGetScoringConfig($db, (int) $offer['site_id']);
    $criteria = recrutementBuildOfferCriteria($offer, $db);
    $offer['_criteria'] = $criteria;

    return recrutementComputeAffinityScore($offer, $candidateProfile, $config);
}

function recrutementRecalculateOfferScores(PDO $db, int $offreId): int
{
    $stmt = $db->prepare('SELECT * FROM offres_emploi WHERE id = :id LIMIT 1');
    $stmt->execute([':id' => $offreId]);
    $offer = $stmt->fetch();
    if (!$offer) {
        return 0;
    }

    $config = recrutementGetScoringConfig($db, (int) $offer['site_id']);
    $criteria = recrutementBuildOfferCriteria($offer, $db);
    $offer['_criteria'] = $criteria;
    $count = 0;

    $stmtExt = $db->prepare('SELECT * FROM candidatures_externes WHERE offre_id = :oid');
    $stmtExt->execute([':oid' => $offreId]);
    foreach ($stmtExt->fetchAll() as $row) {
        $compReponses = specDecodeJson($row['competences_reponses'] ?? null);
        $competences = [];
        if (is_array($compReponses)) {
            if (array_is_list($compReponses)) {
                $competences = $compReponses;
            } else {
                $competences = array_values(array_filter(array_map(
                    fn ($v, $k) => is_string($v) ? $v : (is_array($v) ? ($v['competence'] ?? $v['label'] ?? $k) : $k),
                    $compReponses,
                    array_keys($compReponses)
                )));
            }
        }
        $legacyChamps = specDecodeJson($row['champs_specifiques_json'] ?? null) ?? [];
        if ($competences === [] && isset($legacyChamps['competences'])) {
            $competences = (array) $legacyChamps['competences'];
        }

        $profile = recrutementCandidateProfileFromPayload(array_merge($row, [
            'competences' => $competences,
            'experience_candidat' => $row['experience_candidat'] ?? null,
            'champs_specifiques' => $legacyChamps,
        ]));
        if (!empty($row['experience_candidat']) && function_exists('recrutementExperienceMinToYears')) {
            $profile['experience_annees'] = recrutementExperienceMinToYears($row['experience_candidat']);
        } else {
            $profile['experience_annees'] = $row['experience_annees'] ?? null;
        }
        $profile['niveau_etudes'] = $row['niveau_etudes'] ?? null;
        $result = recrutementComputeAffinityScore($offer, $profile, $config);
        recrutementPersistCandidatureScore($db, 'candidatures_externes', (int) $row['id'], $result['score'], $result['detail']);
        $count++;
    }

    $stmtInt = $db->prepare(
        'SELECT c.*, cand.experience_annees, cand.niveau_etudes, cand.champs_specifiques_json, cand.ville
         FROM candidatures c
         INNER JOIN candidats cand ON c.candidat_id = cand.id
         WHERE c.offre_id = :oid'
    );
    $stmtInt->execute([':oid' => $offreId]);
    foreach ($stmtInt->fetchAll() as $row) {
        $profile = [
            'ville' => $row['ville'] ?? null,
            'experience_annees' => $row['experience_annees'] ?? null,
            'niveau_etudes' => $row['niveau_etudes'] ?? null,
            'competences' => [],
            'langues' => [],
            'champs_specifiques' => specDecodeJson($row['champs_specifiques_json'] ?? null) ?? [],
        ];
        $result = recrutementComputeAffinityScore($offer, $profile, $config);
        recrutementPersistCandidatureScore($db, 'candidatures', (int) $row['id'], $result['score'], $result['detail']);
        $count++;
    }

    return $count;
}

function registerRecrutementScoringRoutes(Router $router): void
{
    // Scoring is invoked from other modules; no standalone routes in v1
}
