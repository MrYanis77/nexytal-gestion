-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Hôte : db5020658636.hosting-data.io
-- Généré le : mer. 10 juin 2026 à 10:12
-- Version du serveur : 10.11.18-MariaDB-log
-- Version de PHP : 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `dbs15772578`
-- Schéma complet Nexytal v3.0 — 49 tables
-- (gdpr_deletion_requests, media_library, seo_metadata incluses)
--

-- --------------------------------------------------------

--
-- Structure de la table `blog_authors`
--

CREATE TABLE `blog_authors` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `slug` varchar(150) NOT NULL,
  `bio` text DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_categories`
--

CREATE TABLE `blog_categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6366f1',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` smallint(6) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_comments`
--

CREATE TABLE `blog_comments` (
  `id` int(10) UNSIGNED NOT NULL,
  `post_id` int(10) UNSIGNED NOT NULL,
  `parent_id` int(10) UNSIGNED DEFAULT NULL,
  `author_name` varchar(150) NOT NULL,
  `author_email` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `status` enum('pending','approved','spam') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_posts`
--

CREATE TABLE `blog_posts` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `author_id` int(10) UNSIGNED DEFAULT NULL,
  `title` varchar(300) NOT NULL,
  `slug` varchar(300) NOT NULL,
  `excerpt` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `cover_image_url` varchar(500) DEFAULT NULL,
  `read_time_mins` tinyint(3) UNSIGNED DEFAULT NULL,
  `status` enum('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `meta_title` varchar(100) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `views_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_posts_versions`
--

CREATE TABLE `blog_posts_versions` (
  `id` int(10) UNSIGNED NOT NULL,
  `post_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(300) NOT NULL,
  `content` longtext NOT NULL,
  `status` varchar(50) NOT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Historique des versions d''un article';

-- --------------------------------------------------------

--
-- Structure de la table `blog_post_tags`
--

CREATE TABLE `blog_post_tags` (
  `post_id` int(10) UNSIGNED NOT NULL,
  `tag_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_related_posts`
--

CREATE TABLE `blog_related_posts` (
  `post_id` int(10) UNSIGNED NOT NULL,
  `related_post_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Articles liés N:N (auto-excluant par convention applicative)';

-- --------------------------------------------------------

--
-- Structure de la table `blog_tags`
--

CREATE TABLE `blog_tags` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_bookings`
--

CREATE TABLE `coaching_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `coach_id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `booked_for` datetime NOT NULL COMMENT 'Date et heure de la séance',
  `duration_minutes` smallint(6) NOT NULL DEFAULT 60,
  `status` enum('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `internal_notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Réservations de séances de coaching';

-- --------------------------------------------------------

--
-- Structure de la table `coaching_certifications`
--

CREATE TABLE `coaching_certifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(30) NOT NULL,
  `organization` varchar(100) NOT NULL,
  `level` tinyint(4) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_certifications`
--

INSERT INTO `coaching_certifications` (`id`, `code`, `organization`, `level`, `created_at`) VALUES
(1, 'CERT_mq7wqitj', 'Test Org', 1, '2026-06-10 12:10:00'),
(2, 'CERT_mq7wr7vp', 'Test Org', 1, '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_cities`
--

CREATE TABLE `coaching_cities` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(110) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_cities`
--

INSERT INTO `coaching_cities` (`id`, `name`, `slug`, `created_at`) VALUES
(1, 'Ville test mq7wa27a', 'ville-test-mq7wa27a', '2026-06-10 11:57:12'),
(2, 'Ville mq7wqitj', 'ville-mq7wqitj', '2026-06-10 12:10:00'),
(3, 'Ville mq7wr7vp', 'ville-mq7wr7vp', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_coaches`
--

CREATE TABLE `coaching_coaches` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `slug` varchar(180) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `short_bio` text DEFAULT NULL,
  `full_bio` longtext DEFAULT NULL,
  `experience_years` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `city_id` int(10) UNSIGNED DEFAULT NULL,
  `languages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`languages`)),
  `rating_avg` decimal(3,2) NOT NULL DEFAULT 0.00,
  `reviews_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_available` tinyint(1) NOT NULL DEFAULT 1,
  `status` enum('active','inactive','pending') NOT NULL DEFAULT 'pending',
  `meta_title` varchar(100) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_coach_certifications`
--

CREATE TABLE `coaching_coach_certifications` (
  `coach_id` int(10) UNSIGNED NOT NULL,
  `certification_id` int(10) UNSIGNED NOT NULL,
  `year_obtained` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_coach_specialties`
--

CREATE TABLE `coaching_coach_specialties` (
  `coach_id` int(10) UNSIGNED NOT NULL,
  `specialty_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_diagnostic_requests`
--

CREATE TABLE `coaching_diagnostic_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `coach_id` int(10) UNSIGNED DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(25) DEFAULT NULL,
  `company` varchar(150) DEFAULT NULL,
  `job_title` varchar(150) DEFAULT NULL,
  `coaching_type` varchar(100) NOT NULL,
  `message` text DEFAULT NULL,
  `budget_range` varchar(50) DEFAULT NULL,
  `status` enum('new','contacted','converted','closed') NOT NULL DEFAULT 'new',
  `internal_notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_reviews`
--

CREATE TABLE `coaching_reviews` (
  `id` int(10) UNSIGNED NOT NULL,
  `coach_id` int(10) UNSIGNED NOT NULL,
  `author_name` varchar(150) NOT NULL,
  `author_title` varchar(150) DEFAULT NULL,
  `author_company` varchar(150) DEFAULT NULL,
  `rating` tinyint(4) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text NOT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Avis clients vérifiés';

-- --------------------------------------------------------

--
-- Structure de la table `coaching_specialties`
--

CREATE TABLE `coaching_specialties` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(110) NOT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_specialties`
--

INSERT INTO `coaching_specialties` (`id`, `name`, `slug`, `icon`, `created_at`) VALUES
(1, 'Spécialité mq7wqitj', 'spec-mq7wqitj', 'star', '2026-06-10 12:10:00'),
(2, 'Spécialité mq7wr7vp', 'spec-mq7wr7vp', 'star', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_activity_logs`
--

CREATE TABLE `core_admin_activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `session_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource` varchar(100) DEFAULT NULL,
  `resource_id` int(10) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Journal d''activité admin (actions UI)';

--
-- Déchargement des données de la table `core_admin_activity_logs`
--

INSERT INTO `core_admin_activity_logs` (`id`, `admin_id`, `session_id`, `action`, `resource`, `resource_id`, `ip_address`, `created_at`) VALUES
(1, 1, NULL, 'login_failed', 'auth', NULL, '2a01:cb09:e00b:3e79:442:39ff:2405:e6b7', '2026-06-10 02:13:00'),
(2, 2, NULL, 'login_failed', 'auth', NULL, '2a01:cb09:e00b:3e79:442:39ff:2405:e6b7', '2026-06-10 02:13:23'),
(3, 2, NULL, 'login_failed', 'auth', NULL, '2a01:cb09:e00b:3e79:442:39ff:2405:e6b7', '2026-06-10 02:13:45'),
(4, 2, 1, 'login_success', 'auth', NULL, '2a01:cb09:e00b:3e79:442:39ff:2405:e6b7', '2026-06-10 02:15:16'),
(5, 2, 2, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 10:23:23'),
(6, 2, 3, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 10:29:16'),
(7, 2, 4, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:53:45'),
(8, 2, 5, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:55:23'),
(9, 2, 6, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:56:12'),
(10, 2, 7, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:56:39'),
(11, 2, 8, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:57:11'),
(12, 2, 9, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:58:47'),
(13, 2, 10, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:59:34'),
(14, 2, 11, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:08:10'),
(15, 2, 12, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:09:59'),
(16, 2, 13, 'login_success', 'auth', NULL, '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_sessions`
--

CREATE TABLE `core_admin_sessions` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `token` varchar(128) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(512) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Sessions admin actives';

--
-- Déchargement des données de la table `core_admin_sessions`
--

INSERT INTO `core_admin_sessions` (`id`, `admin_id`, `token`, `ip_address`, `user_agent`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 2, 'f12c7993713d2c08b60c8b6ff2d0ec20057d12c9e6501f6a1e7747d229dd0349', '2a01:cb09:e00b:3e79:442:39ff:2405:e6b7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-11 02:15:16', '2026-06-10 02:15:16', '2026-06-10 02:15:16'),
(2, 2, '749a499814d2c2275caf360efdb558f0ddceed0be5a939592123d1f4d4f0f5e4', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-06-11 10:23:23', '2026-06-10 10:23:23', '2026-06-10 10:23:23'),
(3, 2, 'b44cf6cd2108a7b973daca169decd2566a6c1549af2baa2affd91995dffb2e85', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-06-11 10:29:16', '2026-06-10 10:29:16', '2026-06-10 10:29:16'),
(4, 2, '2829bae563b5f1eea1d6359f4a7ea063aad9b26fc4720fba1c841d6909e9d584', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:53:45', '2026-06-10 11:53:45', '2026-06-10 11:53:45'),
(5, 2, '9884818cac220f7a64f033907a33b5f411449533a8798f23bcd47e5b717a8be1', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:55:23', '2026-06-10 11:55:23', '2026-06-10 11:55:23'),
(6, 2, '45e5bbcf5b1f0464fae009675148d87675826c1955457fa4ca42f73bb86f78d0', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:56:12', '2026-06-10 11:56:12', '2026-06-10 11:56:12'),
(7, 2, '6c1526c2d5dfd283d23fa0bad0a8b9e3604b86bb1224183f7a09b48e6b4e0ac5', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:56:39', '2026-06-10 11:56:39', '2026-06-10 11:56:39'),
(8, 2, 'f24ec6d469dc1a3eda215b5fe3bc81e0b59485184d9a4e792b251d3707801bc9', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:57:11', '2026-06-10 11:57:11', '2026-06-10 11:57:11'),
(9, 2, '947430a535231d352db5bf40995fd18658e30514c29f6f0395e3dcf125d2f34a', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:58:47', '2026-06-10 11:58:47', '2026-06-10 11:58:47'),
(10, 2, '233581ff1ce62896098b65482c6c3221e5eb9ce83de47eb80feefbf02af194cc', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 11:59:34', '2026-06-10 11:59:34', '2026-06-10 11:59:34'),
(11, 2, 'b3be03aae8a6941e652ac97c2d3de00f5e5cf959d8406f215fe4c6eba032e95b', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 12:08:10', '2026-06-10 12:08:10', '2026-06-10 12:08:10'),
(12, 2, '385d53390204684e9d767c593ddbf9c91dbbc1359a1a4d9cbbcdbd5614520a42', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 12:09:59', '2026-06-10 12:09:59', '2026-06-10 12:09:59'),
(13, 2, 'c17e03d0b4bb1112e995ee8aee62fd02ccddf3a147d8367c448c1b5e20150a79', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', 'node', '2026-06-11 12:10:32', '2026-06-10 12:10:32', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_site_access`
--

CREATE TABLE `core_admin_site_access` (
  `admin_id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Droits d''accès admin ↔ site';

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_users`
--

CREATE TABLE `core_admin_users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(500) NOT NULL COMMENT 'bcrypt ou argon2',
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `role` enum('superadmin','admin','editor','moderator','recruiter') NOT NULL DEFAULT 'editor',
  `avatar_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Comptes administrateurs / éditeurs';

--
-- Déchargement des données de la table `core_admin_users`
--

INSERT INTO `core_admin_users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `avatar_url`, `is_active`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'admin', '$2y$10$eImiTXTN9ScbyzC7u4H2POxM712Gj6vG/yq9oWwPkWbH8v00gV6Vq', 'Jean', 'Dupont', 'superadmin', NULL, 1, NULL, '2026-06-10 00:27:53', '2026-06-10 00:27:53'),
(2, 'admin@nexytal.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Super', 'Admin', 'superadmin', NULL, 1, '2026-06-10 12:10:32', '2026-06-10 02:00:18', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `core_audit_logs`
--

CREATE TABLE `core_audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED DEFAULT NULL,
  `site_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `entity_id` int(10) UNSIGNED DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Journal d''audit complet (old/new data JSON)';

--
-- Déchargement des données de la table `core_audit_logs`
--

INSERT INTO `core_audit_logs` (`id`, `admin_id`, `site_id`, `action`, `entity_type`, `entity_id`, `old_data`, `new_data`, `ip_address`, `created_at`) VALUES
(1, 2, NULL, 'create', 'contract_type', 1, NULL, '{\"code\":\"CDI_mq7wa27a\",\"name\":\"CDI Test\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:57:11'),
(2, 2, NULL, 'create', 'coaching_city', 1, NULL, '{\"name\":\"Ville test mq7wa27a\",\"slug\":\"ville-test-mq7wa27a\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 11:57:12'),
(3, 2, NULL, 'create', 'contract_type', 2, NULL, '{\"code\":\"TST_mq7wqitj\",\"name\":\"Type test mq7wqitj\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:09:59'),
(4, 2, NULL, 'create', 'coaching_city', 2, NULL, '{\"name\":\"Ville mq7wqitj\",\"slug\":\"ville-mq7wqitj\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:00'),
(5, 2, NULL, 'create', 'coaching_specialty', 1, NULL, '{\"name\":\"Spécialité mq7wqitj\",\"slug\":\"spec-mq7wqitj\",\"icon\":\"star\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:00'),
(6, 2, NULL, 'create', 'coaching_certification', 1, NULL, '{\"code\":\"CERT_mq7wqitj\",\"organization\":\"Test Org\",\"level\":1}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:00'),
(7, 2, NULL, 'create', 'contract_type', 3, NULL, '{\"code\":\"TST_mq7wr7vp\",\"name\":\"Type test mq7wr7vp\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:32'),
(8, 2, NULL, 'create', 'coaching_city', 3, NULL, '{\"name\":\"Ville mq7wr7vp\",\"slug\":\"ville-mq7wr7vp\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:32'),
(9, 2, NULL, 'create', 'coaching_specialty', 2, NULL, '{\"name\":\"Spécialité mq7wr7vp\",\"slug\":\"spec-mq7wr7vp\",\"icon\":\"star\"}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:32'),
(10, 2, NULL, 'create', 'coaching_certification', 2, NULL, '{\"code\":\"CERT_mq7wr7vp\",\"organization\":\"Test Org\",\"level\":1}', '2a01:cb08:e79:c400:605d:2e6a:72e2:eed8', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `core_password_reset_tokens`
--

CREATE TABLE `core_password_reset_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED NOT NULL,
  `token` varchar(128) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `used_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tokens de réinitialisation de mot de passe';

-- --------------------------------------------------------

--
-- Structure de la table `core_settings`
--

CREATE TABLE `core_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = paramètre global',
  `setting_key` varchar(100) NOT NULL,
  `setting_value` longtext DEFAULT NULL,
  `setting_type` varchar(50) DEFAULT 'string' COMMENT 'string, int, boolean, json',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Paramètres globaux et par site';

-- --------------------------------------------------------

--
-- Structure de la table `core_sites`
--

CREATE TABLE `core_sites` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Les 6 sites Nexytal';

-- --------------------------------------------------------

--
-- Structure de la table `email_logs`
--

CREATE TABLE `email_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `email_type` varchar(50) NOT NULL COMMENT 'newsletter, confirmation, password_reset…',
  `site_id` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('sent','failed','bounced','opened') NOT NULL DEFAULT 'sent',
  `error_message` text DEFAULT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_categories`
--

CREATE TABLE `formation_categories` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_courses`
--

CREATE TABLE `formation_courses` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `category_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `video_url` varchar(500) DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `is_cpf_eligible` tinyint(1) NOT NULL DEFAULT 0,
  `is_alternance` tinyint(1) NOT NULL DEFAULT 0,
  `rncp_repertoire` varchar(50) DEFAULT NULL COMMENT 'ex: RNCP, RS',
  `rncp_code` varchar(50) DEFAULT NULL COMMENT 'ex: 37680',
  `rncp_title` varchar(255) DEFAULT NULL COMMENT 'Intitulé officiel France Compétences',
  `rncp_level` tinyint(4) DEFAULT NULL COMMENT 'Niveau 5=BAC+2, 6=BAC+3…',
  `rncp_url` varchar(500) DEFAULT NULL COMMENT 'Lien France Compétences',
  `presentation_title` varchar(255) DEFAULT 'Le métier',
  `presentation_text` text DEFAULT NULL,
  `cta_title` varchar(255) DEFAULT 'Prêt à vous lancer ?',
  `cta_subtitle` varchar(255) DEFAULT NULL,
  `meta_title` varchar(100) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `updated_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_courses_versions`
--

CREATE TABLE `formation_courses_versions` (
  `id` int(10) UNSIGNED NOT NULL,
  `course_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `presentation_text` text DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_jobs`
--

CREATE TABLE `formation_jobs` (
  `id` int(10) UNSIGNED NOT NULL,
  `course_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(200) NOT NULL,
  `salary_min` decimal(10,2) DEFAULT NULL,
  `salary_max` decimal(10,2) DEFAULT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_modules`
--

CREATE TABLE `formation_modules` (
  `id` int(10) UNSIGNED NOT NULL,
  `course_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_skills`
--

CREATE TABLE `formation_skills` (
  `id` int(10) UNSIGNED NOT NULL,
  `course_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(200) NOT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_consents`
--

CREATE TABLE `gdpr_consents` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_type` enum('applicant','subscriber','review_author','diagnostic_request') NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `consent_type` enum('marketing','analytics','data_processing') NOT NULL,
  `is_given` tinyint(1) NOT NULL,
  `given_at` datetime NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_deletion_requests`
--

CREATE TABLE `gdpr_deletion_requests` (
  `id` int(10) UNSIGNED NOT NULL,
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
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Demandes de suppression / droit à l''oubli RGPD';

-- --------------------------------------------------------

--
-- Structure de la table `marketing_newsletter_subs`
--

CREATE TABLE `marketing_newsletter_subs` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `unsub_token` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `unsub_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `media_library`
--

CREATE TABLE `media_library` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL = média global partagé',
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `file_size` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `alt_text` varchar(255) DEFAULT NULL,
  `uploaded_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Médiathèque centralisée (images, PDF, favicon…)';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_applications`
--

CREATE TABLE `recrutement_applications` (
  `id` int(10) UNSIGNED NOT NULL,
  `offer_id` int(10) UNSIGNED NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `cv_url` varchar(500) DEFAULT NULL,
  `cover_letter` text DEFAULT NULL,
  `linkedin_url` varchar(500) DEFAULT NULL,
  `status` enum('new','reviewing','interview','offer','hired','rejected') NOT NULL DEFAULT 'new',
  `internal_notes` text DEFAULT NULL,
  `gdpr_consent` tinyint(1) NOT NULL DEFAULT 1,
  `gdpr_consent_date` datetime NOT NULL DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_application_history`
--

CREATE TABLE `recrutement_application_history` (
  `id` int(10) UNSIGNED NOT NULL,
  `application_id` int(10) UNSIGNED NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by_id` int(10) UNSIGNED DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pipeline de suivi des candidatures';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_contract_types`
--

CREATE TABLE `recrutement_contract_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `recrutement_contract_types`
--

INSERT INTO `recrutement_contract_types` (`id`, `code`, `name`, `created_at`) VALUES
(1, 'CDI_mq7wa27a', 'CDI Test', '2026-06-10 11:57:11'),
(2, 'TST_mq7wqitj', 'Type test mq7wqitj', '2026-06-10 12:09:59'),
(3, 'TST_mq7wr7vp', 'Type test mq7wr7vp', '2026-06-10 12:10:32');

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_jobs`
--

CREATE TABLE `recrutement_jobs` (
  `id` int(10) UNSIGNED NOT NULL,
  `sector_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_offers`
--

CREATE TABLE `recrutement_offers` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `job_id` int(10) UNSIGNED DEFAULT NULL,
  `contract_type_id` int(10) UNSIGNED NOT NULL,
  `profession_id` int(10) UNSIGNED DEFAULT NULL,
  `title` varchar(250) NOT NULL,
  `slug` varchar(250) NOT NULL,
  `company_name` varchar(200) NOT NULL,
  `location` varchar(200) NOT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `salary_range` varchar(100) DEFAULT NULL,
  `experience_level` varchar(100) DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `is_urgent` tinyint(1) NOT NULL DEFAULT 0,
  `short_desc` text NOT NULL,
  `full_desc` longtext NOT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'published',
  `published_at` datetime DEFAULT NULL,
  `expires_at` date DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_offer_advantages`
--

CREATE TABLE `recrutement_offer_advantages` (
  `id` int(10) UNSIGNED NOT NULL,
  `offer_id` int(10) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Avantages proposés par l''offre (liste ordonnée)';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_offer_missions`
--

CREATE TABLE `recrutement_offer_missions` (
  `id` int(10) UNSIGNED NOT NULL,
  `offer_id` int(10) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Missions / responsabilités de l''offre (liste ordonnée)';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_offer_profiles`
--

CREATE TABLE `recrutement_offer_profiles` (
  `id` int(10) UNSIGNED NOT NULL,
  `offer_id` int(10) UNSIGNED NOT NULL,
  `content` text NOT NULL,
  `sort_order` smallint(6) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Critères du profil recherché (liste ordonnée)';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_offer_tags`
--

CREATE TABLE `recrutement_offer_tags` (
  `offer_id` int(10) UNSIGNED NOT NULL,
  `tag_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_professions`
--

CREATE TABLE `recrutement_professions` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `slug` varchar(150) NOT NULL,
  `name` varchar(150) NOT NULL,
  `sector` varchar(150) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#6366f1',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Pages métiers SEO – site Médical principalement';

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_sectors`
--

CREATE TABLE `recrutement_sectors` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_tags`
--

CREATE TABLE `recrutement_tags` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tags techniques IT (Docker, Kubernetes, AWS, Python…)';

-- --------------------------------------------------------

--
-- Structure de la table `seo_metadata`
--

CREATE TABLE `seo_metadata` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(10) UNSIGNED NOT NULL,
  `entity_type` varchar(50) NOT NULL COMMENT 'formation_course, recrutement_offer, blog_post, coaching_coach, recrutement_profession…',
  `entity_id` int(10) UNSIGNED NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` text DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `schema_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Métadonnées SEO et Open Graph par entité';

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_auth_slug_site` (`site_id`,`slug`),
  ADD UNIQUE KEY `uq_blog_auth_email_site` (`site_id`,`email`),
  ADD KEY `idx_blog_author_active` (`site_id`,`is_active`);

--
-- Index pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_cat_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_blog_cat_active` (`site_id`,`is_active`);

--
-- Index pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_blog_comment_post` (`post_id`,`status`),
  ADD KEY `idx_blog_comment_status` (`status`),
  ADD KEY `fk_blog_comment_parent` (`parent_id`);

--
-- Index pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_post_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_blog_post_status` (`site_id`,`status`,`published_at`),
  ADD KEY `idx_blog_post_category` (`category_id`),
  ADD KEY `idx_blog_post_author` (`author_id`),
  ADD KEY `idx_blog_post_deleted` (`deleted_at`,`site_id`);

--
-- Index pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_post_version_post` (`post_id`),
  ADD KEY `idx_post_version_created` (`created_at`),
  ADD KEY `fk_post_version_author` (`created_by`);

--
-- Index pour la table `blog_post_tags`
--
ALTER TABLE `blog_post_tags`
  ADD PRIMARY KEY (`post_id`,`tag_id`),
  ADD KEY `fk_blog_pt_tag` (`tag_id`);

--
-- Index pour la table `blog_related_posts`
--
ALTER TABLE `blog_related_posts`
  ADD PRIMARY KEY (`post_id`,`related_post_id`),
  ADD KEY `fk_related_related` (`related_post_id`);

--
-- Index pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_tag_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_blog_tag_site` (`site_id`);

--
-- Index pour la table `coaching_bookings`
--
ALTER TABLE `coaching_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_booking_coach` (`coach_id`,`booked_for`),
  ADD KEY `idx_booking_status` (`status`,`booked_for`),
  ADD KEY `idx_booking_email` (`email`);

--
-- Index pour la table `coaching_certifications`
--
ALTER TABLE `coaching_certifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Index pour la table `coaching_cities`
--
ALTER TABLE `coaching_cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Index pour la table `coaching_coaches`
--
ALTER TABLE `coaching_coaches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coach_slug_site` (`site_id`,`slug`),
  ADD UNIQUE KEY `uq_coach_email` (`email`),
  ADD KEY `idx_coach_status` (`site_id`,`status`,`is_available`),
  ADD KEY `idx_coach_city` (`city_id`),
  ADD KEY `idx_coach_rating` (`rating_avg`);

--
-- Index pour la table `coaching_coach_certifications`
--
ALTER TABLE `coaching_coach_certifications`
  ADD PRIMARY KEY (`coach_id`,`certification_id`),
  ADD KEY `fk_ccc_cert` (`certification_id`);

--
-- Index pour la table `coaching_coach_specialties`
--
ALTER TABLE `coaching_coach_specialties`
  ADD PRIMARY KEY (`coach_id`,`specialty_id`),
  ADD KEY `fk_ccs_spec` (`specialty_id`);

--
-- Index pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_coach_diag_status` (`status`,`created_at`),
  ADD KEY `idx_coach_diag_coach` (`coach_id`),
  ADD KEY `idx_coach_diag_email` (`email`);

--
-- Index pour la table `coaching_reviews`
--
ALTER TABLE `coaching_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_coach_review_published` (`coach_id`,`is_published`),
  ADD KEY `idx_coach_review_rating` (`coach_id`,`rating`);

--
-- Index pour la table `coaching_specialties`
--
ALTER TABLE `coaching_specialties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Index pour la table `core_admin_activity_logs`
--
ALTER TABLE `core_admin_activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_activity` (`admin_id`,`created_at`),
  ADD KEY `idx_activity_action` (`action`,`created_at`);

--
-- Index pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `idx_admin_sessions_token` (`token`),
  ADD KEY `idx_admin_sessions_admin` (`admin_id`),
  ADD KEY `idx_admin_sessions_expires` (`expires_at`);

--
-- Index pour la table `core_admin_site_access`
--
ALTER TABLE `core_admin_site_access`
  ADD PRIMARY KEY (`admin_id`,`site_id`),
  ADD KEY `fk_admin_access_site` (`site_id`);

--
-- Index pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_admin_email` (`email`),
  ADD KEY `idx_admin_role` (`role`),
  ADD KEY `idx_admin_active` (`is_active`);

--
-- Index pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_admin` (`admin_id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_action` (`action`,`created_at`),
  ADD KEY `fk_audit_site` (`site_id`);

--
-- Index pour la table `core_password_reset_tokens`
--
ALTER TABLE `core_password_reset_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token` (`token`),
  ADD KEY `idx_pwd_reset_token` (`token`),
  ADD KEY `idx_pwd_reset_admin` (`admin_id`);

--
-- Index pour la table `core_settings`
--
ALTER TABLE `core_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_setting_site_key` (`site_id`,`setting_key`),
  ADD KEY `idx_settings_site` (`site_id`);

--
-- Index pour la table `core_sites`
--
ALTER TABLE `core_sites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_sites_slug` (`slug`),
  ADD KEY `idx_sites_active` (`is_active`);

--
-- Index pour la table `email_logs`
--
ALTER TABLE `email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email_status` (`status`,`sent_at`),
  ADD KEY `idx_email_recipient` (`recipient_email`),
  ADD KEY `idx_email_type` (`email_type`,`sent_at`),
  ADD KEY `fk_email_log_site` (`site_id`);

--
-- Index pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_form_cat_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_form_cat_active` (`site_id`,`is_active`);

--
-- Index pour la table `formation_courses`
--
ALTER TABLE `formation_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_form_course_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_form_course_status` (`site_id`,`status`),
  ADD KEY `idx_form_course_category` (`category_id`),
  ADD KEY `idx_form_course_created` (`created_by`),
  ADD KEY `fk_course_updated_by` (`updated_by`);

--
-- Index pour la table `formation_courses_versions`
--
ALTER TABLE `formation_courses_versions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_course_version_course` (`course_id`),
  ADD KEY `fk_course_version_author` (`created_by`);

--
-- Index pour la table `formation_jobs`
--
ALTER TABLE `formation_jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_job_course` (`course_id`),
  ADD KEY `idx_form_job_salary` (`salary_min`,`salary_max`);

--
-- Index pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_module_course` (`course_id`);

--
-- Index pour la table `formation_skills`
--
ALTER TABLE `formation_skills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_skill_course` (`course_id`);

--
-- Index pour la table `gdpr_consents`
--
ALTER TABLE `gdpr_consents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdpr_email` (`user_email`),
  ADD KEY `idx_gdpr_type` (`user_type`,`user_id`),
  ADD KEY `idx_gdpr_consent` (`consent_type`,`is_given`);

--
-- Index pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdpr_del_email` (`user_email`),
  ADD KEY `idx_gdpr_del_status` (`status`,`created_at`),
  ADD KEY `idx_gdpr_del_site` (`site_id`),
  ADD KEY `fk_gdpr_del_processed` (`processed_by`);

--
-- Index pour la table `marketing_newsletter_subs`
--
ALTER TABLE `marketing_newsletter_subs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unsub_token` (`unsub_token`),
  ADD UNIQUE KEY `uq_marketing_sub_email_site` (`site_id`,`email`),
  ADD KEY `idx_marketing_sub_active` (`site_id`,`is_active`);

--
-- Index pour la table `media_library`
--
ALTER TABLE `media_library`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_media_site` (`site_id`),
  ADD KEY `idx_media_mime` (`mime_type`),
  ADD KEY `fk_media_uploaded` (`uploaded_by`);

--
-- Index pour la table `recrutement_applications`
--
ALTER TABLE `recrutement_applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recrut_app_offer_email` (`offer_id`,`email`),
  ADD KEY `idx_recrut_app_status` (`offer_id`,`status`,`created_at`),
  ADD KEY `idx_recrut_app_email` (`email`),
  ADD KEY `idx_recrut_app_deleted` (`deleted_at`);

--
-- Index pour la table `recrutement_application_history`
--
ALTER TABLE `recrutement_application_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recrut_apphist_app` (`application_id`),
  ADD KEY `fk_recrut_apphist_admin` (`changed_by_id`);

--
-- Index pour la table `recrutement_contract_types`
--
ALTER TABLE `recrutement_contract_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Index pour la table `recrutement_jobs`
--
ALTER TABLE `recrutement_jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_recrut_job_sector` (`sector_id`);

--
-- Index pour la table `recrutement_offers`
--
ALTER TABLE `recrutement_offers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recrut_offer_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_recrut_offer_status` (`site_id`,`status`,`expires_at`),
  ADD KEY `idx_recrut_offer_job` (`job_id`),
  ADD KEY `idx_recrut_offer_profession` (`profession_id`),
  ADD KEY `idx_recrut_offer_deleted` (`deleted_at`),
  ADD KEY `fk_recrut_offer_contract` (`contract_type_id`),
  ADD KEY `fk_recrut_offer_author` (`created_by`);

--
-- Index pour la table `recrutement_offer_advantages`
--
ALTER TABLE `recrutement_offer_advantages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_offer_advantage` (`offer_id`);

--
-- Index pour la table `recrutement_offer_missions`
--
ALTER TABLE `recrutement_offer_missions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_offer_mission` (`offer_id`);

--
-- Index pour la table `recrutement_offer_profiles`
--
ALTER TABLE `recrutement_offer_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_offer_profile` (`offer_id`);

--
-- Index pour la table `recrutement_offer_tags`
--
ALTER TABLE `recrutement_offer_tags`
  ADD PRIMARY KEY (`offer_id`,`tag_id`),
  ADD KEY `fk_offer_tag_tag` (`tag_id`);

--
-- Index pour la table `recrutement_professions`
--
ALTER TABLE `recrutement_professions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_profession_slug_site` (`site_id`,`slug`),
  ADD KEY `idx_profession_active` (`site_id`,`is_active`);

--
-- Index pour la table `recrutement_sectors`
--
ALTER TABLE `recrutement_sectors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recrut_sector_slug_site` (`site_id`,`slug`);

--
-- Index pour la table `recrutement_tags`
--
ALTER TABLE `recrutement_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recrut_tag_site` (`site_id`,`name`),
  ADD UNIQUE KEY `uq_recrut_tag_slug` (`site_id`,`slug`),
  ADD KEY `idx_recrut_tag_site` (`site_id`);

--
-- Index pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_seo_entity` (`site_id`,`entity_type`,`entity_id`),
  ADD KEY `idx_seo_site` (`site_id`,`entity_type`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `coaching_bookings`
--
ALTER TABLE `coaching_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_certifications`
--
ALTER TABLE `coaching_certifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `coaching_cities`
--
ALTER TABLE `coaching_cities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `coaching_coaches`
--
ALTER TABLE `coaching_coaches`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_reviews`
--
ALTER TABLE `coaching_reviews`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_specialties`
--
ALTER TABLE `coaching_specialties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `core_admin_activity_logs`
--
ALTER TABLE `core_admin_activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `core_password_reset_tokens`
--
ALTER TABLE `core_password_reset_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `core_settings`
--
ALTER TABLE `core_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `core_sites`
--
ALTER TABLE `core_sites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `formation_courses`
--
ALTER TABLE `formation_courses`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_courses_versions`
--
ALTER TABLE `formation_courses_versions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_jobs`
--
ALTER TABLE `formation_jobs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_skills`
--
ALTER TABLE `formation_skills`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `gdpr_consents`
--
ALTER TABLE `gdpr_consents`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketing_newsletter_subs`
--
ALTER TABLE `marketing_newsletter_subs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `media_library`
--
ALTER TABLE `media_library`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_applications`
--
ALTER TABLE `recrutement_applications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_application_history`
--
ALTER TABLE `recrutement_application_history`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_contract_types`
--
ALTER TABLE `recrutement_contract_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `recrutement_jobs`
--
ALTER TABLE `recrutement_jobs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_offers`
--
ALTER TABLE `recrutement_offers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `recrutement_offer_advantages`
--
ALTER TABLE `recrutement_offer_advantages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_offer_missions`
--
ALTER TABLE `recrutement_offer_missions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_offer_profiles`
--
ALTER TABLE `recrutement_offer_profiles`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_professions`
--
ALTER TABLE `recrutement_professions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `recrutement_sectors`
--
ALTER TABLE `recrutement_sectors`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `recrutement_tags`
--
ALTER TABLE `recrutement_tags`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  ADD CONSTRAINT `fk_blog_auth_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD CONSTRAINT `fk_blog_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  ADD CONSTRAINT `fk_blog_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `blog_comments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_comment_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD CONSTRAINT `fk_blog_post_auth` FOREIGN KEY (`author_id`) REFERENCES `blog_authors` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_post_cat` FOREIGN KEY (`category_id`) REFERENCES `blog_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_post_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  ADD CONSTRAINT `fk_post_version` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_post_version_author` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `blog_post_tags`
--
ALTER TABLE `blog_post_tags`
  ADD CONSTRAINT `fk_blog_pt_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_blog_pt_tag` FOREIGN KEY (`tag_id`) REFERENCES `blog_tags` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_related_posts`
--
ALTER TABLE `blog_related_posts`
  ADD CONSTRAINT `fk_related_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_related_related` FOREIGN KEY (`related_post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  ADD CONSTRAINT `fk_blog_tag_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_bookings`
--
ALTER TABLE `coaching_bookings`
  ADD CONSTRAINT `fk_booking_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaching_coaches` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_coaches`
--
ALTER TABLE `coaching_coaches`
  ADD CONSTRAINT `fk_coach_city` FOREIGN KEY (`city_id`) REFERENCES `coaching_cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_coach_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_coach_certifications`
--
ALTER TABLE `coaching_coach_certifications`
  ADD CONSTRAINT `fk_ccc_cert` FOREIGN KEY (`certification_id`) REFERENCES `coaching_certifications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ccc_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaching_coaches` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_coach_specialties`
--
ALTER TABLE `coaching_coach_specialties`
  ADD CONSTRAINT `fk_ccs_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaching_coaches` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ccs_spec` FOREIGN KEY (`specialty_id`) REFERENCES `coaching_specialties` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  ADD CONSTRAINT `fk_coach_diag_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaching_coaches` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `coaching_reviews`
--
ALTER TABLE `coaching_reviews`
  ADD CONSTRAINT `fk_coach_review_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaching_coaches` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_activity_logs`
--
ALTER TABLE `core_admin_activity_logs`
  ADD CONSTRAINT `fk_activity_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  ADD CONSTRAINT `fk_admin_session_user` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_site_access`
--
ALTER TABLE `core_admin_site_access`
  ADD CONSTRAINT `fk_admin_access_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_admin_access_user` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  ADD CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_audit_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `core_password_reset_tokens`
--
ALTER TABLE `core_password_reset_tokens`
  ADD CONSTRAINT `fk_pwd_reset_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_settings`
--
ALTER TABLE `core_settings`
  ADD CONSTRAINT `fk_settings_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `email_logs`
--
ALTER TABLE `email_logs`
  ADD CONSTRAINT `fk_email_log_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  ADD CONSTRAINT `fk_form_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_courses`
--
ALTER TABLE `formation_courses`
  ADD CONSTRAINT `fk_course_created_by` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_course_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_form_course_cat` FOREIGN KEY (`category_id`) REFERENCES `formation_categories` (`id`),
  ADD CONSTRAINT `fk_form_course_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_courses_versions`
--
ALTER TABLE `formation_courses_versions`
  ADD CONSTRAINT `fk_course_version` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_course_version_author` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `formation_jobs`
--
ALTER TABLE `formation_jobs`
  ADD CONSTRAINT `fk_form_job_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  ADD CONSTRAINT `fk_form_module_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_skills`
--
ALTER TABLE `formation_skills`
  ADD CONSTRAINT `fk_form_skill_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  ADD CONSTRAINT `fk_gdpr_del_processed_by` FOREIGN KEY (`processed_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_gdpr_del_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketing_newsletter_subs`
--
ALTER TABLE `marketing_newsletter_subs`
  ADD CONSTRAINT `fk_marketing_sub_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `media_library`
--
ALTER TABLE `media_library`
  ADD CONSTRAINT `fk_media_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_media_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `recrutement_applications`
--
ALTER TABLE `recrutement_applications`
  ADD CONSTRAINT `fk_recrut_app_offer` FOREIGN KEY (`offer_id`) REFERENCES `recrutement_offers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_application_history`
--
ALTER TABLE `recrutement_application_history`
  ADD CONSTRAINT `fk_recrut_apphist_admin` FOREIGN KEY (`changed_by_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recrut_apphist_app` FOREIGN KEY (`application_id`) REFERENCES `recrutement_applications` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_jobs`
--
ALTER TABLE `recrutement_jobs`
  ADD CONSTRAINT `fk_recrut_job_sector` FOREIGN KEY (`sector_id`) REFERENCES `recrutement_sectors` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_offers`
--
ALTER TABLE `recrutement_offers`
  ADD CONSTRAINT `fk_offer_profession` FOREIGN KEY (`profession_id`) REFERENCES `recrutement_professions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recrut_offer_author` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recrut_offer_contract` FOREIGN KEY (`contract_type_id`) REFERENCES `recrutement_contract_types` (`id`),
  ADD CONSTRAINT `fk_recrut_offer_job` FOREIGN KEY (`job_id`) REFERENCES `recrutement_jobs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_recrut_offer_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_offer_advantages`
--
ALTER TABLE `recrutement_offer_advantages`
  ADD CONSTRAINT `fk_advantage_offer` FOREIGN KEY (`offer_id`) REFERENCES `recrutement_offers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_offer_missions`
--
ALTER TABLE `recrutement_offer_missions`
  ADD CONSTRAINT `fk_mission_offer` FOREIGN KEY (`offer_id`) REFERENCES `recrutement_offers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_offer_profiles`
--
ALTER TABLE `recrutement_offer_profiles`
  ADD CONSTRAINT `fk_profile_offer` FOREIGN KEY (`offer_id`) REFERENCES `recrutement_offers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_offer_tags`
--
ALTER TABLE `recrutement_offer_tags`
  ADD CONSTRAINT `fk_offer_tag_offer` FOREIGN KEY (`offer_id`) REFERENCES `recrutement_offers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_offer_tag_tag` FOREIGN KEY (`tag_id`) REFERENCES `recrutement_tags` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_professions`
--
ALTER TABLE `recrutement_professions`
  ADD CONSTRAINT `fk_profession_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_sectors`
--
ALTER TABLE `recrutement_sectors`
  ADD CONSTRAINT `fk_recrut_sector_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recrutement_tags`
--
ALTER TABLE `recrutement_tags`
  ADD CONSTRAINT `fk_recrut_tag_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  ADD CONSTRAINT `fk_seo_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
