<?php
/**
 * modules/settings/pricing_plans.php — CRUD site_pricing_plans (tarifs détaillés par site)
 */

require_once __DIR__ . '/../formation/pricing.php';

const PRICING_PLAN_ENTITY_TYPES = ['formation', 'service', 'coaching', 'trainer', 'other'];
const PRICING_PLAN_BILLING_UNITS = ['forfait', 'heure', 'jour', 'mois', 'session'];

function pricingPlanRowToApi(array $row): array
{
    return [
        'id' => (int) $row['id'],
        'site_id' => (int) $row['site_id'],
        'entity_type' => (string) $row['entity_type'],
        'entity_slug' => (string) $row['entity_slug'],
        'plan_code' => (string) $row['plan_code'],
        'label' => (string) $row['label'],
        'amount_eur' => round((float) $row['amount_eur'], 2),
        'billing_unit' => (string) $row['billing_unit'],
        'description' => $row['description'] ?? null,
        'is_active' => (int) ($row['is_active'] ?? 1) === 1,
        'sort_order' => (int) ($row['sort_order'] ?? 0),
    ];
}

function pricingPlanNormalizeEnum(string $value, array $allowed, string $default): string
{
    $v = strtolower(trim($value));
    return in_array($v, $allowed, true) ? $v : $default;
}

function pricingPlanPayloadFromRequest(array $data, bool $forUpdate = false): array
{
    $entityType = pricingPlanNormalizeEnum((string) ($data['entity_type'] ?? 'service'), PRICING_PLAN_ENTITY_TYPES, 'service');
    $billingUnit = pricingPlanNormalizeEnum((string) ($data['billing_unit'] ?? 'forfait'), PRICING_PLAN_BILLING_UNITS, 'forfait');
    $entitySlug = trim((string) ($data['entity_slug'] ?? ''));
    $planCode = trim((string) ($data['plan_code'] ?? 'default'));
    $label = trim((string) ($data['label'] ?? ''));
    $description = array_key_exists('description', $data)
        ? (trim((string) ($data['description'] ?? '')) ?: null)
        : null;

    if ($entitySlug === '') {
        Response::badRequest('Slug entité requis');
    }
    if ($planCode === '') {
        Response::badRequest('Code plan requis');
    }
    if ($label === '') {
        Response::badRequest('Libellé requis');
    }

    if (!array_key_exists('amount_eur', $data) && !$forUpdate) {
        Response::badRequest('Montant requis');
    }

    $amount = null;
    if (array_key_exists('amount_eur', $data)) {
        $amount = formationParseAmountEur($data['amount_eur']);
        if ($amount === null) {
            Response::badRequest('Montant invalide');
        }
    }

    $isActive = 1;
    if (array_key_exists('is_active', $data)) {
        $isActive = ($data['is_active'] === true || $data['is_active'] === 1 || $data['is_active'] === '1') ? 1 : 0;
    }

    $sortOrder = isset($data['sort_order']) ? (int) $data['sort_order'] : 0;

    $payload = [
        'entity_type' => $entityType,
        'entity_slug' => $entitySlug,
        'plan_code' => $planCode,
        'label' => $label,
        'billing_unit' => $billingUnit,
        'description' => $description,
        'is_active' => $isActive,
        'sort_order' => $sortOrder,
    ];

    if ($amount !== null) {
        $payload['amount_eur'] = $amount;
    }

    return $payload;
}

