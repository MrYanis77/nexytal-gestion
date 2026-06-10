<?php
/**
 * core/Upload.php — Gestion des uploads de fichiers pour Nexytal
 * 
 * Validation MIME via finfo_file, taille max, renommage UUID.
 * Supporte images et PDFs.
 */

class Upload
{
    /** MIME types autorisés par catégorie */
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

    const ALLOWED_ALL = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'image/webp',
        'image/svg+xml',
        'application/pdf',
    ];

    /**
     * Gère l'upload d'un fichier
     * 
     * @param string $fileKey Clé dans $_FILES (ex: 'file', 'cv', 'avatar')
     * @param array $allowedMimes Types MIME autorisés
     * @param int|null $maxSize Taille max en octets (null = UPLOAD_MAX_SIZE)
     * @param string|null $subDir Sous-dossier dans UPLOAD_DIR (ex: 'cv', 'avatars', 'media')
     * @return array ['file_name' => string, 'file_path' => string, 'file_url' => string, 'mime_type' => string, 'file_size' => int]
     */
    public static function handleUpload(
        string $fileKey,
        array $allowedMimes = [],
        ?int $maxSize = null,
        ?string $subDir = null
    ): array {
        // Vérifier que le fichier existe dans $_FILES
        if (!isset($_FILES[$fileKey]) || $_FILES[$fileKey]['error'] === UPLOAD_ERR_NO_FILE) {
            Response::badRequest("No file uploaded for field '$fileKey'");
            exit;
        }

        $file = $_FILES[$fileKey];

        // Vérifier les erreurs d'upload PHP
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $errorMessages = [
                UPLOAD_ERR_INI_SIZE   => 'File exceeds server maximum size',
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

        // Taille max
        $maxSize = $maxSize ?? UPLOAD_MAX_SIZE;
        if ($file['size'] > $maxSize) {
            $maxMb = round($maxSize / 1024 / 1024, 1);
            Response::badRequest("File size exceeds maximum of {$maxMb} MB");
            exit;
        }

        // Vérifier le MIME type réel avec finfo (pas le MIME déclaré par le client)
        $finfo = new \finfo(FILEINFO_MIME_TYPE);
        $mimeType = $finfo->file($file['tmp_name']);

        if (empty($allowedMimes)) {
            $allowedMimes = self::ALLOWED_ALL;
        }

        if (!in_array($mimeType, $allowedMimes, true)) {
            Response::badRequest(
                "File type '$mimeType' is not allowed. Accepted: " . implode(', ', $allowedMimes)
            );
            exit;
        }

        // Déterminer l'extension à partir du MIME type réel
        $extension = self::getExtensionFromMime($mimeType);

        // Générer un nom de fichier unique (UUID)
        $uuid = self::generateUuid();
        $newFileName = $uuid . '.' . $extension;

        // Construire le chemin de destination
        $uploadDir = UPLOAD_DIR;
        if ($subDir) {
            $uploadDir .= rtrim($subDir, '/') . '/';
        }

        // Créer le répertoire s'il n'existe pas
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0755, true)) {
                Response::serverError('Failed to create upload directory');
                exit;
            }
        }

        $destPath = $uploadDir . $newFileName;

        // Déplacer le fichier uploadé
        if (!move_uploaded_file($file['tmp_name'], $destPath)) {
            Response::serverError('Failed to move uploaded file');
            exit;
        }

        // Construire l'URL publique
        $fileUrl = UPLOAD_URL;
        if ($subDir) {
            $fileUrl .= rtrim($subDir, '/') . '/';
        }
        $fileUrl .= $newFileName;

        return [
            'file_name' => $newFileName,
            'original_name' => $file['name'],
            'file_path' => $destPath,
            'file_url'  => $fileUrl,
            'mime_type' => $mimeType,
            'file_size' => $file['size'],
        ];
    }

    /**
     * Supprime un fichier uploadé
     * 
     * @param string $filePath Chemin complet vers le fichier
     * @return bool True si supprimé, false sinon
     */
    public static function deleteFile(string $filePath): bool
    {
        if (file_exists($filePath) && is_file($filePath)) {
            return unlink($filePath);
        }
        return false;
    }

    /**
     * Détermine l'extension de fichier à partir du MIME type
     */
    private static function getExtensionFromMime(string $mimeType): string
    {
        $map = [
            'image/jpeg'        => 'jpg',
            'image/png'         => 'png',
            'image/gif'         => 'gif',
            'image/webp'        => 'webp',
            'image/svg+xml'     => 'svg',
            'application/pdf'   => 'pdf',
        ];

        return $map[$mimeType] ?? 'bin';
    }

    /**
     * Génère un UUID v4
     */
    private static function generateUuid(): string
    {
        $data = random_bytes(16);
        // Set version to 0100
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        // Set bits 6-7 to 10
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
