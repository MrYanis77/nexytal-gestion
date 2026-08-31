-- =============================================================================
-- NEXYTAL PLATFORM — Schéma complet v2.1 (MariaDB / MySQL 8+)
-- Login: admin@nexytal.com / password
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET time_zone = '+00:00';
SET NAMES utf8mb4;

-- =============================================================================
-- 1. CORE — Sites & Administration
-- =============================================================================

CREATE TABLE IF NOT EXISTS `core_sites` (
  `id`         int(11) NOT NULL AUTO_INCREMENT,
  `name`       varchar(255) NOT NULL,
  `slug`       varchar(255) NOT NULL,
  `domain`     varchar(255) NOT NULL,
  `is_active`  tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_site_slug`   (`slug`),
  UNIQUE KEY `uq_site_domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `core_sites` (`id`, `name`, `slug`, `domain`, `is_active`) VALUES
(1, 'Alt Formation',       'alt-formation',       'alt-formation.fr',          1),
(2, 'Nexytal Recrutement', 'nexytal-recrutement', 'recrutement.nexytal.com',   1),
(3, 'Nexytal Médical',     'nexytal-medical',     'medical.nexytal.com',       1),
(4, 'Nexytal Carrière',    'nexytal-carriere',    'carriere.nexytal.com',      1),
(5, 'Nexytal Trainer',     'nexytal-trainer',     'trainer.nexytal.com',       1),
(6, 'Nexytal Coaching',    'nexytal-coaching',    'coaching.nexytal.com',      1);

CREATE TABLE IF NOT EXISTS `core_admin_users` (
  `id`            int(11) NOT NULL AUTO_INCREMENT,
  `email`         varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name`    varchar(100) NOT NULL,
  `last_name`     varchar(100) NOT NULL,
  `role`          enum('superadmin','admin','editor','moderator','recruiter','seo') NOT NULL DEFAULT 'editor',
  `avatar_url`    varchar(255) DEFAULT NULL,
  `is_active`     tinyint(1) NOT NULL DEFAULT 1,
  `last_login`    datetime DEFAULT NULL,
  `created_at`    datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `core_admin_users`
  (`id`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `is_active`, `created_at`)
VALUES
(1, 'admin@nexytal.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Super', 'Admin', 'superadmin', 1, NOW());

CREATE TABLE IF NOT EXISTS `core_admin_site_access` (
  `admin_id` int(11) NOT NULL,
  `site_id`  int(11) NOT NULL,
  PRIMARY KEY (`admin_id`, `site_id`),
  CONSTRAINT `fk_asa_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_asa_site`  FOREIGN KEY (`site_id`)  REFERENCES `core_sites` (`id`)        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `core_admin_site_access` (`admin_id`, `site_id`)
SELECT 1, id FROM `core_sites`;

CREATE TABLE IF NOT EXISTS `core_admin_sessions` (
  `id`         varchar(128) NOT NULL,
  `admin_id`   int(11) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_session_admin_exp` (`admin_id`, `expires_at`),
  CONSTRAINT `fk_session_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `core_audit_logs` (
  `id`          bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id`    int(11) DEFAULT NULL,
  `site_id`     int(11) DEFAULT NULL,
  `action`      varchar(100) NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `entity_id`   int(11) DEFAULT NULL,
  `old_data`    longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data`    longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address`  varchar(45) DEFAULT NULL,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_audit_site_date` (`site_id`, `created_at`),
  INDEX `idx_audit_entity`    (`entity_type`, `entity_id`),
  CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_audit_site`  FOREIGN KEY (`site_id`)  REFERENCES `core_sites` (`id`)        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `core_admin_password_resets` (
  `id`         int(11) NOT NULL AUTO_INCREMENT,
  `admin_id`   int(11) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_pwreset_token` (`token_hash`),
  CONSTRAINT `fk_pwreset_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 2. BLOG
-- =============================================================================

CREATE TABLE IF NOT EXISTS `blog_categories` (
  `id`          int(11) NOT NULL AUTO_INCREMENT,
  `site_id`     int(11) NOT NULL,
  `name`        varchar(255) NOT NULL,
  `slug`        varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `color`       varchar(20) DEFAULT NULL,
  `is_active`   tinyint(1) NOT NULL DEFAULT 1,
  `sort_order`  int(11) NOT NULL DEFAULT 0,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_blog_cat_site_slug` (`site_id`, `slug`),
  INDEX `idx_blog_cat_active` (`site_id`, `is_active`, `sort_order`),
  CONSTRAINT `fk_blog_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_tags` (
  `id`         int(11) NOT NULL AUTO_INCREMENT,
  `site_id`    int(11) NOT NULL,
  `name`       varchar(100) NOT NULL,
  `slug`       varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_blog_tag_site_slug` (`site_id`, `slug`),
  CONSTRAINT `fk_blog_tag_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_authors` (
  `id`          int(11) NOT NULL AUTO_INCREMENT,
  `site_id`     int(11) NOT NULL,
  `first_name`  varchar(100) NOT NULL,
  `last_name`   varchar(100) NOT NULL,
  `email`       varchar(255) NOT NULL,
  `slug`        varchar(255) NOT NULL,
  `bio`         text DEFAULT NULL,
  `avatar_url`  varchar(255) DEFAULT NULL,
  `is_active`   tinyint(1) NOT NULL DEFAULT 1,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_blog_author_site_slug`  (`site_id`, `slug`),
  UNIQUE KEY `uq_blog_author_site_email` (`site_id`, `email`),
  CONSTRAINT `fk_blog_author_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_posts` (
  `id`               int(11) NOT NULL AUTO_INCREMENT,
  `site_id`          int(11) NOT NULL,
  `category_id`      int(11) DEFAULT NULL,
  `author_id`        int(11) DEFAULT NULL,
  `title`            varchar(255) NOT NULL,
  `slug`             varchar(255) NOT NULL,
  `excerpt`          text DEFAULT NULL,
  `content`          longtext NOT NULL,
  `cover_image_url`  varchar(255) DEFAULT NULL,
  `read_time_mins`   int(11) DEFAULT NULL,
  `status`           enum('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured`      tinyint(1) NOT NULL DEFAULT 0,
  `views_count`      int(11) NOT NULL DEFAULT 0,
  `meta_title`       varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `published_at`     datetime DEFAULT NULL,
  `created_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`       datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_blog_post_site_slug` (`site_id`, `slug`),
  INDEX `idx_blog_post_status`   (`site_id`, `status`, `published_at`),
  INDEX `idx_blog_post_featured` (`site_id`, `is_featured`),
  INDEX `idx_blog_post_deleted`  (`deleted_at`),
  CONSTRAINT `fk_blog_post_site`   FOREIGN KEY (`site_id`)     REFERENCES `core_sites` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_blog_post_cat`    FOREIGN KEY (`category_id`) REFERENCES `blog_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_blog_post_author` FOREIGN KEY (`author_id`)   REFERENCES `blog_authors` (`id`)     ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_post_tags` (
  `post_id` int(11) NOT NULL,
  `tag_id`  int(11) NOT NULL,
  PRIMARY KEY (`post_id`, `tag_id`),
  CONSTRAINT `fk_blog_post_tags_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_blog_post_tags_tag`  FOREIGN KEY (`tag_id`)  REFERENCES `blog_tags` (`id`)  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_related_posts` (
  `post_id`         int(11) NOT NULL,
  `related_post_id` int(11) NOT NULL,
  PRIMARY KEY (`post_id`, `related_post_id`),
  CONSTRAINT `fk_blog_rel_post`    FOREIGN KEY (`post_id`)         REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_blog_rel_related` FOREIGN KEY (`related_post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_posts_versions` (
  `id`         int(11) NOT NULL AUTO_INCREMENT,
  `post_id`    int(11) NOT NULL,
  `title`      varchar(255) NOT NULL,
  `content`    longtext NOT NULL,
  `status`     enum('draft','review','published','archived') NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_blog_ver_post` (`post_id`, `created_at`),
  CONSTRAINT `fk_blog_ver_post`   FOREIGN KEY (`post_id`)    REFERENCES `blog_posts` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_blog_ver_author` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `blog_comments` (
  `id`           int(11) NOT NULL AUTO_INCREMENT,
  `post_id`      int(11) NOT NULL,
  `parent_id`    int(11) DEFAULT NULL,
  `author_name`  varchar(150) NOT NULL,
  `author_email` varchar(255) NOT NULL,
  `content`      text NOT NULL,
  `status`       enum('pending','approved','spam') NOT NULL DEFAULT 'pending',
  `created_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_blog_comment_post` (`post_id`, `status`),
  CONSTRAINT `fk_blog_comment_post`   FOREIGN KEY (`post_id`)   REFERENCES `blog_posts` (`id`)    ON DELETE CASCADE,
  CONSTRAINT `fk_blog_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `blog_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. ALT FORMATION
-- =============================================================================

CREATE TABLE IF NOT EXISTS `formation_categories` (
  `id`             int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`        int(11) NOT NULL DEFAULT 1,
  `slug`           varchar(80) NOT NULL,
  `label`          varchar(150) NOT NULL,
  `description`    text DEFAULT NULL,
  `catalogue_type` enum('longue','courte','certifiante','all') NOT NULL DEFAULT 'all',
  `sort_order`     int(11) NOT NULL DEFAULT 0,
  `is_active`      tinyint(1) NOT NULL DEFAULT 1,
  `created_at`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_form_cat_site_slug` (`site_id`, `slug`),
  INDEX `idx_form_cat_active` (`site_id`, `is_active`, `sort_order`),
  CONSTRAINT `fk_form_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formations` (
  `id`                       int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`                  int(11) NOT NULL DEFAULT 1,
  `slug`                     varchar(220) NOT NULL,
  `type`                     enum('longue','courte','certifiante') NOT NULL,
  `category_id`              int(11) UNSIGNED DEFAULT NULL,
  `status`                   enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `published_at`             datetime DEFAULT NULL,
  `hero_title`               varchar(255) NOT NULL,
  `hero_subtitle`            text DEFAULT NULL,
  `hero_video_url`           varchar(512) DEFAULT NULL,
  `hero_image_url`           varchar(512) DEFAULT NULL,
  `card_image_url`           varchar(512) DEFAULT NULL,
  `seo_title`                varchar(255) DEFAULT NULL,
  `seo_description`          text DEFAULT NULL,
  `presentation_title`       varchar(150) DEFAULT 'Le métier',
  `presentation_content`     longtext DEFAULT NULL,
  `presentation_image`       varchar(512) DEFAULT NULL,
  `programme_duration_label` varchar(255) DEFAULT NULL,
  `modalites_catalogue`      longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`modalites_catalogue`)),
  `methodology`              text DEFAULT NULL,
  `certification_label`      varchar(255) DEFAULT NULL,
  `evaluation_title`         varchar(255) DEFAULT NULL,
  `evaluation_description`   text DEFAULT NULL,
  `debouches_title`          varchar(255) DEFAULT NULL,
  `debouches_subtitle`       text DEFAULT NULL,
  `debouches_sectors`        text DEFAULT NULL,
  `info_modalities_title`    varchar(150) DEFAULT 'Modalités pratiques',
  `info_prerequisites_title` varchar(150) DEFAULT 'Prérequis',
  `cta_title`                varchar(255) DEFAULT NULL,
  `cta_subtitle`             text DEFAULT NULL,
  `cta_button_label`         varchar(120) DEFAULT NULL,
  `cta_button_url`           varchar(255) DEFAULT '/contact',
  `cta_secondary_label`      varchar(120) DEFAULT NULL,
  `cta_secondary_url`        varchar(255) DEFAULT NULL,
  `internal_reference`       varchar(80) DEFAULT NULL,
  `sort_order`               int(11) NOT NULL DEFAULT 0,
  `created_by`               int(11) DEFAULT NULL,
  `updated_by`               int(11) DEFAULT NULL,
  `created_at`               datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`               datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_formation_site_slug` (`site_id`, `slug`),
  INDEX `idx_formation_catalogue` (`site_id`, `type`, `status`, `published_at`),
  CONSTRAINT `fk_formation_site`       FOREIGN KEY (`site_id`)     REFERENCES `core_sites` (`id`)             ON DELETE CASCADE,
  CONSTRAINT `fk_formation_category`   FOREIGN KEY (`category_id`) REFERENCES `formation_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_formation_created_by` FOREIGN KEY (`created_by`)  REFERENCES `core_admin_users` (`id`)       ON DELETE SET NULL,
  CONSTRAINT `fk_formation_updated_by` FOREIGN KEY (`updated_by`)  REFERENCES `core_admin_users` (`id`)       ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formation_stats` (
  `id`           int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `label`        varchar(80) NOT NULL,
  `value`        varchar(255) NOT NULL,
  `icon`         varchar(40) DEFAULT NULL,
  `sort_order`   int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_form_stats` (`formation_id`, `sort_order`),
  CONSTRAINT `fk_formation_stats` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formation_modules` (
  `id`             int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `formation_id`   int(11) UNSIGNED NOT NULL,
  `title`          varchar(255) NOT NULL,
  `duration_label` varchar(80) DEFAULT NULL,
  `description`    text DEFAULT NULL,
  `sort_order`     int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_form_modules` (`formation_id`, `sort_order`),
  CONSTRAINT `fk_formation_modules` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formation_list_items` (
  `id`           int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `list_type`    enum('competence','objectif','metier_vise','evaluation_step','info_modalite','info_prerequis') NOT NULL,
  `content`      text NOT NULL,
  `sort_order`   int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_form_list` (`formation_id`, `list_type`, `sort_order`),
  CONSTRAINT `fk_formation_list_items` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formation_job_outcomes` (
  `id`           int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `job_title`    varchar(255) NOT NULL,
  `salary_label` varchar(120) DEFAULT 'Selon expérience',
  `sort_order`   int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_form_jobs` (`formation_id`, `sort_order`),
  CONSTRAINT `fk_formation_job_outcomes` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `formation_official_certifications` (
  `id`                         int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `formation_id`               int(11) UNSIGNED NOT NULL,
  `repertoire`                 enum('RNCP','RS') NOT NULL DEFAULT 'RNCP',
  `code`                       varchar(20) NOT NULL,
  `official_title`             varchar(255) NOT NULL,
  `level`                      tinyint(3) UNSIGNED DEFAULT NULL,
  `france_competences_url`     varchar(512) NOT NULL,
  `show_on_certification_page` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_formation_cert` (`formation_id`, `repertoire`),
  INDEX `idx_official_cert_code` (`repertoire`, `code`),
  CONSTRAINT `fk_formation_official_cert` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 4. RECRUTEMENT & MÉDICAL
-- =============================================================================

CREATE TABLE IF NOT EXISTS `users` (
  `id`                 int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `email`              varchar(255) NOT NULL,
  `password_hash`      varchar(255) DEFAULT NULL,
  `role`               enum('candidat','recruteur','consultant') NOT NULL,
  `email_verifie`      tinyint(1) NOT NULL DEFAULT 0,
  `actif`              tinyint(1) NOT NULL DEFAULT 1,
  `derniere_connexion` datetime DEFAULT NULL,
  `created_at`         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`         datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_email` (`email`),
  INDEX `idx_users_role` (`role`, `actif`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `secteurs_activite` (
  `id`      int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) DEFAULT NULL,
  `slug`    varchar(100) NOT NULL,
  `label`   varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_secteur_slug` (`slug`),
  INDEX `idx_secteur_site` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `entreprises` (
  `id`          int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`     int(11) DEFAULT NULL,
  `nom`         varchar(200) NOT NULL,
  `slug`        varchar(200) NOT NULL,
  `siret`       varchar(14) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `logo_url`    varchar(500) DEFAULT NULL,
  `site_web`    varchar(500) DEFAULT NULL,
  `taille`      enum('1-10','11-50','51-200','201-500','500+') DEFAULT NULL,
  `secteur_id`  int(11) UNSIGNED DEFAULT NULL,
  `adresse`     varchar(300) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `ville`       varchar(100) DEFAULT NULL,
  `departement` varchar(5) DEFAULT NULL,
  `region`      varchar(100) DEFAULT NULL,
  `validee`     tinyint(1) NOT NULL DEFAULT 0,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_entreprise_slug`  (`slug`),
  UNIQUE KEY `uq_entreprise_siret` (`siret`),
  INDEX `idx_entreprise_ville` (`ville`),
  INDEX `idx_entreprise_site` (`site_id`),
  CONSTRAINT `fk_entreprise_secteur` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs_activite` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recruteurs` (
  `id`            int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`       int(11) UNSIGNED DEFAULT NULL,
  `entreprise_id` int(11) UNSIGNED NOT NULL,
  `prenom`        varchar(100) NOT NULL,
  `nom`           varchar(100) NOT NULL,
  `fonction`      varchar(150) DEFAULT NULL,
  `telephone`     varchar(20) DEFAULT NULL,
  `principal`     tinyint(1) NOT NULL DEFAULT 0,
  `statut`        enum('actif','suspendu') NOT NULL DEFAULT 'actif',
  `created_at`    datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_recruteur_user` (`user_id`),
  INDEX `idx_recruteur_entreprise` (`entreprise_id`),
  CONSTRAINT `fk_recruteur_user`       FOREIGN KEY (`user_id`)       REFERENCES `users` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_recruteur_entreprise` FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `metiers` (
  `id`             int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`        int(11) DEFAULT NULL,
  `code_rome`      varchar(20) DEFAULT NULL,
  `slug`           varchar(150) NOT NULL,
  `libelle`        varchar(200) NOT NULL,
  `description`    text DEFAULT NULL,
  `famille_metier` varchar(150) DEFAULT NULL,
  `secteur_id`     int(11) UNSIGNED DEFAULT NULL,
  `niveau_etudes`  varchar(100) DEFAULT NULL,
  `perspectives`   text DEFAULT NULL,
  `actif`          tinyint(1) NOT NULL DEFAULT 1,
  `created_at`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_metier_site_slug` (`site_id`, `slug`),
  INDEX `idx_metier_actif` (`site_id`, `actif`),
  FULLTEXT INDEX `ft_metier` (`libelle`, `description`),
  CONSTRAINT `fk_metier_site`    FOREIGN KEY (`site_id`)    REFERENCES `core_sites` (`id`)         ON DELETE CASCADE,
  CONSTRAINT `fk_metier_secteur` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs_activite` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `competences` (
  `id`        int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`      varchar(100) NOT NULL,
  `label`     varchar(150) NOT NULL,
  `categorie` enum('technique','soft_skill','langue','outil','certification') NOT NULL DEFAULT 'technique',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_competence_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `metier_competences` (
  `metier_id`     int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `importance`    enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle',
  PRIMARY KEY (`metier_id`, `competence_id`),
  CONSTRAINT `fk_mc_metier`     FOREIGN KEY (`metier_id`)     REFERENCES `metiers` (`id`)     ON DELETE CASCADE,
  CONSTRAINT `fk_mc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidats` (
  `id`                        int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                   int(11) UNSIGNED NOT NULL,
  `prenom`                    varchar(100) NOT NULL,
  `nom`                       varchar(100) NOT NULL,
  `telephone`                 varchar(20) DEFAULT NULL,
  `date_naissance`            date DEFAULT NULL,
  `situation_professionnelle` enum('salarie','demandeur_emploi','independant','cadre_reconversion','parent_reprise','autre') DEFAULT NULL,
  `resume_court`              varchar(500) DEFAULT NULL,
  `ville`                     varchar(100) DEFAULT NULL,
  `code_postal`               varchar(10) DEFAULT NULL,
  `region`                    varchar(100) DEFAULT NULL,
  `mobilite_km`               smallint(6) DEFAULT NULL,
  `teletravail_souhaite`      enum('non','partiel','total','indifferent') DEFAULT 'indifferent',
  `disponibilite`             date DEFAULT NULL,
  `recherche_active`          tinyint(1) NOT NULL DEFAULT 1,
  `salaire_souhaite_min`      int(11) UNSIGNED DEFAULT NULL,
  `type_contrat_souhaite`     set('cdi','cdd','interim','alternance','freelance','stage') DEFAULT NULL,
  `rgpd_consent_at`           datetime NOT NULL,
  `profil_public`             tinyint(1) NOT NULL DEFAULT 0,
  `cv_url`                    varchar(500) DEFAULT NULL,
  `champs_specifiques_json`   JSON DEFAULT NULL,
  `experience_annees`         smallint(5) UNSIGNED DEFAULT NULL,
  `niveau_etudes`             varchar(100) DEFAULT NULL,
  `created_at`                datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`                datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`                datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_candidat_user` (`user_id`),
  INDEX `idx_candidat_ville`     (`ville`),
  INDEX `idx_candidat_recherche` (`recherche_active`, `profil_public`),
  CONSTRAINT `fk_candidat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidat_metiers_souhaites` (
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `metier_id`   int(11) UNSIGNED NOT NULL,
  `priorite`    tinyint(4) NOT NULL DEFAULT 1,
  `source`      enum('bilan','manuel','suggestion') NOT NULL DEFAULT 'manuel',
  PRIMARY KEY (`candidat_id`, `metier_id`),
  CONSTRAINT `fk_cms_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cms_metier`   FOREIGN KEY (`metier_id`)   REFERENCES `metiers` (`id`)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidat_competences` (
  `candidat_id`   int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `niveau`        enum('debutant','intermediaire','confirme','expert') NOT NULL DEFAULT 'intermediaire',
  `annees`        tinyint(3) UNSIGNED DEFAULT NULL,
  PRIMARY KEY (`candidat_id`, `competence_id`),
  CONSTRAINT `fk_cc_candidat`   FOREIGN KEY (`candidat_id`)   REFERENCES `candidats` (`id`)   ON DELETE CASCADE,
  CONSTRAINT `fk_cc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidat_experiences` (
  `id`          int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `metier_id`   int(11) UNSIGNED DEFAULT NULL,
  `entreprise`  varchar(200) NOT NULL,
  `poste`       varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `date_debut`  date NOT NULL,
  `date_fin`    date DEFAULT NULL,
  `en_cours`    tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_exp_candidat` (`candidat_id`),
  CONSTRAINT `fk_exp_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exp_metier`   FOREIGN KEY (`metier_id`)   REFERENCES `metiers` (`id`)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidat_formations` (
  `id`              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `candidat_id`     int(11) UNSIGNED NOT NULL,
  `diplome`         varchar(200) NOT NULL,
  `etablissement`   varchar(200) DEFAULT NULL,
  `annee_obtention` smallint(6) DEFAULT NULL,
  `niveau`          enum('cap','bac','bac+2','bac+3','bac+5','doctorat','certification') DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_form_candidat` (`candidat_id`),
  CONSTRAINT `fk_form_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offres_emploi` (
  `id`               int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`          int(11) NOT NULL,
  `entreprise_id`    int(11) UNSIGNED NOT NULL,
  `recruteur_id`     int(11) UNSIGNED DEFAULT NULL,
  `metier_id`        int(11) UNSIGNED DEFAULT NULL,
  `reference`        varchar(50) DEFAULT NULL,
  `slug`             varchar(250) NOT NULL,
  `titre`            varchar(300) NOT NULL,
  `description`      longtext NOT NULL,
  `profil_recherche` text DEFAULT NULL,
  `avantages`        text DEFAULT NULL,
  `type_contrat`     enum('cdi','cdd','interim','alternance','freelance','stage') NOT NULL,
  `experience_min`   enum('debutant','1-2','3-5','5-10','10+') DEFAULT NULL,
  `salaire_min`      int(11) UNSIGNED DEFAULT NULL,
  `salaire_max`      int(11) UNSIGNED DEFAULT NULL,
  `salaire_afficher` tinyint(1) NOT NULL DEFAULT 1,
  `teletravail`      enum('non','partiel','total') NOT NULL DEFAULT 'non',
  `temps_travail`    enum('temps_plein','temps_partiel','variable') NOT NULL DEFAULT 'temps_plein',
  `ville`            varchar(100) DEFAULT NULL,
  `code_postal`      varchar(10) DEFAULT NULL,
  `departement`      varchar(5) DEFAULT NULL,
  `region`           varchar(100) DEFAULT NULL,
  `is_featured`      tinyint(1) NOT NULL DEFAULT 0,
  `is_urgent`        tinyint(1) NOT NULL DEFAULT 0,
  `statut`           enum('en_attente','brouillon','publiee','pourvue','expiree','archivee','refusee') NOT NULL DEFAULT 'brouillon',
  `source_soumission` enum('admin','employeur') NOT NULL DEFAULT 'admin',
  `motif_refus`      text DEFAULT NULL,
  `soumis_par_email` varchar(255) DEFAULT NULL,
  `date_publication` datetime DEFAULT NULL,
  `date_expiration`  datetime DEFAULT NULL,
  `vues`             int(11) UNSIGNED NOT NULL DEFAULT 0,
  `meta_title`       varchar(70) DEFAULT NULL,
  `meta_description` varchar(160) DEFAULT NULL,
  `criteres_json`    JSON DEFAULT NULL,
  `disponibilite`    varchar(100) DEFAULT NULL,
  `created_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_offre_site_slug` (`site_id`, `slug`),
  INDEX `idx_offre_site_statut` (`site_id`, `statut`, `date_publication`),
  INDEX `idx_offre_statut_created` (`statut`, `created_at`),
  INDEX `idx_offre_ville`       (`ville`),
  FULLTEXT INDEX `ft_offre` (`titre`, `description`, `profil_recherche`),
  CONSTRAINT `fk_offre_site`       FOREIGN KEY (`site_id`)       REFERENCES `core_sites` (`id`)    ON DELETE CASCADE,
  CONSTRAINT `fk_offre_entreprise` FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`)   ON DELETE CASCADE,
  CONSTRAINT `fk_offre_recruteur`  FOREIGN KEY (`recruteur_id`)  REFERENCES `recruteurs` (`id`)    ON DELETE SET NULL,
  CONSTRAINT `fk_offre_metier`     FOREIGN KEY (`metier_id`)     REFERENCES `metiers` (`id`)       ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offre_competences` (
  `offre_id`      int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `importance`    enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle',
  PRIMARY KEY (`offre_id`, `competence_id`),
  CONSTRAINT `fk_oc_offre`      FOREIGN KEY (`offre_id`)      REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_oc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidatures` (
  `id`                 int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `offre_id`           int(11) UNSIGNED NOT NULL,
  `candidat_id`        int(11) UNSIGNED NOT NULL,
  `message_motivation` text DEFAULT NULL,
  `notes_recruteur`    text DEFAULT NULL,
  `statut`             enum('recue','vue','shortlist','entretien','offre','refusee','retiree') NOT NULL DEFAULT 'recue',
  `score_affinite`     tinyint(3) UNSIGNED DEFAULT NULL,
  `score_detail_json`  JSON DEFAULT NULL,
  `source`             enum('site','bilan','alerte','recommandation') NOT NULL DEFAULT 'site',
  `date_candidature`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`         datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_candidature` (`offre_id`, `candidat_id`),
  INDEX `idx_candidature_statut` (`statut`, `date_candidature`),
  INDEX `idx_candidature_score` (`offre_id`, `score_affinite`),
  CONSTRAINT `fk_cand_offre`    FOREIGN KEY (`offre_id`)    REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cand_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`)     ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidatures_externes` (
  `id`                int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `offre_id`          int(11) UNSIGNED NOT NULL,
  `site_id`           int(11) NOT NULL,
  `prenom`            varchar(100) NOT NULL,
  `nom`               varchar(100) NOT NULL,
  `email`             varchar(255) NOT NULL,
  `telephone`         varchar(20) DEFAULT NULL,
  `lettre_motivation` text DEFAULT NULL,
  `linkedin_url`      varchar(500) DEFAULT NULL,
  `cv_url`            varchar(500) DEFAULT NULL,
  `champs_specifiques_json` JSON DEFAULT NULL,
  `experience_annees` smallint(5) UNSIGNED DEFAULT NULL,
  `niveau_etudes`     varchar(100) DEFAULT NULL,
  `statut`            enum('recue','vue','shortlist','entretien','offre','refusee') NOT NULL DEFAULT 'recue',
  `score_affinite`    tinyint(3) UNSIGNED DEFAULT NULL,
  `score_detail_json` JSON DEFAULT NULL,
  `notes_rh`          text DEFAULT NULL,
  `rgpd_consent_at`   datetime NOT NULL,
  `created_at`        datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_cand_ext_offre` (`offre_id`, `statut`),
  INDEX `idx_candext_score` (`offre_id`, `score_affinite`),
  CONSTRAINT `fk_candext_offre` FOREIGN KEY (`offre_id`) REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_candext_site` FOREIGN KEY (`site_id`)  REFERENCES `core_sites` (`id`)   ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `candidature_historique` (
  `id`              int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `candidature_id`  int(11) UNSIGNED NOT NULL,
  `ancien_statut`   varchar(50) DEFAULT NULL,
  `nouveau_statut`  varchar(50) NOT NULL,
  `commentaire`     text DEFAULT NULL,
  `auteur_user_id`  int(11) UNSIGNED DEFAULT NULL,
  `auteur_admin_id` int(11) DEFAULT NULL,
  `created_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_hist_candidature` (`candidature_id`, `created_at`),
  CONSTRAINT `fk_hist_candidature` FOREIGN KEY (`candidature_id`)  REFERENCES `candidatures` (`id`)      ON DELETE CASCADE,
  CONSTRAINT `fk_hist_user`        FOREIGN KEY (`auteur_user_id`)  REFERENCES `users` (`id`)              ON DELETE SET NULL,
  CONSTRAINT `fk_hist_admin`       FOREIGN KEY (`auteur_admin_id`) REFERENCES `core_admin_users` (`id`)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `offres_favorites` (
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `offre_id`    int(11) UNSIGNED NOT NULL,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`candidat_id`, `offre_id`),
  CONSTRAINT `fk_fav_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_fav_offre`    FOREIGN KEY (`offre_id`)    REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `alertes_emploi` (
  `id`            int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `candidat_id`   int(11) UNSIGNED NOT NULL,
  `metier_id`     int(11) UNSIGNED DEFAULT NULL,
  `mots_cles`     varchar(300) DEFAULT NULL,
  `ville`         varchar(100) DEFAULT NULL,
  `rayon_km`      smallint(6) DEFAULT NULL,
  `type_contrat`  enum('cdi','cdd','interim','alternance','freelance','stage') DEFAULT NULL,
  `frequence`     enum('quotidienne','hebdomadaire') NOT NULL DEFAULT 'hebdomadaire',
  `active`        tinyint(1) NOT NULL DEFAULT 1,
  `dernier_envoi` datetime DEFAULT NULL,
  `created_at`    datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_alerte_active` (`candidat_id`, `active`),
  CONSTRAINT `fk_alerte_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_alerte_metier`   FOREIGN KEY (`metier_id`)   REFERENCES `metiers` (`id`)   ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 5. TRAINERS
-- =============================================================================

CREATE TABLE IF NOT EXISTS `expertises` (
  `id`          int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        varchar(80) NOT NULL,
  `label`       varchar(120) NOT NULL,
  `subtitle`    varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `sort_order`  int(11) NOT NULL DEFAULT 0,
  `is_active`   tinyint(1) NOT NULL DEFAULT 1,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_expertise_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_skills` (
  `id`   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trainer_skill_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_certifications` (
  `id`   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trainer_cert_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_cities` (
  `id`          int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`        varchar(80) NOT NULL,
  `name`        varchar(100) NOT NULL,
  `region`      varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active`   tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trainer_city_slug` (`slug`),
  INDEX `idx_trainer_city_region` (`region`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_languages` (
  `id`   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trainer_lang_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainers` (
  `id`                   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`                 varchar(120) DEFAULT NULL,
  `first_name`           varchar(80) NOT NULL,
  `last_name`            varchar(80) NOT NULL,
  `title`                varchar(200) NOT NULL,
  `tagline`              varchar(300) DEFAULT NULL,
  `bio`                  text DEFAULT NULL,
  `avatar_initials`      varchar(4) DEFAULT NULL,
  `avatar_url`           varchar(512) DEFAULT NULL,
  `city_id`              int(11) UNSIGNED DEFAULT NULL,
  `experience_years`     int(11) NOT NULL DEFAULT 0,
  `tjm_eur`              decimal(10,2) DEFAULT NULL,
  `availability`         enum('available','soon','unavailable') DEFAULT 'available',
  `legal_status`         enum('auto_entrepreneur','sasu','eurl','portage_salarial','other') DEFAULT NULL,
  `primary_expertise_id` int(11) UNSIGNED DEFAULT NULL,
  `email`                varchar(255) NOT NULL,
  `phone`                varchar(30) DEFAULT NULL,
  `linkedin_url`         varchar(512) DEFAULT NULL,
  `status`               enum('draft','pending_review','active','inactive','rejected') DEFAULT 'pending_review',
  `is_featured`          tinyint(1) NOT NULL DEFAULT 0,
  `qualiopi_eligible`    tinyint(1) NOT NULL DEFAULT 0,
  `rating_avg`           decimal(2,1) NOT NULL DEFAULT 0.0,
  `reviews_count`        int(11) NOT NULL DEFAULT 0,
  `published_at`         datetime DEFAULT NULL,
  `created_at`           datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`           datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`           datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_trainer_email` (`email`),
  UNIQUE KEY `uq_trainer_slug`  (`slug`),
  INDEX `idx_trainers_catalog` (`status`, `availability`, `rating_avg`),
  CONSTRAINT `fk_trainer_city`      FOREIGN KEY (`city_id`)              REFERENCES `trainer_cities` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_trainer_expertise` FOREIGN KEY (`primary_expertise_id`) REFERENCES `expertises` (`id`)    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_expertise_links` (
  `trainer_id`   int(11) UNSIGNED NOT NULL,
  `expertise_id` int(11) UNSIGNED NOT NULL,
  `is_primary`   tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`trainer_id`, `expertise_id`),
  CONSTRAINT `fk_tel_trainer`   FOREIGN KEY (`trainer_id`)   REFERENCES `trainers` (`id`)   ON DELETE CASCADE,
  CONSTRAINT `fk_tel_expertise` FOREIGN KEY (`expertise_id`) REFERENCES `expertises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_skill_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `skill_id`   int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`trainer_id`, `skill_id`),
  CONSTRAINT `fk_tsl_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_tsl_skill`   FOREIGN KEY (`skill_id`)   REFERENCES `trainer_skills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_certification_links` (
  `trainer_id`       int(11) UNSIGNED NOT NULL,
  `certification_id` int(11) UNSIGNED NOT NULL,
  `obtained_at`      date DEFAULT NULL,
  `expires_at`       date DEFAULT NULL,
  PRIMARY KEY (`trainer_id`, `certification_id`),
  CONSTRAINT `fk_tcl_trainer` FOREIGN KEY (`trainer_id`)       REFERENCES `trainers` (`id`)             ON DELETE CASCADE,
  CONSTRAINT `fk_tcl_cert`    FOREIGN KEY (`certification_id`) REFERENCES `trainer_certifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_modalities` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `modality`   enum('presentiel','distanciel','hybride') NOT NULL,
  PRIMARY KEY (`trainer_id`, `modality`),
  CONSTRAINT `fk_tmod_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_language_links` (
  `trainer_id`  int(11) UNSIGNED NOT NULL,
  `language_id` int(11) UNSIGNED NOT NULL,
  `level`       varchar(20) DEFAULT 'native',
  PRIMARY KEY (`trainer_id`, `language_id`),
  CONSTRAINT `fk_tll_trainer` FOREIGN KEY (`trainer_id`)  REFERENCES `trainers` (`id`)          ON DELETE CASCADE,
  CONSTRAINT `fk_tll_lang`    FOREIGN KEY (`language_id`) REFERENCES `trainer_languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_city_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `city_id`    int(11) UNSIGNED NOT NULL,
  PRIMARY KEY (`trainer_id`, `city_id`),
  CONSTRAINT `fk_tcityl_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`)       ON DELETE CASCADE,
  CONSTRAINT `fk_tcityl_city`    FOREIGN KEY (`city_id`)    REFERENCES `trainer_cities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_courses` (
  `id`               int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id`       int(11) UNSIGNED NOT NULL,
  `title`            varchar(200) NOT NULL,
  `duration_label`   varchar(50) DEFAULT NULL,
  `duration_days`    decimal(4,1) DEFAULT NULL,
  `level`            enum('debutant','intermediaire','avance','expert') DEFAULT NULL,
  `participants_min` int(11) DEFAULT NULL,
  `participants_max` int(11) DEFAULT NULL,
  `description`      text DEFAULT NULL,
  `is_active`        tinyint(1) NOT NULL DEFAULT 1,
  `sort_order`       int(11) NOT NULL DEFAULT 0,
  `created_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tcourse_trainer` (`trainer_id`, `is_active`),
  CONSTRAINT `fk_tcourse_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_reviews` (
  `id`           int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `trainer_id`   int(11) UNSIGNED NOT NULL,
  `author_name`  varchar(100) NOT NULL,
  `company`      varchar(150) DEFAULT NULL,
  `rating`       smallint(6) NOT NULL CHECK (`rating` BETWEEN 1 AND 5),
  `comment`      text NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_treview_trainer` (`trainer_id`, `is_published`),
  CONSTRAINT `fk_treview_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `trainer_applications` (
  `id`                   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name`           varchar(80) NOT NULL,
  `last_name`            varchar(80) NOT NULL,
  `email`                varchar(255) NOT NULL,
  `phone`                varchar(30) DEFAULT NULL,
  `linkedin_url`         varchar(512) DEFAULT NULL,
  `primary_expertise_id` int(11) UNSIGNED DEFAULT NULL,
  `experience_range`     varchar(20) DEFAULT NULL,
  `experience_years`     int(11) DEFAULT NULL,
  `tjm_requested`        decimal(10,2) DEFAULT NULL,
  `certifications_text`  text DEFAULT NULL,
  `message`              text DEFAULT NULL,
  `status`               enum('new','in_review','interview','approved','rejected') NOT NULL DEFAULT 'new',
  `reviewed_by`          int(11) DEFAULT NULL,
  `reviewed_at`          datetime DEFAULT NULL,
  `trainer_id`           int(11) UNSIGNED DEFAULT NULL,
  `created_at`           datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tapp_status` (`status`, `created_at`),
  CONSTRAINT `fk_tapp_expertise` FOREIGN KEY (`primary_expertise_id`) REFERENCES `expertises` (`id`)       ON DELETE SET NULL,
  CONSTRAINT `fk_tapp_reviewer`  FOREIGN KEY (`reviewed_by`)          REFERENCES `core_admin_users` (`id`)  ON DELETE SET NULL,
  CONSTRAINT `fk_tapp_trainer`   FOREIGN KEY (`trainer_id`)           REFERENCES `trainers` (`id`)          ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP VIEW IF EXISTS `v_trainers_catalog`;
CREATE VIEW `v_trainers_catalog` AS
SELECT
  t.id, t.slug,
  CONCAT(t.first_name, ' ', t.last_name) AS name,
  t.title, t.bio, t.avatar_initials, t.avatar_url,
  t.tjm_eur AS tjm, t.experience_years AS experience,
  t.availability, t.rating_avg AS rating, t.reviews_count AS reviews,
  t.created_at,
  COALESCE(GROUP_CONCAT(DISTINCT c_link.region ORDER BY c_link.region SEPARATOR ', '), c_main.region) AS region,
  COALESCE(GROUP_CONCAT(DISTINCT c_link.name ORDER BY c_link.name SEPARATOR ', '), c_main.name) AS cities,
  COALESCE((SELECT c2.slug FROM trainer_city_links tcl2 JOIN trainer_cities c2 ON c2.id = tcl2.city_id WHERE tcl2.trainer_id = t.id LIMIT 1), c_main.slug) AS city_slug,
  GROUP_CONCAT(DISTINCT e.label ORDER BY e.label SEPARATOR ', ') AS expertise,
  GROUP_CONCAT(DISTINCT sk.name ORDER BY sk.name SEPARATOR ', ') AS skills,
  GROUP_CONCAT(DISTINCT cert.name ORDER BY cert.name SEPARATOR ', ') AS certifications,
  GROUP_CONCAT(DISTINCT tm.modality SEPARATOR ', ') AS modalities
FROM trainers t
LEFT JOIN trainer_cities c_main ON c_main.id = t.city_id
LEFT JOIN trainer_city_links tcl ON tcl.trainer_id = t.id
LEFT JOIN trainer_cities c_link ON c_link.id = tcl.city_id
LEFT JOIN trainer_expertise_links tel ON tel.trainer_id = t.id
LEFT JOIN expertises e ON e.id = tel.expertise_id
LEFT JOIN trainer_skill_links tsl ON tsl.trainer_id = t.id
LEFT JOIN trainer_skills sk ON sk.id = tsl.skill_id
LEFT JOIN trainer_certification_links tc ON tc.trainer_id = t.id
LEFT JOIN trainer_certifications cert ON cert.id = tc.certification_id
LEFT JOIN trainer_modalities tm ON tm.trainer_id = t.id
WHERE t.status = 'active' AND t.deleted_at IS NULL
GROUP BY t.id, t.slug, t.first_name, t.last_name, t.title, t.bio,
  t.avatar_initials, t.avatar_url, t.tjm_eur, t.experience_years,
  t.availability, t.rating_avg, t.reviews_count, t.created_at,
  c_main.name, c_main.slug, c_main.region;

-- =============================================================================
-- 6. NEWSLETTER
-- =============================================================================

CREATE TABLE IF NOT EXISTS `newsletter_lists` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_nl_list_slug` (`site_id`, `slug`),
  CONSTRAINT `fk_nl_list_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletter_subscribers` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `status` enum('pending','active','unsubscribed','bounced','complained') NOT NULL DEFAULT 'pending',
  `confirm_token` varchar(128) DEFAULT NULL,
  `confirm_token_expires_at` datetime DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `unsubscribed_at` datetime DEFAULT NULL,
  `unsubscribe_reason` varchar(255) DEFAULT NULL,
  `rgpd_consent_at` datetime NOT NULL,
  `rgpd_consent_ip` varchar(45) DEFAULT NULL,
  `user_id` int(11) UNSIGNED DEFAULT NULL,
  `source` enum('form','import','api','candidat','checkout') NOT NULL DEFAULT 'form',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_subscriber_site_email` (`site_id`, `email`),
  INDEX `idx_subscriber_status` (`site_id`, `status`),
  CONSTRAINT `fk_nl_sub_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nl_sub_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletter_subscriptions` (
  `subscriber_id` int(11) UNSIGNED NOT NULL,
  `list_id` int(11) UNSIGNED NOT NULL,
  `subscribed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `unsubscribed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`subscriber_id`, `list_id`),
  CONSTRAINT `fk_nl_sub_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscribers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nl_sub_list` FOREIGN KEY (`list_id`) REFERENCES `newsletter_lists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletter_campaigns` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `list_id` int(11) UNSIGNED DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `preview_text` varchar(255) DEFAULT NULL,
  `content_html` longtext NOT NULL,
  `content_text` longtext DEFAULT NULL,
  `status` enum('draft','scheduled','sending','sent','cancelled') NOT NULL DEFAULT 'draft',
  `scheduled_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `recipients_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `opens_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `clicks_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `bounces_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `unsubscribes_count` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_campaign_status` (`site_id`, `status`),
  CONSTRAINT `fk_nl_camp_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nl_camp_list` FOREIGN KEY (`list_id`) REFERENCES `newsletter_lists` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_nl_camp_created_by` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletter_events` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) UNSIGNED NOT NULL,
  `subscriber_id` int(11) UNSIGNED NOT NULL,
  `event_type` enum('sent','opened','clicked','bounced','complained','unsubscribed') NOT NULL,
  `url_clicked` varchar(500) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_nl_event_campaign` (`campaign_id`, `event_type`),
  CONSTRAINT `fk_nl_evt_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `newsletter_campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nl_evt_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscribers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `newsletter_lists` (`site_id`, `name`, `slug`, `description`) VALUES
(1, 'Newsletter générale', 'generale', 'Actualités Alt Formation'),
(2, 'Alertes emploi', 'alertes', 'Nouvelles offres recrutement'),
(3, 'Alertes médical', 'alertes', 'Offres secteur médical'),
(4, 'Newsletter carrière', 'generale', 'Conseils carrière'),
(5, 'Newsletter trainers', 'generale', 'Actualités formateurs'),
(6, 'Newsletter coaching', 'generale', 'Actualités coaching');

-- =============================================================================
-- 7. RGPD, SEO, EMAIL LOGS
-- =============================================================================

CREATE TABLE IF NOT EXISTS `gdpr_consents_log` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `consent_type` varchar(50) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `granted` tinyint(1) NOT NULL DEFAULT 1,
  `granted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_gdpr_site_type` (`site_id`, `consent_type`, `granted_at`),
  CONSTRAINT `fk_gdpr_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `gdpr_deletion_requests` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `status` enum('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_gdpr_del_status` (`site_id`, `status`),
  CONSTRAINT `fk_gdpr_del_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_gdpr_del_admin` FOREIGN KEY (`processed_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `seo_metadata` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(11) UNSIGNED NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` text DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `schema_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seo_entity` (`site_id`, `entity_type`, `entity_id`),
  CONSTRAINT `fk_seo_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recrutement_scoring_config` (
  `id`                   int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`              int(11) DEFAULT NULL,
  `poids_competences`    tinyint(3) UNSIGNED NOT NULL DEFAULT 40,
  `poids_experience`     tinyint(3) UNSIGNED NOT NULL DEFAULT 25,
  `poids_localisation`   tinyint(3) UNSIGNED NOT NULL DEFAULT 15,
  `poids_diplome`        tinyint(3) UNSIGNED NOT NULL DEFAULT 12,
  `poids_langues`        tinyint(3) UNSIGNED NOT NULL DEFAULT 8,
  `bonus_champs_site`    tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `updated_at`           datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_admin_id`  int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_scoring_site` (`site_id`),
  CONSTRAINT `fk_scoring_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_scoring_admin` FOREIGN KEY (`updated_by_admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recrutement_scoring_history` (
  `id`                  int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id`             int(11) DEFAULT NULL,
  `config_json`         JSON NOT NULL,
  `auteur_admin_id`     int(11) DEFAULT NULL,
  `created_at`          datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_scoring_hist_site` (`site_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `marketing_email_logs` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` int(11) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `template_used` varchar(100) DEFAULT NULL,
  `status` enum('sent','failed','bounced') NOT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email_log_site` (`site_id`, `created_at`),
  CONSTRAINT `fk_email_log_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