function registerPricingPlansRoutes(Router $router): void
{
    $router->get('/api/admin/pricing-plans', function () {
        Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();

        $stmt = $db->prepare(
            'SELECT id, site_id, entity_type, entity_slug, plan_code, label, amount_eur,
                    billing_unit, description, is_active, sort_order
             FROM site_pricing_plans
             WHERE site_id = :site_id
             ORDER BY sort_order ASC, id ASC'
        );
        $stmt->execute([':site_id' => $siteId]);
        $rows = array_map('pricingPlanRowToApi', $stmt->fetchAll(PDO::FETCH_ASSOC));
        Response::success($rows);
    });

    $router->post('/api/admin/pricing-plans', function () {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $payload = pricingPlanPayloadFromRequest($data, false);

        if (!isset($payload['amount_eur'])) {
            Response::badRequest('Montant requis');
            return;
        }

        $db = getDb();
        try {
            $stmt = $db->prepare(
                'INSERT INTO site_pricing_plans
                 (site_id, entity_type, entity_slug, plan_code, label, amount_eur, billing_unit, description, is_active, sort_order)
                 VALUES
                 (:site_id, :entity_type, :entity_slug, :plan_code, :label, :amount_eur, :billing_unit, :description, :is_active, :sort_order)'
            );
            $stmt->execute([
                ':site_id' => $siteId,
                ':entity_type' => $payload['entity_type'],
                ':entity_slug' => $payload['entity_slug'],
                ':plan_code' => $payload['plan_code'],
                ':label' => $payload['label'],
                ':amount_eur' => $payload['amount_eur'],
                ':billing_unit' => $payload['billing_unit'],
                ':description' => $payload['description'],
                ':is_active' => $payload['is_active'],
                ':sort_order' => $payload['sort_order'],
            ]);
        } catch (PDOException $e) {
            if ((int) ($e->errorInfo[1] ?? 0) === 1062) {
                Response::badRequest('Un plan avec ce slug et ce code existe déjà pour ce site.');
                return;
            }
            throw $e;
        }

        $newId = (int) $db->lastInsertId();
        Audit::log((int) $admin['id'], $siteId, 'create', 'site_pricing_plans', $newId, null, $data);
        Response::created(['id' => $newId]);
    });

    $router->put('/api/admin/pricing-plans/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin', 'editor']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $data = Router::getJsonBody();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM site_pricing_plans WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Plan tarifaire introuvable');
            return;
        }

        $payload = pricingPlanPayloadFromRequest(array_merge($old, $data), true);
        if (!isset($payload['amount_eur'])) {
            $payload['amount_eur'] = round((float) $old['amount_eur'], 2);
        }

        try {
            $stmt = $db->prepare(
                'UPDATE site_pricing_plans SET
                    entity_type = :entity_type,
                    entity_slug = :entity_slug,
                    plan_code = :plan_code,
                    label = :label,
                    amount_eur = :amount_eur,
                    billing_unit = :billing_unit,
                    description = :description,
                    is_active = :is_active,
                    sort_order = :sort_order
                 WHERE id = :id AND site_id = :site_id'
            );
            $stmt->execute([
                ':entity_type' => $payload['entity_type'],
                ':entity_slug' => $payload['entity_slug'],
                ':plan_code' => $payload['plan_code'],
                ':label' => $payload['label'],
                ':amount_eur' => $payload['amount_eur'],
                ':billing_unit' => $payload['billing_unit'],
                ':description' => $payload['description'],
                ':is_active' => $payload['is_active'],
                ':sort_order' => $payload['sort_order'],
                ':id' => $id,
                ':site_id' => $siteId,
            ]);
        } catch (PDOException $e) {
            if ((int) ($e->errorInfo[1] ?? 0) === 1062) {
                Response::badRequest('Un plan avec ce slug et ce code existe déjà pour ce site.');
                return;
            }
            throw $e;
        }

        Audit::log((int) $admin['id'], $siteId, 'update', 'site_pricing_plans', $id, $old, $data);
        Response::success(['id' => $id], 'Plan tarifaire mis à jour');
    });

    $router->delete('/api/admin/pricing-plans/{id}', function (array $params) {
        $admin = Middleware::requireRole(['superadmin', 'admin']);
        $siteId = Middleware::requireSiteIdFromRequest();
        $db = getDb();
        $id = (int) $params['id'];

        $stmt = $db->prepare('SELECT * FROM site_pricing_plans WHERE id = :id AND site_id = :site_id LIMIT 1');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        $old = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$old) {
            Response::notFound('Plan tarifaire introuvable');
            return;
        }

        $stmt = $db->prepare('DELETE FROM site_pricing_plans WHERE id = :id AND site_id = :site_id');
        $stmt->execute([':id' => $id, ':site_id' => $siteId]);
        Audit::log((int) $admin['id'], $siteId, 'delete', 'site_pricing_plans', $id, $old, null);
        Response::noContent();
    });
}
