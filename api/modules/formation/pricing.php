<?php
/**
 * modules/formation/pricing.php — CRUD site_pricing (tarifs par site)
 */

function formationParseAmountEur(mixed $value): ?float
{
    if ($value === null || $value === '') {
        return null;
    }
    if (is_int($value) || is_float($value)) {
        return round((float) $value, 2);
    }

    $s = trim((string) $value);
    $s = str_replace(["\xc2\xa0", ' '], '', $s);

    if ($s === '') {
        return null;
    }

    if (preg_match('/^\d{1,3}(\.\d{3})+(,\d+)?$/', $s)) {
        $s = str_replace('.', '', $s);
        $s = str_replace(',', '.', $s);
    } else {
        $s = str_replace(',', '.', $s);
    }

    if (!is_numeric($s)) {
        return null;
    }

    return round((float) $s, 2);
}

function formationPricingRowToApi(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'site_id' => (int) $row['site_id'],
        'amount_eur' => round((float) $row['amount_eur'], 2),
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
    ];
}

function registerFormationPricingRoutes(Router $router): void
{
    $router->get('/api/admin/formation/pricing', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, site_id, amount_eur, created_at, updated_at
             FROM site_pricing
             WHERE site_id = :site_id
             ORDER BY id ASC'
        );
        $stmt->execute([':site_id' => $siteId]);
        $rows = array_map('formationPricingRowToApi', $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::success($rows);
    });

    $router->post('/api/admin/formation/pricing', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();

        Validator::make($data)
            ->required('amount_eur', 'Montant')
            ->validate();

        $db = getDb();
        $amount = formationParseAmountEur($data['amount_eur'] ?? null);
        if ($amount === null) {
            Response::badRequest('Montant invalide');
            return;
        }

        $stmt = $db->prepare(
            'INSERT INTO site_pricing (site_id, amount_eur, created_at)
             VALUES (:site_id, :amount_eur, NOW())'
        );
        $stmt->execute([
            ':site_id' => $siteId,
            ':amount_eur' => $amount,
        ]);

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'site_pricing', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/formation/pricing/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM site_pricing WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Tarif introuvable');
            return;
        }

        if (!array_key_exists('amount_eur', $data)) {
            Response::badRequest('Montant requis');
            return;
        }

        $amount = formationParseAmountEur($data['amount_eur']);
        if ($amount === null) {
            Response::badRequest('Montant invalide');
            return;
        }

        $stmt = $db->prepare(
            'UPDATE site_pricing SET amount_eur = :amount_eur, updated_at = NOW()
             WHERE id = :id AND site_id = :site_id'
        );
        $stmt->execute([
            ':amount_eur' => $amount,
            ':id' => $id,
            ':site_id' => $siteId,
        ]);

        Audit::log((int) $admin['id'], $siteId, 'update', 'site_pricing', $id, $old, $data);
        Response::success(['id' => $id], 'Tarif mis à jour');
    });

    $router->delete('/api/admin/formation/pricing/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM site_pricing WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Tarif introuvable');
            return;
        }

        $stmt = $db->prepare('DELETE FROM site_pricing WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'site_pricing', $id, $old, null);
        Response::noContent();
    });
}
