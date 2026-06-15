-- Médiathèque Nexytal — compatible schema_v2 / MariaDB Ionos (core_sites.id = int(11))
-- Exécuter sur dbs15772578 si la table n'existe pas encore.

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `media_library` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL COMMENT 'NULL = média global partagé entre sites',
  `file_name` varchar(255) NOT NULL COMMENT 'Nom sur disque (UUID + extension)',
  `original_name` varchar(255) DEFAULT NULL COMMENT 'Nom original du fichier uploadé',
  `file_path` varchar(500) NOT NULL COMMENT 'URL publique (/uploads/…)',
  `mime_type` varchar(100) NOT NULL,
  `file_type` enum('image','video','document','other') NOT NULL DEFAULT 'image',
  `file_size` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Taille en octets',
  `alt_text` varchar(255) DEFAULT NULL COMMENT 'Texte alternatif (accessibilité / SEO)',
  `uploaded_by` int(11) DEFAULT NULL COMMENT 'Admin ayant uploadé le fichier',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_media_site` (`site_id`),
  KEY `idx_media_mime` (`mime_type`),
  KEY `idx_media_type` (`file_type`),
  KEY `idx_media_uploaded` (`uploaded_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Médiathèque centralisée (images, vidéos, PDF…)';

-- Clés étrangères (après création — types int(11) alignés sur core_sites / core_admin_users)
ALTER TABLE `media_library`
  ADD CONSTRAINT `fk_media_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_media_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

-- Si la table existait déjà sans les nouvelles colonnes :
ALTER TABLE `media_library`
  ADD COLUMN IF NOT EXISTS `original_name` varchar(255) DEFAULT NULL COMMENT 'Nom original du fichier uploadé' AFTER `file_name`,
  ADD COLUMN IF NOT EXISTS `file_type` enum('image','video','document','other') NOT NULL DEFAULT 'image' AFTER `mime_type`;

UPDATE `media_library`
SET `file_type` = CASE
  WHEN `mime_type` LIKE 'video/%' THEN 'video'
  WHEN `mime_type` = 'application/pdf' THEN 'document'
  WHEN `mime_type` LIKE 'image/%' THEN 'image'
  ELSE 'other'
END
WHERE `file_type` = 'image' AND `mime_type` NOT LIKE 'image/%';

-- Corriger les URLs : fichiers servis sous /api/uploads/ sur Ionos
UPDATE `media_library`
SET `file_path` = CONCAT('/api', `file_path`)
WHERE `file_path` LIKE '/uploads/%'
  AND `file_path` NOT LIKE '/api/uploads/%';
