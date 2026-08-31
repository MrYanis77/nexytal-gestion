<?php
/**
 * modules/media/media.php - Media library: upload images, videos and documents.
 * Compatible with the legacy Ionos schema (filename, path, size_bytes)
 * and the extended schema (file_name, file_path, file_size, file_type, alt_text).
 */

require_once __DIR__ . '/../blog/blog_helpers.php';
require_once __DIR__ . '/../recrutement/site_scope.php';

function mediaTableExists(PDO $db): bool
{
    static $exists = null;

    if ($exists === null) {
        try {
            $stmt = $db->query(
                "SELECT 1 FROM information_schema.TABLES
                 WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'media_library' LIMIT 1"
            );
            $exists = (bool) $stmt->fetchColumn();
        } catch (\Throwable $e) {
            $exists = false;
        }
    }

    return $exists;
}

function mediaHasColumn(PDO $db, string $column): bool
{
    static $cache = [];

    if (!array_key_exists($column, $cache)) {
        $cache[$column] = recrutementTableHasColumn($db, 'media_library', $column);
    }

    return $cache[$column];
}

function mediaUsesExtendedSchema(PDO $db): bool
{
    return mediaHasColumn($db, 'file_path');
}

function mediaSelectColumns(PDO $db): string
{
    $fileName = mediaHasColumn($db, 'file_name')
        ? 'file_name'
        : (mediaHasColumn($db, 'filename') ? 'filename AS file_name' : "'' AS file_name");

    if (mediaHasColumn($db, 'original_name')) {
        $originalName = 'original_name';
    } elseif (mediaHasColumn($db, 'file_name')) {
        $originalName = 'file_name AS original_name';
    } elseif (mediaHasColumn($db, 'filename')) {
        $originalName = 'filename AS original_name';
    } else {
        $originalName = 'NULL AS original_name';
    }

    $filePath = mediaHasColumn($db, 'file_path')
        ? 'file_path'
        : (mediaHasColumn($db, 'path') ? 'path AS file_path' : "'' AS file_path");

    $fileSize = mediaHasColumn($db, 'file_size')
        ? 'file_size'
        : (mediaHasColumn($db, 'size_bytes') ? 'size_bytes AS file_size' : '0 AS file_size');

    return implode(', ', [
        'id',
        mediaHasColumn($db, 'site_id') ? 'site_id' : 'NULL AS site_id',
        $fileName,
        $originalName,
        $filePath,
        mediaHasColumn($db, 'mime_type') ? 'mime_type' : "'' AS mime_type",
        mediaHasColumn($db, 'file_type') ? 'file_type' : 'NULL AS file_type',
        $fileSize,
        mediaHasColumn($db, 'alt_text') ? 'alt_text' : 'NULL AS alt_text',
        mediaHasColumn($db, 'uploaded_by') ? 'uploaded_by' : 'NULL AS uploaded_by',
        mediaHasColumn($db, 'created_at') ? 'created_at' : 'NOW() AS created_at',
        mediaHasColumn($db, 'updated_at') ? 'updated_at' : 'NULL AS updated_at',
    ]);
}

function mediaResolveFileType(string $mimeType): string
{
    if (str_starts_with($mimeType, 'image/')) {
        return 'image';
    }
    if (str_starts_with($mimeType, 'video/')) {
        return 'video';
    }
    if ($mimeType === 'application/pdf') {
        return 'document';
    }

    return 'other';
}

function mediaResolveSubDir(string $context): string
{
    $map = [
        'trainers'    => 'trainers',
        'trainer'     => 'trainers',
        'formation'   => 'alt',
        'alt'         => 'alt',
        'blog'        => 'blog',
        'recrutement' => 'recrut',
        'recrut'      => 'recrut',
        'medical'     => 'medical',
        'carriere'    => 'carriere',
        'coaching'    => 'coaches',
        'coaches'     => 'coaches',
        'global'      => 'global',
        'cv'          => 'cv',
    ];

    $key = strtolower(preg_replace('/[^a-z0-9_-]/', '', $context));

    return $map[$key] ?? 'media';
}

function mediaOptionalSiteId(): ?int
{
    $raw = $_GET['site_id'] ?? $_SERVER['HTTP_X_SITE_ID'] ?? null;
    if ($raw === null || $raw === '') {
        return null;
    }

    $siteId = (int) $raw;

    return $siteId > 0 ? $siteId : null;
}

function mediaAbsolutePath(string $filePath): string
{
    $resolved = Upload::resolveSafePath($filePath);

    return $resolved ?? rtrim(UPLOAD_DIR, '/') . '/' . ltrim($filePath, '/');
}

