<?php
/**
 * modules/media/media.php — Médiathèque : upload images, vidéos, documents
 */

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
    $stmt = $db->prepare(
        'SELECT id, site_id, file_name, original_name, file_path, mime_type, file_type,
                file_size, alt_text, uploaded_by, created_at, updated_at
         FROM media_library WHERE id = :id LIMIT 1'
    );
    $stmt->bindValue(':id', $id, PDO::PARAM_INT);
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    return $row ?: null;
}

function mediaRowToItem(array $row): array
{
    return [
        'id'            => (int) $row['id'],
        'site_id'       => $row['site_id'] !== null ? (int) $row['site_id'] : null,
        'url'           => UploadUrl::resolve((string) $row['file_path']),
        'path'          => $row['file_path'],
        'file_name'     => $row['file_name'],
        'original_name' => $row['original_name'],
        'mime_type'     => $row['mime_type'],
        'file_type'     => $row['file_type'] ?? mediaResolveFileType($row['mime_type']),
        'file_size'     => (int) $row['file_size'],
        'alt_text'      => $row['alt_text'],
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
    try {
        $stmt = $db->prepare(
            'INSERT INTO media_library
                (site_id, file_name, original_name, file_path, mime_type, file_type, file_size, alt_text, uploaded_by, created_at)
             VALUES
                (:site_id, :file_name, :original_name, :file_path, :mime_type, :file_type, :file_size, :alt_text, :uploaded_by, NOW())'
        );

        $stmt->bindValue(':site_id', $siteId, $siteId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':file_name', $upload['file_name'], PDO::PARAM_STR);
        $stmt->bindValue(':original_name', mb_substr((string) $upload['original_name'], 0, 255), PDO::PARAM_STR);
        $stmt->bindValue(':file_path', $upload['file_url'], PDO::PARAM_STR);
        $stmt->bindValue(':mime_type', $upload['mime_type'], PDO::PARAM_STR);
        $stmt->bindValue(':file_type', $fileType, PDO::PARAM_STR);
        $stmt->bindValue(':file_size', $upload['file_size'], PDO::PARAM_INT);
        $stmt->bindValue(':alt_text', $altText, $altText === null || $altText === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':uploaded_by', $adminId, PDO::PARAM_INT);
        $stmt->execute();
    } catch (PDOException $e) {
        $stmt = $db->prepare(
            'INSERT INTO media_library
                (site_id, file_name, file_path, mime_type, file_size, alt_text, uploaded_by, created_at)
             VALUES
                (:site_id, :file_name, :file_path, :mime_type, :file_size, :alt_text, :uploaded_by, NOW())'
        );

        $stmt->bindValue(':site_id', $siteId, $siteId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        $stmt->bindValue(':file_name', $upload['file_name'], PDO::PARAM_STR);
        $stmt->bindValue(':file_path', $upload['file_url'], PDO::PARAM_STR);
        $stmt->bindValue(':mime_type', $upload['mime_type'], PDO::PARAM_STR);
        $stmt->bindValue(':file_size', $upload['file_size'], PDO::PARAM_INT);
        $stmt->bindValue(':alt_text', $altText, $altText === null || $altText === '' ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':uploaded_by', $adminId, PDO::PARAM_INT);
        $stmt->execute();
    }

    return [
        'id'            => (int) $db->lastInsertId(),
        'url'           => UploadUrl::resolve($upload['file_url']),
        'path'          => $upload['file_url'],
        'file_name'     => $upload['file_name'],
        'original_name' => $upload['original_name'],
        'mime_type'     => $upload['mime_type'],
        'file_type'     => $fileType,
        'file_size'     => $upload['file_size'],
    ];
}

function registerMediaRoutes(Router $router): void
{
    $router->post('/api/admin/media/upload', function () {
        $admin = Middleware::authenticate();
        $db = getDb();

        if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            Response::badRequest('Aucun fichier reçu ou erreur d\'upload');
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

        $uploadResult = Upload::handleUpload('file', $allowedTypes, $maxSize, $subDir);
        $fileType = mediaResolveFileType($uploadResult['mime_type']);

        $siteId = mediaOptionalSiteId();
        if ($siteId !== null) {
            Middleware::requireSiteAccess($siteId);
        }

        $record = mediaInsertRecord($db, $uploadResult, $fileType, $siteId, (int) $admin['id'], $altText);

        Response::created($record, 'Fichier uploadé avec succès');
    });

    $router->get('/api/admin/media/disk-space', function () {
        Middleware::authenticate();

        Response::success(UploadDiskSpace::stats());
    });

    $router->get('/api/admin/media', function () {
        Middleware::authenticate();
        $db = getDb();

        $siteId = mediaOptionalSiteId();
        $fileType = isset($_GET['file_type']) ? trim((string) $_GET['file_type']) : null;
        $limit = min(100, max(1, (int) ($_GET['limit'] ?? 50)));

        $sql = 'SELECT id, site_id, file_name, original_name, file_path, mime_type, file_type,
                       file_size, alt_text, uploaded_by, created_at
                FROM media_library WHERE 1=1';
        $params = [];

        if ($siteId !== null) {
            Middleware::requireSiteAccess($siteId);
            $sql .= ' AND (site_id = :site_id OR site_id IS NULL)';
            $params[':site_id'] = $siteId;
        }

        if ($fileType !== null && $fileType !== '') {
            $sql .= ' AND file_type = :file_type';
            $params[':file_type'] = $fileType;
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
            Response::notFound('Média introuvable');
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
            Response::notFound('Média introuvable');
            return;
        }

        $siteId = $row['site_id'] !== null ? (int) $row['site_id'] : null;
        mediaEnsureAccess($siteId);

        $data = Router::getJsonBody();
        $altText = array_key_exists('alt_text', $data)
            ? (trim((string) $data['alt_text']) ?: null)
            : $row['alt_text'];

        $stmt = $db->prepare(
            'UPDATE media_library SET alt_text = :alt_text, updated_at = NOW() WHERE id = :id'
        );
        $stmt->bindValue(':alt_text', $altText, $altText === null ? PDO::PARAM_NULL : PDO::PARAM_STR);
        $stmt->bindValue(':id', $id, PDO::PARAM_INT);
        $stmt->execute();

        $updated = mediaFetchById($db, $id);
        Response::success(mediaRowToItem($updated));
    });

    $router->delete('/api/admin/media/{id}', function (array $params) {
        Middleware::authenticate();
        $db = getDb();
        $id = (int) $params['id'];
        $row = mediaFetchById($db, $id);

        if (!$row) {
            Response::notFound('Média introuvable');
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
