<?php
/**
 * UploadUrl — Chemins publics et URLs CDN pour les médias uploadés.
 *
 * En BDD : chemins relatifs (/api/uploads/trainers/uuid.jpg).
 * À l'affichage : préfixe optionnel MEDIA_PUBLIC_BASE_URL (domaine couvert par le CDN Ionos/Cloudflare).
 */

class UploadUrl
{
    /**
     * Chemin public relatif (sans domaine) — valeur stockée en BDD.
     */
    public static function publicPath(?string $subDir, string $fileName): string
    {
        $base = rtrim(UPLOAD_URL, '/');
        $subDir = $subDir !== null && $subDir !== '' ? trim($subDir, '/') : '';

        if ($subDir !== '') {
            $base .= '/' . $subDir;
        }

        return $base . '/' . $fileName;
    }

    /**
     * Résout un chemin BDD ou URL externe vers l'URL affichable (relative ou absolue CDN).
     */
    public static function resolve(string $path): string
    {
        if ($path === '') {
            return '';
        }

        if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) {
            return $path;
        }

        $normalized = str_starts_with($path, '/') ? $path : '/' . $path;

        // Rétrocompatibilité anciens chemins /uploads/…
        if (str_starts_with($normalized, '/uploads/') && !str_starts_with($normalized, '/api/uploads/')) {
            $normalized = '/api' . $normalized;
        }

        $cdnBase = defined('MEDIA_PUBLIC_BASE_URL') ? rtrim((string) MEDIA_PUBLIC_BASE_URL, '/') : '';

        if ($cdnBase === '') {
            return $normalized;
        }

        return $cdnBase . $normalized;
    }

    /**
     * URL absolue pour partage vers les sites satellites (alt-formation.fr, etc.).
     */
    public static function absolute(string $path): string
    {
        return self::resolve($path);
    }
}