function mediaFetchById(PDO $db, int $id): ?array
{
    if (!mediaTableExists($db)) {
        return null;
    }

    $stmt = $db->prepare(
        'SELECT ' . mediaSelectColumns($db) . ' FROM media_library WHERE id = :id LIMIT 1'
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row ?: null;
}

function mediaRowToItem(array $row): array
{
    $path = (string) ($row['file_path'] ?? $row['path'] ?? '');
    $mimeType = (string) ($row['mime_type'] ?? '');

    return [
        'id'            => (int) $row['id'],
        'site_id'       => $row['site_id'] !== null ? (int) $row['site_id'] : null,
        'url'           => UploadUrl::resolve($path),
        'path'          => $path,
        'file_name'     => $row['file_name'] ?? $row['filename'] ?? '',
        'original_name' => $row['original_name'] ?? $row['file_name'] ?? $row['filename'] ?? '',
        'mime_type'     => $mimeType,
        'file_type'     => $row['file_type'] ?? mediaResolveFileType($mimeType),
        'file_size'     => (int) ($row['file_size'] ?? $row['size_bytes'] ?? 0),
        'alt_text'      => $row['alt_text'] ?? null,
        'uploaded_by'   => $row['uploaded_by'] !== null ? (int) $row['uploaded_by'] : null,
        'created_at'    => $row['created_at'],
        'updated_at'    => $row['updated_at'] ?? null,
    ];
}

function mediaEnsureAccess(?int $siteId): void
{
    if ($siteId !== null) {
        Middleware::requireSiteAccess($siteId);
    }
}

function mediaInsertRecord(PDO $db, array $upload, string $fileType, ?int $siteId, int $adminId, ?string $altText): array
{
    $base = [
        'id'            => 0,
        'url'           => UploadUrl::resolve($upload['file_url']),
        'path'          => $upload['file_url'],
        'file_name'     => $upload['file_name'],
        'original_name' => $upload['original_name'],
        'mime_type'     => $upload['mime_type'],
        'file_type'     => $fileType,
        'file_size'     => $upload['file_size'],
    ];

    if (!mediaTableExists($db)) {
        return $base;
    }

    $altText = ($altText !== null && trim($altText) !== '') ? trim($altText) : null;
    $row = [];

    if (mediaHasColumn($db, 'site_id')) {
        $row['site_id'] = $siteId;
    }
    if (mediaHasColumn($db, 'file_name')) {
        $row['file_name'] = $upload['file_name'];
    }
    if (mediaHasColumn($db, 'filename')) {
        $row['filename'] = $upload['file_name'];
    }
    if (mediaHasColumn($db, 'original_name')) {
        $row['original_name'] = mb_substr((string) $upload['original_name'], 0, 255);
    }
    if (mediaHasColumn($db, 'file_path')) {
        $row['file_path'] = $upload['file_url'];
    }
    if (mediaHasColumn($db, 'path')) {
        $row['path'] = $upload['file_url'];
    }
    if (mediaHasColumn($db, 'mime_type')) {
        $row['mime_type'] = $upload['mime_type'];
    }
    if (mediaHasColumn($db, 'file_type')) {
        $row['file_type'] = $fileType;
    }
    if (mediaHasColumn($db, 'file_size')) {
        $row['file_size'] = $upload['file_size'];
    }
    if (mediaHasColumn($db, 'size_bytes')) {
        $row['size_bytes'] = $upload['file_size'];
    }
    if (mediaHasColumn($db, 'alt_text')) {
        $row['alt_text'] = $altText;
    }
    if (mediaHasColumn($db, 'uploaded_by')) {
        $row['uploaded_by'] = $adminId;
    }
    if (mediaHasColumn($db, 'created_at')) {
        $row['created_at'] = date('Y-m-d H:i:s');
    }

    $newId = blogInsert($db, 'media_library', $row);
    $base['id'] = $newId;

    return $base;
}

function registerMediaRoutes(Router $router): void
{
    $router->post('/api/admin/media/upload', function () {
        $admin = Middleware::authenticate();
        $db = getDb();

        if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            Response::badRequest('Aucun fichier recu ou erreur d\'upload');
            return;
        }

        $requestedType = $_POST['type'] ?? 'image';
        $context = $_POST['context'] ?? 'media';
        $altText = isset($_POST['alt_text']) ? trim((string) $_POST['alt_text']) : null;
        $subDir = mediaResolveSubDir($context);

        $allowedTypes = Upload::ALLOWED_IMAGES;
        $maxSize = UPLOAD_MAX_SIZE_IMAGE;

        if ($requestedType === 'document') {
            $allowedTypes = Upload::ALLOWED_DOCUMENTS;
            $maxSize = UPLOAD_MAX_SIZE_DOCUMENT;
        } elseif ($requestedType === 'video') {
            $allowedTypes = Upload::ALLOWED_VIDEOS;
            $maxSize = UPLOAD_MAX_SIZE_VIDEO;
        }

        UploadDiskSpace::assertSpaceFor($maxSize);

        try {
            $uploadResult = Upload::handleUpload('file', $allowedTypes, $maxSize, $subDir);
        } catch (\Throwable $e) {
            Response::serverError('Echec de l\'upload fichier', $e->getMessage());
            return;
        }

        $fileType = mediaResolveFileType($uploadResult['mime_type']);

        $siteId = mediaOptionalSiteId();
        if ($siteId !== null) {
            Middleware::requireSiteAccess($siteId);
        }

        try {
            $record = mediaInsertRecord($db, $uploadResult, $fileType, $siteId, (int) $admin['id'], $altText);
        } catch (\Throwable $e) {
            Upload::deleteFile($uploadResult['file_path']);
            Response::serverError('Enregistrement media impossible', $e->getMessage());
            return;
        }

        Response::created($record, 'Fichier uploade avec succes');
    });

    $router->get('/api/admin/media/disk-space', function () {
        Middleware::authenticate();

        Response::success(UploadDiskSpace::stats());
    });

    $router->get('/api/admin/media', function () {
        Middleware::authenticate();
        $db = getDb();

        if (!mediaTableExists($db)) {
            Response::success([]);
            return;
        }

        $siteId = mediaOptionalSiteId();
        $fileType = isset($_GET['file_type']) ? trim((string) $_GET['file_type']) : null;
        $limit = min(100, max(1, (int) ($_GET['limit'] ?? 50)));

        $sql = 'SELECT ' . mediaSelectColumns($db) . ' FROM media_library WHERE 1=1';
        $params = [];

        if ($siteId !== null && mediaHasColumn($db, 'site_id')) {
            Middleware::requireSiteAccess($siteId);
            $sql .= ' AND (site_id = :site_id OR site_id IS NULL)';
            $params[':site_id'] = $siteId;
        }

        if ($fileType !== null && $fileType !== '' && mediaHasColumn($db, 'file_type')) {
            $sql .= ' AND file_type = :file_type';
            $params[':file_type'] = $fileType;
        } elseif ($fileType !== null && $fileType !== '' && mediaHasColumn($db, 'mime_type')) {
            if ($fileType === 'image') {
                $sql .= " AND mime_type LIKE 'image/%'";
            } elseif ($fileType === 'video') {
                $sql .= " AND mime_type LIKE 'video/%'";
            } elseif ($fileType === 'document') {
                $sql .= " AND mime_type = 'application/pdf'";
            }
        }

        $sql .= ' ORDER BY created_at DESC LIMIT ' . $limit;

        $stmt = $db->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->execute();

        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $items = array_map(static fn (array $row) => mediaRowToItem($row), $rows);

        Response::success($items);
    });

    $router->get('/api/admin/media/{id}', function (array $params) {
        Middleware::authenticate();
        $db = getDb();
        $id = (int) $params['id'];
        $row = mediaFetchById($db, $id);

        if (!$row) {
            Response::notFound('Media introuvable');
            return;
        }

        $siteId = $row['site_id'] !== null ? (int) $row['site_id'] : null;
        mediaEnsureAccess($siteId);

        Response::success(mediaRowToItem($row));
    });

    $router->put('/api/admin/media/{id}', function (array $params) {
        Middleware::authenticate();
        $db = getDb();
        $id = (int) $params['id'];
        $row = mediaFetchById($db, $id);

        if (!$row) {
            Response::notFound('Media introuvable');
            return;
        }

        $siteId = $row['site_id'] !== null ? (int) $row['site_id'] : null;
        mediaEnsureAccess($siteId);

        $data = Router::getJsonBody();
        $altText = array_key_exists('alt_text', $data)
            ? (trim((string) $data['alt_text']) ?: null)
            : $row['alt_text'];

        if (mediaHasColumn($db, 'alt_text')) {
            $sets = ['alt_text = :alt_text'];
            if (mediaHasColumn($db, 'updated_at')) {
                $sets[] = 'updated_at = NOW()';
            }

            $stmt = $db->prepare('UPDATE media_library SET ' . implode(', ', $sets) . ' WHERE id = :id');
            $stmt->bindValue(':alt_text', $altText, $altText === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
            $stmt->bindValue(':id', $id, PDO::PARAM_INT);
            $stmt->execute();
        }

        $updated = mediaFetchById($db, $id);
        Response::success(mediaRowToItem($updated));
    });

    $router->delete('/api/admin/media/{id}', function (array $params) {
        Middleware::authenticate();
        $db = getDb();
        $id = (int) $params['id'];
        $row = mediaFetchById($db, $id);

        if (!$row) {
            Response::notFound('Media introuvable');
            return;
        }

        $siteId = $row['site_id'] !== null ? (int) $row['site_id'] : null;
        mediaEnsureAccess($siteId);

        $absolutePath = mediaAbsolutePath((string) $row['file_path']);
        Upload::deleteFile($absolutePath);

        $stmt = $db->prepare('DELETE FROM media_library WHERE id = :id');
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        Response::success(['id' => $id, 'deleted' => true]);
    });
}
