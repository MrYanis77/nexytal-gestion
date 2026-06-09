<?php
/**
 * modules/media/media.php — Gestion de la mediathèque et uploads globaux
 */

function registerMediaRoutes(Router $router): void
{
    $router->post('/api/admin/media/upload', function () {
        Middleware::authenticate();
        $db = getDb();

        if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
            Response::badRequest('No file uploaded or upload error');
            return;
        }

        $type = $_POST['type'] ?? 'image'; // image, document, video

        $allowedTypes = Upload::ALLOWED_IMAGES;
        $maxSize = 2 * 1024 * 1024; // 2MB default

        if ($type === 'document') {
            $allowedTypes = Upload::ALLOWED_DOCUMENTS;
            $maxSize = 5 * 1024 * 1024; // 5MB
        } elseif ($type === 'video') {
            $allowedTypes = ['video/mp4', 'video/webm'];
            $maxSize = 50 * 1024 * 1024; // 50MB
        }

        $uploadResult = Upload::handleUpload('file', $allowedTypes, $maxSize, 'uploads');
        
        Response::created(['url' => $uploadResult['file_url']], 'File uploaded successfully');
    });
}
