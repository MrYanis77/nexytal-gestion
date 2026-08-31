<?php
/**
 * core/Upload.php — Upload sécurisé (MIME réel, magic bytes, UUID, quota disque).
 *
 * Ne jamais faire confiance à $_FILES['type'] ni à l'extension du nom client.
 */

class Upload
{
    const ALLOWED_IMAGES = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/svg+xml',
    ];

    const ALLOWED_DOCUMENTS = [
        'application/pdf',
    ];

    const ALLOWED_VIDEOS = [
        'video/mp4',
        'video/webm',
        'video/quicktime',
        'video/x-msvideo',
    ];

    const ALLOWED_ALL = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/svg+xml',
        'application/pdf',
        'video/mp4',
        'video/webm',
        'video/quicktime',
        'video/x-msvideo',
    ];

    /** Extensions dangereuses dans le nom original (double extension, polyglot). */
    private const BLOCKED_EXTENSIONS = [
        'php', 'php3', 'php4', 'php5', 'php7', 'php8', 'phtml', 'phps', 'phar',
        'cgi', 'pl', 'py', 'rb', 'sh', 'bash', 'exe', 'dll', 'so', 'asp', 'aspx',
        'jsp', 'jspx', 'shtml', 'htaccess', 'htpasswd', 'ini', 'config',
    ];

    /** Sous-dossiers autorisés sous UPLOAD_DIR (anti path traversal). */
    private const ALLOWED_SUBDIRS = [
        'trainers', 'global', 'alt', 'blog', 'recrut', 'medical', 'carriere',
        'coaches', 'cv', 'candidatures', 'media',
    ];

    /**
     * @return array{
     *   file_name: string,
     *   original_name: string,
     *   file_path: string,
     *   file_url: string,
     *   mime_type: string,
     *   file_size: int
     * }
     */
    public static function handleUpload(
        string $fileKey,
        array $allowedMimes = [],
        ?int $maxSize = null,
        ?string $subDir = null
    ): array {
        if (!isset($_FILES[$fileKey]) || $_FILES[$fileKey]['error'] === UPLOAD_ERR_NO_FILE) {
            Response::badRequest("No file uploaded for field '$fileKey'");
            exit;
        }

        $file = $_FILES[$fileKey];

        if ($file['error'] !== UPLOAD_ERR_OK) {
            $errorMessages = [
                UPLOAD_ERR_INI_SIZE   => 'File exceeds server maximum size (php.ini)',
                UPLOAD_ERR_FORM_SIZE  => 'File exceeds form maximum size',
                UPLOAD_ERR_PARTIAL    => 'File was only partially uploaded',
                UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
                UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
                UPLOAD_ERR_EXTENSION  => 'File upload stopped by extension',
            ];
            $msg = $errorMessages[$file['error']] ?? 'Unknown upload error';
            Response::badRequest("Upload error: $msg");
            exit;
        }

        if (!is_uploaded_file($file['tmp_name'])) {
            Response::badRequest('Invalid upload source');
            exit;
        }

        $maxSize = $maxSize ?? UPLOAD_MAX_SIZE;

        if ($file['size'] <= 0) {
            Response::badRequest('Empty file is not allowed');
            exit;
        }

        if ($file['size'] > $maxSize) {
            $maxMb = round($maxSize / 1024 / 1024, 1);
            Response::badRequest("File size exceeds maximum of {$maxMb} MB");
            exit;
        }

        self::rejectDangerousClientFilename((string) $file['name']);

        $allowedMimes = empty($allowedMimes) ? self::ALLOWED_ALL : $allowedMimes;

        $mimeType = self::detectMimeType($file['tmp_name']);

        if (!in_array($mimeType, $allowedMimes, true)) {
            Response::badRequest(
                "File type '$mimeType' is not allowed. Accepted: " . implode(', ', $allowedMimes)
            );
            exit;
        }

        self::validateFileContent($file['tmp_name'], $mimeType);

        $extension = self::getExtensionFromMime($mimeType);
        if ($extension === null) {
            Response::badRequest('Unable to determine safe file extension from MIME type');
            exit;
        }

        $safeSubDir = self::sanitizeSubDir($subDir);

        UploadDiskSpace::assertSpaceFor((int) $file['size']);

        $uuid = self::generateUuid();
        $newFileName = $uuid . '.' . $extension;

        $uploadDir = rtrim(UPLOAD_DIR, '/\\') . '/';
        if ($safeSubDir !== '') {
            $uploadDir .= $safeSubDir . '/';
        }

        if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
            Response::serverError('Failed to create upload directory');
            exit;
        }

        $destPath = $uploadDir . $newFileName;

        if (!move_uploaded_file($file['tmp_name'], $destPath)) {
            Response::serverError('Failed to move uploaded file');
            exit;
        }

        @chmod($destPath, 0644);

        $writtenSize = filesize($destPath);
        if ($writtenSize === false || $writtenSize !== (int) $file['size']) {
            @unlink($destPath);
            Response::serverError('Uploaded file integrity check failed');
            exit;
        }

        $fileUrl = UploadUrl::publicPath($safeSubDir !== '' ? $safeSubDir : null, $newFileName);

        return [
            'file_name'     => $newFileName,
            'original_name' => self::sanitizeOriginalName((string) $file['name']),
            'file_path'     => $destPath,
            'file_url'      => $fileUrl,
            'mime_type'     => $mimeType,
            'file_size'     => (int) $file['size'],
        ];
    }

    public static function deleteFile(string $filePath): bool
    {
        $resolved = self::resolveSafePath($filePath);

        if ($resolved === null) {
            return false;
        }

        if (file_exists($resolved) && is_file($resolved)) {
            return unlink($resolved);
        }

        return false;
    }

    /**
     * Détecte le MIME via finfo, avec repli magic bytes si application/octet-stream.
     */
    public static function detectMimeType(string $path): string
    {
        $mimeType = false;

        if (class_exists('finfo', false)) {
            $finfo = new \finfo(FILEINFO_MIME_TYPE);
            $mimeType = $finfo->file($path);
        }

        if ($mimeType === false || $mimeType === 'application/octet-stream') {
            $fromMagic = self::detectMimeFromMagic($path);
            if ($fromMagic !== null) {
                return $fromMagic;
            }
        }

        return $mimeType ?: 'application/octet-stream';
    }

    private static function detectMimeFromMagic(string $path): ?string
    {
        $handle = @fopen($path, 'rb');
        if ($handle === false) {
            return null;
        }

        $header = fread($handle, 16);
        fclose($handle);

        if ($header === false || strlen($header) < 4) {
            return null;
        }

        if (str_starts_with($header, '%PDF')) {
            return 'application/pdf';
        }

        if (str_starts_with($header, "\xFF\xD8\xFF")) {
            return 'image/jpeg';
        }

        if (str_starts_with($header, "\x89PNG\r\n\x1a\n")) {
            return 'image/png';
        }

        if (str_starts_with($header, 'GIF87a') || str_starts_with($header, 'GIF89a')) {
            return 'image/gif';
        }

        if (str_starts_with($header, 'RIFF') && strlen($header) >= 12 && substr($header, 8, 4) === 'WEBP') {
            return 'image/webp';
        }

        if (str_starts_with($header, "\x1a\x45\xdf\xa3")) {
            return 'video/webm';
        }

        if (strlen($header) >= 12 && substr($header, 4, 4) === 'ftyp') {
            return 'video/mp4';
        }

        $textStart = ltrim(substr($header, 0, 512));
        if (str_starts_with($textStart, '<') && (str_contains($textStart, '<svg') || str_contains($textStart, '<?xml'))) {
            return 'image/svg+xml';
        }

        return null;
    }

    private static function validateFileContent(string $path, string $mimeType): void
    {
        switch ($mimeType) {
            case 'image/jpeg':
            case 'image/png':
            case 'image/gif':
            case 'image/webp':
                if (@getimagesize($path) === false) {
                    Response::badRequest('Invalid or corrupted image file');
                    exit;
                }
                break;

            case 'image/svg+xml':
                self::validateSvgFile($path);
                break;

            case 'application/pdf':
                $handle = @fopen($path, 'rb');
                if ($handle === false || fread($handle, 5) !== '%PDF-') {
                    if ($handle) {
                        fclose($handle);
                    }
                    Response::badRequest('Invalid PDF file');
                    exit;
                }
                fclose($handle);
                break;

            case 'video/mp4':
            case 'video/quicktime':
                self::validateMp4Container($path);
                break;

            case 'video/webm':
                $handle = @fopen($path, 'rb');
                $magic = $handle ? fread($handle, 4) : false;
                if ($handle) {
                    fclose($handle);
                }
                if ($magic !== "\x1a\x45\xdf\xa3") {
                    Response::badRequest('Invalid WebM video file');
                    exit;
                }
                break;

            case 'video/x-msvideo':
                if (@filesize($path) < 12) {
                    Response::badRequest('Invalid AVI video file');
                    exit;
                }
                break;
        }
    }

    private static function validateMp4Container(string $path): void
    {
        $handle = @fopen($path, 'rb');
        if ($handle === false) {
            Response::badRequest('Unable to read video file');
            exit;
        }

        $header = fread($handle, 12);
        fclose($handle);

        if ($header === false || strlen($header) < 8) {
            Response::badRequest('Invalid MP4/MOV video file');
            exit;
        }

        $ftyp = substr($header, 4, 4);
        if ($ftyp !== 'ftyp' && $ftyp !== 'wide' && $ftyp !== 'mdat' && $ftyp !== 'moov') {
            Response::badRequest('Invalid MP4/MOV video container');
            exit;
        }
    }

    private static function validateSvgFile(string $path): void
    {
        $maxRead = 512 * 1024;
        $content = @file_get_contents($path, false, null, 0, $maxRead);

        if ($content === false || $content === '') {
            Response::badRequest('Invalid SVG file');
            exit;
        }

        $lower = strtolower($content);

        $forbidden = [
            '<script',
            'javascript:',
            'vbscript:',
            'data:text/html',
            '<iframe',
            '<object',
            '<embed',
            '<?php',
            '<?',
            '<!entity',
            'onload=',
            'onerror=',
            'onclick=',
        ];

        foreach ($forbidden as $pattern) {
            if (str_contains($lower, $pattern)) {
                Response::badRequest('SVG file contains forbidden active content');
                exit;
            }
        }

        if (!str_contains($lower, '<svg')) {
            Response::badRequest('Invalid SVG file structure');
            exit;
        }
    }

    private static function rejectDangerousClientFilename(string $filename): void
    {
        $basename = basename(str_replace('\\', '/', $filename));
        $parts = explode('.', strtolower($basename));

        foreach ($parts as $part) {
            if (in_array($part, self::BLOCKED_EXTENSIONS, true)) {
                Response::badRequest('Filename contains a forbidden extension');
                exit;
            }
        }

        if (preg_match('/[\x00-\x1f\x7f]/', $basename)) {
            Response::badRequest('Invalid characters in filename');
            exit;
        }
    }

    private static function sanitizeOriginalName(string $name): string
    {
        $name = basename(str_replace('\\', '/', $name));
        $name = preg_replace('/[^\p{L}\p{N}\s._\-()]/u', '_', $name) ?? 'upload';

        return mb_substr(trim($name), 0, 255) ?: 'upload';
    }

    private static function sanitizeSubDir(?string $subDir): string
    {
        if ($subDir === null || $subDir === '') {
            return '';
        }

        $subDir = str_replace(['\\', "\0"], '', $subDir);
        $subDir = trim($subDir, '/');

        if ($subDir === '' || str_contains($subDir, '..') || str_contains($subDir, '/')) {
            Response::badRequest('Invalid upload subdirectory');
            exit;
        }

        if (!preg_match('/^[a-z0-9_-]+$/', $subDir)) {
            Response::badRequest('Invalid upload subdirectory');
            exit;
        }

        if (!in_array($subDir, self::ALLOWED_SUBDIRS, true)) {
            Response::badRequest('Upload subdirectory not allowed');
            exit;
        }

        return $subDir;
    }

    /**
     * Résout un chemin absolu ou URL publique vers le fichier sur disque (anti traversal).
     */
    public static function resolveSafePath(string $filePath): ?string
    {
        $relative = str_replace('\\', '/', trim($filePath));

        foreach (['/api/uploads/', '/uploads/'] as $prefix) {
            if (str_starts_with($relative, $prefix)) {
                $relative = ltrim(substr($relative, strlen($prefix)), '/');
                break;
            }
        }

        if (str_starts_with($relative, 'uploads/')) {
            $relative = ltrim(substr($relative, strlen('uploads/')), '/');
        }

        $urlPrefix = rtrim(UPLOAD_URL, '/');
        if (str_starts_with($relative, $urlPrefix)) {
            $relative = ltrim(substr($relative, strlen($urlPrefix)), '/');
        }

        if (str_starts_with($relative, UPLOAD_DIR)) {
            $relative = ltrim(substr($relative, strlen(rtrim(UPLOAD_DIR, '/\\'))), '/\\');
        }

        $relative = str_replace('\\', '/', $relative);
        $relative = ltrim($relative, '/');

        if ($relative === '' || str_contains($relative, '..')) {
            return null;
        }

        $bases = array_values(array_filter([
            realpath(rtrim(UPLOAD_DIR, '/\\')),
            realpath(dirname(__DIR__) . '/uploads'),
            realpath(dirname(__DIR__, 2) . '/uploads'),
        ]));

        if ($bases === []) {
            return null;
        }

        foreach ($bases as $base) {
            $candidate = $base . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
            $resolved = realpath($candidate);

            if ($resolved !== false && is_file($resolved)) {
                if (str_starts_with($resolved, $base . DIRECTORY_SEPARATOR) || $resolved === $base) {
                    return $resolved;
                }
            }

            if (is_file($candidate)) {
                $realCandidate = realpath($candidate);
                if ($realCandidate !== false
                    && (str_starts_with($realCandidate, $base . DIRECTORY_SEPARATOR) || $realCandidate === $base)
                ) {
                    return $realCandidate;
                }
            }
        }

        return null;
    }

    private static function getExtensionFromMime(string $mimeType): ?string
    {
        $map = [
            'image/jpeg'        => 'jpg',
            'image/png'         => 'png',
            'image/gif'         => 'gif',
            'image/webp'        => 'webp',
            'image/svg+xml'     => 'svg',
            'application/pdf'   => 'pdf',
            'video/mp4'         => 'mp4',
            'video/webm'        => 'webm',
            'video/quicktime'   => 'mov',
            'video/x-msvideo'   => 'avi',
        ];

        return $map[$mimeType] ?? null;
    }

    private static function generateUuid(): string
    {
        $data = random_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}

