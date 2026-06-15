<?php
/**
 * UploadDiskSpace — Vérification de l'espace disque avant upload (Ionos / Apache).
 *
 * Sur hébergement mutualisé, disk_free_space() renvoie l'espace du volume
 * où se trouve UPLOAD_DIR (souvent le quota webspace Ionos).
 */

class UploadDiskSpace
{
    /**
     * Espace libre en octets sur le volume des uploads, ou null si indéterminable.
     */
    public static function getFreeBytes(?string $path = null): ?int
    {
        $path = $path ?? UPLOAD_DIR;

        if (!is_dir($path)) {
            $path = dirname(rtrim($path, '/\\'));
        }

        if (!is_dir($path)) {
            return null;
        }

        $free = @disk_free_space($path);

        return $free === false ? null : (int) $free;
    }

    /**
     * Espace total du volume (quota), ou null si indéterminable.
     */
    public static function getTotalBytes(?string $path = null): ?int
    {
        $path = $path ?? UPLOAD_DIR;

        if (!is_dir($path)) {
            $path = dirname(rtrim($path, '/\\'));
        }

        if (!is_dir($path)) {
            return null;
        }

        $total = @disk_total_space($path);

        return $total === false ? null : (int) $total;
    }

    /**
     * Statistiques pour monitoring admin (endpoint optionnel).
     *
     * @return array{free_bytes: int|null, total_bytes: int|null, used_bytes: int|null, free_mb: float|null, total_mb: float|null}
     */
    public static function stats(?string $path = null): array
    {
        $free = self::getFreeBytes($path);
        $total = self::getTotalBytes($path);
        $used = ($free !== null && $total !== null) ? max(0, $total - $free) : null;

        return [
            'free_bytes'  => $free,
            'total_bytes' => $total,
            'used_bytes'  => $used,
            'free_mb'     => $free !== null ? round($free / 1024 / 1024, 1) : null,
            'total_mb'    => $total !== null ? round($total / 1024 / 1024, 1) : null,
        ];
    }

    /**
     * Refuse l'upload si l'espace libre est insuffisant (fichier + marge de sécurité).
     */
    public static function assertSpaceFor(int $requiredBytes): void
    {
        $reserve = defined('UPLOAD_MIN_FREE_BYTES') ? (int) UPLOAD_MIN_FREE_BYTES : (256 * 1024 * 1024);
        $free = self::getFreeBytes();

        if ($free === null) {
            // Hébergeur peut désactiver disk_free_space — ne pas bloquer, journaliser si possible.
            error_log('[UploadDiskSpace] disk_free_space unavailable — skip quota check');
            return;
        }

        $needed = $requiredBytes + $reserve;

        if ($free < $needed) {
            $freeMb = round($free / 1024 / 1024, 1);
            $neededMb = round($needed / 1024 / 1024, 1);
            Response::badRequest(
                "Espace disque insuffisant ({$freeMb} Mo libres, {$neededMb} Mo requis incluant la marge de sécurité)"
            );
            exit;
        }
    }
}
