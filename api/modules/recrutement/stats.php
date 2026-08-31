<?php
/**
 * stats.php — Statistiques recrutement (dashboard admin) — aligné bdd.sql
 */

require_once __DIR__ . '/site_scope.php';

function recrutementStatsHandler(): void
{
    Middleware::requireRole(['superadmin', 'admin']);
    $db = getDb();
    $siteId = Router::getQueryParam('site_id');
    $siteFilter = '';
    $bind = [];
    if ($siteId !== null && $siteId !== '') {
        $siteFilter = ' AND site_id = :site_id';
        $bind[':site_id'] = (int) $siteId;
    }

    $monthStart = date('Y-m-01 00:00:00');
    $todayStart = date('Y-m-d 00:00:00');

    $stmt = $db->prepare(
        "SELECT statut, COUNT(*) as cnt FROM offres_emploi
         WHERE created_at >= :month $siteFilter GROUP BY statut"
    );
    $stmt->execute(array_merge([':month' => $monthStart], $bind));
    $offersByStatus = [];
    foreach ($stmt->fetchAll() as $row) {
        $offersByStatus[$row['statut']] = (int) $row['cnt'];
    }

    $stmt = $db->prepare(
        "SELECT COUNT(*) as cnt FROM candidatures_externes ce
         INNER JOIN offres_emploi o ON ce.offre_id = o.id
         WHERE ce.created_at >= :today" . ($siteFilter ? str_replace('site_id', 'o.site_id', $siteFilter) : '')
    );
    $stmt->execute(array_merge([':today' => $todayStart], $bind));
    $extToday = (int) $stmt->fetch()['cnt'];

    $stmt = $db->prepare(
        "SELECT COUNT(*) as cnt FROM candidatures c
         INNER JOIN offres_emploi o ON c.offre_id = o.id
         WHERE c.date_candidature >= :today" . ($siteFilter ? str_replace('site_id', 'o.site_id', $siteFilter) : '')
    );
    $stmt->execute(array_merge([':today' => $todayStart], $bind));
    $intToday = (int) $stmt->fetch()['cnt'];

    $avgScore = 0.0;
    $hasExtScore = recrutementTableHasColumn($db, 'candidatures_externes', 'score_nexytal');
    $hasIntScore = recrutementTableHasColumn($db, 'candidatures', 'score_nexytal');
    if ($hasExtScore || $hasIntScore) {
        $parts = [];
        if ($hasExtScore) {
            $parts[] = "SELECT ce.score_nexytal as score FROM candidatures_externes ce
                INNER JOIN offres_emploi o ON ce.offre_id = o.id
                WHERE ce.score_nexytal IS NOT NULL" . ($siteFilter ? str_replace('site_id', 'o.site_id', $siteFilter) : '');
        }
        if ($hasIntScore) {
            $parts[] = "SELECT c.score_nexytal as score FROM candidatures c
                INNER JOIN offres_emploi o ON c.offre_id = o.id
                WHERE c.score_nexytal IS NOT NULL" . ($siteFilter ? str_replace('site_id', 'o.site_id', $siteFilter) : '');
        }
        if ($parts !== []) {
            $avgSql = 'SELECT AVG(score) as avg_score FROM (' . implode(' UNION ALL ', $parts) . ') t';
            $stmt = $db->prepare($avgSql);
            $stmt->execute($bind);
            $avgScore = round((float) ($stmt->fetch()['avg_score'] ?? 0), 1);
        }
    }

    $days = (int) (Router::getQueryParam('days') ?? 30);
    $days = max(7, min(90, $days));
    $since = date('Y-m-d 00:00:00', strtotime("-{$days} days"));

    $stmt = $db->prepare(
        "SELECT o.site_id, s.name as site_name, COUNT(*) as cnt
         FROM offres_emploi o
         INNER JOIN core_sites s ON o.site_id = s.id
         WHERE o.created_at >= :since AND o.statut IN ('publiee','brouillon')
         GROUP BY o.site_id, s.name ORDER BY cnt DESC"
    );
    $stmt->execute([':since' => $since]);
    $offersPerSite = $stmt->fetchAll();

    $stmtPending = $db->prepare(
        "SELECT COUNT(*) as cnt FROM offres_emploi o
         WHERE o.statut = 'brouillon' AND o.recruteur_id IS NOT NULL
         AND o.created_at >= :month" . ($siteFilter ? str_replace('site_id', 'o.site_id', $siteFilter) : '')
    );
    $stmtPending->execute(array_merge([':month' => $monthStart], $bind));
    $pendingCount = (int) $stmtPending->fetch()['cnt'];

    Response::success([
        'offers_this_month' => [
            'pending' => $pendingCount,
            'published' => $offersByStatus['publiee'] ?? 0,
            'rejected' => $offersByStatus['archivee'] ?? 0,
        ],
        'applications_today' => $extToday + $intToday,
        'average_affinity_score' => $avgScore,
        'offers_per_site' => array_map(fn ($r) => [
            'site_id' => (int) $r['site_id'],
            'site_name' => $r['site_name'],
            'count' => (int) $r['cnt'],
        ], $offersPerSite),
        'period_days' => $days,
    ]);
}

function registerRecrutementStatsRoutes(Router $router): void
{
    $router->get('/api/admin/recrutement/stats', function () {
        recrutementStatsHandler();
    });

    $router->get('/api/stats', function () {
        recrutementStatsHandler();
    });
}
