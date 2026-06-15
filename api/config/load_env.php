<?php
/**
 * Charge les variables depuis un fichier KEY=VALUE.
 * Ordre : .env → env (sans point, FTP Ionos) → secrets.env → racine projet.
 */

/** @var list<string> Fichiers .env effectivement chargés */
$GLOBALS['_env_loaded_files'] = [];

function loadEnvFile(string $path): void
{
    if (!is_readable($path)) {
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if ($lines === false) {
        return;
    }

    if (isset($lines[0])) {
        $lines[0] = preg_replace('/^\xEF\xBB\xBF/', '', $lines[0]) ?? $lines[0];
    }

    foreach ($lines as $line) {
        $line = trim($line);
        if ($line === '' || str_starts_with($line, '#')) {
            continue;
        }

        $pos = strpos($line, '=');
        if ($pos === false) {
            continue;
        }

        $key = trim(substr($line, 0, $pos));
        $value = trim(substr($line, $pos + 1));

        if (
            (str_starts_with($value, '"') && str_ends_with($value, '"')) ||
            (str_starts_with($value, "'") && str_ends_with($value, "'"))
        ) {
            $value = substr($value, 1, -1);
        }
        $value = trim($value, " \t\r\n\0\x0B");

        if ($key !== '' && !array_key_exists($key, $_ENV)) {
            $_ENV[$key] = $value;
            // putenv peut être désactivé sur certains hébergeurs Ionos
            if (function_exists('putenv')) {
                @putenv("{$key}={$value}");
            }
        }
    }

    $GLOBALS['_env_loaded_files'][] = $path;
}

function env(string $key, ?string $default = null): ?string
{
    if (array_key_exists($key, $_ENV) && $_ENV[$key] !== '') {
        return (string) $_ENV[$key];
    }
    $value = getenv($key);
    if ($value !== false && $value !== '') {
        return (string) $value;
    }
    return $default;
}

$envDir = dirname(__DIR__);

// 1. Secrets — DB_PASSWORD (fichier « env » sans point : plus fiable sur FTP Ionos)
loadEnvFile(__DIR__ . '/.env');
loadEnvFile(__DIR__ . '/env');
loadEnvFile(__DIR__ . '/secrets.env');
loadEnvFile($envDir . '/../.env');

// 2. Surcharges hôte / base / user / mot de passe (config.local.php)
if (is_readable(__DIR__ . '/config.local.php')) {
    require __DIR__ . '/config.local.php';
}
