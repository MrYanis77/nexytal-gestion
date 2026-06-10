-- Patch Ionos : ajoute les 3 tables manquantes au schéma v3.0
-- À exécuter sur dbs15772578 si vous ne souhaitez pas tout réimporter.
-- Prérequis : core_sites et core_admin_users doivent exister.

SET NAMES utf8mb4;
USE `dbs15772578`;

CREATE TABLE IF NOT EXISTS `gdpr_deletion_requests` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(10) UNSIGNED DEFAULT NULL,
  `user_type` enum('applicant','subscriber','diagnostic_request','review_author','other') DEFAULT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `request_type` varchar(100) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `details` text DEFAULT NULL,
  `status` enum('pending','completed','processed','rejected') NOT NULL DEFAULT 'pending',
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int(10) UNSIGNED DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_gdpr_del_email` (`user_email`),
  KEY `idx_gdpr_del_status` (`status`,`created_at`),
  KEY `idx_gdpr_del_site` (`site_id`),
  KEY `fk_gdpr_del_processed` (`processed_by`),
  CONSTRAINT `fk_gdpr_del_processed_by` FOREIGN KEY (`processed_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_gdpr_del_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `media_library` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = média global partagé',
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `alt_text` varchar(255) DEFAULT NULL,
  `uploaded_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_media_site` (`site_id`),
  KEY `idx_media_mime` (`mime_type`),
  KEY `fk_media_uploaded` (`uploaded_by`),
  CONSTRAINT `fk_media_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_media_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `seo_metadata` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(10) UNSIGNED NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(10) UNSIGNED NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` text DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `schema_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seo_entity` (`site_id`,`entity_type`,`entity_id`),
  KEY `idx_seo_site` (`site_id`,`entity_type`),
  CONSTRAINT `fk_seo_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
