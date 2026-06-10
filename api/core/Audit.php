<?php
/**
 * core/Audit.php — Helper pour écrire dans core_audit_logs
 * 
 * Enregistre chaque opération CRUD admin avec old_data/new_data en JSON.
 * Capture automatique de l'IP client.
 */

class Audit
{
    /**
     * Enregistre une entrée d'audit
     * 
     * @param int|null $adminId ID de l'admin qui effectue l'action
     * @param int|null $siteId ID du site concerné
     * @param string $action Action effectuée (create, update, delete, login, etc.)
     * @param string $entityType Type d'entité (blog_post, offer, user, etc.)
     * @param int|null $entityId ID de l'entité concernée
     * @param array|null $oldData Données avant modification
     * @param array|null $newData Données après modification
     */
    public static function log(
        ?int $adminId,
        ?int $siteId,
        string $action,
        string $entityType,
        ?int $entityId = null,
        ?array $oldData = null,
        ?array $newData = null
    ): void {
        try {
            $db = getDb();
            $ip = RateLimit::getClientIp();

            $oldJson = $oldData !== null ? json_encode($oldData, JSON_UNESCAPED_UNICODE) : null;
            $newJson = $newData !== null ? json_encode($newData, JSON_UNESCAPED_UNICODE) : null;

            $stmt = $db->prepare(
                'INSERT INTO core_audit_logs 
                 (admin_id, site_id, action, entity_type, entity_id, old_data, new_data, ip_address, created_at) 
                 VALUES (:admin_id, :site_id, :action, :entity_type, :entity_id, :old_data, :new_data, :ip, NOW())'
            );

            $stmt->bindParam(':admin_id', $adminId, PDO::PARAM_INT);
            $stmt->bindParam(':site_id', $siteId, PDO::PARAM_INT);
            $stmt->bindParam(':action', $action, PDO::PARAM_STR);
            $stmt->bindParam(':entity_type', $entityType, PDO::PARAM_STR);
            $stmt->bindParam(':entity_id', $entityId, PDO::PARAM_INT);
            $stmt->bindParam(':old_data', $oldJson, PDO::PARAM_STR);
            $stmt->bindParam(':new_data', $newJson, PDO::PARAM_STR);
            $stmt->bindParam(':ip', $ip, PDO::PARAM_STR);

            $stmt->execute();
        } catch (\Exception $e) {
            // L'audit ne doit jamais bloquer l'opération principale
            // Log en fichier si possible
            if (APP_ENV === 'development') {
                error_log('Audit log error: ' . $e->getMessage());
            }
        }
    }

    /**
     * Récupère les logs d'audit avec filtres et pagination
     * 
     * @param array $filters Filtres optionnels : admin_id, site_id, action, entity_type, date_from, date_to
     * @param int $limit Nombre max de résultats
     * @param int $offset Offset pour pagination
     * @return array ['data' => [...], 'total' => int]
     */
    public static function getLogs(array $filters = [], int $limit = 50, int $offset = 0): array
    {
        $db = getDb();
        $where = [];
        $params = [];

        if (!empty($filters['admin_id'])) {
            $where[] = 'a.admin_id = :admin_id';
            $params[':admin_id'] = $filters['admin_id'];
        }
        if (!empty($filters['site_id'])) {
            $where[] = 'a.site_id = :site_id';
            $params[':site_id'] = $filters['site_id'];
        }
        if (!empty($filters['action'])) {
            $where[] = 'a.action = :action';
            $params[':action'] = $filters['action'];
        }
        if (!empty($filters['entity_type'])) {
            $where[] = 'a.entity_type = :entity_type';
            $params[':entity_type'] = $filters['entity_type'];
        }
        if (!empty($filters['date_from'])) {
            $where[] = 'a.created_at >= :date_from';
            $params[':date_from'] = $filters['date_from'];
        }
        if (!empty($filters['date_to'])) {
            $where[] = 'a.created_at <= :date_to';
            $params[':date_to'] = $filters['date_to'];
        }

        $whereClause = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

        // Count total
        $countSql = "SELECT COUNT(*) as total FROM core_audit_logs a $whereClause";
        $stmt = $db->prepare($countSql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->execute();
        $total = (int) $stmt->fetch()['total'];

        // Fetch data
        $sql = "SELECT a.*, 
                    CONCAT(u.first_name, ' ', u.last_name) as admin_name
                FROM core_audit_logs a
                LEFT JOIN core_admin_users u ON a.admin_id = u.id
                $whereClause
                ORDER BY a.created_at DESC
                LIMIT :limit OFFSET :offset";

        $stmt = $db->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll();

        // Décoder les JSON old_data/new_data
        foreach ($data as &$row) {
            $row['old_data'] = $row['old_data'] ? json_decode($row['old_data'], true) : null;
            $row['new_data'] = $row['new_data'] ? json_decode($row['new_data'], true) : null;
        }

        return ['data' => $data, 'total' => $total];
    }
}
