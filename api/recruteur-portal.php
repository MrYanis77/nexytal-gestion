<?php
/**
 * recruteur-portal.php — Compatibilité sites satellites (medical, carriere, etc.)
 *
 * Ancien endpoint : ?action=download_candidature_cv&candidature_id=…&type=externe
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/core/Response.php';
require_once __DIR__ . '/core/Router.php';
require_once __DIR__ . '/core/Auth.php';
require_once __DIR__ . '/core/AdminSession.php';
require_once __DIR__ . '/core/Upload.php';
require_once __DIR__ . '/modules/recrutement/recruteur_portal.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

try {
    recruteurPortalLegacyDispatch();
} catch (\PDOException $e) {
    Response::serverError('Database error', $e->getMessage());
} catch (\Exception $e) {
    Response::serverError('Server error', $e->getMessage());
}
