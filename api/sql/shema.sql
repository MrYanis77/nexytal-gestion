-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Hôte : db5020658636.hosting-data.io
-- Généré le : jeu. 30 juil. 2026 à 03:07
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
--

-- --------------------------------------------------------

--
-- Structure de la table `alertes_emploi`
--

CREATE TABLE `alertes_emploi` (
  `id` int(10) UNSIGNED NOT NULL,
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `metier_id` int(10) UNSIGNED DEFAULT NULL,
  `mots_cles` varchar(300) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `rayon_km` smallint(6) DEFAULT NULL,
  `type_contrat` enum('cdi','cdd','interim','alternance','freelance','stage') DEFAULT NULL,
  `frequence` enum('quotidienne','hebdomadaire') NOT NULL DEFAULT 'hebdomadaire',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `dernier_envoi` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_authors`
--

CREATE TABLE `blog_authors` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `bio` text DEFAULT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_authors`
--

INSERT INTO `blog_authors` (`id`, `site_id`, `first_name`, `last_name`, `email`, `slug`, `bio`, `avatar_url`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 5, 'yanis', 'laldji', 'yanislaldjipro@gmail.com', 'yanis-laldji', 'bonjour', NULL, 1, '2026-07-09 22:59:46', NULL),
(2, 6, 'zedzed', 'efef', 'yanislaldjipro@gmail.com', 'zedzed-efef', NULL, NULL, 1, '2026-07-10 01:59:28', NULL),
(3, 4, 'zefez', 'zefzef', 'yanislaldjipro@gmail.com', 'zefez-zefzef', 'eez', NULL, 1, '2026-07-10 02:14:44', NULL),
(10, 3, 'Équipe', 'Nexytal Médical', 'contact@nexytal.com', 'equipe-nexytal-medical', 'L\'équipe éditoriale de Nexytal Médical', NULL, 1, '2026-07-10 15:25:53', NULL),
(11, 2, 'fe', 'zefzef', 'yanislaldjipro@gmail.com', 'fe-zefzef', 'zefzffz', NULL, 1, '2026-07-23 12:50:58', NULL),
(12, 1, 'njbhbh', 'bhbhb', 'yanislaldjipro@gmail.com', 'njbhbh-bhbhb', 'jjhbbh', NULL, 1, '2026-07-24 03:38:08', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_categories`
--

CREATE TABLE `blog_categories` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `color` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_categories`
--

INSERT INTO `blog_categories` (`id`, `site_id`, `name`, `slug`, `description`, `color`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 5, 'test', 'test', 'ferferf', NULL, 1, 0, '2026-07-09 22:59:54', NULL),
(2, 6, 'ezfez', 'ezfez', NULL, NULL, 1, 0, '2026-07-10 01:59:36', NULL),
(3, 4, 'ezff', 'ezff', 'zeff', NULL, 1, 0, '2026-07-10 02:14:59', NULL),
(10, 3, 'Recrutement médical', 'recrutement-medical', 'Conseils recrutement médical', NULL, 1, 1, '2026-07-10 15:25:53', NULL),
(11, 3, 'Intérim médical', 'interim-medical', 'Missions intérim santé', NULL, 1, 2, '2026-07-10 15:25:53', NULL),
(12, 3, 'Carrière santé', 'carriere-sante', 'Conseils carrière santé', NULL, 1, 3, '2026-07-10 15:25:53', NULL),
(13, 3, 'Actualités', 'actualites', 'Actualités du secteur de la santé', NULL, 1, 4, '2026-07-10 15:25:53', NULL),
(14, 2, 'efzefezf', 'efzefezf', 'zefzfzf', NULL, 1, 0, '2026-07-23 12:51:06', '2026-07-23 12:51:57'),
(15, 1, 'njnjnjnj', 'njnjnjnj', 'njnjj', NULL, 1, 0, '2026-07-24 03:38:17', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_comments`
--

CREATE TABLE `blog_comments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `post_id` int(11) NOT NULL,
  `author_name` varchar(150) NOT NULL,
  `author_email` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `status` enum('pending','approved','rejected','spam') NOT NULL DEFAULT 'pending',
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_posts`
--

CREATE TABLE `blog_posts` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `cover_image_url` varchar(500) DEFAULT NULL,
  `read_time_mins` smallint(5) UNSIGNED DEFAULT NULL,
  `status` enum('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `views_count` int(11) NOT NULL DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_posts`
--

INSERT INTO `blog_posts` (`id`, `site_id`, `category_id`, `author_id`, `title`, `slug`, `excerpt`, `content`, `cover_image_url`, `read_time_mins`, `status`, `is_featured`, `views_count`, `published_at`, `created_at`, `deleted_at`) VALUES
(1, 5, 1, 1, 'test article', 'test-article', 'dfrfefefz', 'zefezfzef', '/api/uploads/blog/35f2a563-457c-4d3b-9f0e-6ec08427f1c9.jpg', 14, 'published', 1, 0, '2026-07-09 00:00:00', '2026-07-09 23:00:30', NULL),
(2, 6, 2, 2, 'zezfzef', 'zezfzef', 'zezfef', 'zefzfe', '/api/uploads/blog/f03fd86a-d712-4e21-ab5b-23f2b0de4eaa.jpg', 45, 'published', 0, 0, '2026-07-10 00:00:00', '2026-07-10 02:00:10', NULL),
(3, 4, 3, 3, 'ezfezf', 'ezfezf', 'rgegrege', 'ergegre', '/api/uploads/blog/c0e68f4b-c013-40b1-80ca-ba04902c81a0.png', NULL, 'published', 0, 0, '2026-07-10 02:15:30', '2026-07-10 02:15:30', NULL),
(4, 3, 13, 10, 'Recruter un infirmier en Île-de-France : les bonnes pratiques', 'recruter-un-infirmier-en-ile-de-france-les-bonnes-pratiques', 'Conseils pour attirer et fidéliser les IDE dans un contexte de tension sur les effectifs hospitaliers.', 'Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.', 'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&amp;amp;cs=tinysrgb&amp;amp;w=800', 5, 'published', 1, 0, '2026-07-10 00:00:00', '2026-07-10 15:25:53', NULL),
(5, 3, 11, 10, 'Intérim médical : quand et comment le mobiliser ?', 'interim-medical-quand-le-mobiliser', 'Remplacements, pics d\'activité, continuité des soins — l\'intérim comme levier de sécurisation des équipes.', 'L\'intérim médical permet de répondre aux absences imprévues et aux pics saisonniers. Bien anticipé, il sécurise la continuité des soins sans alourdir la charge des équipes permanentes.', 'https://images.pexels.com/photos/263402/pexels-photo-263402.jpeg?auto=compress&cs=tinysrgb&w=800', 4, 'published', 0, 0, '2026-07-10 15:25:53', '2026-07-10 15:25:53', NULL),
(6, 3, 12, 10, 'Carrière aide-soignant : tendances et débouchés en 2026', 'carriere-aide-soignant-2026', 'EHPAD, hôpital, domicile — panorama des opportunités pour les aides-soignants en France.', 'Les aides-soignants restent au cœur de la prise en charge des patients. Les besoins sont soutenus et les évolutions de carrière multiples : spécialisation, encadrement, formation continue.', 'https://images.pexels.com/photos/4386466/pexels-photo-4386466.jpeg?auto=compress&cs=tinysrgb&w=800', 6, 'published', 0, 0, '2026-07-10 15:25:53', '2026-07-10 15:25:53', NULL),
(7, 2, 14, 11, 'fzefzfz', 'fzefzfz', 'zefzfze', 'efzefzfzf', '/api/uploads/blog/dc011904-c356-45dc-a356-14fd386a1e4a.png', 15, 'published', 0, 0, '2026-07-23 12:51:48', '2026-07-23 12:51:48', NULL),
(8, 1, 15, 12, 'bhlbhjbh', 'bhlbhjbh', 'bbhbhjbh', 'nkmnnmlknlk', '/api/uploads/blog/ec8e7a4b-4733-401a-9fdc-b97ccf46ecea.png', NULL, 'published', 1, 0, '2026-07-24 03:38:53', '2026-07-24 03:38:53', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_posts_versions`
--

CREATE TABLE `blog_posts_versions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `post_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `status` varchar(30) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_posts_versions`
--

INSERT INTO `blog_posts_versions` (`id`, `post_id`, `title`, `content`, `status`, `created_by`, `created_at`) VALUES
(1, 4, 'Recruter un infirmier en Île-de-France : les bonnes pratiques', 'Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.', 'published', 1, '2026-07-20 18:30:22'),
(2, 4, 'Recruter un infirmier en Île-de-France : les bonnes pratiques', 'Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.', 'published', 1, '2026-07-20 18:31:04'),
(3, 1, 'test article', 'zefezfzef', 'published', 1, '2026-07-27 14:24:45'),
(4, 2, 'zezfzef', 'zefzfe', 'published', 1, '2026-07-27 16:23:52');

-- --------------------------------------------------------

--
-- Structure de la table `blog_post_tags`
--

CREATE TABLE `blog_post_tags` (
  `post_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_post_tags`
--

INSERT INTO `blog_post_tags` (`post_id`, `tag_id`) VALUES
(1, 1),
(2, 2),
(4, 4),
(7, 5),
(8, 6);

-- --------------------------------------------------------

--
-- Structure de la table `blog_related_posts`
--

CREATE TABLE `blog_related_posts` (
  `post_id` int(11) NOT NULL,
  `related_post_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `blog_tags`
--

CREATE TABLE `blog_tags` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_tags`
--

INSERT INTO `blog_tags` (`id`, `site_id`, `name`, `slug`, `created_at`) VALUES
(1, 5, 'oui', 'oui', '2026-07-09 22:59:29'),
(2, 6, 'ed', 'ed', '2026-07-10 01:59:15'),
(3, 4, 'ezfze', 'ezfze', '2026-07-10 02:14:28'),
(4, 3, 'zfzfe', 'zfzfe', '2026-07-20 18:29:41'),
(5, 2, 'dff', 'dff', '2026-07-23 12:50:46'),
(6, 1, 'njbhbh', 'njbhbh', '2026-07-24 03:37:54');

-- --------------------------------------------------------

--
-- Structure de la table `candidats`
--

CREATE TABLE `candidats` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `teletravail_souhaite` enum('non','partiel','total') DEFAULT 'non',
  `disponibilite` date DEFAULT NULL,
  `recherche_active` tinyint(1) NOT NULL DEFAULT 1,
  `type_contrat_souhaite` set('cdi','cdd','interim','alternance','freelance','stage') DEFAULT NULL,
  `rgpd_consent_at` datetime NOT NULL,
  `profil_public` tinyint(1) NOT NULL DEFAULT 0,
  `cv_filename` varchar(255) DEFAULT NULL,
  `resume_court` text DEFAULT NULL,
  `lettre_motivation` text DEFAULT NULL,
  `linkedin_url` varchar(500) DEFAULT NULL,
  `situation_professionnelle` varchar(100) DEFAULT NULL,
  `experience_candidat` enum('debutant','1-2','3-5','5-10','10+') DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidats`
--

INSERT INTO `candidats` (`id`, `user_id`, `prenom`, `nom`, `telephone`, `ville`, `code_postal`, `region`, `teletravail_souhaite`, `disponibilite`, `recherche_active`, `type_contrat_souhaite`, `rgpd_consent_at`, `profil_public`, `cv_filename`, `resume_court`, `lettre_motivation`, `linkedin_url`, `situation_professionnelle`, `experience_candidat`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Yanis', 'Laldji', '0782124452', NULL, NULL, NULL, 'non', '2026-06-18', 1, NULL, '2026-07-10 02:39:47', 0, NULL, NULL, NULL, NULL, NULL, '3-5', '2026-07-10 02:39:47', '2026-07-20 21:44:57', NULL),
(2, 2, 'test', 'Laldji', '0782124452', NULL, NULL, NULL, 'non', '2026-07-23', 1, NULL, '2026-07-23 13:08:14', 0, 'uploads/candidats-profil/2/profil-2-ba17541aeb24d1ac.pdf', NULL, NULL, NULL, NULL, '3-5', '2026-07-23 13:08:14', '2026-07-23 13:09:09', NULL),
(3, 3, 'test', 'test', '078545869', NULL, NULL, NULL, 'non', '2026-07-23', 1, NULL, '2026-07-23 13:22:46', 0, 'uploads/candidats-profil/2/profil-3-225a5f3bda6b2d50.pdf', NULL, NULL, NULL, NULL, '3-5', '2026-07-23 13:22:46', '2026-07-23 13:23:22', NULL),
(4, 4, 'test', 'test', '0782124452', NULL, NULL, NULL, 'non', '2026-07-24', 1, NULL, '2026-07-24 02:26:26', 0, 'uploads/candidats-profil/2/profil-4-8d91aae6a8d04524.pdf', NULL, NULL, NULL, NULL, '5-10', '2026-07-24 02:26:26', '2026-07-24 02:27:02', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `candidatures`
--

CREATE TABLE `candidatures` (
  `id` int(10) UNSIGNED NOT NULL,
  `offre_id` int(10) UNSIGNED NOT NULL,
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `message_motivation` text DEFAULT NULL,
  `notes_recruteur` text DEFAULT NULL,
  `statut` enum('recue','vue','shortlist','entretien','offre','refusee','retiree') NOT NULL DEFAULT 'recue',
  `verifie_nexytal` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Profil validé par Nexytal',
  `score_nexytal` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'Score matching 0-100',
  `note_nexytal` text DEFAULT NULL COMMENT 'Synthèse Nexytal',
  `source` enum('site','bilan','alerte','recommandation') NOT NULL DEFAULT 'site',
  `date_candidature` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidatures`
--

INSERT INTO `candidatures` (`id`, `offre_id`, `candidat_id`, `message_motivation`, `notes_recruteur`, `statut`, `verifie_nexytal`, `score_nexytal`, `note_nexytal`, `source`, `date_candidature`, `updated_at`) VALUES
(1, 1, 1, 'efzfzef', NULL, 'recue', 0, NULL, NULL, 'site', '2026-07-10 02:40:37', '2026-07-10 02:40:37'),
(2, 2, 1, 'motiver', NULL, 'entretien', 0, NULL, NULL, 'site', '2026-07-20 21:29:55', '2026-07-20 21:32:18'),
(3, 3, 2, 'fezfzfzfzef', NULL, 'refusee', 0, NULL, NULL, 'site', '2026-07-23 13:09:09', '2026-07-23 13:13:39'),
(4, 3, 3, 'csffe', NULL, 'recue', 0, NULL, NULL, 'site', '2026-07-23 13:23:22', '2026-07-23 13:23:22'),
(5, 3, 4, 'efzfferfezft(-', NULL, 'recue', 0, NULL, NULL, 'site', '2026-07-24 02:27:02', '2026-07-24 02:27:02');

-- --------------------------------------------------------

--
-- Structure de la table `candidatures_externes`
--

CREATE TABLE `candidatures_externes` (
  `id` int(10) UNSIGNED NOT NULL,
  `offre_id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `lettre_motivation` text DEFAULT NULL,
  `linkedin_url` varchar(500) DEFAULT NULL,
  `statut` enum('recue','vue','shortlist','entretien','offre','refusee') NOT NULL DEFAULT 'recue',
  `verifie_nexytal` tinyint(1) NOT NULL DEFAULT 0,
  `score_nexytal` tinyint(3) UNSIGNED DEFAULT NULL,
  `note_nexytal` text DEFAULT NULL,
  `rgpd_consent_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `cv_filename` varchar(255) DEFAULT NULL,
  `experience_candidat` enum('debutant','1-2','3-5','5-10','10+') DEFAULT NULL,
  `competences_reponses` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`competences_reponses`)),
  `disponibilite` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidature_historique`
--

CREATE TABLE `candidature_historique` (
  `id` int(10) UNSIGNED NOT NULL,
  `candidature_id` int(10) UNSIGNED NOT NULL,
  `ancien_statut` varchar(30) DEFAULT NULL,
  `nouveau_statut` varchar(30) NOT NULL,
  `commentaire` text DEFAULT NULL,
  `auteur_type` enum('admin','recruteur','systeme') NOT NULL DEFAULT 'systeme',
  `auteur_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidature_historique`
--

INSERT INTO `candidature_historique` (`id`, `candidature_id`, `ancien_statut`, `nouveau_statut`, `commentaire`, `auteur_type`, `auteur_id`, `created_at`) VALUES
(1, 2, 'recue', 'entretien', 'Candidature inscrite mise à jour depuis l espace recruteur.', 'recruteur', 2, '2026-07-20 21:32:18');

-- --------------------------------------------------------

--
-- Structure de la table `candidat_competences`
--

CREATE TABLE `candidat_competences` (
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `competence_id` int(10) UNSIGNED NOT NULL,
  `niveau` enum('debutant','intermediaire','confirme','expert') DEFAULT 'intermediaire'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_metiers_souhaites`
--

CREATE TABLE `candidat_metiers_souhaites` (
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `metier_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_tokens`
--

CREATE TABLE `candidat_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidat_tokens`
--

INSERT INTO `candidat_tokens` (`id`, `candidat_id`, `token_hash`, `ip_address`, `user_agent`, `expires_at`, `created_at`) VALUES
(1, 1, '217a5119338cf585bf6833aaf4f9b24bd8d4e548758c01d564e0a01f1bb892ad', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-08-09 02:39:47', '2026-07-10 02:39:47'),
(3, 1, 'c08246a6cceb4c60673e82ba4084a93ce292bc1b02e0073e0caed44672fb8b61', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-08-09 16:07:19', '2026-07-10 16:07:19'),
(4, 1, 'fc9ffa7107da1e43d6bfa9ba17a612eea32e2d1e0f5cd71bfe5e408227b7df92', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-08-19 21:29:17', '2026-07-20 21:29:17'),
(14, 1, 'ace6463a20f6de354b46a5d197750e81a2edec78d86a1cca3500b04826048a94', '2a01:cb08:13:a000:f95f:dd96:f3fe:70b9', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-08-29 02:41:04', '2026-07-30 02:41:04');

-- --------------------------------------------------------

--
-- Structure de la table `career_applications`
--

CREATE TABLE `career_applications` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `offer_id` int(11) UNSIGNED DEFAULT NULL,
  `application_type` enum('collaborateur','formateur') NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `contract_or_expertise` varchar(255) NOT NULL,
  `cover_letter_text` text DEFAULT NULL,
  `cv_filename` varchar(500) NOT NULL,
  `status` enum('recue','vue','entretien','offre','refusee') NOT NULL DEFAULT 'recue',
  `rgpd_consent_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `career_job_offers`
--

CREATE TABLE `career_job_offers` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `department` enum('collaborateur','formateur') NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `contract_type` varchar(80) NOT NULL,
  `location` varchar(150) NOT NULL,
  `short_description` text DEFAULT NULL,
  `full_description` longtext DEFAULT NULL,
  `status` enum('draft','published','closed') NOT NULL DEFAULT 'draft',
  `published_at` datetime DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaches`
--

CREATE TABLE `coaches` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slug` varchar(120) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `title` varchar(200) NOT NULL,
  `bio_short` text DEFAULT NULL,
  `bio_full` longtext DEFAULT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `avatar_initials` char(3) DEFAULT NULL,
  `city_id` int(11) UNSIGNED DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `linkedin_url` varchar(512) DEFAULT NULL,
  `experience_years` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `status` enum('draft','pending_review','active','inactive') NOT NULL DEFAULT 'pending_review',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `validated_at` datetime DEFAULT NULL,
  `validated_by` int(11) DEFAULT NULL COMMENT 'Admin validateur (Nexytal Gestion)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaches`
--

INSERT INTO `coaches` (`id`, `site_id`, `slug`, `first_name`, `last_name`, `title`, `bio_short`, `bio_full`, `avatar_url`, `avatar_initials`, `city_id`, `email`, `phone`, `linkedin_url`, `experience_years`, `status`, `is_featured`, `sort_order`, `published_at`, `validated_at`, `validated_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(36, 6, 'anis-aldji', 'Compte', 'supprimÃ©', 'rzfr\"ef', NULL, NULL, NULL, NULL, 1, 'deleted-coach-36@removed.nexytal.local', NULL, NULL, 5, 'inactive', 0, 0, '2026-07-10 01:49:17', '2026-07-10 01:49:17', 1, '2026-07-10 01:48:41', '2026-07-10 02:06:27', '2026-07-10 02:06:27'),
(37, 6, 'anis-aldji-2', 'Yanis', 'Laldji', 'ezfzef', NULL, NULL, NULL, 'YL', 1, 'yanislaldjipro@gmail.com', '+33782124452', NULL, 5, 'active', 0, 0, '2026-07-27 16:56:11', '2026-07-27 16:56:11', 1, '2026-07-27 16:55:36', '2026-07-27 16:56:11', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `coaching_appointment_slots`
--

CREATE TABLE `coaching_appointment_slots` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slot_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time DEFAULT NULL,
  `coach_id` int(11) UNSIGNED DEFAULT NULL,
  `capacity` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `booked_count` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_appointment_slots`
--

INSERT INTO `coaching_appointment_slots` (`id`, `site_id`, `slot_date`, `start_time`, `end_time`, `coach_id`, `capacity`, `booked_count`, `is_active`, `created_at`) VALUES
(1, 6, '2026-07-10', '09:00:00', '10:00:00', 36, 5, 1, 0, '2026-07-10 01:53:33');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_certifications`
--

CREATE TABLE `coaching_certifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `name` varchar(150) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_certifications`
--

INSERT INTO `coaching_certifications` (`id`, `slug`, `name`, `sort_order`) VALUES
(1, 'sdzef', 'sdzef', 0);

-- --------------------------------------------------------

--
-- Structure de la table `coaching_cities`
--

CREATE TABLE `coaching_cities` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `name` varchar(100) NOT NULL,
  `region` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_cities`
--

INSERT INTO `coaching_cities` (`id`, `slug`, `name`, `region`, `is_active`) VALUES
(1, 'coaching', 'villevaudé', 'ezfzef', 1);

-- --------------------------------------------------------

--
-- Structure de la table `coaching_client_profiles`
--

CREATE TABLE `coaching_client_profiles` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `company` varchar(150) DEFAULT NULL,
  `job_title` varchar(150) DEFAULT NULL,
  `avatar_initials` char(3) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_client_profiles`
--

INSERT INTO `coaching_client_profiles` (`id`, `site_id`, `first_name`, `last_name`, `email`, `phone`, `company`, `job_title`, `avatar_initials`, `status`, `created_at`) VALUES
(1, 6, 'Yanis', 'Laldji', 'yanislaldjipro@gmail.com', '0782124452', 'efzfze', 'zefzfe', 'YL', 'active', '2026-07-10 01:52:48'),
(2, 6, 'Yanis', 'Laldji', 'oui@gmail.com', '0782124452', 'fezf', 'efzefze', 'YL', 'active', '2026-07-27 16:57:07');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_coach_client_links`
--

CREATE TABLE `coaching_coach_client_links` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `coach_id` int(11) UNSIGNED NOT NULL,
  `client_id` int(11) UNSIGNED NOT NULL,
  `status` enum('pending','active','ended') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_coach_client_links`
--

INSERT INTO `coaching_coach_client_links` (`id`, `site_id`, `coach_id`, `client_id`, `status`, `created_at`) VALUES
(1, 6, 36, 1, 'active', '2026-07-10 01:54:14');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_contact_requests`
--

CREATE TABLE `coaching_contact_requests` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slot_id` int(11) UNSIGNED DEFAULT NULL,
  `slot_label` varchar(120) DEFAULT NULL,
  `profil` varchar(50) NOT NULL,
  `besoins` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`besoins`)),
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(25) DEFAULT NULL,
  `entreprise` varchar(150) DEFAULT NULL,
  `fonction` varchar(150) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `statut` enum('nouveau','contacte','planifie','ferme') NOT NULL DEFAULT 'nouveau',
  `rgpd_consent_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_contact_slots`
--

CREATE TABLE `coaching_contact_slots` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `label` varchar(120) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_diagnostic_requests`
--

CREATE TABLE `coaching_diagnostic_requests` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `appointment_slot_id` int(11) UNSIGNED DEFAULT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(25) DEFAULT NULL,
  `profil` varchar(50) NOT NULL,
  `statut` enum('nouveau','confirme','annule','termine') NOT NULL DEFAULT 'nouveau',
  `rgpd_consent_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_languages`
--

CREATE TABLE `coaching_languages` (
  `id` int(11) UNSIGNED NOT NULL,
  `code` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  `flag_emoji` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_languages`
--

INSERT INTO `coaching_languages` (`id`, `code`, `name`, `flag_emoji`) VALUES
(1, 'fr', 'edd', ''),
(12, 'edd', 'edd', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `coaching_portal_accounts`
--

CREATE TABLE `coaching_portal_accounts` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `role` enum('coach','client') NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `coach_id` int(11) UNSIGNED DEFAULT NULL,
  `client_id` int(11) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_portal_accounts`
--

INSERT INTO `coaching_portal_accounts` (`id`, `site_id`, `role`, `email`, `password_hash`, `coach_id`, `client_id`, `is_active`, `last_login_at`, `created_at`) VALUES
(2, 6, 'client', 'yanislaldjipro@gmail.com', '$argon2id$v=19$m=65536,t=4,p=1$VThDNGExWFRpMEEvLkM0YQ$G1EqddEY0kdXo7wVT8MAJ3//z4Lv/6OoaeRfbf6CDjY', NULL, 1, 1, '2026-07-10 01:54:10', '2026-07-10 01:52:49'),
(3, 6, 'coach', 'yanislaldjipro@gmail.com', '$2y$12$x9Pf/W982DAa7r5ByM6iBepr.p7Mq2gkmJeL49seSRXzVOZhZ0TCy', 37, NULL, 1, NULL, '2026-07-27 16:56:11'),
(4, 6, 'client', 'oui@gmail.com', '$argon2id$v=19$m=65536,t=4,p=1$RjFITjJmbnFQVnZtZmJiaw$/6sisgeiJ8vN5dnffWM7JXGOWzAusaLEP85G0M30Ru8', NULL, 2, 1, '2026-07-27 16:57:08', '2026-07-27 16:57:08');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_portal_password_resets`
--

CREATE TABLE `coaching_portal_password_resets` (
  `id` int(11) UNSIGNED NOT NULL,
  `account_id` int(11) UNSIGNED NOT NULL,
  `role` enum('coach','client') NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_portal_password_resets`
--

INSERT INTO `coaching_portal_password_resets` (`id`, `account_id`, `role`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(3, 3, 'coach', '4b159981011122629f9007c2a5bfce9f68b814f148765b795ff7effc27bb393c', '2026-07-30 16:56:11', NULL, '2026-07-27 16:56:11');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_portal_tokens`
--

CREATE TABLE `coaching_portal_tokens` (
  `id` int(11) UNSIGNED NOT NULL,
  `account_id` int(11) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `coaching_session_bookings`
--

CREATE TABLE `coaching_session_bookings` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slot_id` int(11) UNSIGNED NOT NULL,
  `client_id` int(11) UNSIGNED NOT NULL,
  `coach_id` int(11) UNSIGNED NOT NULL,
  `status` enum('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'confirmed',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_session_bookings`
--

INSERT INTO `coaching_session_bookings` (`id`, `site_id`, `slot_id`, `client_id`, `coach_id`, `status`, `notes`, `created_at`) VALUES
(1, 6, 1, 1, 36, 'confirmed', NULL, '2026-07-10 01:54:14');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_specialties`
--

CREATE TABLE `coaching_specialties` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `name` varchar(120) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_specialties`
--

INSERT INTO `coaching_specialties` (`id`, `slug`, `name`, `sort_order`, `is_active`) VALUES
(1, 'zefzfz', 'zefzfz', 0, 1);

-- --------------------------------------------------------

--
-- Structure de la table `coach_certification_links`
--

CREATE TABLE `coach_certification_links` (
  `coach_id` int(11) UNSIGNED NOT NULL,
  `certification_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coach_certification_links`
--

INSERT INTO `coach_certification_links` (`coach_id`, `certification_id`) VALUES
(36, 1),
(37, 1);

-- --------------------------------------------------------

--
-- Structure de la table `coach_language_links`
--

CREATE TABLE `coach_language_links` (
  `coach_id` int(11) UNSIGNED NOT NULL,
  `language_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coach_language_links`
--

INSERT INTO `coach_language_links` (`coach_id`, `language_id`) VALUES
(36, 1),
(37, 1);

-- --------------------------------------------------------

--
-- Structure de la table `coach_specialty_links`
--

CREATE TABLE `coach_specialty_links` (
  `coach_id` int(11) UNSIGNED NOT NULL,
  `specialty_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coach_specialty_links`
--

INSERT INTO `coach_specialty_links` (`coach_id`, `specialty_id`) VALUES
(36, 1),
(37, 1);

-- --------------------------------------------------------

--
-- Structure de la table `competences`
--

CREATE TABLE `competences` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `slug` varchar(100) NOT NULL,
  `label` varchar(150) NOT NULL,
  `categorie` enum('technique','soft_skill','langue','outil','certification') NOT NULL DEFAULT 'technique'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_password_resets`
--

CREATE TABLE `core_admin_password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(11) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_sessions`
--

CREATE TABLE `core_admin_sessions` (
  `id` char(64) NOT NULL COMMENT 'SHA-256 du session id, jamais l id en clair',
  `admin_id` int(11) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_admin_sessions`
--

INSERT INTO `core_admin_sessions` (`id`, `admin_id`, `ip_address`, `user_agent`, `expires_at`, `created_at`) VALUES
('38ce5628f949dc4e122dce85e856478487a272ce8f5b692e48cdde43147e7b87', 1, '2a01:cb09:e03a:23f0:0:4b:e5bc:cc01', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36', '2026-07-11 10:29:48', '2026-07-10 10:29:48'),
('5a59e797726d1953bf11b3ddf15fd2aefd8d5b62de42aef6a13b02884f14e9d6', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-10 16:03:10', '2026-07-09 16:03:10'),
('5fbf5132e47e891b4a220fba80a9298a860d405eb8a05ef86611e06c9b2eb7b5', 1, '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-11 15:35:48', '2026-07-10 15:35:48'),
('a88c7e5be892adac66a6b6f02932f3cd35f91c565b913f0747c7041f9fc387ec', 1, '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-25 02:28:09', '2026-07-24 02:28:09'),
('d8eb9db1552fbeaf2d35f88f51e0c2564dcaea7d33b9852f217b231e83f08b8f', 1, '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-21 18:29:26', '2026-07-20 18:29:26'),
('e7a06174e7fea0b65fe553296ccc5c401686dd452434d4d46ae10010fd547075', 1, '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-28 14:24:02', '2026-07-27 14:24:02'),
('f34035b1a849a26aff9ef95a511c8cb7ed3e67c30271fe3762f27586cf32c6bc', 1, '2a01:cb01:1027:bc0f:8c1f:b00b:9fd0:2e64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-24 01:08:30', '2026-07-23 01:08:30');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_site_access`
--

CREATE TABLE `core_admin_site_access` (
  `admin_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_users`
--

CREATE TABLE `core_admin_users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL DEFAULT '',
  `last_name` varchar(100) NOT NULL DEFAULT '',
  `role` enum('superadmin','admin','editor') NOT NULL DEFAULT 'admin',
  `avatar_url` varchar(500) DEFAULT NULL,
  `two_factor_secret` varchar(255) DEFAULT NULL,
  `two_factor_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_admin_users`
--

INSERT INTO `core_admin_users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `avatar_url`, `two_factor_secret`, `two_factor_enabled`, `is_active`, `last_login`, `last_login_ip`, `created_at`, `updated_at`) VALUES
(1, 'admin@nexytal.com', '$2y$12$P6XdwcTlnOSDgdZckhrMm.SNt1Lv/NdEhtE1P1UqotyoH9m/71Qwq', 'Super', 'Admin', 'superadmin', NULL, NULL, 0, 1, '2026-07-27 14:24:02', NULL, '2026-06-01 09:00:00', '2026-07-27 14:24:02'),
(2, 'xavier.j@alt-rh.com', '$2y$12$60jr7g94klBaaonVHzCNlOtNQ3MuEzfj0uXl.8mqMYjY1jYqsO0cm', 'Xavier', 'Job', 'admin', NULL, NULL, 0, 1, '2026-06-28 17:00:00', NULL, '2026-06-10 10:00:00', '2026-06-30 13:12:37');

-- --------------------------------------------------------

--
-- Structure de la table `core_audit_logs`
--

CREATE TABLE `core_audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `entity_type` varchar(80) NOT NULL,
  `entity_id` int(10) UNSIGNED DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_audit_logs`
--

INSERT INTO `core_audit_logs` (`id`, `admin_id`, `site_id`, `action`, `entity_type`, `entity_id`, `old_data`, `new_data`, `ip_address`, `created_at`) VALUES
(1, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 16:03:10'),
(2, 1, 5, 'create', 'expertise', 9, NULL, '{\"site_id\":5,\"label\":\"test\",\"slug\":\"test\",\"name\":\"test\",\"subtitle\":null,\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":0,\"is_active\":0,\"skills_json\":[\"scdsdc\"],\"certifications_json\":[\"sdcscsdc\"],\"faq_json\":[]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 16:04:40'),
(3, 1, 5, 'update', 'expertise', 9, '{\"id\":9,\"site_id\":5,\"slug\":\"test\",\"label\":\"test\",\"name\":\"test\",\"subtitle\":\"\",\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":0,\"is_active\":0,\"skills_json\":\"[\\\"scdsdc\\\"]\",\"certifications_json\":\"[\\\"sdcscsdc\\\"]\",\"faq_json\":null,\"created_at\":\"2026-07-09 16:04:40\",\"updated_at\":null}', '{\"site_id\":5,\"label\":\"test\",\"slug\":\"test\",\"name\":\"test\",\"subtitle\":null,\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":1,\"is_active\":0,\"skills_json\":[],\"certifications_json\":[],\"faq_json\":[]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 16:06:12'),
(4, 1, 5, 'create', 'trainer_skills', 1, NULL, '{\"name\":\"oui\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 16:06:54'),
(5, 1, 5, 'update', 'expertise', 9, '{\"id\":9,\"site_id\":5,\"slug\":\"test\",\"label\":\"test\",\"name\":\"test\",\"subtitle\":\"\",\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":1,\"is_active\":0,\"skills_json\":null,\"certifications_json\":null,\"faq_json\":null,\"created_at\":\"2026-07-09 16:04:40\",\"updated_at\":\"2026-07-09 16:06:12\"}', '{\"site_id\":5,\"label\":\"test\",\"slug\":\"test\",\"name\":\"test\",\"subtitle\":null,\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":1,\"is_active\":1,\"skills_json\":[],\"certifications_json\":[],\"faq_json\":[]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 17:44:22'),
(6, 1, 5, 'update', 'expertise', 9, '{\"id\":9,\"site_id\":5,\"slug\":\"test\",\"label\":\"test\",\"name\":\"test\",\"subtitle\":\"\",\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":1,\"is_active\":1,\"skills_json\":null,\"certifications_json\":null,\"faq_json\":null,\"created_at\":\"2026-07-09 16:04:40\",\"updated_at\":\"2026-07-09 17:44:22\"}', '{\"site_id\":5,\"label\":\"test\",\"slug\":\"test\",\"name\":\"test\",\"subtitle\":null,\"description\":\"dcsc\",\"icon\":\"shield\",\"sort_order\":1,\"is_active\":1,\"skills_json\":[\"test\",\"test\"],\"certifications_json\":[\"ciidezz\"],\"faq_json\":[{\"q\":\"est ce que c\'est dur ?\",\"a\":\"oui\"}]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 17:46:59'),
(7, 1, 5, 'publish', 'trainers', 13, '{\"id\":13,\"site_id\":5,\"slug\":\"anis-aldji\",\"first_name\":\"Yanis\",\"last_name\":\"Laldji\",\"title\":\"fbhefh\",\"bio\":\"njsnjsvdsbdfdsh\",\"tagline\":\"djsnfjds\",\"avatar_url\":null,\"avatar_initials\":\"YL\",\"city_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"experience_years\":2,\"tjm_eur\":\"450.00\",\"primary_expertise_id\":9,\"legal_status\":\"EURL\",\"qualiopi_eligible\":1,\"status\":\"pending_review\",\"is_featured\":0,\"sort_order\":0,\"rating_avg\":\"0.00\",\"reviews_count\":0,\"published_at\":null,\"validated_at\":null,\"validated_by\":null,\"created_at\":\"2026-07-09 17:49:00\",\"updated_at\":\"2026-07-09 17:49:00\",\"deleted_at\":null}', '{\"status\":\"active\",\"validated_by\":1,\"email_sent\":false}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 17:49:58'),
(8, 1, 5, 'create', 'trainer_language', 2, NULL, '{\"name\":\"test\",\"code\":\"te\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 21:53:06'),
(9, 1, 5, 'create', 'trainer_certifications', 2, NULL, '{\"name\":\"eded\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 21:53:12'),
(10, 1, 5, 'create', 'trainer_city', 2, NULL, '{\"name\":\"efzf\",\"region\":\"zefzf\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 21:53:20'),
(11, 1, 6, 'create', 'coaching_cities', 1, NULL, '{\"name\":\"coaching\",\"region\":\"ezfzef\",\"is_active\":1}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:08:10'),
(12, 1, 5, 'publish', 'trainers', 14, '{\"id\":14,\"site_id\":5,\"slug\":\"anis-aldji\",\"first_name\":\"Yanis\",\"last_name\":\"Laldji\",\"title\":\"eferf\",\"bio\":\"elkgrnjgnejr\",\"tagline\":\"rfegr\",\"avatar_url\":null,\"avatar_initials\":\"YL\",\"city_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"experience_years\":4,\"tjm_eur\":\"600.00\",\"primary_expertise_id\":9,\"legal_status\":\"SASU\",\"qualiopi_eligible\":0,\"status\":\"pending_review\",\"is_featured\":0,\"sort_order\":0,\"rating_avg\":\"0.00\",\"reviews_count\":0,\"published_at\":null,\"validated_at\":null,\"validated_by\":null,\"created_at\":\"2026-07-09 22:50:38\",\"updated_at\":\"2026-07-09 22:50:38\",\"deleted_at\":null}', '{\"status\":\"active\",\"validated_by\":1,\"email_sent\":false}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:50:57'),
(13, 1, 5, 'create', 'blog_tag', 1, NULL, '{\"name\":\"oui\",\"slug\":\"oui\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:59:29'),
(14, 1, 5, 'create', 'blog_author', 1, NULL, '{\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"yanis-laldji\",\"bio\":\"bonjour\",\"is_active\":1}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:59:46'),
(15, 1, 5, 'create', 'blog_category', 1, NULL, '{\"name\":\"test\",\"slug\":\"test\",\"description\":\"ferferf\",\"is_active\":1,\"sort_order\":0}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:59:54'),
(16, 1, 5, 'create', 'blog_post', 1, NULL, '{\"title\":\"test article\",\"slug\":\"test-article\",\"excerpt\":\"dfrfefefz\",\"content\":\"zefezfzef\",\"category_id\":1,\"author_id\":1,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/2eb4d5ad-f489-4ea7-80e9-444bdadded4d.png\",\"read_time_mins\":14,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2004-06-18 00:00:00\",\"tag_ids\":[1]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 23:00:30'),
(17, 1, 6, 'create', 'coaching_languages', 1, NULL, '{\"name\":\"edd\",\"code\":\"fr\",\"flag_emoji\":\"\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 23:37:31'),
(18, 1, 6, 'create', 'coaching_certifications', 1, NULL, '{\"name\":\"sdzef\",\"sort_order\":\"\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 23:37:38'),
(19, 1, 6, 'create', 'coaching_specialties', 1, NULL, '{\"name\":\"zefzfz\",\"sort_order\":\"\",\"is_active\":1}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 23:37:46'),
(20, 1, 5, 'publish', 'trainers', 15, '{\"id\":15,\"site_id\":5,\"slug\":\"anis-aldji-2\",\"first_name\":\"Yanis\",\"last_name\":\"Laldji\",\"title\":\"ezfzf\",\"bio\":\"zefezfez\",\"tagline\":\"zefzfe\",\"avatar_url\":null,\"avatar_initials\":\"YL\",\"city_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"experience_years\":0,\"tjm_eur\":\"600.00\",\"primary_expertise_id\":9,\"legal_status\":\"EURL\",\"qualiopi_eligible\":0,\"status\":\"pending_review\",\"is_featured\":0,\"sort_order\":0,\"rating_avg\":\"0.00\",\"reviews_count\":0,\"published_at\":null,\"validated_at\":null,\"validated_by\":null,\"created_at\":\"2026-07-10 01:44:18\",\"updated_at\":\"2026-07-10 01:44:18\",\"deleted_at\":null}', '{\"status\":\"active\",\"validated_by\":1,\"email_sent\":false}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:44:36'),
(21, 1, 6, 'publish', 'coaches', 36, '{\"id\":36,\"site_id\":6,\"slug\":\"anis-aldji\",\"first_name\":\"Yanis\",\"last_name\":\"Laldji\",\"title\":\"rzfr\\\"ef\",\"bio_short\":null,\"bio_full\":null,\"avatar_url\":null,\"avatar_initials\":\"YL\",\"city_id\":1,\"email\":\"sinay.l777@gmail.com\",\"phone\":\"+33782124452\",\"linkedin_url\":null,\"experience_years\":5,\"status\":\"pending_review\",\"is_featured\":0,\"sort_order\":0,\"published_at\":null,\"validated_at\":null,\"validated_by\":null,\"created_at\":\"2026-07-10 01:48:41\",\"updated_at\":null,\"deleted_at\":null}', '{\"status\":\"active\",\"validated_by\":1,\"email_sent\":false}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:49:18'),
(22, 1, 6, 'create', 'blog_tag', 2, NULL, '{\"name\":\"ed\",\"slug\":\"ed\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:59:15'),
(23, 1, 6, 'create', 'blog_author', 2, NULL, '{\"first_name\":\"zedzed\",\"last_name\":\"efef\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"zedzed-efef\",\"bio\":null,\"is_active\":1}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:59:28'),
(24, 1, 6, 'create', 'blog_category', 2, NULL, '{\"name\":\"ezfez\",\"slug\":\"ezfez\",\"description\":null,\"is_active\":1,\"sort_order\":0}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:59:36'),
(25, 1, 6, 'create', 'blog_post', 2, NULL, '{\"title\":\"zezfzef\",\"slug\":\"zezfzef\",\"excerpt\":\"zezfef\",\"content\":\"zefzfe\",\"category_id\":2,\"author_id\":2,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/850892e4-bb72-4531-ae70-1a9999a1c19c.png\",\"read_time_mins\":45,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-07-17 00:00:00\",\"tag_ids\":[2]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:00:10'),
(26, 1, 4, 'create', 'blog_tag', 3, NULL, '{\"name\":\"ezfze\",\"slug\":\"ezfze\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:14:28'),
(27, 1, 4, 'create', 'blog_author', 3, NULL, '{\"first_name\":\"zefez\",\"last_name\":\"zefzef\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"zefez-zefzef\",\"bio\":\"eez\",\"is_active\":1}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:14:44'),
(28, 1, 4, 'create', 'blog_category', 3, NULL, '{\"name\":\"ezff\",\"slug\":\"ezff\",\"description\":\"zeff\",\"is_active\":1,\"sort_order\":0}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:14:59'),
(29, 1, 4, 'create', 'blog_post', 3, NULL, '{\"title\":\"ezfezf\",\"slug\":\"ezfezf\",\"excerpt\":\"rgegrege\",\"content\":\"ergegre\",\"category_id\":3,\"author_id\":3,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/c0e68f4b-c013-40b1-80ca-ba04902c81a0.png\",\"read_time_mins\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-07-17 00:00:00\",\"tag_ids\":[]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:15:30'),
(30, 1, NULL, 'validate', 'recruteur', 1, '{\"id\":1,\"entreprise_id\":1,\"nom_entreprise\":\"Mr Yanis\",\"prenom\":\"Yanis\",\"nom\":\"Laldji\",\"telephone\":\"0782124452\",\"fonction\":\"ezfzefze\",\"email\":\"sinay.l777@gmail.com\",\"status\":\"pending\",\"validated_at\":null,\"validated_by\":null,\"last_login_at\":null,\"created_at\":\"2026-07-10 02:30:57\",\"updated_at\":\"2026-07-10 02:30:57\"}', '{\"sites\":[\"medical\"]}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:31:48'),
(31, 1, 3, 'publish', 'offre_emploi', 1, '{\"id\":1,\"site_id\":3,\"department\":null,\"entreprise_id\":1,\"recruteur_id\":1,\"metier_id\":null,\"reference\":\"dsfzz\",\"slug\":\"yanis-43732\",\"titre\":\"yanis\",\"description\":\"zefzfz\",\"profil_recherche\":\"efzfzef\",\"avantages\":\"zfezfez\",\"competences_text\":\"ezfzfze\",\"type_contrat\":\"cdi\",\"experience_min\":\"debutant\",\"salaire_min\":2800,\"salaire_max\":null,\"salaire_afficher\":1,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"paris\",\"code_postal\":\"77410\",\"departement\":\"77\",\"region\":\"idf\",\"is_featured\":0,\"is_urgent\":1,\"statut\":\"brouillon\",\"date_publication\":null,\"date_expiration\":\"2026-07-17 23:59:59\",\"vues\":0,\"sort_order\":0,\"created_at\":\"2026-07-10 02:35:32\",\"updated_at\":\"2026-07-10 02:35:32\"}', '{\"statut\":\"publiee\"}', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:35:47'),
(32, 1, NULL, 'login_failed', 'auth', NULL, NULL, NULL, '2a01:cb09:e03a:23f0:0:4b:e5bc:cc01', '2026-07-10 10:29:42'),
(33, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb09:e03a:23f0:0:4b:e5bc:cc01', '2026-07-10 10:29:48'),
(34, 1, 3, 'create', 'metier', 9, NULL, '{\"libelle\":\"erferf\",\"titre\":\"zefzfezef\",\"description_courte\":\"zefzefe\",\"description\":\"zefzefe\",\"presentation\":\"zefzefzef\",\"journee_type\":\"zefezfzfe\",\"secteur_id\":null,\"site_id\":3,\"code_rome\":null,\"famille_metier\":null,\"niveau_etudes\":\"5\",\"perspectives\":\"zef\\\"fzef\",\"image_url\":\"\\/api\\/uploads\\/medical\\/f53831f5-69a2-4979-8854-ebcbd00487ba.png\",\"salaire_fourchette\":\"2200\",\"salaire_debutant\":\"2000\",\"salaire_confirme\":\"14521\",\"salaire_liberal\":\"9599\",\"salaire_details\":\"jefjijezirnjengf\",\"actif\":1}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:25:59'),
(35, 1, 3, 'create', 'secteur_activite', 1, NULL, '{\"label\":\"dfdzef\",\"site_id\":3}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:26:36'),
(36, 1, 3, 'create', 'secteur_activite', 2, NULL, '{\"label\":\"ezefzf\",\"site_id\":3}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:27:23'),
(37, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:35:48'),
(38, 1, 3, 'create', 'secteur_activite', 3, NULL, '{\"label\":\"ererf\",\"site_id\":3}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:36:09'),
(39, 1, 3, 'create', 'secteur_activite', 4, NULL, '{\"label\":\"dsnkfnezfehfzf\",\"site_id\":3}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:36:27'),
(40, 1, 3, 'create', 'secteur_activite', 5, NULL, '{\"label\":\"ededed\",\"site_id\":3}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:36:41'),
(41, 1, 3, 'delete', 'metier', 2, '{\"id\":2,\"site_id\":3,\"code_rome\":null,\"slug\":\"aide-soignant\",\"libelle\":\"Aide-soignant(e)\",\"titre\":\"Aide-soignant(e)\",\"description_courte\":\"Accompagnement des patients dans les actes de la vie quotidienne.\",\"description\":\"L\'aide-soignant(e) dispense, en collaboration avec l\'infirmier, des soins de prévention, de maintien, de relation et d\'éducation à la santé pour préserver et restaurer la continuité de la vie, le bien-être et l\'autonomie de la personne.\",\"image_url\":null,\"presentation\":null,\"journee_type\":null,\"perspectives\":null,\"niveau_etudes\":null,\"salaire_fourchette\":null,\"salaire_debutant\":null,\"salaire_confirme\":null,\"salaire_liberal\":null,\"salaire_details\":null,\"famille_metier\":\"Soins de base\",\"secteur_id\":null,\"actif\":1,\"created_at\":\"2026-07-10 15:25:53\",\"updated_at\":\"0000-00-00 00:00:00\"}', NULL, '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:39:51'),
(42, 1, 3, 'create', 'metier', 1, NULL, '{\"libelle\":\"erezr\",\"titre\":\"fsfzeffe\",\"description_courte\":\"zefzeff\",\"description\":\"ezfzefze\",\"presentation\":\"reerezrg\",\"journee_type\":\"zefzefz\",\"secteur_id\":1,\"site_id\":3,\"code_rome\":null,\"famille_metier\":null,\"niveau_etudes\":\"5\",\"perspectives\":\"ezfzfez\",\"image_url\":\"\\/api\\/uploads\\/medical\\/431ab378-2378-4d04-b4e4-eb256e9594af.png\",\"salaire_fourchette\":\"5210\",\"salaire_debutant\":\"64\",\"salaire_confirme\":\"545\",\"salaire_liberal\":\"98\",\"salaire_details\":\"efzef\",\"actif\":1}', '2a01:cb09:8043:9e9d:9985:daac:b197:e42a', '2026-07-10 15:44:18'),
(43, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 18:29:26'),
(44, 1, 3, 'create', 'blog_tag', 4, NULL, '{\"name\":\"zfzfe\",\"slug\":\"zfzfe\"}', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 18:29:41'),
(45, 1, 3, 'update', 'blog_post', 4, '{\"id\":4,\"site_id\":3,\"category_id\":10,\"author_id\":10,\"title\":\"Recruter un infirmier en Île-de-France : les bonnes pratiques\",\"slug\":\"recrutement-infirmier-idf\",\"excerpt\":\"Conseils pour attirer et fidéliser les IDE dans un contexte de tension sur les effectifs hospitaliers.\",\"content\":\"Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.\",\"cover_image_url\":\"https:\\/\\/images.pexels.com\\/photos\\/4173239\\/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&w=800\",\"read_time_mins\":5,\"status\":\"published\",\"is_featured\":1,\"views_count\":0,\"published_at\":\"2026-07-10 15:25:53\",\"created_at\":\"2026-07-10 15:25:53\",\"deleted_at\":null}', '{\"title\":\"Recruter un infirmier en Île-de-France : les bonnes pratiques\",\"slug\":\"recruter-un-infirmier-en-ile-de-france-les-bonnes-pratiques\",\"excerpt\":\"Conseils pour attirer et fidéliser les IDE dans un contexte de tension sur les effectifs hospitaliers.\",\"content\":\"Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.\",\"category_id\":10,\"author_id\":10,\"cover_image_url\":\"https:\\/\\/images.pexels.com\\/photos\\/4173239\\/pexels-photo-4173239.jpeg?auto=compress&amp;cs=tinysrgb&amp;w=800\",\"read_time_mins\":5,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2026-07-10 00:00:00\",\"tag_ids\":[4]}', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 18:30:22'),
(46, 1, 3, 'update', 'blog_post', 4, '{\"id\":4,\"site_id\":3,\"category_id\":10,\"author_id\":10,\"title\":\"Recruter un infirmier en Île-de-France : les bonnes pratiques\",\"slug\":\"recruter-un-infirmier-en-ile-de-france-les-bonnes-pratiques\",\"excerpt\":\"Conseils pour attirer et fidéliser les IDE dans un contexte de tension sur les effectifs hospitaliers.\",\"content\":\"Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.\",\"cover_image_url\":\"https:\\/\\/images.pexels.com\\/photos\\/4173239\\/pexels-photo-4173239.jpeg?auto=compress&amp;cs=tinysrgb&amp;w=800\",\"read_time_mins\":5,\"status\":\"published\",\"is_featured\":1,\"views_count\":0,\"published_at\":\"2026-07-10 00:00:00\",\"created_at\":\"2026-07-10 15:25:53\",\"deleted_at\":null}', '{\"title\":\"Recruter un infirmier en Île-de-France : les bonnes pratiques\",\"slug\":\"recruter-un-infirmier-en-ile-de-france-les-bonnes-pratiques\",\"excerpt\":\"Conseils pour attirer et fidéliser les IDE dans un contexte de tension sur les effectifs hospitaliers.\",\"content\":\"Le recrutement infirmier en Île-de-France reste un enjeu majeur. Nexytal Médical accompagne les structures dans la définition du besoin et la mise en relation avec des professionnels diplômés.\",\"category_id\":13,\"author_id\":10,\"cover_image_url\":\"https:\\/\\/images.pexels.com\\/photos\\/4173239\\/pexels-photo-4173239.jpeg?auto=compress&amp;amp;cs=tinysrgb&amp;amp;w=800\",\"read_time_mins\":5,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2026-07-10 00:00:00\",\"tag_ids\":[4]}', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 18:31:04'),
(47, 1, NULL, 'validate', 'recruteur', 2, '{\"id\":2,\"entreprise_id\":2,\"nom_entreprise\":\"zenfjkzfnejfzf\",\"prenom\":\"efzefzf\",\"nom\":\"efzfzef\",\"telephone\":\"07 82 12 44 52\",\"fonction\":\"ezfzfze\",\"email\":\"sinay.l777@gmail.com\",\"status\":\"pending\",\"validated_at\":null,\"validated_by\":null,\"last_login_at\":null,\"created_at\":\"2026-07-20 19:44:11\",\"updated_at\":\"2026-07-20 19:44:11\"}', '{\"sites\":[\"medical\"]}', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 19:44:23'),
(48, 1, 3, 'publish', 'offre_emploi', 2, '{\"id\":2,\"site_id\":3,\"department\":null,\"entreprise_id\":2,\"recruteur_id\":2,\"metier_id\":1,\"reference\":\"fefef\",\"slug\":\"dzdefzef-75679\",\"titre\":\"dzdefzef\",\"description\":\"efzfefdz\",\"profil_recherche\":\"jeune,fort\",\"avantages\":\"chèque vacance, ticket resto\",\"competences_text\":\"exigence, intelligence, élégance\",\"type_contrat\":\"cdi\",\"experience_min\":\"3-5\",\"salaire_min\":2500,\"salaire_max\":null,\"salaire_afficher\":1,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"némours\",\"code_postal\":\"77777\",\"departement\":\"74\",\"region\":null,\"is_featured\":0,\"is_urgent\":1,\"statut\":\"brouillon\",\"date_publication\":null,\"date_expiration\":\"2026-07-29 23:59:59\",\"vues\":0,\"sort_order\":0,\"created_at\":\"2026-07-20 21:27:59\",\"updated_at\":\"2026-07-20 21:27:59\"}', '{\"statut\":\"publiee\"}', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', '2026-07-20 21:28:36'),
(49, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb01:1027:bc0f:8c1f:b00b:9fd0:2e64', '2026-07-23 01:08:30'),
(50, 1, NULL, 'validate', 'recruteur', 3, '{\"id\":3,\"entreprise_id\":3,\"nom_entreprise\":\"efzefzfef\",\"prenom\":\"Yanis\",\"nom\":\"Laldji\",\"telephone\":\"0782124452\",\"fonction\":\"fezfnzjf\",\"email\":\"yanislaldjipro@gmail.com\",\"status\":\"pending\",\"validated_at\":null,\"validated_by\":null,\"last_login_at\":null,\"created_at\":\"2026-07-23 01:07:47\",\"updated_at\":\"2026-07-23 01:07:47\"}', '{\"sites\":[\"recrutement\"]}', '2a01:cb01:1027:bc0f:8c1f:b00b:9fd0:2e64', '2026-07-23 01:08:44'),
(51, 1, 2, 'publish', 'offre_emploi', 3, '{\"id\":3,\"site_id\":2,\"department\":null,\"entreprise_id\":3,\"recruteur_id\":3,\"metier_id\":null,\"reference\":null,\"slug\":\"scdscsc-61860\",\"titre\":\"scdscsc\",\"description\":\"scscdscd\",\"profil_recherche\":\"sdcdscsc\",\"avantages\":null,\"competences_text\":\"oui, non\",\"type_contrat\":\"cdi\",\"experience_min\":\"3-5\",\"salaire_min\":45000,\"salaire_max\":null,\"salaire_afficher\":1,\"teletravail\":\"partiel\",\"temps_travail\":\"temps_partiel\",\"ville\":\"dcsdcsc\",\"code_postal\":null,\"departement\":\"7441\",\"region\":null,\"is_featured\":0,\"is_urgent\":0,\"statut\":\"brouillon\",\"date_publication\":null,\"date_expiration\":\"2026-07-24 23:59:59\",\"vues\":0,\"sort_order\":0,\"created_at\":\"2026-07-23 01:11:00\",\"updated_at\":\"2026-07-23 01:11:00\"}', '{\"statut\":\"publiee\"}', '2a01:cb01:1027:bc0f:8c1f:b00b:9fd0:2e64', '2026-07-23 01:11:20'),
(52, 1, 2, 'create', 'blog_tag', 5, NULL, '{\"name\":\"dff\",\"slug\":\"dff\"}', '2a01:cb01:1027:bc0f:e4dd:8712:22ed:d986', '2026-07-23 12:50:46'),
(53, 1, 2, 'create', 'blog_author', 11, NULL, '{\"first_name\":\"fe\",\"last_name\":\"zefzef\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"fe-zefzef\",\"bio\":\"zefzffz\",\"is_active\":1}', '2a01:cb01:1027:bc0f:e4dd:8712:22ed:d986', '2026-07-23 12:50:58'),
(54, 1, 2, 'create', 'blog_category', 14, NULL, '{\"name\":\"efzefezf\",\"slug\":\"efzefezf\",\"description\":\"zefzfzf\",\"is_active\":0,\"sort_order\":0}', '2a01:cb01:1027:bc0f:e4dd:8712:22ed:d986', '2026-07-23 12:51:06'),
(55, 1, 2, 'create', 'blog_post', 7, NULL, '{\"title\":\"fzefzfz\",\"slug\":\"fzefzfz\",\"excerpt\":\"zefzfze\",\"content\":\"efzefzfzf\",\"category_id\":14,\"author_id\":11,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/dc011904-c356-45dc-a356-14fd386a1e4a.png\",\"read_time_mins\":15,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-07-23 00:00:00\",\"tag_ids\":[5]}', '2a01:cb01:1027:bc0f:e4dd:8712:22ed:d986', '2026-07-23 12:51:48'),
(56, 1, 2, 'update', 'blog_category', 14, '{\"id\":14,\"site_id\":2,\"name\":\"efzefezf\",\"slug\":\"efzefezf\",\"description\":\"zefzfzf\",\"color\":null,\"is_active\":0,\"sort_order\":0,\"created_at\":\"2026-07-23 12:51:06\",\"updated_at\":null}', '{\"name\":\"efzefezf\",\"slug\":\"efzefezf\",\"description\":\"zefzfzf\",\"is_active\":1,\"sort_order\":0}', '2a01:cb01:1027:bc0f:e4dd:8712:22ed:d986', '2026-07-23 12:51:57'),
(57, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 02:28:09'),
(58, 1, 1, 'create', 'formation_category', 1, NULL, '{\"label\":\"hghbgg\",\"description\":\"hbhbb\",\"catalogue_type\":\"all\",\"is_active\":1}', '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 03:34:49'),
(59, 1, 1, 'create', 'blog_tag', 6, NULL, '{\"name\":\"njbhbh\",\"slug\":\"njbhbh\"}', '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 03:37:54'),
(60, 1, 1, 'create', 'blog_author', 12, NULL, '{\"first_name\":\"njbhbh\",\"last_name\":\"bhbhb\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"njbhbh-bhbhb\",\"bio\":\"jjhbbh\",\"is_active\":1}', '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 03:38:08'),
(61, 1, 1, 'create', 'blog_category', 15, NULL, '{\"name\":\"njnjnjnj\",\"slug\":\"njnjnjnj\",\"description\":\"njnjj\",\"is_active\":1,\"sort_order\":0}', '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 03:38:17'),
(62, 1, 1, 'create', 'blog_post', 8, NULL, '{\"title\":\"bhlbhjbh\",\"slug\":\"bhlbhjbh\",\"excerpt\":\"bbhbhjbh\",\"content\":\"nkmnnmlknlk\",\"category_id\":15,\"author_id\":12,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/ec8e7a4b-4733-401a-9fdc-b97ccf46ecea.png\",\"read_time_mins\":null,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2026-07-24 00:00:00\",\"tag_ids\":[6]}', '2a01:cb09:805e:58fd:d8a0:be87:894a:10bd', '2026-07-24 03:38:53'),
(63, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 14:24:02'),
(64, 1, 5, 'update', 'blog_post', 1, '{\"id\":1,\"site_id\":5,\"category_id\":1,\"author_id\":1,\"title\":\"test article\",\"slug\":\"test-article\",\"excerpt\":\"dfrfefefz\",\"content\":\"zefezfzef\",\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/2eb4d5ad-f489-4ea7-80e9-444bdadded4d.png\",\"read_time_mins\":14,\"status\":\"published\",\"is_featured\":1,\"views_count\":0,\"published_at\":\"2026-07-09 23:00:30\",\"created_at\":\"2026-07-09 23:00:30\",\"deleted_at\":null}', '{\"title\":\"test article\",\"slug\":\"test-article\",\"excerpt\":\"dfrfefefz\",\"content\":\"zefezfzef\",\"category_id\":1,\"author_id\":1,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/35f2a563-457c-4d3b-9f0e-6ec08427f1c9.jpg\",\"read_time_mins\":14,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2026-07-09 00:00:00\",\"tag_ids\":[1]}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 14:24:45'),
(65, 1, 5, 'create', 'expertise', 10, NULL, '{\"site_id\":5,\"label\":\"tanis\",\"slug\":\"tanis\",\"name\":\"dfsdfs\",\"subtitle\":\"sdfsdfs\",\"description\":\"sdfsfdsdfdse\",\"icon\":\"users\",\"sort_order\":2,\"is_active\":1,\"skills_json\":[\"sezefz\",\"sdfsffz\"],\"certifications_json\":[\"efzedzef\"],\"faq_json\":[{\"q\":\"tyvgv\",\"a\":\"ferfg\'\"}]}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 14:31:14'),
(66, 1, 6, 'update', 'blog_post', 2, '{\"id\":2,\"site_id\":6,\"category_id\":2,\"author_id\":2,\"title\":\"zezfzef\",\"slug\":\"zezfzef\",\"excerpt\":\"zezfef\",\"content\":\"zefzfe\",\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/850892e4-bb72-4531-ae70-1a9999a1c19c.png\",\"read_time_mins\":45,\"status\":\"published\",\"is_featured\":0,\"views_count\":0,\"published_at\":\"2026-07-10 02:00:10\",\"created_at\":\"2026-07-10 02:00:10\",\"deleted_at\":null}', '{\"title\":\"zezfzef\",\"slug\":\"zezfzef\",\"excerpt\":\"zezfef\",\"content\":\"zefzfe\",\"category_id\":2,\"author_id\":2,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/f03fd86a-d712-4e21-ab5b-23f2b0de4eaa.jpg\",\"read_time_mins\":45,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-07-10 00:00:00\",\"tag_ids\":[2]}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 16:23:52'),
(67, 1, 6, 'update', 'coaching_cities', 1, NULL, '{\"name\":\"villevaudé\",\"region\":\"ezfzef\",\"is_active\":1}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 16:54:56'),
(68, 1, 6, 'publish', 'coaches', 37, '{\"id\":37,\"site_id\":6,\"slug\":\"anis-aldji-2\",\"first_name\":\"Yanis\",\"last_name\":\"Laldji\",\"title\":\"ezfzef\",\"bio_short\":null,\"bio_full\":null,\"avatar_url\":null,\"avatar_initials\":\"YL\",\"city_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"+33782124452\",\"linkedin_url\":null,\"experience_years\":5,\"status\":\"pending_review\",\"is_featured\":0,\"sort_order\":0,\"published_at\":null,\"validated_at\":null,\"validated_by\":null,\"created_at\":\"2026-07-27 16:55:36\",\"updated_at\":null,\"deleted_at\":null}', '{\"status\":\"active\",\"validated_by\":1,\"email_sent\":false}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 16:56:12');

-- --------------------------------------------------------

--
-- Structure de la table `core_sites`
--

CREATE TABLE `core_sites` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `site_code` enum('formation','recrutement','medical','carriere','trainers','coaching') NOT NULL,
  `domain` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_sites`
--

INSERT INTO `core_sites` (`id`, `name`, `slug`, `site_code`, `domain`, `is_active`) VALUES
(1, 'Alt Formation', 'alt-formation', 'formation', 'alt-formation.fr', 1),
(2, 'Nexytal Recrutement', 'nexytal-recrutement', 'recrutement', 'recrutement.nexytal.com', 1),
(3, 'Nexytal Médical', 'nexytal-medical', 'medical', 'medical.nexytal.com', 1),
(4, 'Nexytal Carrière', 'nexytal-carriere', 'carriere', 'carriere.nexytal.com', 1),
(5, 'Nexytal Trainer', 'nexytal-trainer', 'trainers', 'trainer.nexytal.com', 1),
(6, 'Nexytal Coaching', 'nexytal-coaching', 'coaching', 'coaching.nexytal.com', 1);

-- --------------------------------------------------------

--
-- Structure de la table `demandes_urgentes`
--

CREATE TABLE `demandes_urgentes` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `recruteur_id` int(10) UNSIGNED DEFAULT NULL,
  `nom` varchar(150) NOT NULL,
  `etablissement` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `metier` varchar(100) NOT NULL,
  `ville` varchar(150) NOT NULL,
  `message` text DEFAULT NULL,
  `statut` enum('recue','en_cours','traitee','archivee') NOT NULL DEFAULT 'recue',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `entreprises`
--

CREATE TABLE `entreprises` (
  `id` int(10) UNSIGNED NOT NULL,
  `nom` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `siret` char(14) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `taille` enum('1-10','11-50','51-200','201-500','500+') DEFAULT NULL,
  `secteur_id` int(10) UNSIGNED DEFAULT NULL,
  `adresse` varchar(300) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `departement` varchar(5) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `validee` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `entreprises`
--

INSERT INTO `entreprises` (`id`, `nom`, `slug`, `siret`, `description`, `taille`, `secteur_id`, `adresse`, `code_postal`, `ville`, `departement`, `region`, `validee`, `created_at`, `updated_at`) VALUES
(1, 'Mr Yanis', 'mr-yanis', 'ezfzfzef', 'zefezfzfe', '51-200', NULL, '14 All. de la Grande Mare', '77410', 'Villevaudé', '77', 'idf', 1, '2026-07-10 02:30:57', '2026-07-10 02:31:47'),
(2, 'zenfjkzfnejfzf', 'zenfjkzfnejfzf', 'zefezfezffzef', NULL, '201-500', NULL, '14 Rue de la Grande Mare', '77410', 'Villevaudé', NULL, NULL, 1, '2026-07-20 19:44:10', '2026-07-20 19:44:23'),
(3, 'efzefzfef', 'efzefzfef', 'ezfzfezef', NULL, '51-200', NULL, NULL, NULL, 'ezfzfeezf', NULL, NULL, 1, '2026-07-23 01:07:47', '2026-07-23 01:08:44');

-- --------------------------------------------------------

--
-- Structure de la table `expertises`
--

CREATE TABLE `expertises` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL COMMENT 'core_sites.id — NULL = catalogue global, 5 = Nexytal Trainer',
  `slug` varchar(110) NOT NULL,
  `label` varchar(150) NOT NULL COMMENT 'Titre affiché (ex: Formateur IA)',
  `name` varchar(150) DEFAULT NULL COMMENT 'Nom court menu (ex: IA)',
  `subtitle` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL COMMENT 'Texte SEO page catalogue',
  `icon` varchar(50) DEFAULT NULL COMMENT 'Identifiant icône front (brain, shield, cloud…)',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `skills_json` text DEFAULT NULL COMMENT 'Compétences — une par ligne (stockage texte, pas JSON MySQL)',
  `certifications_json` text DEFAULT NULL COMMENT 'Certifications — une par ligne',
  `faq_json` text DEFAULT NULL COMMENT 'FAQ — format: Question?|Réponse (une paire par ligne)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `expertises`
--

INSERT INTO `expertises` (`id`, `site_id`, `slug`, `label`, `name`, `subtitle`, `description`, `icon`, `sort_order`, `is_active`, `skills_json`, `certifications_json`, `faq_json`, `created_at`, `updated_at`) VALUES
(9, 5, 'test', 'test', 'test', '', 'dcsc', 'shield', 1, 1, '[\"test\",\"test\"]', '[\"ciidezz\"]', '[{\"q\":\"est ce que c\'est dur ?\",\"a\":\"oui\"}]', '2026-07-09 16:04:40', '2026-07-09 17:46:59'),
(10, 5, 'tanis', 'tanis', 'dfsdfs', 'sdfsdfs', 'sdfsfdsdfdse', 'users', 2, 1, '[\"sezefz\",\"sdfsffz\"]', '[\"efzedzef\"]', '[{\"q\":\"tyvgv\",\"a\":\"ferfg\'\"}]', '2026-07-27 14:31:14', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `formation_categories`
--

CREATE TABLE `formation_categories` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_categories`
--

INSERT INTO `formation_categories` (`id`, `site_id`, `name`, `slug`, `description`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 1, 'hghbgg', 'hghbgg', 'hbhbb', 0, 1, '2026-07-24 03:34:49'),
(2, 1, 'Cybersecurite, Reseaux & Infrastructure', 'cybersecurite-reseaux', 'Cybersecurite, systemes, reseaux, cloud et infrastructure.', 10, 1, '2026-07-27 03:16:28'),
(3, 1, 'Developpement, IA & Data', 'digital-developpement', 'Developpement web, applications, IA, data et ingenierie logicielle.', 20, 1, '2026-07-27 03:16:28'),
(4, 1, 'IA, Data & Programmation', 'ia-data', 'Intelligence artificielle, data, automatisation et programmation.', 30, 1, '2026-07-27 03:16:28'),
(5, 1, 'Ressources humaines', 'ressources-humaines', 'RH, insertion, administration et accompagnement professionnel.', 40, 1, '2026-07-27 03:16:28'),
(6, 1, 'Comptabilite & Gestion', 'comptabilite-gestion', 'Comptabilite, gestion, commerce, immobilier et management.', 50, 1, '2026-07-27 03:16:28'),
(7, 1, 'Cybersecurite', 'cybersecurite', 'Formations courtes cyber, pentest, audit et securite.', 60, 1, '2026-07-27 03:16:28'),
(8, 1, 'Management', 'management', 'Management, projet, agilite et RSE.', 70, 1, '2026-07-27 03:16:28'),
(9, 1, 'DevOps / DevSecOps', 'devops-devsecops', 'Conteneurs, CI/CD, automatisation et securite DevOps.', 80, 1, '2026-07-27 03:16:28'),
(10, 1, 'DevOps', 'devops', 'Methodes, outils et certifications DevOps.', 90, 1, '2026-07-27 03:16:28'),
(11, 1, 'Informatique & Systemes', 'informatique-systemes-reseaux', 'Administration systeme, reseaux et infrastructure.', 110, 1, '2026-07-27 03:16:28'),
(12, 1, 'Systemes embarques & IoT', 'systemes-embarques-iot', 'Android embarque, Linux embarque et objets connectes.', 120, 1, '2026-07-27 03:16:28'),
(13, 1, 'Bureautique', 'bureautique', 'Excel, Word, PowerPoint et certifications bureautiques.', 130, 1, '2026-07-27 03:16:28');

-- --------------------------------------------------------

--
-- Structure de la table `formation_courses`
--

CREATE TABLE `formation_courses` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `course_type` varchar(50) DEFAULT 'diplomante',
  `subtitle` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `modality_label` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `certification_label` varchar(255) DEFAULT NULL,
  `reference_code` varchar(100) DEFAULT NULL,
  `rncp_repertoire` varchar(20) DEFAULT NULL,
  `is_cpf_eligible` tinyint(1) NOT NULL DEFAULT 0,
  `is_alternance` tinyint(1) NOT NULL DEFAULT 0,
  `rncp_code` varchar(100) DEFAULT NULL,
  `rncp_title` varchar(255) DEFAULT NULL,
  `rncp_level` varchar(50) DEFAULT NULL,
  `rncp_url` varchar(255) DEFAULT NULL,
  `presentation_title` varchar(255) DEFAULT NULL,
  `presentation_text` mediumtext DEFAULT NULL,
  `presentation_image_url` varchar(255) DEFAULT NULL,
  `programme_duration_total` varchar(255) DEFAULT NULL,
  `debouches_title` varchar(255) DEFAULT NULL,
  `debouches_subtitle` text DEFAULT NULL,
  `debouches_sectors` text DEFAULT NULL,
  `evaluation_title` varchar(255) DEFAULT NULL,
  `evaluation_description` text DEFAULT NULL,
  `cta_title` varchar(255) DEFAULT NULL,
  `cta_subtitle` text DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `extra_json` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_courses`
--

INSERT INTO `formation_courses` (`id`, `site_id`, `category_id`, `title`, `slug`, `course_type`, `subtitle`, `video_url`, `duration`, `modality_label`, `price`, `certification_label`, `reference_code`, `rncp_repertoire`, `is_cpf_eligible`, `is_alternance`, `rncp_code`, `rncp_title`, `rncp_level`, `rncp_url`, `presentation_title`, `presentation_text`, `presentation_image_url`, `programme_duration_total`, `debouches_title`, `debouches_subtitle`, `debouches_sectors`, `evaluation_title`, `evaluation_description`, `cta_title`, `cta_subtitle`, `status`, `sort_order`, `created_at`, `extra_json`) VALUES
(119, 1, 2, 'Devenez Administrateur·rice d’infrastructures sécurisées', 'formations-administrateur-dinfrastructures-securisees-ais', 'diplomante', 'Concevez, administrez et sécurisez les infrastructures informatiques des entreprises.', '/assets/video/formations/admin-infra.mp4', '24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37680', 'Administrateur d’infrastructures sécurisées', '6', 'https://www.francecompetences.fr/recherche/rncp/37680/', 'Le métier', 'L’Administrateur·rice d’infrastructures sécurisées est un pilier stratégique du système d’information. Il·elle conçoit, administre et sécurise les infrastructures informatiques afin de garantir leur disponibilité, leur performance et leur protection. Son rôle est central : il·elle intervient aussi bien sur les serveurs, les réseaux, les systèmes que sur les enjeux de cybersécurité, en veillant à la continuité d’activité et à la protection des données. 👉 C’est un métier à forte responsabilité, recherché par les entreprises confrontées à des enjeux croissants de sécurité informatique.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · IT / Systèmes & Réseaux', NULL, NULL, 'Prêt·e à devenir Administrateur·rice d’infrastructures sécurisées ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 1, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(120, 1, 3, 'Devenez Développeur·euse Web & Mobile', 'formations-developpeur-web-mobile', 'diplomante', 'Concevez des applications web et mobiles performantes, du front-end au back-end.', '/assets/video/formations/dev-web-mobile.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37674', 'Développeur web et web mobile', '5', 'https://www.francecompetences.fr/recherche/rncp/37674/', 'Le métier', 'Le·la Développeur·euse Web & Web Mobile conçoit et développe des applications accessibles via un navigateur ou un terminal mobile. Il·elle travaille sur la partie visible (interface utilisateur) comme sur la partie technique (serveur, base de données), en veillant à la performance, à la sécurité et à l’expérience utilisateur. Il·elle collabore avec des chef·fe·s de projet, designers et autres développeur·euse·s dans des environnements agiles ou classiques.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation certifiante · Développement Web & Mobile', NULL, NULL, 'Prêt·e à devenir Développeur·euse Web & Mobile ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 2, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(121, 1, 3, 'Devenez Développeur·euse d’applications multimédia', 'formations-developpeur-dapplications-multimedia', 'diplomante', 'Créez des applications interactives alliant graphisme, animation, son et vidéo.', '/assets/video/formations/dev-app.mp4', 'Durée', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '39111', 'Développeur d’applications web ou web mobile', '5', 'https://www.francecompetences.fr/recherche/rncp/39111/', 'Le métier', 'Développeur·euse d’Applications Multimédia : un métier créatif et technique. Le·la Développeur·euse d’Applications Multimédia conçoit des applications interactives intégrant différents médias (graphisme, animation, son, vidéo). Il·elle intervient sur des projets variés : applications web, mobiles, interfaces interactives, supports numériques ou expériences immersives. Il·elle travaille en collaboration avec des designers, chef·fe·s de projet et équipes techniques afin de proposer des solutions performantes, ergonomiques et innovantes.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · IT / Systèmes & Réseaux', NULL, NULL, 'Prêt·e à devenir Développeur·euse d’applications multimédia ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 3, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(122, 1, 3, 'Devenez Concepteur·rice Développeur·euse d’Applications', 'formations-concepteur-developpeur-dapplications', 'diplomante', 'Concevez et développez des applications logicielles complètes, de l\'analyse des besoins à la mise en production.', '/assets/video/formations/dev-app.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37625', 'Concepteur développeur d’applications', '6', 'https://www.francecompetences.fr/recherche/rncp/37625/', 'Le métier', 'Le·la Concepteur·rice Développeur·euse d’Applications conçoit et développe des applications logicielles complètes répondant à des besoins métiers spécifiques. Il·elle intervient sur l’analyse des besoins, la conception technique, le développement, les tests et la maintenance des solutions applicatives. Il·elle travaille en collaboration avec des chef·fe·s de projet, développeur·euse·s, designers et équipes métiers, dans des environnements agiles ou classiques.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Concepteur·rice Développeur·euse d’Applications', NULL, NULL, 'Prêt·e à devenir Concepteur·rice Développeur·euse d’Applications ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 4, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(123, 1, 2, 'Devenez Technicien·ne supérieur·e systèmes et réseaux', 'formations-technicien-superieur-systemes-et-reseaux', 'diplomante', 'Installez, configurez et maintenez les infrastructures informatiques des organisations.', '/assets/video/formations/technicien-sr.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37682', 'Technicien supérieur systèmes et réseaux', '5', 'https://www.francecompetences.fr/recherche/rncp/37682/', 'Le métier', 'Le·la Technicien·ne Supérieur·e Systèmes et Réseaux assure l’installation, la configuration et la maintenance des infrastructures informatiques d’une organisation. Il·elle veille à la disponibilité des systèmes, à la sécurité des réseaux et accompagne les utilisateurs dans leur usage quotidien des outils numériques. Il·elle travaille en lien avec les équipes informatiques, les prestataires et les utilisateurs finaux.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · IT / Systèmes & Réseaux', NULL, NULL, 'Prêt·e à devenir Technicien·ne supérieur·e systèmes et réseaux ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 5, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(124, 1, 3, 'Devenez Lead Développeur·euse Web', 'formations-lead-developpeur-web', 'diplomante', 'Pilotez des projets web complexes, coordonnez vos équipes et définissez les choix d\'architecture.', '/assets/video/formations/dev-app.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '39608', 'Concepteur développeur web full stack', '6', 'https://www.francecompetences.fr/recherche/rncp/39608/', 'Le métier', 'Le·la Lead Développeur·euse Web conçoit, développe et supervise des applications web complexes. Il·elle coordonne les équipes techniques, définit les choix d’architecture, veille à la qualité du code et assure la mise en production des projets. Il·elle joue un rôle clé entre les équipes techniques, les chef·fe·s de projet et les clients, en garantissant le respect des délais, des performances et des standards de développement.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante Développement & Pilotage web', NULL, NULL, 'Prêt·e à devenir Lead Développeur·euse Web ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 6, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(125, 1, 6, 'Devenez Community Manager', 'formations-community-manager', 'diplomante', 'Animez les communautés en ligne, créez du contenu engageant et développez l\'e-réputation des marques.', '/assets/video/formations/manager.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '41364', 'Community manager', '6', 'https://www.francecompetences.fr/recherche/rncp/41364/', 'Le métier', 'Ce métier central vous permet d\'intervenir sur la gestion administrative, le développement des talents et la stratégie des ressources humaines au sein de l\'entreprise. Vous serez l\'interlocuteur·rice clé entre la direction et les collaborateur·rice·s, garantissant un environnement de travail épanouissant et conforme à la législation.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Ressources Humaines, Secrétariat, Management, Tertiaire.', NULL, NULL, 'Prêt·e à devenir Community Manager ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 7, '2026-07-27 03:19:56', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(126, 1, 5, 'Devenez Assistant·e Ressources Humaines', 'formations-assistante-ressources-humaines', 'diplomante', 'Gérez l\'administration du personnel, participez au recrutement et contribuez au bon climat social de l\'entreprise.', '/assets/video/formations/rh.mp4', '12 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36612', 'Assistant ressources humaines', '5', 'https://www.francecompetences.fr/recherche/rncp/36612/', 'Le métier', 'L\'Assistant·e Ressources Humaines gère les dossiers administratifs du personnel, de l\'embauche jusqu\'au départ du ou de la salarié·e. Il ou elle prépare les éléments fixes et variables de la paie, participe aux processus de recrutement et aide au déploiement du plan de développement des compétences. 👉 C\'est un métier polyvalent et humain, indispensable au bon fonctionnement de toute entreprise ou structure.', NULL, 'Programme complet de 12 mois', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine des RH.', 'Formation diplômante · Gestion / RH', NULL, NULL, 'Prêt·e à devenir Assistant·e Ressources Humaines ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 8, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(127, 1, 5, 'Devenez Assistant·e Administratif·ve', 'formations-assistante-administratifve', 'diplomante', 'Gérez l\'accueil, le courrier et l\'administration courante pour assurer le bon fonctionnement des services.', '/assets/video/formations/administration.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36390', 'Assistant de gestion et d’administration d’entreprise', '5', 'https://www.francecompetences.fr/recherche/rncp/36390/', 'Le métier', 'Ce métier central vous permet d\'intervenir sur la gestion administrative, le développement des talents et la stratégie des ressources humaines au sein de l\'entreprise. Vous serez l\'interlocuteur·rice clé entre la direction et les collaborateur·rice·s, garantissant un environnement de travail épanouissant et conforme à la législation.', NULL, 'Programme complet de 12 mois', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine administratif.', 'Ressources Humaines, Secrétariat, Management, Tertiaire.', NULL, NULL, 'Prêt·e à devenir Assistant·e Administratif·ve ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 9, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(128, 1, 5, 'Devenez Assistant·e Commercial·e', 'formations-assistante-commerciale', 'diplomante', 'Assurez le suivi commercial en tant qu\'interface clé entre clients, commerciaux et services internes.', '/assets/video/formations/administration.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '41254', 'Assistant commercial', '5', 'https://www.francecompetences.fr/recherche/rncp/41254/', 'Le métier', 'Ce métier central vous permet d\'intervenir sur la gestion administrative, le développement des talents et la stratégie des ressources humaines au sein de l\'entreprise. Vous serez l\'interlocuteur·rice clé entre la direction et les collaborateur·rice·s, garantissant un environnement de travail épanouissant et conforme à la législation.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Ressources Humaines, Secrétariat, Management, Tertiaire.', NULL, NULL, 'Prêt·e à devenir Assistant·e Commercial·e ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 10, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(129, 1, 6, 'Devenez Secrétaire Comptable', 'formations-secretaire-comptable', 'diplomante', 'Combinez polyvalence administrative et rigueur comptable pour gérer facturation et comptabilité en entreprise.', '/assets/video/formations/comptable.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36434', 'Secrétaire comptable', '4', 'https://www.francecompetences.fr/recherche/rncp/36434/', 'Le métier', 'La comptabilité est la colonne vertébrale de l\'entreprise. Vous serez responsable de la lisibilité financière de la structure, de la saisie des opérations courantes jusqu\'à la préparation des bilans. C\'est un métier exigeant l\'application de normes strictes et une maîtrise des outils numériques actuels.', NULL, 'Programme complet de 12 mois', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes polyvalents en PME.', 'Cabinets d\'expertise comptable, PME, Grandes entreprises.', NULL, NULL, 'Prêt·e à devenir Secrétaire Comptable ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 11, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(130, 1, 5, 'Devenez Conseiller·ère Relation Client à Distance', 'formations-conseillerere-relation-client-a-distance', 'diplomante', 'Assurez l\'accueil, le conseil et l\'assistance à distance pour garantir la satisfaction client.', '/assets/video/contact.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '35304', 'Conseiller relation client à distance', '4', 'https://www.francecompetences.fr/recherche/rncp/35304/', 'Le métier', 'Ce métier central vous permet d\'intervenir sur la gestion administrative, le développement des talents et la stratégie des ressources humaines au sein de l\'entreprise. Vous serez l\'interlocuteur·rice clé entre la direction et les collaborateur·rice·s, garantissant un environnement de travail épanouissant et conforme à la législation.', NULL, 'Programme modulaire intensif', 'Les métiers visés', 'Après cette formation, vous pourrez postuler en centre de relation client ou en entreprise.', 'Ressources Humaines, Secrétariat, Management, Tertiaire.', NULL, NULL, 'Prêt·e à devenir Conseiller·ère Relation Client ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 12, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(131, 1, 2, 'Devenez Administrateur·rice Réseaux NetOps', 'administrateur-reseaux-netops', 'diplomante', 'Configurez, supervisez et automatisez les infrastructures réseau modernes avec les outils NetOps.', '/assets/video/formations/admin-infra.mp4', 'Durée', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36163', 'Administrateur réseaux NetOps', '6', 'https://www.francecompetences.fr/recherche/rncp/36163/', 'Le métier', 'La formation Administrateur·rice Réseaux NetOps prépare aux métiers de l’administration et de l’automatisation des infrastructures réseau modernes. Elle permet d’acquérir les compétences nécessaires pour configurer, supervisez et sécurisez des réseaux informatiques complexes, qu’ils soient déployés en entreprise, dans un datacenter ou dans le cloud. Ce parcours mène à l’obtention d’un Titre Professionnel de niveau 6 (équivalent Bac +3/4) reconnu par l’État et inscrit au Répertoire National des Certifications Professionnelles (RNCP 36163). Les apprenant·e·s développent une expertise dans l’administration réseau, l’automatisation des infrastructures et la supervision des systèmes afin d’assurer la continuité, la sécurité et la performance des réseaux informatiques.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · IT / Systèmes & Réseaux', NULL, NULL, 'Prêt·e à devenir Administrateur·rice Réseaux NetOps ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 13, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(132, 1, 3, 'Devenez Administrateur·rice système DevOps', 'administrateursysteme-devops', 'diplomante', 'Concevez, administrez et sécurisez les infrastructures informatiques des entreprises.', '/assets/video/formations/technicien-sr.mp4', '24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36061', 'Administrateur système DevOps', '6', 'https://www.francecompetences.fr/recherche/rncp/36061/', 'Le métier', 'L’Administrateur·rice d’infrastructures sécurisées est un pilier stratégique du système d’information. Il·elle conçoit, administre et sécurise les infrastructures informatiques afin de garantir leur disponibilité, leur performance et leur protection. Son rôle est central : il·elle intervient aussi bien sur les serveurs, les réseaux, les systèmes que sur les enjeux de cybersécurité, en veillant à la continuité d’activité et à la protection des données. 👉 C’est un métier à forte responsabilité, recherché par les entreprises confrontées à des enjeux croissants de sécurité informatique.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · Gestion / RH', NULL, NULL, 'Prêt·e à devenir Administrateur·rice système DevOps ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 14, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(133, 1, 2, 'Devenez Technicien·ne réseaux cybersécurité', 'technicien-reseaux-cybersecurite', 'diplomante', 'Concevez, administrez et sécurisez les infrastructures informatiques des entreprises.', '/assets/video/formations/cyber.mp4', '24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '39611', 'Administrateur systèmes, réseaux et cybersécurité', '6', 'https://www.francecompetences.fr/recherche/rncp/39611/', 'Le métier', 'L’Administrateur·rice d’infrastructures sécurisées est un pilier stratégique du système d’information. Il·elle conçoit, administre et sécurise les infrastructures informatiques afin de garantir leur disponibilité, leur performance et leur protection. Son rôle est central : il·elle intervient aussi bien sur les serveurs, les réseaux, les systèmes que sur les enjeux de cybersécurité, en veillant à la continuité d’activité et à la protection des données. 👉 C’est un métier à forte responsabilité, recherché par les entreprises confrontées à des enjeux croissants de sécurité informatique.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine.', 'Formation diplômante · Gestion / RH', NULL, NULL, 'Prêt·e à devenir Technicien·ne réseaux cybersécurité ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 15, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(134, 1, 6, 'Gestionnaire comptable et fiscal·e — Titre professionnel Bac+2', 'gestionnaire-comptable-fiscal', 'diplomante', 'Avec Alt RH & formations, pilotez la comptabilité générale, les déclarations fiscales et les documents financiers au cœur de la stratégie de l\'entreprise.', '/assets/video/formations/comptable.mp4', '679 heures — 6 à 18 mois selon modalité', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37949', 'Gestionnaire comptable et fiscal', '5', 'https://www.francecompetences.fr/recherche/rncp/37949/', 'Le métier', 'Le·la Gestionnaire comptable et fiscal·e assure la tenue de la comptabilité générale, réalise les déclarations et participe à la production des documents financiers (bilan, compte de résultat). Il·elle garantit la fiabilité des chiffres, le respect des obligations légales et contribue au pilotage de l\'organisation — en PME polyvalent·e ou au sein d\'une équipe en cabinet d\'expertise-comptable. Le titre professionnel de niveau 5 (équivalent Bac+2, RNCP 37949) vise l\'autonomie sur l\'intégralité du cycle comptable : arrêtés comptables, conformité fiscale et accompagnement à la décision. Alt RH & formations vous accompagne sur tout le parcours : choix de la modalité (présentiel mixte, visioconférence ou e-learning), montage du financement (CPF — code 2314, OPCO, France Travail) et préparation à l\'examen en présentiel. Certification inscrite au RNCP via France Compétences, reconnue par le Ministère du Travail.', NULL, '679 heures — 3 blocs de compétences certifiants et dossier professionnel (6 mois en continue + stage conseillé, 12 à 24 mois en alternance)', 'Débouchés et évolutions de carrière', 'Un marché de l\'emploi dynamique en PME, cabinets et services — avec des perspectives d\'évolution vers le niveau 6 ou des postes de responsabilité financière.', 'Entreprises et organisations du secteur marchand, des services ou non marchand, cabinets d\'expertise-comptable (tenue ou révision de comptabilité).', NULL, NULL, 'Construisez votre expertise comptable avec Alt RH & formations', 'Choisissez votre modalité et échangez avec nos conseillers sur le financement, le stage et les prochaines rentrées.', 'published', 16, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(135, 1, 6, 'Devenez Comptable Assistant·e', 'formations-comptable-assistant', 'diplomante', 'Comptabilisez les documents financiers et réalisez les déclarations courantes de l\'entreprise.', '/assets/video/formations/comptable.mp4', '12 à 24 mois', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37121', 'Comptable assistant', '4', 'https://www.francecompetences.fr/recherche/rncp/37121/', 'Le métier', 'La comptabilité est la colonne vertébrale de l\'entreprise. Vous serez responsable de la lisibilité financière de la structure, de la saisie des opérations courantes jusqu\'à la préparation des bilans. C\'est un métier exigeant l\'application de normes strictes et une maîtrise des outils numériques actuels.', NULL, 'Programme complet de 9 à 12 mois', 'Les métiers visés', 'Après cette formation, vous pourrez postuler dans divers environnements comptables.', 'Cabinets d\'expertise comptable, PME, Grandes entreprises.', NULL, NULL, 'Prêt·e à devenir Comptable Assistant·e ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 17, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(136, 1, 3, 'Devenez Concepteur·rice Designer UI', 'formations-concepteur-designer-ui', 'diplomante', 'Créez des interfaces numériques alliant créativité graphique et expérience utilisateur (UX/UI).', '/assets/video/formations/dev-app.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '35634', 'Concepteur designer UI', '6', 'https://www.francecompetences.fr/recherche/rncp/35634/', 'Le métier', 'Le·la concepteur·rice designer UI conçoit et réalise des interfaces numériques (sites web, applications, supports digitaux) en combinant créativité graphique et compréhension des besoins utilisateurs. À partir d\'un brief, d\'un cahier des charges ou d\'une demande client, il·elle analyse les attentes, imagine l\'univers visuel, crée des maquettes et définit l\'expérience utilisateur (UX/UI). Il·elle conçoit des chartes graphiques, produit des visuels et développe des prototypes interactifs. Il·elle intègre les contenus à l\'aide d\'outils professionnels, de langages web et de CMS, veille à la cohérence visuelle et à la compatibilité sur tous les supports. Il·elle optimise également l\'expérience utilisateur en testant ses réalisations et en analysant les comportements des utilisateurs. 👉 Un métier créatif et technique, au cœur de la transformation digitale des entreprises.', NULL, 'Programme complet – voir brochure pour les détails', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes variés dans le domaine du design numérique.', 'Agences digitales · Entreprises · Startups · Freelance', NULL, NULL, 'Prêt·e à devenir Concepteur·rice Designer UI ?', 'Contactez-nous pour en savoir plus sur les prochaines sessions et les modalités de financement.', 'published', 18, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(137, 1, 5, 'Devenez Assistant·e de Direction', 'formations-assistante-de-direction', 'diplomante', 'Coordonnez l\'activité et facilitez la prise de décision en tant que bras droit du dirigeant.', '/assets/video/formations/administration.mp4', '5h45', NULL, '3450.00', NULL, NULL, 'RNCP', 0, 0, '38667', 'Assistant de direction', '5', 'https://www.francecompetences.fr/recherche/rncp/38667/', 'Le métier', 'L\'Assistant·e de Direction est le·la collaborateur·rice direct·e d\'un ou plusieurs dirigeant·e·s. Il·elle centralise les informations, organise les plannings, prépare les réunions et assure le suivi des dossiers confidentiels. Il·elle est le lien privilégié entre la direction, les équipes internes et les partenaires extérieurs. C\'est un métier qui exige une excellente communication, une maîtrise parfaite des outils bureautiques et une grande capacité d\'adaptation.', NULL, 'Dates fixes, de 9h00 à 13h00 et de 14h00 à 17h00', 'Les métiers visés', 'Après cette formation, vous pourrez postuler à des postes clés de l\'assistanat.', 'Toutes entreprises (PME, ETI, Grands groupes), Fonction publique, Associations.', NULL, NULL, 'Prêt·e à devenir Assistant·e de Direction ?', 'Nos conseillers sont à votre écoute pour vous aider à monter votre dossier (CPF, France Travail, etc.).', 'published', 19, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}'),
(138, 1, 3, 'Executive Mastère Ingénierie Avancée du Logiciel', 'executive-mastere-ingenierie-logiciel', 'diplomante', 'Pilotez des projets logiciels complexes avec performance, qualité et méthodologie agile.', '/assets/video/formations/dev-app.mp4', '820 heures', NULL, '9910.00', NULL, NULL, 'RNCP', 0, 0, '38590', 'Manager de l’ingénierie numérique', '7', 'https://www.francecompetences.fr/recherche/rncp/38590/', 'Le métier', 'Dans un contexte de transformation numérique accélérée, les entreprises recherchent des professionnel·le·s capables de piloter des projets de développement complexes, en intégrant les enjeux de performance, de qualité logicielle et de collaboration agile.\r\n\r\nCe cycle de formation vous donne toutes les clés pour analyser les besoins d’un client, concevoir et déployer une architecture technique adaptée, et encadrer efficacement des équipes de développement. Que vous soyez déjà développeur·euse, chef·fe de projet technique ou en reconversion vers des fonctions plus stratégiques, ce programme vous permet de renforcer vos compétences dans des environnements modernes (DevOps, architectures distribuées, cloud computing).\r\n\r\nVous serez en mesure de gérer un projet de bout en bout, depuis l’expression du besoin jusqu’à la mise en production continue.', NULL, '820 heures', 'Débouchés', NULL, NULL, NULL, NULL, NULL, NULL, 'published', 20, '2026-07-27 03:19:57', '{\"avantages_visiplus\":[{\"titre\":\"Une plateforme digital learning dédiée\",\"desc\":\"Suivez l’intégralité de nos formations au format e-learning à votre propre rythme.\"},{\"titre\":\"Un suivi personnalisé\",\"desc\":\"Conseiller·ère·s, formateur·rice·s et mentor·e·s individuel·le·s à votre disposition à chaque étape de votre parcours.\"},{\"titre\":\"Le soutien de toute une communauté\",\"desc\":\"Echangez au quotidien avec vos pairs et notre équipe pédagogique.\"},{\"titre\":\"Votre employabilité renforcée\",\"desc\":\"Des formations conçues par des professionnel·le·s expert·e·s pour répondre aux besoins du marché.\"},{\"titre\":\"Un réseau d’Alumni pour échanger\",\"desc\":\"Cercle Alumni de plus de 20 000 diplômé·e·s pour networker et élargir votre réseau professionnel.\"}],\"financement\":{\"titre\":\"Financer sa formation en Développement Web / Informatique\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\"}}'),
(139, 1, 6, 'Devenez Responsable d\'Établissement Marchand', 'formations-responsable-etablissement-marchand', 'diplomante', 'Avec Alt RH & formations, accédez au titre professionnel commerce & distribution : pilotage du magasin, performance économique et management d\'équipes.', '/assets/video/formations/administration.mp4', '672 heures de formation', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '38666', 'Responsable d’établissement marchand', '6', 'https://www.francecompetences.fr/recherche/rncp/38666/', 'Le métier', 'Le·la Responsable d\'Établissement Marchand est le pilote opérationnel d\'un point de vente : il·elle garantit le respect des règles, décline la stratégie de l\'enseigne sur le terrain et cherche en permanence l\'équilibre entre satisfaction client, performance commerciale et rentabilité. C\'est un métier de terrain, de leadership et d\'analyse, particulièrement recherché dans la grande distribution, le commerce de proximité et les enseignes spécialisées. Alt RH & formations vous accompagne sur l\'ensemble du parcours : définition de votre projet, montage du financement (CPF, OPCO, France Travail…), suivi pédagogique en e-learning et préparation à la certification. Le parcours en formation continue inclut une immersion en entreprise (350 h de stage). À l\'issue de la validation, vous obtenez le titre professionnel de niveau Bac+3 délivré par le Ministère du Travail.', NULL, 'Parcours de 672 heures structuré en 3 blocs de compétences certifiants, préparation au dossier professionnel et accompagnement emploi inclus par Alt RH & formations', 'Les débouchés après votre titre', 'Ce diplôme d\'État ouvre des fonctions de direction opérationnelle en magasin — des postes à responsabilité, évolutifs et présents sur tout le territoire.', 'Grande et moyenne distribution (GMS/GMS alimentaire), commerce spécialisé, boutiques, négoce inter-entreprises et tout établissement marchand à fort trafic client.', NULL, NULL, 'Construisez votre projet avec Alt RH & formations', 'Échangez avec nos conseillers sur les prochaines sessions e-learning, le stage en entreprise et les solutions de financement (CPF, OPCO, France Travail).', 'published', 21, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(140, 1, 6, 'Devenez Assistant·e Immobilier·ère', 'formations-assistant-immobilier', 'diplomante', 'Avec Alt RH & formations, préparez le titre professionnel immobilier (Bac+2) : transactions, gestion locative et copropriété.', '/assets/video/formations/administration.mp4', '6 mois + 140 h de stage', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '40989', 'Assistant immobilier', '5', 'https://www.francecompetences.fr/recherche/rncp/40989/', 'Le métier', 'L\'Assistant·e Immobilier·ère est un professionnel·le polyvalent·e au cœur des agences, syndics et réseaux de gestion : il·elle sécurise les dossiers administratifs des ventes et locations, assure le suivi locatif au quotidien et participe à la gestion des copropriétés. Ce métier allie rigueur juridique, relation client et organisation. Alt RH & formations vous accompagne de bout en bout — choix du cursus (continue, alternance ou e-learning), financement (CPF, OPCO, France Travail), suivi pédagogique et préparation à l\'examen devant jury. Le titre professionnel de niveau Bac+2 (RNCP 40989), inscrit au répertoire national, est délivré par le Ministère du Travail après validation des compétences en présentiel.', NULL, '3 blocs de compétences certifiants, préparation à l\'épreuve (36 h incluses), dossier professionnel et accompagnement emploi — parcours modulable selon votre modalité (6 à 18 mois en e-learning)', 'Les débouchés après votre titre', 'Un secteur porteur où la demande de profils administratifs qualifiés reste forte, en agence comme en gestion locative et syndic.', 'Agences immobilières, réseaux de transaction, gestion locative, syndics de copropriété, bailleurs sociaux, promoteurs et administrations.', NULL, NULL, 'Lancez votre carrière immobilière avec Alt RH & formations', 'Choisissez votre modalité (présentiel mixte, visio, e-learning ou alternance) et échangez avec nos conseillers sur le financement et les prochaines rentrées.', 'published', 22, '2026-07-27 03:19:57', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(141, 1, 6, 'Devenez Assistant·e Import-Export', 'formations-assistant-import-export', 'diplomante', 'Avec Alt RH & formations, préparez le titre professionnel commerce international (Bac+2) : ventes, logistique et développement à l\'export.', '/assets/video/formations/administration.mp4', '6 mois + 140 h de stage', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '36964', 'Assistant import-export', '5', 'https://www.francecompetences.fr/recherche/rncp/36964/', 'Le métier', 'L\'Assistant·e Import-Export assure le lien opérationnel entre l\'entreprise et ses partenaires étrangers : il·elle traite les offres et commandes internationales, coordonne la logistique et le dédouanement, et contribue au développement commercial à l\'export. Bilingue (français et anglais), ce métier exige rigueur administrative, sens du service et compréhension des flux mondiaux. Alt RH & formations vous accompagne sur tout le parcours : choix du cursus (continue, alternance ou e-learning), montage du financement (CPF — code 245783, OPCO, France Travail), suivi pédagogique et préparation à l\'examen en présentiel. À l\'issue de la validation, vous obtenez le titre professionnel de niveau Bac+2 (RNCP 36964), diplôme du Ministère du Travail, ouvrant l\'accès aux métiers du commerce et de la logistique internationale.', NULL, '3 blocs de compétences (français et anglais), préparation à l\'épreuve (42 h incluses), dossier professionnel et accompagnement emploi — parcours de 6 à 18 mois selon la modalité choisie', 'Les débouchés après votre titre', 'Industries, PME, ETI et grands groupes avec une activité à l\'international recrutent en permanence des profils administratifs et commerciaux export.', 'Industrie, négoce, distribution, logistique et services : toute structure — de la micro-entreprise au grand groupe — ayant des flux commerciaux à l\'international, quel que soit le secteur d\'activité.', NULL, NULL, 'Ouvrez-vous au commerce international avec Alt RH & formations', 'Choisissez votre modalité (présentiel mixte, visio, e-learning ou alternance) et échangez avec nos conseillers sur le financement et les prochaines rentrées.', 'published', 23, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(142, 1, 5, 'Devenez Conseiller·ère en insertion professionnelle', 'formations-conseiller-insertion-professionnelle', 'diplomante', 'Avec Alt RH & formations, préparez le titre CIP (Bac+2) : accompagnement des publics en difficulté d\'insertion, partenariat employeurs et insertion durable.', '/assets/video/formations/administration.mp4', '700 heures de formation', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37274', 'Conseiller en insertion professionnelle', '5', 'https://www.francecompetences.fr/recherche/rncp/37274/', 'Le métier', 'Le·la Conseiller·ère en insertion professionnelle (CIP) accompagne des jeunes et des adultes confrontés à des difficultés d\'insertion ou de reconversion. Par des réponses individualisées, il·elle les aide à construire un parcours vers l\'emploi en tenant compte des dimensions multiples de l\'insertion : formation, logement, santé, mobilité, accès aux droits… Son action combine écoute, diagnostic partagé, mise en réseau et mobilisation des employeurs du territoire. Alt RH & formations vous guide à chaque étape : définition du projet, choix de la modalité (continue, alternance ou e-learning), montage du financement (CPF, OPCO, France Travail, AGEFIPH…) et préparation à la certification devant jury en présentiel. Le parcours en formation continue inclut une immersion professionnelle de 385 h. À l\'issue de la validation, vous obtenez le titre professionnel de niveau Bac+2 (RNCP 37274), diplôme du Ministère du Travail.', NULL, 'Parcours de 700 heures en 3 blocs de compétences certifiants, dossier professionnel et accompagnement emploi — 8 mois en continue (8 à 18 mois en e-learning) ou 14 à 24 mois en alternance', 'Les débouchés après votre titre', 'Un métier engagé, présent dans le service public, l\'économie sociale et solidaire et le secteur privé.', 'Missions locales, PAIO, structures d\'insertion, associations, ESS, opérateurs de compétences, entreprises adaptées et acteurs privés de l\'accompagnement vers l\'emploi.', NULL, NULL, 'Engagez-vous dans l\'accompagnement avec Alt RH & formations', 'Choisissez votre modalité (présentiel mixte, visio, e-learning ou alternance) et échangez avec nos conseillers sur le financement et les prochaines sessions.', 'published', 24, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(143, 1, 6, 'Devenez Conseiller·ère de vente', 'formations-conseiller-de-vente', 'diplomante', 'Titre professionnel RNCP 37098 (niveau 4, équivalent Bac) — vente omnicanale, efficacité commerciale de l’unité marchande et expérience client, avec Alt RH & formations.', '/assets/video/formations/administration.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37098', 'Conseiller de vente', '4', 'https://www.francecompetences.fr/recherche/rncp/37098/', 'Le métier', 'Le·la conseiller·ère de vente intervient dans un environnement omnicanal : point de vente physique et canaux digitaux se complètent (click & collect, réservation web, conseil à distance lorsque le poste le prévoit). Il·elle assure la veille commerciale, participe aux flux marchands et au merchandising, analyse ses résultats, conseille avec méthode, représente la marque ou l’enseigne du linéaire, assure le suivi des ventes et renforce la fidélité des client·es par une expérience cohérente de bout en bout. Le titre RNCP 37098 est structuré en deux blocs certifiés par le Ministère du Travail jusqu’aux évaluations officielles de certification. Alt RH & formations vous aide à composer un parcours adapté — présentiel mixte, visioconférence, e‑learning ou alternance — et à préparer dossier professionnel et épreuves. En formation hors alternance, une période de stage permet de consolider la mise en situation sur le terrain.', NULL, '560 h environ — dossier professionnel, deux blocs RNCP 37098, préparation gratuite aux épreuves et accompagnement emploi ; 6 à 18 mois selon modalité (e-learning avec entrées régulières).', 'Les débouchés après votre titre', 'GMS alimentaires ou spécialisées, grands magasins, boutiques, négoce inter-entreprises : autant de contextes où le titre Conseiller·ère de vente est attendu.', 'Grandes et moyennes surfaces alimentaires ou spécialisées, grands magasins, boutiques, négoce inter-entreprises et points de vente à forte valeur ajoutée conseil.', NULL, NULL, 'Développez votre talent commercial avec Alt RH & formations', 'Choisissez votre modalité (présentiel mixte, visio, e-learning ou alternance) et échangez avec nos conseillers sur le financement et les prochaines rentrées.', 'published', 25, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(144, 1, 3, 'Créer son site internet : HTML, CSS, WordPress & référencement', 'creer-site-internet-html-css-wordpress', 'diplomante', 'Avec Alt RH & formations, concevez un site fidèle à vos attentes, optimisez son référencement et publiez-le sur le web.', '/assets/video/formations/dev-web-mobile.mp4', '70 heures', NULL, '1480.00', NULL, NULL, 'RS', 0, 0, '7525', 'ICDL – Concevoir, structurer et gérer un site web avec un outil d’édition de site web', NULL, 'https://www.francecompetences.fr/recherche/rs/7525/', 'Le métier', 'Cette formation vous permet de créer un site internet professionnel, fidèle à vos attentes : réussir son webdesign, gérer du trafic, optimiser le référencement et analyser vos données. Vous maîtriserez les fondamentaux du développement web (HTML, CSS), les bonnes pratiques d\'optimisation et l\'exploitation avancée de WordPress (thèmes, extensions, tableau de bord). À l\'issue du parcours, votre site pourra être publié sur le web. Alt RH & formations vous accompagne sur le montage du financement (CPF, OPCO, France Travail) et l\'organisation de votre session en présentiel ou visioconférence.', NULL, '70 heures — 4 compétences clés, de la création à la mise en ligne', 'Après la formation', 'Des compétences immédiatement mobilisables pour votre projet web personnel ou professionnel.', 'TPE, PME, associations, collectivités, freelances et toute organisation souhaitant créer ou reprendre la main sur son site vitrine ou institutionnel.', NULL, NULL, 'Lancez votre site avec Alt RH & formations', 'Contactez nos conseillers pour connaître les prochaines sessions, les modalités et les solutions de financement.', 'published', 26, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(145, 1, 6, 'Employé·e Commercial·e — Titre professionnel CAP/BEP', 'formations-employe-commercial', 'diplomante', 'Avec Alt RH & formations, préparez le titre niveau 3 (RNCP 37099) : mise en rayon, accueil client et vente en magasin omnicanal.', '/assets/video/formations/administration.mp4', '6 mois + 280 h de stage', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37099', 'Employé commercial', '3', 'https://www.francecompetences.fr/recherche/rncp/37099/', 'Le métier', 'L\'Employé·e Commercial·e met à disposition des clients les produits de l\'unité marchande dans un environnement omnicanal : approvisionnement, présentation marchande, gestion des stocks, accueil, conseil et tenue de caisse. C\'est un métier de terrain, au contact du public, essentiel en grande distribution, commerce spécialisé et commerce de gros. Alt RH & formations vous accompagne sur tout le parcours : choix de la modalité (présentiel mixte, visioconférence, e-learning ou alternance), montage du financement (CPF, OPCO, France Travail) et préparation à l\'examen en présentiel. Le parcours en formation continue inclut 280 h de stage en entreprise. À l\'issue de la validation, vous obtenez le titre professionnel de niveau 3 (équivalent CAP/BEP, RNCP 37099), diplôme du Ministère du Travail.', NULL, '2 blocs de compétences certifiants, préparation à l\'épreuve (42 h incluses), dossier professionnel et accompagnement emploi — 6 à 18 mois selon la modalité', 'Les débouchés après votre titre', 'Des postes accessibles dès la certification dans la distribution et le commerce de détail.', 'Grandes et moyennes surfaces alimentaires ou spécialisées, boutiques, commerce de gros et tout point de vente à dominante alimentaire ou spécialisée.', NULL, NULL, 'Intégrez la distribution avec Alt RH & formations', 'Choisissez votre modalité (présentiel mixte, visio, e-learning ou alternance) et échangez avec nos conseillers sur le financement et les prochaines rentrées.', 'published', 27, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(146, 1, 3, 'Devenez Graphiste', 'formations-graphiste', 'diplomante', 'Concevez et réalisez des supports de communication visuelle pour l\'impression et le numérique — Titre professionnel RNCP 39532 (niveau 5).', '/assets/video/formations/dev-app.mp4', '1 h 25', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '39532', 'Graphiste', '5', 'https://www.francecompetences.fr/recherche/rncp/39532/', 'Le métier', 'Le·la graphiste conçoit et réalise des supports de communication visuelle pour différents médias, destinés à l\'impression ou au numérique. Son objectif est de créer des designs qui attirent l\'attention, correspondent aux objectifs commerciaux du client et transmettent des messages clairs aux publics cibles. Cette formation ouvre l\'accès à un large éventail de débouchés, du studio de création aux agences de communication, en passant par les services marketing, l\'édition ou le freelancing. Le·la graphiste intervient dans des univers variés — design visuel, communication digitale, édition, publicité et web — où il·elle façonne des supports créatifs et percutants.', NULL, 'Titre professionnel RNCP 39532 — programme par blocs de compétences (BC1 à BC3)', 'Les débouchés', 'Après validation de tous les blocs de compétences, vous pourrez viser les métiers suivants.', 'Studios de création · Agences de communication · Services marketing · Édition · Freelance', NULL, NULL, 'Prêt·e à devenir Graphiste ?', 'Contactez-nous pour en savoir plus sur le titre professionnel RNCP 39532, les sessions et les modalités de financement.', 'published', 28, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'inscrire maintenant\",\"url\":\"/contact\"}]}}');
INSERT INTO `formation_courses` (`id`, `site_id`, `category_id`, `title`, `slug`, `course_type`, `subtitle`, `video_url`, `duration`, `modality_label`, `price`, `certification_label`, `reference_code`, `rncp_repertoire`, `is_cpf_eligible`, `is_alternance`, `rncp_code`, `rncp_title`, `rncp_level`, `rncp_url`, `presentation_title`, `presentation_text`, `presentation_image_url`, `programme_duration_total`, `debouches_title`, `debouches_subtitle`, `debouches_sectors`, `evaluation_title`, `evaluation_description`, `cta_title`, `cta_subtitle`, `status`, `sort_order`, `created_at`, `extra_json`) VALUES
(147, 1, 3, 'Devenez Monteur·euse audiovisuel·le — option Analyste vidéo sport', 'formations-monteur-audiovisuel-analyse-sportive', 'diplomante', 'Titre professionnel de niveau 5 (Bac+2) — RNCP 38752, enregistré le 19/03/2024 et délivré par certification du Ministère du Travail. Montage professionnel sur tous supports et coloration « analyste vidéo sport » (100 h).', '/assets/video/formations/dev-app.mp4', '5 h 40', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '38752', 'Monteur audiovisuel', '5', 'https://www.francecompetences.fr/recherche/rncp/38752/', 'Le métier', 'Le·la monteur·euse audiovisuel·le réalise le montage de productions audiovisuelles pour différents supports. À partir d\'un cahier des charges ou d\'intentions données par journaliste, réalisateur ou commanditaire, il·elle structure le projet, estime les délais, respecte les échéances et travaille avec des logiciels pros en gardant à l\'esprit la finalité, le public visé et les contraintes techniques. La coloration Analyste vidéo sport vous forme aussi aux captations terrain, aux logiciels de segmentation et d\'annotation (performance, tactique, gestes techniques) et aux vidéos de debrief destinées aux staffs sportifs — avec narration visuelle adaptée au contexte sportif. Ce titre permet de poursuivre vers le Community manager (RNCP) ou d\'autres diplômes de niveau 6 selon projet. Alt RH & formations organise la session en mix présentiel / distance avec suivi régulier, extranet documentaire et mises en situation.', NULL, 'Titre RNCP 38752 : deux blocs de compétences (BC1, BC2) et la coloration « Analyste vidéo sport » (100 h)', 'Les débouchés', 'Certification nationale — possibilité de valider bloc par bloc. Pistes de poursuite vers le titre Community manager ou d\'autres cursus niveau 6 après expérience et orientation.', 'Audiovisuel · Chaînes · Médias numériques · Sport professionnel ou amateur · Agences · Streaming · Production indépendante', NULL, NULL, 'Rejoignez la cohorte RNCP 38752 (analyste vidéo sport)', 'Places limitées selon groupe — échange avec un conseiller Alt RH pour vérifier prérequis, session 2025-2026 et financement mobilisable.', 'published', 29, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Demander une étude personnalisée\",\"url\":\"/contact\"}]}}'),
(148, 1, 6, 'Devenez Responsable de petite ou moyenne structure', 'formations-responsable-petite-moyenne-structure', 'diplomante', 'Pilotez une structure de moins de 50 salariés : stratégie, territoire, équipes, offre et pilotage jusqu’au rapport d’activité — titre RNCP niveau Bac+2.', '/assets/video/formations/administration.mp4', NULL, 'Présentiel mixte · Visioconférence · Distanciel (e-learning), selon calendriers', NULL, NULL, NULL, 'RNCP', 0, 0, '38575', 'Responsable de petite ou moyenne structure', '5', 'https://www.francecompetences.fr/recherche/rncp/38575/', 'Le métier', 'Le·la Responsable de petite ou moyenne structure dirige et fait vivre au quotidien une entreprise, un établissement ou une association de taille modeste dans ses dimensions stratégique, humaine, commerciale, productive, financière et administrative : il·elle analyse le contexte, inscrit la structure sur son territoire, coordonne une équipe, développe et diffuse l’offre, puis restitue un rapport d’activité à partir du bilan et du compte de résultat. Titre récent (parcours ouverts depuis février 2024 jusqu’à l’échéance ministérielle prévue au RNCP — voir France Compétences). Alt RH & formations vous aide à composer un parcours adapté à votre situation — continue, avec stage en entreprise ou en alternance, et à distance lorsque votre projet le permet.', NULL, 'Parcours modulaire RNCP — durée variable selon que vous passez le titre dans son intégralité ou un ou plusieurs blocs : continue « type » environ 6 mois + stage 210 h ; alternance 12 à 24 mois sous contrat ; parcours distancé généralement compris entre 6 ', 'Les débouchés', 'Structure commerciale, association, administration ou tout organisme nécessitant une direction de proximité.', 'Formation diplômante · Direction opérationnelle · PME-PMI · Associations · Services aux entreprises.', NULL, NULL, 'Construire votre projet Responsable de petite ou moyenne structure', 'Nous précisons avec vous la modalité, le calendrier, le cofinancement et la composition des blocs que vous désirez passer.', 'published', 30, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Échanger avec un conseiller Alt RH\",\"url\":\"/contact\"}]}}'),
(149, 1, 6, 'Devenez Gestionnaire·euse de paie', 'formations-gestionnaire-de-paie', 'diplomante', 'Titre professionnel de niveau 5 (Bac+2) délivré par le Ministère du Travail (RNCP 37948). Production de bulletins conformes à la réglementation, DSN et accompagnement des salariés et organismes sociaux — avec Alt RH & formations.', '/assets/video/formations/comptable.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '37948', 'Gestionnaire de paie', '5', 'https://www.francecompetences.fr/recherche/rncp/37948/', 'Le métier', 'Le·la gestionnaire de paie assure le cycle salarial (variables, bulletin, déclarations) et coopère étroitement avec les services RH, juridique et comptabilité. Il ou elle est aussi l’interface naturelle avec les organismes externes (URSSAF, caisses, inspection du travail, médecine du travail, cabinets d’expertise-comptable, prestataires de paie) et conduit un rôle de conseil auprès des salarié·es et managers, tout en veillant à la conformité et à la mise à jour de la réglementation sociale et fiscale. Le titre ministériel RNCP 37948 (niveau 5, équivalent Bac+2) prépare ces missions en deux blocs : production des bulletins et traitement des événements de vie professionnelle jusqu’aux situations les plus complexes. Après cette certification, plusieurs parcours de niveau 6 légal‑social peuvent faire suite selon projet. Alt RH & formations peut ajuster votre parcours : présentiel mixte, visioconférence ou e‑learning encadré, avec différentes rentrées au fil de l’année selon calendriers annoncés lors de votre inscription.', NULL, 'Parcours de certification construit à partir du titre RNCP 37948 à deux blocs : session continue environ six mois (rythmes variables), alternance généralement un an tout en suivant même référentiel, ou dispositifs distants sur des plages de quelques mois ', 'Les débouchés', 'Tous secteurs : entreprises, associations, parapublic ou structures spécialisées (cabinet ou prestataire de paie).', 'PME ou grands groupes (pôle social interne ou mutualisé) · Cabinets d\'expertise-comptable · Prestataires de paie externalisée · Fonction publique hospitalière ou assimilée lorsque vos missions le permettent.', NULL, NULL, 'Construire votre parcours Gestionnaire de paie avec Alt RH', 'Un conseiller vous indique les prochaines rentrées, les financements éventuels et les étapes de positionnement (souvent sous deux semaines ouvrées).', 'published', 31, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Parler projet paie avec un conseiller Alt RH\",\"url\":\"/contact\"}]}}'),
(150, 1, 5, 'Devenez Secrétaire·e assistant·e médico-administratif·ve', 'formations-secretaire-assistant-medico-administratif', 'diplomante', 'Diplôme du Ministère du Travail — titre professionnel RNCP 40800 (niveau 4, équivalent Bac). Présentiel mixte, visioconférence ou e‑learning tutoré. Alt RH & formations.', '/assets/video/formations/administration.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '40800', 'Secrétaire assistant médico-administratif', '4', 'https://www.francecompetences.fr/recherche/rncp/40800/', 'Le métier', 'Le secrétaire assistant médico-administratif est le premier interlocuteur du patient et travaille en étroite collaboration avec les professionnels de santé d’une structure médicale. Conformément aux procédures de la structure, il assure l’accueil, la prise en charge administrative et financière du patient, la planification des activités des professionnels de santé ou d’un service, la transcription d’écrits médicaux et le suivi médico-administratif du dossier patient.\r\n\r\nMissions principales — Accueil & gestion administrative : accueil physique et téléphonique, création des dossiers et facturation (entrées/sorties). Coordination des soins : planifier les rendez-vous, orienter les patients et assurer le lien avec l’équipe médicale et les partenaires. Suivi opérationnel : transcrire les comptes rendus, classer les dossiers et gérer le courrier médical. Accompagnement spécifique : adapter la prise en charge aux besoins des patients, notamment en situation de handicap.', NULL, 'Le titre RNCP 40800 est composé de deux blocs de compétences. Durées adaptées à votre modalité : formation continue environ six mois avec MSP fortement conseillée (~126 h selon conventions types), alternance douze à vingt-quatre mois, ou parcours e-learni', 'Débouchés et carrières', 'Après le titre RNCP 40800 : embauche directe ou poursuite vers un niveau 5 (assistants de l’Éducation nationale ou ministériels selon projet).', 'Formation diplômante · RH & Comptabilité / Gestion · secteurs public et privé : hôpitaux, centres hospitaliers spécialisés et cliniques ; cabinets médicaux, maisons de santé, centres de santé, centres d’imagerie médicale, laboratoires d’analyses médicales.', NULL, NULL, 'Construire votre parcours Secrétaire assistant médico-administratif avec Alt RH', 'Un conseiller vous présente les rentrées, les modalités (mixte, visio, e‑learning), le financement et les étapes de positionnement.', 'published', 32, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Parler projet avec un conseiller Alt RH\",\"url\":\"/contact\"}]}}'),
(151, 1, 5, 'Devenez Chargé·e d’accueil et de gestion administrative', 'formations-charge-accueil-et-gestion-administrative', 'diplomante', 'Titre professionnel RNCP 41239 (niveau 4 — Bac), diplôme du Ministère du Travail. Accueil, gestion administrative courante et relation aux publics — présentiel mixte, visio ou e‑learning tutoré avec Alt RH & formations.', '/assets/video/formations/administration.mp4', NULL, NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '41239', 'Chargé d’accueil et gestion administrative', '4', 'https://www.francecompetences.fr/recherche/rncp/41239/', 'Le métier', 'Ce titre prépare à tenir les fonctions d’interface entre une organisation et ses publics : accueil physique et téléphonique, circulation de l’information, gestion des dossiers et des réclamations courantes dans le respect des procédures internes et des exigences de qualité de service.\r\n\r\nÀ l’issue de la formation réussie, vous obtenez un titre professionnel de niveau Bac. En parcours continu, une période en entreprise (stage) permet de mettre en œuvre les compétences du référentiel officiel dans un contexte réel.\r\n\r\nAlt RH & formations est certifié Qualiopi lorsque cette certification couvre votre parcours ; les équipes vous accompagnent sur les modalités (mixte, visio, e‑learning ou alternance), le dossier professionnel et la préparation au jury.', NULL, 'Parcours construit sur le référentiel RNCP 41239 à deux blocs de compétences — durées selon modalité : environ six mois en continu avec stage conseillé (~133 h), alternance douze à vingt-quatre mois, ou parcours e-learning tutoré sur six à dix-huit mois s', 'Après la formation', 'Le titre RNCP 41239 vise des fonctions polyvalentes d’accueil et d’administration dans tous secteurs.', 'Formation diplômante · RH & Comptabilité / Gestion · emploi dans tout type de structure : entreprises privées, fonctions publiques ou parapubliques, associations, structures commerciales ou non marchandes.', NULL, NULL, 'Préparez le titre Chargé·e d’accueil et de gestion administrative avec Alt RH', 'Un conseiller vous explique les rentrées, le financement, le stage et la préparation au jury.', 'published', 33, '2026-07-27 03:19:58', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Échanger avec un conseiller Alt RH\",\"url\":\"/contact\"}]}}'),
(152, 1, 6, 'Devenez Responsable du développement des activités', 'formations-responsable-developpement-des-activites', 'diplomante', 'Titre professionnel RNCP 40889 — niveau 6 (équivalent Bac+3). Stratégie de croissance, marketing omnicanal, pilotage de projets et management d’équipe avec Alt RH & formations.', '/assets/video/formations/administration.mp4', '~490 h de formation (dont contraintes certificateur à respecter)', NULL, NULL, NULL, NULL, 'RNCP', 0, 0, '40889', 'Responsable du développement des activités', '6', 'https://www.francecompetences.fr/recherche/rncp/40889/', 'Le métier', 'Le ou la Responsable du développement des activités a pour mission de contribuer à la croissance de l’entreprise ou de l’organisation : analyse du marché, identification d’opportunités, conception et déploiement d’une stratégie de développement (commerciale, partenariale ou digitale), pilotage de plans d’actions pour atteindre les objectifs.\r\n\r\nAu quotidien, ce métier coordonne les équipes mobilisées, suit les indicateurs de performance, travaille à la fidélisation des clients et au développement du portefeuille. Il conjugue vision stratégique et mise en œuvre opérationnelle : organisation, relationnel fort et culture du résultat.\r\n\r\nLa formation prépare au titre RNCP 40889 ; les modalités d’évaluation et le certificateur suivent le cadre officiel France Compétences (sessions et jurys communiqués dans votre dossier d’examen).', NULL, 'Parcours construit sur le référentiel RNCP 40889 — enveloppe indicative d’environ 490 h ; incluant au minimum 210 h en entreprise pour prétendre à la certification selon les exigences du titre. Durées exactes et émargements précisés dans votre convention ', 'Débouchés', 'Des fonctions variées dans tous les secteurs économiques et sur différentes échelles géographiques.', 'Formation diplômante · RH & Comptabilité / Gestion · industrie, construction, commerce et distribution, services, structures publiques (administrations, collectivités), associations ou ONG — marchés locaux, nationaux ou internationaux selon l’employeur.', NULL, NULL, 'Candidatez au titre RNCP 40889 avec Alt RH & formations', 'Vérifiez votre éligibilité, les 210 h entreprise et le calendrier de certification avec un conseiller.', 'published', 34, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Demander un accompagnement personnalisé\",\"url\":\"/contact\"}]}}'),
(153, 1, 10, 'DASA DevOps Fundamentals', 'dasa-devops-fundamentals', 'certifiante', 'Avec Alt RH Formations, renforcez votre culture DevOps et préparez la certification DASA : articulation entre équipes, livraison continue et indicateurs utiles au terrain.', '/assets/video/formations/dev_equipe.mp4', '3 jours', 'Présentiel', '2170.00', 'DASA DevOps Fundamentals', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Chez Alt RH Formations, ce parcours certifiant s’inscrit dans une logique d’accompagnement : comprendre les fondamentaux DevOps et les relier à vos enjeux de delivery, sans jargon superflu.\r\n\r\nNous travaillons la compréhension des flux de valeur, des rôles et des pratiques qui sécurisent la transformation numérique côté équipes IT.\r\n\r\nÀ l’issue de la session, vous disposerez de repères concrets pour l’automatisation des tests, l’infrastructure et le déploiement continu, et pour aborder l’examen DASA DevOps Fundamentals sereinement.', '/assets/images/devops.jpg', '3 jours — Formation présentielle intensive avec ateliers et examen blanc', NULL, NULL, NULL, 'Évaluation & Progression', 'Alt RH Formations met en place un suivi clair : objectifs personnels en amont, retours du formateur pendant le parcours, évaluations en fin de module et regard sur la satisfaction.', 'Prêt à obtenir votre certification DevOps ?', 'Un conseiller Alt RH Formations vous aide à caler les dates et le format (inter / intra). Réponse sous 48 h ouvrées en général.', 'published', 35, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(154, 1, 10, 'DevOps, méthode et organisation', 'devops-methode-organisation', 'certifiante', 'Alt RH Formations vous propose un parcours pour relier culture d’équipe, chaîne de déploiement et culture de la mesure, avec des ateliers directement exploitables.', '/assets/video/formations/dev_equipe.mp4', '2 jours', 'Présentiel', '1770.00', 'Formation non certifiante', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Nous partons des racines du mouvement DevOps pour éclairer les angles culturels d’une équipe qui livre plus souvent et plus sereinement.\r\n\r\nVous travaillerez la chaîne de déploiement continu : réflexes, outillages simples et rituels qui tiennent sur la durée.\r\n\r\nDes ateliers et TP vous aident à poser un premier plan d’action compatible avec votre organisation.', '/assets/images/devops.jpg', '2 jours — Ateliers collaboratifs et travaux pratiques sur chaque module', NULL, NULL, NULL, 'Évaluation & Progression', 'Alt RH Formations met en place un suivi clair : objectifs personnels en amont, retours du formateur pendant le parcours, évaluations en fin de module et regard sur la satisfaction.', 'Prêt à transformer votre organisation en DevOps ?', 'Un conseiller Alt RH Formations vous aide à caler les dates et le format (inter / intra). Réponse sous 48 h ouvrées en général.', 'published', 36, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(155, 1, 2, 'ISO/IEC 27035 — Information Security Incident Management — Foundation', 'iso-iec-27035-incident-management-foundation', 'certifiante', 'Alt RH Formations vous accompagne sur la gestion d’incidents ISO/IEC 27035 et la préparation au niveau Foundation PECB, en classe virtuelle pilotée.', '/assets/video/formations/cyber.mp4', '14 h (2 jours)', 'Classe virtuelle', '712.00', 'PECB ISO/IEC 27035 Foundation', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Le parcours donne des repères opérationnels pour prévenir, détecter et traiter les incidents de sécurité de l’information, en cohérence avec un SMSI et la famille ISO/IEC 27000.\r\n\r\nVous structurez les rôles, le plan de réponse et les échanges internes / externes, du signalement jusqu’aux retours d’expérience.\r\n\r\nLa session est animée à distance en synchrone, avec quiz et exercices intégrés ; Alt RH Formations vous aide à préparer l’examen PECB ISO/IEC 27035 Foundation et à choisir vos dates.\r\n\r\nLes financements possibles (CPF, plan de développement des compétences, etc.) dépendent de votre situation : nos équipes vous orientent sur les démarches, sans promesse d’éligibilité avant analyse de dossier.', '/assets/images/analyst_soc.jpg', '14 heures sur 2 jours — Classe virtuelle, quiz et exercices intégrés, préparation au schéma de certification PECB ISO/IEC 27035', NULL, NULL, NULL, 'Évaluation', 'Évaluation en cohérence avec le référentiel certifiant : auto-positionnement, attestations et préparation à l’épreuve PECB.', 'Certifiez-vous en gestion d\'incidents ISO/IEC 27035', 'Inter, intra ou calendrier classe virtuelle : écrivez à Alt RH Formations ou passez par la page contact — prise en charge rapide des demandes.', 'published', 37, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(156, 1, 3, 'Langage SQL — Exploiter une base de données relationnelle (certifiante)', 'sql-langage-bases-donnees-relationnelles-certifiante', 'certifiante', 'Renforcez vos fondamentaux SGBDR et requêtes SQL sur les moteurs courants, avec un rythme adapté et un accompagnement Alt RH Formations jusqu’à la certification RS7205.', '/assets/video/formations/informatique.mp4', '20 h', 'Présentiel / distanciel / téléprésentiel', '1760.00', 'Langage SQL — exploiter une base de données relationnelle (référence RS7205 — Répertoire Spécifique France Compétences)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Chez Alt RH Formations, ce parcours certifiant ancre le SQL sur vos usages métier : modèle relationnel, algèbre portée en requêtes, sélections complexes et mises à jour contrôlées.\r\n\r\nVous travaillez sur un environnement SQL pertinent pour la session (MySQL, Oracle, PostgreSQL ou SQL Server), avec une progression nette sur jointures, sous-requêtes, vues, CTE et fonctions de fenêtrage.\r\n\r\nLa pédagogie mêle apports ciblés, démonstrations et travaux guidés. Elle vise la certification RS7205 (Répertoire Spécifique France Compétences) ; en financement CPF, le passage à l’examen peut être requis selon les règles du dispositif.\r\n\r\nNous proposons inter, intra, présentiel ou distanciel depuis nos dispositifs à Bailly-Romainvilliers et Serris : un conseiller vous aide à choisir le format et à monter votre dossier.', '/assets/images/analyste_data.jpg', '20 heures — Équilibre théorie / démonstrations / exercices ; préparation à la certification RS7205', NULL, NULL, NULL, 'Évaluation des acquis', 'Alt RH Formations assure un suivi continu : vous savez où vous en êtes avant l’examen de certification.', 'Réservez votre formation SQL certifiante', 'Inter ou intra, présentiel ou distanciel : nos équipes à Bailly-Romainvilliers et Serris vous proposent un créneau adapté et vous aident sur le financement et la certification.', 'published', 38, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(157, 1, 10, 'Docker — Concevoir, tester et déployer des applications (certifiante)', 'docker-concevoir-deployer-applications-certifiante', 'certifiante', 'Prenez en main Docker avec Alt RH Formations : images, conteneurs, Dockerfiles, réseaux, volumes, Compose et Swarm pour déployer vos applications proprement tout en gardant la sécurité à l’œil.', '/assets/video/formations/dev.mp4', '21 h', 'Présentiel / distanciel / téléprésentiel', '1770.00', 'Concevoir, tester et déployer des applications avec Docker (référence RS6425 — Répertoire Spécifique France Compétences)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce parcours certifiant vous accompagne pas à pas sur Docker, de l’installation à la mise en production : Linux, Windows ou macOS, cycle de vie des images et des conteneurs, réseaux, volumes, Compose puis Swarm lorsque vous montez en charge.\r\n\r\nVous sécurisez vos Dockerfiles, vos registres (dont CI de build d’images) et vos stacks multi-services avec des retours d’expérience concrets.\r\n\r\nÀ l’issue du parcours, vous savez placer Docker dans votre paysage technique, livrer des environnements reproductibles et identifier limites, risques et premiers durcissements utiles.\r\n\r\nLa formation prépare à la certification RS6425 (Répertoire Spécifique France Compétences). Le financement CPF et l’obligation éventuelle de passer l’examen dépendent de votre dossier : nos conseillers vous le rappellent clairement avant le démarrage. Dates inter ou intra sur simple demande auprès d’Alt RH Formations.', '/assets/images/devops.jpg', '21 heures — Alternance théorie, démonstrations et travaux pratiques ; préparation à la certification RS6425', NULL, NULL, NULL, 'Évaluation des acquis', 'Nous suivons votre progression de bout en bout pour que la certification RS6425 reste un objectif réaliste.', 'Planifiez votre formation Docker certifiante', 'Calendrier inter ou intra, présentiel ou distanciel : un interlocuteur Alt RH Formations vous répond sur les sessions et les aides au financement.', 'published', 39, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(158, 1, 2, 'Cybersécurité — Menaces, risques et architectures défensives', 'cybersecurite-exhaustive-menaces-architectures-certifiante', 'certifiante', 'Chez Alt RH Formations, reliez menaces actuelles, architectures défensives et pilotage SSI : attaquants et TTPs, IoT/ICS, risques, gouvernance, SOC, Threat Intelligence et défense en profondeur.', '/assets/video/formations/cyber.mp4', '21 h', 'Présentiel / distanciel / téléprésentiel', '2360.00', 'Parcours certifiant : l’intitulé exact et le référentiel France Compétences associé vous sont communiqués par Alt RH Formations lors de la réservation, selon la session retenue.', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Parcours structuré pour comprendre comment les menaces se matérialisent, quelles erreurs de conception coûtent cher et quels leviers réduisent réellement votre surface d’exposition.\r\n\r\nDu panorama offensif aux réseaux industriels et objets connectés, en passant par risques, PSSI et gouvernance, vous reliez technique, organisation et cadres utiles à la DSI.\r\n\r\nThreat Intelligence, SOC et architectures défensives (segmentation, firewalls, IDS, honeypots, VPN, PKI, durcissement poste, chiffrement) sont abordés avec des mises en situation type cyber-range lorsque le dispositif le permet.\r\n\r\nSessions en présentiel ou à distance ; financements étudiés au cas par cas. Alt RH Formations assure le suivi administratif depuis vos sites de proximité en Seine-et-Marne.', '/assets/images/expert_cyber.jpg', '21 heures — Théorie, démonstrations, exercices et cas pratiques (dont cyber-range lorsque prévu)', NULL, NULL, NULL, 'Évaluation des acquis', 'Un fil conducteur de suivi vous permet de valider chaque grande familie de compétences avant la clôture.', 'Sécurisez votre SI avec une vision globale', 'Sessions mai / septembre / décembre (indicatif) ou intra sur mesure : contactez Alt RH Formations pour caler votre date et votre dispositif de financement.', 'published', 40, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(159, 1, 3, 'Certification ISTQB — Testeur certifié niveau Fondation', 'istqb-testeur-certifie-niveau-fondation-ihmisen', 'certifiante', 'Accompagnez la certification ISTQB niveau Fondation avec Alt RH Formations : principes des tests, techniques structurées et préparation à l’épreuve officielle, en présentiel ou en classe virtuelle.', '/assets/video/formations/dev-app.mp4', '21 h', 'Classe virtuelle / Présentiel', '970.02', 'ISTQB — Testeur certifié niveau Fondation (Foundation Level)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce parcours certifiant vous donne les repères ISTQB Foundation pour structurer vos campagnes de test : vocabulaire, niveaux, techniques et pilotage quotidien.\r\n\r\nTesteurs, QA, MOA ou chefs de projet y trouvent un socle commun, y compris lorsque vous formalisez déjà de l’expérience terrain.\r\n\r\nSessions synchrones en présentiel ou à distance ; inter-entreprises ou intra lorsque vous regroupez vos équipes.\r\n\r\nPour le CPF ou autres dispositifs, nos conseillers Alt RH Formations vous expliquent les obligations (dont examen lorsque le financement l’exige) avant validation du dossier.', '/assets/images/concepteur_app.jpg', '21 heures sur 3 jours — Classe virtuelle ou présentiel ; révisions QCM ; préparation et passage de l’examen officiel ISTQB Fondation', NULL, NULL, NULL, 'Évaluation', 'Alt RH Formations assure un suivi sur trois jours : vous validez les blocs du syllabus avant l’épreuve officielle.', 'Certifiez-vous ISTQB niveau Fondation', 'Sessions inter ou intra, modalités d’examen et devis : 01 60 43 94 32 ou formations@altrh.com — réponse rapide en semaine (9h00 – 18h00).', 'published', 41, '2026-07-27 03:19:59', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(160, 1, 3, 'ISTQB — Extension Fondation Testeur Agile', 'istqb-testeur-agile-fondation-ib-cegos', 'certifiante', 'Avec Alt RH Formations, préparez l’extension ISTQB Testeur Agile : pratiques de test en contexte Agile, techniques, outils et épreuve officielle (présentiel ou classe virtuelle).', '/assets/video/formations/dev-app.mp4', '21 h', 'Classe virtuelle / Présentiel', '960.00', 'ISTQB — Extension Fondation Testeur Agile (Agile Tester)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce parcours certifiant prépare l’extension ISTQB Fondation « Testeur Agile » : enchaîner user stories, itérations et stratégie de test sans perdre la rigueur.\r\n\r\nIl s’adresse aux testeurs, QA, analystes et chefs de projet qui sécurisent la qualité dans des équipes déjà tournées vers l’Agile.\r\n\r\nAlt RH Formations dispense la session en présentiel ou en distanciel synchrone ; les calendriers inter sont communiqués à l’inscription.\r\n\r\nLes aides mobilisables (CPF, plans entreprise, etc.) sont précisées dossier par dossier ; aucune promesse d’éligibilité avant analyse.', '/assets/images/concepteur_app.jpg', '21 heures sur 3 jours — Exposés, travaux dirigés, examen blanc officiel ISTQB commenté et préparation / passage de l’examen (1 h, 40 questions QCM, 65 % requis)', NULL, NULL, NULL, 'Évaluation', 'Un suivi pédagogique sur trois jours puis passage à l’épreuve officielle lorsque vous validez le calendrier avec Alt RH Formations.', 'Certifiez-vous ISTQB Testeur Agile', 'Choisissez une session visio ou salle, ou un intra sur mesure : contactez Alt RH Formations au 01 60 43 94 32 ou formations@altrh.com.', 'published', 42, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(161, 1, 3, 'ISTQB — Extension Fondation Tests d’acceptation', 'istqb-tests-acceptation-fondation-m2i', 'certifiante', 'Structurer tests d’acceptation (ATDD, BDD, BPMN, exigences non fonctionnelles) et viser la certification ISTQB Extension « Tests d’acceptation » avec Alt RH Formations, en classe virtuelle synchrone.', '/assets/video/formations/dev-app.mp4', '14 h (2 jours)', 'Classe virtuelle', '642.00', 'ISTQB — Extension Fondation Tests d’acceptation (Acceptance Testing)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce parcours certifiant prépare l’extension ISTQB « Tests d’acceptation » : relier besoins métiers, exigences et preuves de conformité utilisateur.\r\n\r\nPublic : équipes test/QA, MOA et analystes métiers qui sécurisent l’aval de projet.\r\n\r\nAlt RH Formations anime la session en classe virtuelle interactive : même exigence de présence qu’en salle, avec des travaux guidés en direct.\r\n\r\nSessions inter régulières ; possibilité intra pour regrouper vos équipes sur vos créneaux (minimum de participants communiqué lors du devis).\r\n\r\nLes financements sont étudiés dossier par dossier avec un interlocuteur Alt RH Formations.', '/assets/images/concepteur_app.jpg', '14 heures sur 2 jours — Travaux pratiques, QCM corrigés en groupe, examen blanc commenté et préparation à l’épreuve officielle', NULL, NULL, NULL, 'Évaluation', 'Progression vérifiée en continu puis certification officielle ISTQB.', 'Certifiez-vous ISTQB Tests d’acceptation', 'Devis, dates de classe virtuelle ou intra : écrivez à formations@altrh.com ou appelez le 01 60 43 94 32.', 'published', 43, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(162, 1, 2, 'Piloter et animer la sécurité informatique', 'piloter-animer-securite-informatique-sysdream', 'certifiante', 'Avec Alt RH Formations, parcours certifiant long format (217 h) : stratégie cyber, ISO 27001/27005, EBIOS Risk Manager, réseaux et Linux durcis, réponse à incident et sensibilisation — 100 % classe virtuelle et travaux pratiques immersifs.', '/assets/video/formations/infra-reseau.mp4', '217 h', '100 % classe virtuelle', '15377.00', 'Parcours certifiant « Piloter et animer la sécurité informatique » — organisme et modalités d’examen communiqués par Alt RH Formations selon votre inscription.', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce parcours certifiant vise la maîtrise opérationnelle du pilotage cyber en entreprise : analyse du risque, SMSI ISO 27001/27002, ISO 27005, EBIOS Risk Manager, durcissement réseaux et systèmes, réponse à incident et montée en puissance de la sensibilisation.\r\n\r\nIl s’adresse aux profils IT (techniciens, support, DSI) titulaires d’un niveau 5 ou 6 lorsque la cybersécurité n’est pas encore leur cœur de métier.\r\n\r\nLa pédagogie combine apports, démonstrations, retours d’expérience et travaux pratiques sur une plateforme immersive (scénarios type ransomware, phishing, etc.).\r\n\r\nLe format est 100 % classe virtuelle pour permettre une montée en charge progressive sans vous éloigner durablement de vos missions.\r\n\r\nAlt RH Formations coordonne inscriptions, financements éventuels et calendrier ; les engagements intra sont chiffrés au plus près de vos effectifs.', '/assets/images/expert_cyber.jpg', '217 heures — 7 axes ; évaluation continue ; dossier professionnel et soutenance devant jury', NULL, NULL, NULL, 'Évaluation des acquis', 'Alt RH Formations s’appuie sur une progression continue puis une validation finale type jury professionnel.', 'Engagez un parcours long en cybersécurité', 'Montant, certification, planning intra ou inter : nos conseillers Alt RH Formations répondent au 01 60 43 94 32 ou via formations@altrh.com.', 'published', 44, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(163, 1, 3, 'Développement Web — HTML5, CSS3 et JavaScript', 'html5-css3-javascript-certifiante-eni', 'certifiante', 'Applications web réactives : intégration HTML/CSS, JavaScript, DOM, services REST et WebSocket — parcours pratique Alt RH Formations préparant à la certification Éditions ENI.', '/assets/video/formations/dev-web-mobile.mp4', '35 h', 'Présentiel / téléprésentiel / distanciel', NULL, 'Créer et mettre en forme des pages web (HTML5 et CSS3) — Editions ENI', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Parcours certifiant pour concevoir des applications web modernes : HTML5, CSS3 (responsive, Flexbox), formulaires, JavaScript côté navigateur, consommation d’API REST et usage de WebSocket.\r\n\r\nPublic : intégrateurs et développeurs front. Alt RH Formations alterne apports, démonstrations et travaux pratiques ; chaque stagiaire dispose d’un poste adapté et de supports numériques ou papier.\r\n\r\nFormats possibles : présentiel à Bailly-Romainvilliers ou Serris, salle immersive (formateur à distance) ou distanciel synchrone depuis votre lieu de travail.\r\n\r\nLe parcours prépare la certification Éditions ENI « Créer et mettre en forme des pages web (HTML5 et CSS3) ». L’examen reste volontaire hors obligation contractuelle ; un travail personnel complémentaire renforce les chances de réussite.\r\n\r\nCPF : respect du délai légal d’au moins 11 jours ouvrés entre la proposition commerciale et le démarrage. Inscriptions en général jusqu’à 48 h avant la session. Accessibilité aux personnes en situation de handicap prise en charge sur demande. Intra entreprise chiffré au cas par cas.', '/assets/images/concepteur_web.jpg', '35 heures — dont TP sur fil rouge (pages liées, formulaires, tableaux, responsive, API distante, WebSocket)', NULL, NULL, NULL, 'Évaluation des acquis', 'Alt RH Formations assure un suivi de progression et vous prépare, si vous le souhaitez, à la certification Éditions ENI.', 'Planifiez votre formation Web certifiante', 'Inter, intra ou financement : un conseiller Alt RH Formations vous répond au 01 60 43 94 32 ou via formations@altrh.com.', 'published', 45, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(164, 1, 3, 'Python — Programmation orientée objet (certifiante)', 'python-oriente-objet-certifiante-eni', 'certifiante', 'Renforcez Python orienté objet avec PyCharm : modules, classes, exceptions, tests et interfaces Tkinter — chemin Alt RH Formations vers la certification RS6701 délivrée par les Éditions ENI.', '/assets/video/formations/dev-app.mp4', '35 h', 'Présentiel / téléprésentiel / distanciel', '2820.00', 'Langage Python — Editions ENI, référence RS6701 (Répertoire Spécifique France Compétences, depuis le 19/07/2024)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Parcours certifiant centré sur Python objet : installation, environnements virtuels, syntaxe, modules, classes (encapsulation, héritage, polymorphisme), exceptions, tests unittest, automatisation avec la bibliothèque standard et interfaces Tkinter.\r\n\r\nFil rouge pédagogique : jeux sur nombres aléatoires, calculs de dates, hiérarchie de comptes bancaires testée et sérialisée, puis IHM de consultation.\r\n\r\nPublic : développeurs et chefs de projet techniques. Alt RH Formations propose présentiel sur site, salle immersive ou distanciel synchrone ; groupes de 1 à 12 personnes pour garder le lien avec le formateur.\r\n\r\nUne certification « Langage Python » (Éditions ENI) inscrite au Répertoire Spécifique France Compétences (référence RS6701 depuis le 19/07/2024). En financement CPF, passage de l’examen obligatoire ; les modalités officielles sont celles du certificateur.\r\n\r\nCalendrier inter indicatif et lieux (distanciel ou villes partenaires) : précisés lors de votre demande auprès d’Alt RH Formations. Intra entreprise sur devis.', '/assets/images/concepteur_app.jpg', '35 heures — alternance cours, démonstrations et travaux pratiques', NULL, NULL, NULL, 'Évaluation des acquis', 'Suivi Alt RH Formations et préparation à la certification RS6701 lorsque celle-ci fait partie de votre parcours.', 'Réservez votre session Python certifiante', 'Inter, intra ou financement CPF : écrivez à formations@altrh.com ou composez le 01 60 43 94 32 — nos bureaux de Bailly-Romainvilliers et Serris traitent les demandes sous 48 h ouvrées en moyenne.', 'published', 46, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(165, 1, 3, 'Développer la culture digitale', 'developper-culture-digitale', 'certifiante', 'Journée présentielle pour étudiants et professionnels : cadrer la révolution digitale, les usages, l’impact économique et les métiers du numérique, avec un vocabulaire commun et des mises en situation.', '/assets/video/formations/informatique.mp4', '1 jour (5 h à 7 h)', 'Présentiel', '1000.00', 'Attestation de fin de formation — Référence NUM_DIGIT_06', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation d’une journée vous donne des repères solides sur la culture digitale, son impact sur l’économie et les organisations, et les grands courants technologiques (web, réseaux sociaux, collaboration, IoT, IA, données…).\r\n\r\nVous partirez avec un socle de vocabulaire partagé et une meilleure lecture des métiers et des enjeux (transformation du travail, réglementation, réputation numérique).\r\n\r\nAlt RH Formations propose l’Inter-entreprise et l’intra sur mesure ; les dates s’organisent avec nos équipes de Bailly-Romainvilliers et Serris. Référence catalogue : NUM_DIGIT_06.', '/assets/images/designer_app_mobile.jpg', '1 jour — Constructions participatives, apports, quiz, études de cas et jeux de rôle', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Dispositif en plusieurs temps pour cadrer vos objectifs, suivre votre progression et mesurer l’impact dans la durée.', 'Demander une formation culture digitale', 'Inter ou intra, dates à construire avec vous : contactez Alt RH Formations pour une proposition adaptée à vos objectifs.', 'published', 47, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(166, 1, 3, 'C# — Développer en .NET avec Visual Studio', 'csharp-dotnet-visual-studio', 'certifiante', 'Cinq jours présentiels pour maîtriser la plateforme .NET, la syntaxe C#, la POO et Visual Studio, jusqu’aux applications desktop, web et accès aux données.', '/assets/video/formations/dev-app.mp4', '5 jours', 'Présentiel', '3000.00', 'Attestation de fin de formation — Référence NUM_DEV_21', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Parcours certifiant pour développeurs qui veulent produire des applications .NET professionnelles avec Visual Studio : compréhension de la plateforme, langage C# (y compris évolutions récentes), POO, bibliothèques de base, LINQ et aperçu des stacks WPF, ASP.NET MVC et services.\r\n\r\nLa progression alterne apports, démonstrations et travaux pratiques guidés (algorithmes, classes, exceptions, collections, mini-projets).\r\n\r\nInter-entreprise ou intra sur demande ; planning construit avec Alt RH Formations (Bailly-Romainvilliers / Serris). Référence catalogue : NUM_DEV_21.', '/assets/images/concepteur_app.jpg', '5 jours — Alternance cours, démonstrations et travaux pratiques sur Visual Studio', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Même dispositif qu’accoutumé : objectifs, suivi en cours, validation finale et bilan à froid.', 'Planifiez votre formation C# et .NET', 'Devis, intra ou session inter : nos équipes vous aident à monter le créneau et le format adaptés.', 'published', 48, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(167, 1, 3, 'Conception orientée objet', 'conception-orientee-objet', 'certifiante', 'Quatre jours présentiels pour passer d’une logique fonctionnelle à une conception objet : principes, UML, traduction vers le code, frameworks, composants et design patterns.', '/assets/video/formations/dev-app.mp4', '4 jours', 'Présentiel', '2400.00', 'Attestation de fin de formation — Référence NUM_DEV_01', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'La formation pose les fondations de la pensée objet : modularité, réutilisabilité, évolutivité, bibliothèques de composants, puis la modélisation UML (classes, séquences) et les critères de bonne structuration.\r\n\r\nVous verrez comment aller du modèle à l’implémentation (langages et bases), les enjeux du distribué et les grandes plateformes (.NET, Jakarta EE), puis les frameworks, composants et design patterns comme levier de réutilisation d’expérience.\r\n\r\nInter ou intra sur demande ; planning avec Alt RH Formations. Référence catalogue : NUM_DEV_01.', '/assets/images/concepteur_app.jpg', '4 jours — Apports, ateliers, modélisation et mises en situation', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Parcours d’évaluation aligné sur les autres formations certifiantes Alt RH Formations.', 'Demander la formation Conception orientée objet', 'Dates inter ou intra : contactez Alt RH Formations pour une proposition alignée sur vos enjeux.', 'published', 49, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(168, 1, 2, 'Maîtriser le rôle de RSSI et piloter la gouvernance cybersécurité', 'rssi-gouvernance-cybersecurite', 'certifiante', 'Trois jours présentiels pour cadrer votre fonction de RSSI : SMSI ISO/IEC 27001, analyse de risques (EBIOS RM, ISO/IEC 27005), culture ANSSI et stratégie alignée métier et réglementation.', '/assets/video/formations/cyber.mp4', '3 jours', 'Présentiel', '2800.00', 'Maîtriser le rôle de RSSI et piloter efficacement la gouvernance de la cybersécurité — attestation de fin de formation', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette session certifiante aide les futurs ou actuels responsables sécurité à structurer la gouvernance du SI : cadrage ISO/IEC 27001, analyse et traitement du risque avec EBIOS RM et ISO/IEC 27005, et intégration des recommandations et référentiels utiles (dont logique ANSSI).\r\n\r\nVous travaillerez l’articulation entre vision métier, exigences réglementaires et plan d’action opérationnel pour une stratégie cybersécurité durable.\r\n\r\nAlt RH Formations propose l’inter-entreprise sur calendrier régulier et l’intra sur devis (Île-de-France et distanciel selon session). Inscription : 01 60 43 94 32 / formations@altrh.com.', '/assets/images/expert_cyber.jpg', '3 jours — Un jour par grand thème, équilibre apports et ateliers', NULL, NULL, NULL, 'Évaluation des acquis', 'Validation des compétences tout au long des trois jours et en clôture.', 'Réservez votre session RSSI — gouvernance SSI', 'Choisissez une date dans le calendrier inter ou demandez un intra : nos conseillers sécurisent votre inscription et votre financement.', 'published', 50, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(169, 1, 2, 'Cloud Technology Associate (CTA) — Fondamentaux du cloud et de la virtualisation', 'cloud-technology-associate-cta', 'certifiante', 'Trois jours en présentiel visant la certification CTA : modèles et référentiels (NIST, ISO, Gartner), virtualisation, panorama technologique, sécurité et gouvernance, mise en œuvre, Cloud Service Management et passage d’examen.', '/assets/video/formations/infra-reseau.mp4', '3 jours', 'Présentiel', '2500.00', 'Certification Cloud Technology Associate (CTA) — référence NUM_Cloud_07', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation pose les bases du cloud computing et de la virtualisation pour décideurs et cadres techniques : repères ISO, Gartner et NIST, modèles de service et de déploiement, enjeux de sécurité, conformité et gouvernance du SI.\r\n\r\nVous progresserez jusqu’aux sujets de mise en œuvre (architectures, migration, rôle des fournisseurs) et aux principes de Cloud Service Management, avant un examen blanc commenté et le passage de la certification CTA.\r\n\r\nSessions inter-entreprise ou intra sur devis ; aucun calendrier inter fixe pour le moment — dates sur demande. Référence catalogue : NUM_Cloud_07. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/Datacenter.jpg', '3 jours — Apports, ateliers participatifs et préparation à l’examen CTA', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Un dispositif en quatre temps pour cadrer vos objectifs, suivre votre montée en compétences et mesurer la satisfaction et l’impact dans le temps.', 'Demander la formation Cloud Technology Associate (CTA)', 'Inter ou intra sur mesure : nous vous proposons des dates et un devis adaptés — réponse personnalisée sous peu.', 'published', 51, '2026-07-27 03:20:00', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(170, 1, 2, 'Cisco CCNA — Les fondamentaux des réseaux', 'cisco-ccna-fondamentaux', 'certifiante', 'Cinq jours en présentiel : du modèle OSI à la configuration de commutateurs et routeurs Cisco (IOS, VLAN, routage statique, sécurisation), introduction IPv6 et préparation à l’examen de certification 200-301.', '/assets/video/formations/infra-reseau.mp4', '5 jours', 'Présentiel', '3500.00', 'CCD — Cisco CCNA, implémentation et administration des solutions Cisco ; préparation et objectif de réussite à l’examen 200-301 — réf. Num_Netw_05', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'La formation couvre les fondamentaux des réseaux (classification, OSI, TCP/IP, LAN), la prise en main de l’IOS Cisco et de la CLI, Ethernet et commutation, puis l’adressage IP, le routage statique, les listes d’accès et l’accès Internet.\r\n\r\nLes journées suivants abordent les réseaux LAN de taille moyenne : spanning tree, VLAN et trunk, routage inter-VLAN, DHCP sur équipement Cisco, introduction aux protocoles de routage dynamique et aux technologies WAN, puis la sécurisation des équipements et une introduction à IPv6.\r\n\r\nAteliers pratiques sur commutateurs et routeurs tout au long du parcours. Sessions inter ou intra sur devis ; aucun calendrier inter fixe pour le moment. Référence catalogue : Num_Netw_05. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/Terchnicien_reseau.jpg', '5 jours — Cours, travaux pratiques sur équipements Cisco et préparation à l’examen 200-301', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Évaluation alignée sur le parcours standard des formations certifiantes Alt RH Formations, avant, pendant et après la session.', 'Demander la formation Cisco CCNA — fondamentaux', 'Planning inter ou intra sur mesure : nos conseillers vous répondent pour dates, devis et inscription.', 'published', 52, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}');
INSERT INTO `formation_courses` (`id`, `site_id`, `category_id`, `title`, `slug`, `course_type`, `subtitle`, `video_url`, `duration`, `modality_label`, `price`, `certification_label`, `reference_code`, `rncp_repertoire`, `is_cpf_eligible`, `is_alternance`, `rncp_code`, `rncp_title`, `rncp_level`, `rncp_url`, `presentation_title`, `presentation_text`, `presentation_image_url`, `programme_duration_total`, `debouches_title`, `debouches_subtitle`, `debouches_sectors`, `evaluation_title`, `evaluation_description`, `cta_title`, `cta_subtitle`, `status`, `sort_order`, `created_at`, `extra_json`) VALUES
(171, 1, 2, 'Professional Cloud Solution Architect (PCSA) — Architecture cloud certifiante EXIN', 'professional-cloud-solution-architect-pcsa', 'certifiante', 'Deux jours en présentiel pour cadrer l’impact du cloud sur l’architecture d’entreprise, les modèles XaaS, les cycles de vie et la transition — puis préparation et passage de l’examen PCSA.', '/assets/video/formations/infra-reseau.mp4', '2 jours', 'Présentiel', '2700.00', 'Professional Cloud Solution Architect (PCSA) — EXIN — réf. NUM_Cloud_08', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette session relie histoire et enjeux du cloud aux cadres d’architecture (SOA, architecture d’entreprise), aux risques, à la sécurité et aux aspects juridiques, puis aux vues IaaS, PaaS et SaaS et aux familles XaaS.\r\n\r\nVous travaillerez les cycles de vie des services cloud, la transition et la transformation des métiers, les perspectives côté métier et fournisseur, l’écosystème (dont lien IoT / IoE) et la définition d’une cible : spécifications, business case et roadmap, avant un examen blanc et la certification PCSA EXIN.\r\n\r\nInter ou intra sur devis ; aucun calendrier inter fixe actuellement. Référence catalogue : NUM_Cloud_08. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/Datacenter.jpg', '2 jours — Apports, ateliers et préparation à l’examen PCSA (EXIN)', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Dispositif en quatre temps pour objectifs, suivi, acquis et satisfaction dans la durée.', 'Demander la formation PCSA — Professional Cloud Solution Architect', 'Inter ou intra sur mesure : devis et dates avec Alt RH Formations.', 'published', 53, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(172, 1, 2, 'Cybersécurité : Audit sécurité d’applications mobiles Android – Introduction', 'cybersecurite-audit-android-introduction', 'certifiante', 'Deux jours en présentiel pour maîtriser les bases des audits de sécurité avancés sur applications Android : tests d’intrusion mobiles, analyse statique, analyse réseau et dynamique.', '/assets/video/formations/cyber.mp4', '2 jours', 'Présentiel', '1056.00', 'Audit sécurité d’applications mobiles Android – Introduction (certification incluse au tarif indiqué)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation certifiante pose les fondations pour des audits mobiles avancés : mise en œuvre d’un dispositif de tests d’intrusion ciblant Android, lecture du code et de la surface d’attaque (analyse statique), puis observation du comportement applicatif et des flux (analyse réseau et dynamique).\r\n\r\nLes travaux pratiques alternent avec des apports méthodologiques pour que vous repartiez avec des réflexes opérationnels.\r\n\r\nAlt RH Formations propose l’inter-entreprise (calendrier communiqué à l’inscription) et l’intra sur devis. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/analyst_soc.jpg', '2 jours — Présentiel, travaux pratiques', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Parcours d’évaluation aligné sur les autres formations certifiantes Alt RH Formations.', 'Réserver l’audit sécurité Android – Introduction', 'Choisissez une session inter ou demandez un intra : nos conseillers vous répondent pour dates, devis et financement.', 'published', 54, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(173, 1, 10, 'DevSecOps Engineering (DSOE)', 'devsecops-engineering-dsoe', 'certifiante', 'Deux jours en présentiel pour intégrer la sécurité dans la culture et les pipelines DevOps, puis préparer la certification DevSecOps Engineering.', '/assets/video/formations/dev_equipe.mp4', '2 jours', 'Présentiel', '2000.00', 'Certification DevSecOps Engineering (DSOE) — réf. NUM_DEVSEC_02', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Le parcours relie vocabulaire et principes DevSecOps à la culture d’entreprise : stratégie, sciences de la donnée appliquées au risque, équipes rouges et bleues, et implémentation concrète dans les flux CI/CD.\r\n\r\nVous aborderez l’hygiène de sécurité, l’IAM, la sécurité applicative (AST, menaces, automatisation), la sécurité opérationnelle, la GRC et la conformité dans un contexte DevOps, puis journalisation, détection et réponse.\r\n\r\nInter ou intra sur devis ; aucune session inter figée pour le moment. Référence : NUM_DEVSEC_02. Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/devops.jpg', '2 jours — Apports, exercices guidés et préparation à la certification DSOE', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Dispositif standard des formations certifiantes Alt RH Formations, du positionnement initial au bilan à froid.', 'Demander la formation DevSecOps Engineering (DSOE)', 'Planning inter ou intra sur mesure : nos conseillers montent votre dossier et vous proposent des dates.', 'published', 55, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(174, 1, 3, 'Programmation orientée objet en C++', 'programmation-objet-cpp', 'certifiante', 'Cinq jours en présentiel pour maîtriser la syntaxe C++, l’approche objet, les templates, la STL et les apports majeurs du C++11, avec une étude de cas fil rouge.', '/assets/video/formations/dev-app.mp4', '5 jours', 'Présentiel', '3000.00', 'Attestation de fin de formation — réf. NUM_DEV_13', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'La formation enchaîne la syntaxe et les spécificités C++ (par rapport au C), puis l’approche orientée objet avec prise en main de l’outil de développement et des travaux pratiques structurés autour d’une étude de cas.\r\n\r\nVous explorerez classes, héritage et polymorphisme, exceptions, surcharge d’opérateurs, modèles (templates), entrées/sorties et aperçu de la STL, tout en intégrant les constructions clés du C++11 (auto, constructeurs de déplacement et de copie, délégation, boucle sur intervalles, etc.).\r\n\r\nUne conclusion aborde le cycle de vie logiciel, les interactions avec d’autres environnements et une lecture critique de l’écosystème C++. Inter ou intra sur devis. Référence catalogue : NUM_DEV_13. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/concepteur_app.jpg', '5 jours — Cours, étude de cas fil rouge et travaux pratiques', NULL, NULL, NULL, 'Évaluation de la formation et de votre progression', 'Évaluation structurée comme sur les autres parcours certifiants Alt RH Formations.', 'Demander la formation Programmation objet en C++', 'Inter ou intra : devis et dates avec Alt RH Formations.', 'published', 56, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(175, 1, 2, 'Cybersécurité — C-DFE : Certified Digital Forensics Examiner', 'cybersecurite-c-dfe-certified-digital-forensics-examiner', 'certifiante', 'Cinq jours en présentiel pour maîtriser les standards de criminalistique numérique, les bonnes pratiques et préparer l’examen Mile2 C-DFE (Certified Digital Forensics Examiner).', '/assets/video/formations/cyber.mp4', '5 jours', 'Présentiel', '2399.20', 'C-DFE : Certified Digital Forensics Examiner — Mile2 — certification incluse au tarif inter indiqué', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'À l’issue du parcours, les participants sont en mesure d’instaurer des standards professionnels reconnus en criminalistique numérique, alignés sur les meilleures pratiques et politiques du secteur, et de se présenter sereinement à l’examen C-DFE.\r\n\r\nLe programme couvre incidents, théorie et processus d’enquête, acquisitions et analyse sur disques et systèmes (Windows, Linux, macOS), preuves numériques, laboratoire, eDiscovery, mobile, gestion d’incident et restitution.\r\n\r\nInter-entreprise selon calendrier Mile2 / Alt RH Formations, ou intra sur devis. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/expert_cyber.jpg', '5 jours — Présentiel, parcours couvrant 19 modules Mile2', NULL, NULL, NULL, 'Objectifs et évaluation', 'L’évaluation est cohérente avec la préparation à la certification C-DFE : acquisition des référentiels Mile2, mise en pratique et positionnement avant passage de l’examen.', 'Réserver la formation C-DFE — Certified Digital Forensics Examiner', 'Choisissez une session inter ou demandez un intra : devis, financement et inscription avec Alt RH Formations.', 'published', 57, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(176, 1, 2, 'Cybersécurité — CISSP : Certified Information Systems Security Professional (ISC2)', 'cybersecurite-isc2-cissp', 'certifiante', 'Cinq jours en présentiel pour couvrir les 8 domaines du référentiel CISSP et préparer l’examen (ISC)² Certified Information Systems Security Professional.', '/assets/video/formations/cyber.mp4', '5 jours', 'Présentiel', '3120.00', 'CISSP — Certified Information Systems Security Professional — (ISC)² — certification incluse au tarif inter indiqué', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'La formation relie les concepts IT et sécurité aux enjeux opérationnels : protection des actifs sur leur cycle de vie, conception et supervision de systèmes, réseaux et applications avec une exigence de confidentialité, intégrité et disponibilité (CIA).\r\n\r\nVous aborderez l’architecture et les principes de sécurité, la cryptographie, la sécurité physique, les réseaux (y compris une lecture en couches du modèle OSI 1 à 7), le contrôle d’accès, les stratégies de test et d’audit, les opérations de sécurité et le développement sécurisé — socle reconnu pour viser la certification CISSP.\r\n\r\nInter-entreprise selon calendrier, ou intra sur devis. Contact : 01 60 43 94 32 — formations@altrh.com.', '/assets/images/expert_cyber.jpg', '5 jours — Présentiel, les 8 domaines du référentiel CISSP', NULL, NULL, NULL, 'Objectifs et évaluation', 'Parcours aligné sur la préparation à l’examen CISSP : acquisition du référentiel (ISC)², exercices et positionnement.', 'Réserver la formation CISSP — Certified Information Systems Security Professional', 'Choisissez une session inter ou demandez un intra : devis, financement et inscription avec Alt RH Formations.', 'published', 58, '2026-07-27 03:20:01', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(177, 1, 4, 'Programmer et automatiser des tâches avec Python', 'formation-python-tosa', 'certifiante', 'Maîtrisez Python pour automatiser des tâches, analyser des données et développer des applications.', '/assets/video/formations/dev-app.mp4', '30 heures', NULL, '1246.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce cycle de formation vous guide pas à pas dans l’apprentissage de la syntaxe de base du langage, la manipulation des structures de données, l’application de la programmation orientée objet et l’utilisation des modules et packages pour structurer vos projets. Vous êtes également formé·e à l’optimisation du code afin de garantir des scripts performants et maintenables.\r\n\r\nConçu pour les professionnel·le·s en reconversion ou en évolution de carrière, ce programme vous permet de développer des compétences immédiatement opérationnelles, tout en vous donnant l’opportunité de valider la certification TOSA.\r\n\r\nLe saviez-vous ? Python est aujourd’hui le langage de programmation le plus enseigné dans les universités à travers le monde. Il est aussi régulièrement classé numéro 1 dans les classements des langages les plus populaires, notamment grâce à sa simplicité et sa polyvalence.', NULL, '30 heures (estimées)', NULL, NULL, NULL, NULL, NULL, 'Prêt·e à maîtriser Python ?', 'Recevez une documentation complète ou contactez un conseiller pour étudier votre financement.', 'published', 59, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Recevoir la documentation\",\"url\":\"/documentation\"},{\"label\":\"Contacter un conseiller\",\"url\":\"/contact\"}]},\"avantages_visiplus\":[{\"titre\":\"Plateforme digital learning dédiée\",\"description\":\"Apprentissage à votre rythme sur tous vos appareils connectés.\"},{\"titre\":\"Suivi personnalisé\",\"description\":\"Accompagnement par des expert·e·s de l\'élaboration du dossier à la certification.\"},{\"titre\":\"Communauté active\",\"description\":\"Échanges quotidiens avec vos pairs et formateur·rice·s.\"},{\"titre\":\"Employabilité renforcée\",\"description\":\"Formations conçues par des professionnel·le·s pour les besoins du marché.\"},{\"titre\":\"Réseau Alumni\",\"description\":\"Accès à un cercle de plus de 20 000 diplômé·e·s.\"}],\"accueil_psh\":\"VISIPLUS accompagne les participant·e·s en situation de handicap. Un livret d\'accueil dédié est disponible en téléchargement.\",\"financement\":{\"titre\":\"Financer sa formation\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\",\"lien_guide\":\"https://academy.visiplus.com/financement\"}}'),
(178, 1, 3, 'Responsive Web Design', 'formation-responsive-web-design', 'certifiante', 'Concevez des expériences utilisateur ergonomiques et accessibles sur tous les supports numériques.', '/assets/video/formations/dev-web-mobile.mp4', '15 heures', NULL, '850.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'published', 60, '2026-07-27 03:20:02', '{\"avantages_visiplus\":[{\"titre\":\"Plateforme digital learning\",\"desc\":\"Suivez vos modules partout, à votre rythme.\"},{\"titre\":\"Suivi personnalisé\",\"desc\":\"Accompagnement par des expert·e·s à chaque étape.\"},{\"titre\":\"Communauté et Alumni\",\"desc\":\"Réseau de 20 000 diplômé·e·s pour networker.\"},{\"titre\":\"Employabilité\",\"desc\":\"Compétences en phase avec le marché du travail.\"}],\"avis_clients\":[{\"auteur\":\"Lydie A.\",\"poste\":\"Responsable communication\",\"commentaire\":\"Discours qui va à l’essentiel.\"},{\"auteur\":\"Laetitia G.\",\"poste\":\"Graphiste intégrateur·rice\",\"commentaire\":\"Formateur très professionnel.\"},{\"auteur\":\"Jérôme M.\",\"poste\":\"Webmaster\",\"commentaire\":\"La formation est véritablement intéressante.\"}],\"cycle_associe\":{\"titre\":\"Web Designer / UX Designer\",\"niveau\":\"Titre certifié de niveau 6 reconnu par l\'État\",\"debouches\":[\"Développeur·euse web\",\"Intégrateur·rice web\",\"Webdesigner\",\"Webmaster\"]},\"financement\":{\"titre\":\"Financer sa formation\",\"description\":\"Plusieurs dispositifs de financement sont possibles (jusqu\'à 100%) selon votre statut professionnel.\"}}'),
(179, 1, 3, 'Formation PHP', 'formation-php', 'certifiante', 'Créez des sites web dynamiques, vitrines et e-commerce avec le langage de programmation PHP.', '/assets/video/formations/dev-app.mp4', '15 heures', NULL, '850.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'published', 61, '2026-07-27 03:20:02', '{\"avantages_visiplus\":[{\"titre\":\"Une plateforme digital learning dédiée\",\"desc\":\"Suivez vos modules de formation depuis un appareil connecté où que vous soyez et à votre propre rythme.\"},{\"titre\":\"Un suivi personnalisé\",\"desc\":\"Conseiller·ère·s formation, coordinateur·rice·s pédagogiques, formateur·rice·s, mentor·e·s individuel·le·s à votre disposition.\"},{\"titre\":\"Le soutien de toute une communauté\",\"desc\":\"Echangez au quotidien avec vos pairs, vos formateur·rice·s et toute notre équipe pédagogique.\"},{\"titre\":\"Votre employabilité renforcée\",\"desc\":\"Des formations conçues spécifiquement pour des professionnel·le·s, par des professionnel·le·s expert·e·s.\"},{\"titre\":\"Un réseau d’Alumni pour échanger\",\"desc\":\"Cercle Alumni de plus de 20 000 diplômé·e·s pour élargir votre réseau professionnel.\"}],\"cycle_associe\":{\"titre\":\"Web Designer / UX Designer\",\"description\":\"La formation PHP fait partie du cycle long de formation (diplômante) Web Designer/UX Designer.\",\"niveau\":\"Titre Certifié Web Designer / UX Designer\",\"debouches\":[\"Chef·fe de projet web\",\"Graphiste web\",\"Intégrateur·rice web\",\"Responsable communication\",\"Webdesigner\",\"Webmaster\"]},\"financement\":{\"titre\":\"Financer sa formation en Développement Web / Informatique\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\"}}'),
(180, 1, 2, 'Initiation à la Cybersécurité', 'formation-initiation-cybersecurite', 'certifiante', 'Identifiez les cybermenaces et protégez-vous efficacement dans l\'espace numérique.', '/assets/video/formations/cyber.mp4', '15 heures', NULL, '850.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'published', 62, '2026-07-27 03:20:02', '{\"avantages_visiplus\":[{\"titre\":\"Une plateforme digital learning dédiée\",\"desc\":\"Suivez vos modules de formation depuis un appareil connecté où que vous soyez et à votre propre rythme.\"},{\"titre\":\"Un suivi personnalisé\",\"desc\":\"Conseiller·ère·s formation, coordinateur·rice·s pédagogiques, formateur·rice·s, mentor·e·s individuel·le·s à votre disposition.\"},{\"titre\":\"Le soutien de toute une communauté\",\"desc\":\"Echangez au quotidien avec vos pairs, vos formateur·rice·s et toute notre équipe pédagogique.\"},{\"titre\":\"Votre employabilité renforcée\",\"desc\":\"Des formations conçues spécifiquement pour des professionnel·le·s, par des professionnel·le·s expert·e·s.\"},{\"titre\":\"Un réseau d’Alumni pour échanger\",\"desc\":\"Cercle Alumni de plus de 20 000 diplômé·e·s pour élargir votre réseau professionnel.\"}],\"financement\":{\"titre\":\"Financer sa formation en Développement Web / Informatique\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\"}}'),
(181, 1, 2, 'Implémenter une politique de Cybersécurité', 'formation-implementer-politique-cybersecurite', 'certifiante', 'Mettez en place une politique de cybersécurité efficace pour protéger votre entreprise des menaces numériques.', '/assets/video/formations/cyber.mp4', '15 heures', NULL, '850.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'published', 63, '2026-07-27 03:20:02', '{\"avantages_visiplus\":[{\"titre\":\"Une plateforme digital learning dédiée\",\"desc\":\"Suivez vos modules de formation depuis un appareil connecté où que vous soyez et à votre propre rythme.\"},{\"titre\":\"Un suivi personnalisé\",\"desc\":\"Conseiller·ère·s formation, coordinateur·rice·s pédagogiques, formateur·rice·s, mentor·e·s individuel·le·s à votre disposition.\"},{\"titre\":\"Le soutien de toute une communauté\",\"desc\":\"Echangez au quotidien avec vos pairs, vos formateur·rice·s et toute notre équipe pédagogique.\"},{\"titre\":\"Votre employabilité renforcée\",\"desc\":\"Des formations conçues spécifiquement pour des professionnel·le·s, par des professionnel·le·s expert·e·s.\"},{\"titre\":\"Un réseau d’Alumni pour échanger\",\"desc\":\"Cercle Alumni de plus de 20 000 diplômé·e·s pour élargir votre réseau professionnel.\"}],\"financement\":{\"titre\":\"Financer sa formation en Développement Web / Informatique\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\"}}'),
(182, 1, 2, 'Configuration et administration d’équipements réseaux CISCO', 'formation-cisco-configuration-administration', 'certifiante', 'Configurez les équipements Cisco et administrez les services réseaux de votre organisation.', '/assets/video/formations/infra-reseau.mp4', '15 heures', NULL, '850.00', NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'published', 64, '2026-07-27 03:20:02', '{\"avantages_visiplus\":[{\"titre\":\"Une plateforme digital learning dédiée\",\"desc\":\"Suivez vos modules de formation depuis un appareil connecté où que vous soyez et à votre propre rythme.\"},{\"titre\":\"Un suivi personnalisé\",\"desc\":\"Conseiller·ère·s formation, coordinateur·rice·s pédagogiques, formateur·rice·s, mentor·e·s individuel·le·s à votre disposition.\"},{\"titre\":\"Le soutien de toute une communauté\",\"desc\":\"Echangez au quotidien avec vos pairs, vos formateur·rice·s et toute notre équipe pédagogique.\"},{\"titre\":\"Votre employabilité renforcée\",\"desc\":\"Des formations conçues spécifiquement pour des professionnel·le·s, par des professionnel·le·s expert·e·s.\"},{\"titre\":\"Un réseau d’Alumni pour échanger\",\"desc\":\"Cercle Alumni de plus de 20 000 diplômé·e·s pour élargir votre réseau professionnel.\"}],\"cycle_associe\":{\"titre\":\"Technicien·ne Systèmes, réseaux et sécurité\",\"niveau\":\"Titre Certifié de niveau 5\",\"description\":\"Ce module de formation est dispensé dans le cadre du cycle long diplômant \\\"Technicien·ne Systèmes, réseaux et sécurité\\\", permettant d\'acquérir un large spectre de compétences en hardware, software et notions transversales clés.\",\"debouches\":[\"Gestionnaire de parc informatique\",\"Technicien·ne sécurité informatique\",\"Technicien·ne informatique et réseaux\",\"Technicien·ne support utilisateur\",\"Technicien·ne systèmes et réseaux\",\"Assistant·e administration systèmes, réseaux\"]},\"financement\":{\"titre\":\"Financer sa formation en Développement Web / Informatique\",\"description\":\"Plusieurs dispositifs de financement sont possibles en fonction de votre statut professionnel et peuvent financer jusqu’à 100% votre formation.\"}}'),
(183, 1, 4, 'Microsoft 365 Copilot — IA générative en contexte professionnel', 'microsoft-365-copilot-ai-business-professional', 'certifiante', 'Comprenez et utilisez l’intelligence artificielle générative avec Microsoft 365 Copilot : automatiser des tâches, enrichir la création de contenu et fluidifier la collaboration, sans compétences techniques.', '/assets/video/formations/dev-app.mp4', '7 heures (1 jour)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Préparation à l’examen AB-730 — Transformer des flux de travail métier avec l’IA générative, conduisant à la certification Microsoft Certified : AI Business Professional.', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation certifiante permet de comprendre comment utiliser l’intelligence artificielle générative dans un contexte professionnel avec Microsoft 365 Copilot. Vous découvrez comment automatiser des tâches, améliorer la création de contenu et optimiser la collaboration au sein des outils Microsoft 365.\r\n\r\nLe programme s’appuie sur des cas d’usage concrets pour intégrer Copilot dans les activités quotidiennes, sans compétences de développement. Il couvre la rédaction de contenu, l’analyse de données, la gestion des réunions et l’organisation du travail.\r\n\r\nAccessible à tous les profils métier, ce parcours vise à accélérer l’adoption efficace de l’IA générative et de Microsoft 365 Copilot en entreprise.', '/assets/images/analyste_data.jpg', '7 heures — ateliers et cas d’usage sur une journée', NULL, NULL, NULL, 'Évaluation des acquis & certification', 'Parcours d’évaluation aligné sur les standards Alt RH & formations : positionnement, mise en pratique sur cas réels et préparation à la certification Microsoft.', 'Préparez la certification Microsoft AI Business Professional', 'Un conseiller Alt RH & formations vous aide à choisir le format (inter / intra) et à monter votre financement.', 'published', 65, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(184, 1, 4, 'IA générative pour l’administration systèmes et réseaux', 'ia-generative-administration-systemes-reseaux', 'certifiante', 'Maîtrisez ChatGPT, Copilot, Mistral, Perplexity et autres LLM pour scripts, diagnostic, automatisation et documentation — un parcours résolument pratique, centré sur les métiers IT.', '/assets/video/formations/infra-reseau.mp4', '2 jours (≈ 14 h)', 'Présentiel, téléprésentiel ou à distance', '1590.00', 'Formation certifiante — attestation de fin de formation et évaluation des acquis selon les objectifs pédagogiques (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Face à l’évolution des environnements informatiques et à la montée de l’IA, les administrateur·rice·s et technicien·ne·s ont l’opportunité de transformer leur façon de travailler. Cette formation certifiante vise à faire découvrir et maîtriser l’usage concret de l’IA générative (ChatGPT, Copilot, Mistral, Perplexity, etc.) au service des tâches quotidiennes d’administration systèmes et réseaux.\r\n\r\nS’appuyant sur des outils d’IA avancés, vous apprenez à générer et optimiser des scripts, résoudre plus vite des incidents, automatiser des opérations de maintenance et produire une documentation technique plus efficace. L’approche repose sur des cas d’usage réels, tirés du quotidien des professionnel·le·s IT.\r\n\r\nAlt RH & formations vous accompagne sur le format (inter / intra), les sessions et le montage de financement. Les modalités détaillées (groupes, délais d’inscription, accessibilité) sont précisées ci-dessous.', '/assets/images/Terchnicien_reseau.jpg', '2 jours — ateliers et mises en situation sur cas réels', NULL, NULL, NULL, 'Évaluation des acquis', 'Dispositif aligné sur les pratiques Alt RH & formations : auto-évaluation, exercices et retours formateur.', 'Intégrez l’IA générative dans vos opérations IT', 'Demandez un devis intra-entreprise ou les prochaines dates inter-entreprise.', 'published', 66, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(185, 1, 4, 'IA générative intensive — LLM, Transformers & chatbots', 'ia-generative-maitrise-llm-transformers', 'certifiante', 'Plongez dans ChatGPT, GPT-4 et l’écosystème des modèles génératifs : prompts avancés, automatisation, synthèses, création de chatbots et alternatives open source — avec de nombreux exercices pratiques.', '/assets/video/formations/dev-app.mp4', '≈ 14 heures (2 jours intensifs)', 'Présentiel, téléprésentiel ou à distance', '1750.00', 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation intensive vous fait explorer l’histoire, le fonctionnement et l’architecture des outils d’IA générative les plus avancés : ChatGPT, les familles GPT, et au-delà de nombreux acteurs du marché. Vous comprenez comment ces technologies transforment la finance, l’éducation, la santé et d’autres secteurs.\r\n\r\nVous apprenez à produire des illustrations et des rapports assistés par IA, à automatiser des tâches par prompts structurés, et à devenir efficace en conception de prompts (« prompt engineering »). Un module approfondit les transformers et les LLM. Vous créez votre propre chatbot et découvrez des alternatives libres et open source pour élargir votre palette d’outils.\r\n\r\nUn support de cours au format numérique (type présentation structurée) est remis aux participant·e·s. Alt RH & formations vous accompagne sur les modalités, les sessions inter / intra et le financement.', '/assets/images/analyste_data.jpg', 'Environ 14 heures sur 2 jours — apports, démonstrations et travaux pratiques', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Passez à la maîtrise des IA génératives', 'Contactez Alt RH & formations pour les dates, le format et le financement.', 'published', 67, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(186, 1, 3, 'ChatGPT & API OpenAI pour développeurs', 'chatgpt-openai-api-developpeurs', 'certifiante', 'Formation intensive : maîtriser ChatGPT et l’API OpenAI pour générer et refactoriser du code, sécuriser et fiabiliser vos développements — avec un projet web fil rouge de bout en bout.', '/assets/video/formations/dev-web-mobile.mp4', '14 heures (≈ 2 jours)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation intensive place les développeur·euses au cœur des IA génératives : introduction approfondie à ChatGPT et à l’API OpenAI, pour faire évoluer la façon dont vous produisez et maintenez du code.\r\n\r\nVous apprenez à vous faire assister pour la génération et la refactorisation, la détection de failles de sécurité et l’amélioration de la qualité du code — le tout ancré dans la pratique via le développement d’une application web complète (front et back). Vous abordez aussi sécurité, éthique, limites et perspectives d’évolution de ces technologies.\r\n\r\nUn support de cours au format numérique (présentation structurée par le formateur) est remis à chaque participant·e. Alt RH & formations vous accompagne sur le format (inter / intra), le calendrier et le montage de financement.', '/assets/images/concepteur_web.jpg', '14 heures — approche fortement pratique (projet fil rouge)', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les standards Alt RH & formations.', 'Boostez votre développement avec ChatGPT & OpenAI', 'Demandez une date inter-entreprise ou un devis intra.', 'published', 68, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(187, 1, 3, 'API ChatGPT (OpenAI) — intégration web & mobile', 'api-chatgpt-openai-integration-applications', 'certifiante', 'Configurez et exploitez l’API ChatGPT : conversations multi-tours, personnalisation, intégration dans vos applications, puis déploiement, performances, sécurité et éthique — atelier pratique tout au long du parcours.', '/assets/video/formations/dev-app.mp4', '21 heures (≈ 3 jours)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous fait exploiter tout le potentiel de l’API ChatGPT d’OpenAI pour des applications web et mobiles : configuration, authentification, requêtes et réponses, paramètres avancés et conversations multi-tours pour des échanges plus précis et contextualisés.\r\n\r\nVous approfondissez l’intégration dans vos propres projets : choix d’hébergement, optimisation des performances en production, sécurité de l’architecture, respect de la vie privée et des politiques OpenAI. Les travaux pratiques s’appuient sur des notebooks (ex. Jupyter) et des mises en situation réalistes.\r\n\r\nSupport de cours au format numérique remis aux participant·e·s. Alt RH & formations vous accompagne sur le calendrier, le format inter / intra et le financement.', '/assets/images/concepteur_app.jpg', '21 heures — atelier pratique en parallèle des modules', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Intégrez l’API ChatGPT dans vos applications', 'Contactez Alt RH & formations pour planifier une session ou un devis intra.', 'published', 69, '2026-07-27 03:20:02', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(188, 1, 4, 'IA générative — communication & webmarketing', 'ia-generative-communication-webmarketing', 'certifiante', 'Prompts efficaces, stratégie digitale, contenus SEO, relations presse, réseaux sociaux et e-réputation : utilisez l’IA générative au service de votre communication, avec ateliers pratiques en contexte entreprise.', '/assets/video/formation.mp4', '≈ 15 h 30 (2 jours)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation approfondit l’usage de l’intelligence artificielle générative dans une perspective communication et webmarketing : fondements, rédaction de prompts, création de contenus éditoriaux, et mise en œuvre concrète dans vos campagnes et dispositifs digitaux.\r\n\r\nLe programme relie stratégie webmarketing, SEO, relations médias et e-réputation, en mettant l’accent sur l’IA comme levier — sans négliger cadre légal, propriété intellectuelle et posture professionnelle. Des ateliers renforcent la mise en application sur des cas réels d’entreprise.\r\n\r\nSupport de cours numérique remis aux participant·e·s. Alt RH & formations vous accompagne sur les formats inter / intra et le financement.', '/assets/images/designer_app_mobile.jpg', 'Environ 15 h 30 sur 2 jours — ateliers inclus', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Passez à l’IA dans votre communication', 'Demandez une session ou un devis intra-entreprise.', 'published', 70, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(189, 1, 4, 'Machine Learning — fondamentaux & mise en pratique', 'machine-learning-fondamentaux-intensif', 'certifiante', 'Supervisé et non supervisé, du cadrage du problème au déploiement de modèles : régression, forêts aléatoires, réseaux de neurones, SVM, réduction de dimension, clustering, détection d’anomalies, recommandation — avec travaux pratiques sur données réelles ', '/assets/video/formation.mp4', '≈ 35 h (5 jours)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette session intensive couvre les principes fondamentaux du machine learning, de la définition d’un problème adapté jusqu’à la production de résultats actionnables : prétraitement des données, construction et évaluation de modèles, et identification des verrous techniques (sur-apprentissage, biais, qualité des données, etc.).\r\n\r\nVous aborderez l’apprentissage supervisé et non supervisé — régression linéaire et logistique, forêts aléatoires, réseaux de neurones, SVM, réduction de dimensionnalité, K-means, détection d’anomalies, introduction aux réseaux adverses (GAN) — avec une attention particulière aux systèmes de recommandation et au filtrage collaboratif.\r\n\r\nLes travaux pratiques s’appuient sur des jeux de données réels pour le traitement d’images, de texte et les problèmes de recommandation. Alt RH & formations vous accompagne sur les formats inter / intra et le financement.', '/assets/images/analyste_data.jpg', 'Environ 35 h sur 5 jours — alternance cours et travaux pratiques', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Renforcez vos compétences en machine learning', 'Planifiez une session inter ou un devis intra-entreprise.', 'published', 71, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(190, 1, 4, 'Séminaire — panorama IA, Machine Learning & Deep Learning', 'seminaire-vue-ensemble-ia-ml-deep-learning', 'certifiante', 'Enjeux, tendances et limites des systèmes actuels : vision, langage, séries temporelles, raisonnement ; acteurs du marché et recherche ; secteurs porteurs et mise en chemin vers une transition IA dans vos systèmes métiers — avec démonstration concrète.', '/assets/video/formation.mp4', '≈ 7 h (1 jour)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Ce séminaire propose une vue d’ensemble des enjeux et tendances de l’intelligence artificielle, avec un accent sur le machine learning et le deep learning : retour historique, questions d’actualité (éthique, données, emploi…), et panorama des capacités réelles des systèmes d’aujourd’hui.\r\n\r\nVous découvrirez les grands domaines d’application — vision par ordinateur, traitement du langage, prévision sur séries temporelles, raisonnement assisté — illustrés par une démonstration. Puis un regard croisé sur les acteurs industriels et la recherche académique, les évolutions récentes et les secteurs dynamiques.\r\n\r\nEnfin, des études de cas (transport, santé, informatique) pour comprendre comment l’IA transforme les métiers, et des repères pour amorcer une transition vers l’IA dans les systèmes métiers. Alt RH & formations vous accompagne sur les formats inter / intra et le financement.', '/assets/images/analyste_data.jpg', 'Environ 7 h sur 1 jour — conférence structurée et démonstration', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Donnez du contexte à votre stratégie IA', 'Réservez une date en inter-entreprises ou demandez un séminaire intra.', 'published', 72, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(191, 1, 4, 'Deep learning pour le traitement du langage (NLP)', 'deep-learning-traitement-langage-nlp', 'certifiante', 'Des fondamentaux du deep learning aux architectures dédiées au texte : réseaux récurrents, LSTM, GRU, attention, embeddings et modèles récents ; applications traduction, résumé, génération, classification, sentiment, sujets — avec travaux pratiques sur do', '/assets/video/formation.mp4', '≈ 28 h (4 jours)', 'Présentiel, téléprésentiel ou à distance', NULL, 'Formation certifiante — attestation de fin de formation et évaluation des acquis (organisme certifié Qualiopi).', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation propose une introduction solide au deep learning appliqué au traitement du langage : réseaux de neurones, rétropropagation du gradient, fonctions de non-linéarité, puis enchaînement sur les briques classiques et modernes du NLP (réseaux récurrents, LSTM, GRU, softmax, embeddings, mécanismes d’attention et de mémoire, évolutions récentes de la littérature).\r\n\r\nVous mettrez en œuvre des cas concrets : traduction automatique, résumé, génération de texte, classification, analyse de sentiment, modélisation de sujets (topics). Les volets ingénierie — métriques, lecture des courbes d’apprentissage, recherche d’hyperparamètres — permettent de relier expérimentation et résultats exploitables métier.\r\n\r\nLes travaux pratiques s’appuient sur des données réelles et des modèles récents, dans une perspective alignée sur l’état de la recherche. Alt RH & formations vous accompagne sur les formats inter / intra et le financement.', '/assets/images/analyste_data.jpg', 'Environ 28 h sur 4 jours — cours et travaux pratiques', NULL, NULL, NULL, 'Évaluation des acquis', 'Évaluation alignée sur les pratiques Alt RH & formations.', 'Passez du machine learning au NLP profond', 'Demandez une session inter ou un devis intra-entreprise.', 'published', 73, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\",\"url\":\"/contact\"}]}}'),
(192, 1, 12, 'Systèmes Embarqués & IOT : Android, construire son propre système embarqué', 'systemes-embarques-iot-android', 'elearning', 'Maîtrisez la construction et la personnalisation d\'Android pour systèmes embarqués, du noyau Linux aux applications mobiles.', '/assets/video/formations/dev-web-mobile.mp4', '4 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous permettra de comprendre le fonctionnement interne d\'Android et de mettre en œuvre son système de fabrication complet, de la récupération des sources à la génération d\'une image bootable.\r\n\r\nVous apprendrez à adapter Android à un matériel spécifique, à configurer et compiler le noyau Linux associé, et à intégrer de nouveaux périphériques dans un système Android existant.\r\n\r\nÀ l\'issue de cette formation, vous serez capable de construire votre propre image Android personnalisée, de la déboguer via ADB et de la déployer sur du matériel embarqué réel ou en émulation.', NULL, '4 jours — Formation intensive avec travaux pratiques sur chaque module', NULL, NULL, NULL, NULL, NULL, 'Prêt à maîtriser Android embarqué ?', 'Formation disponible sur demande. Contactez-nous pour planifier une session adaptée à vos besoins et à votre équipe.', 'published', 74, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"NOUS CONTACTER\"}]}}'),
(193, 1, 7, 'Cybersécurité : Test d’intrusion des serveurs et des applications Web', 'cybersecurite-pentest-web-serveurs', 'elearning', 'Obtenez les bases nécessaires pour la compréhension des applications Web et des vulnérabilités associées.', '/assets/video/formations/cyber.mp4', '2 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation intensive vous apporte les compétences fondamentales pour identifier et exploiter les failles de sécurité courantes des infrastructures web.\r\n\r\nVous explorerez les méthodologies de collecte d\'information et de contournement d\'autorisation avant de vous attaquer aux vulnérabilités majeures telles que le XSS, les injections et les failles CSRF.\r\n\r\nÀ l\'issue de ce stage, vous serez capable d\'auditer la sécurité des serveurs et des applications web, d\'analyser les tokens JWT et de sécuriser les mécanismes de téléchargement.', NULL, '2 jours — Formation rythmée par des exercices pratiques', NULL, NULL, NULL, NULL, NULL, 'Prêt à sécuriser vos applications Web ?', 'De nombreuses sessions disponibles. Inscrivez-vous dès maintenant ou demandez un programme sur mesure pour votre équipe.', 'published', 75, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'INSCRIRE\"},{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(194, 1, 7, 'Cybersécurité : Préparation Offensive Security Exploit Developer (OSED)', 'cybersecurite-preparation-osed', 'elearning', 'Maîtrisez le développement d\'exploits Windows, le contournement des protections modernes et préparez la certification OSED.', '/assets/video/formations/cyber.mp4', '5 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous permettra de maîtriser le développement d\'exploits Windows en mode utilisateur sur architecture x86, en couvrant l\'ensemble des techniques requises pour la certification OSED d\'Offensive Security.\r\n\r\nVous apprendrez à contourner les mécanismes de sécurité modernes tels que DEP et ASLR, à développer des chaînes ROP personnalisées et à écrire du shellcode sur mesure.\r\n\r\nÀ l\'issue de cette formation, vous serez capable d\'appliquer des techniques avancées de reverse engineering pour identifier des vulnérabilités et vous présenter avec confiance à l\'examen de certification OSED.', NULL, '5 jours — Formation intensive avec travaux pratiques', NULL, NULL, NULL, NULL, NULL, 'Prêt à maîtriser le développement d\'exploits ?', 'De nombreuses sessions disponibles tout au long de l\'année. Inscrivez-vous à la date qui vous convient ou contactez-nous pour une formation sur mesure.', 'published', 76, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'INSCRIRE\"},{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(195, 1, 7, 'Cybersécurité : PECB CERTIFIED Lead Cloud Security Manager', 'cybersecurite-pecb-lead-cloud-security-manager', 'elearning', 'Maîtrisez la planification, la mise en œuvre et la gestion d\'un programme complet de sécurité du cloud selon les normes ISO/IEC 27017 et 27018.', '/assets/video/formations/admin-infra.mp4', '5 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous permet d’acquérir une compréhension complète des concepts, approches, méthodes et techniques utilisés pour la mise en œuvre et la gestion efficace d’un programme de sécurité du cloud.\r\n\r\nVous apprendrez à interpréter les lignes directrices des normes ISO/IEC 27017 et ISO/IEC 27018 dans le contexte spécifique d’un organisme et comprendrez leur corrélation avec d’autres cadres réglementaires.\r\n\r\nÀ l\'issue de cette formation, vous aurez développé les compétences pratiques pour aider ou conseiller une organisation à planifier, mettre en œuvre, gérer, surveiller et maintenir un programme de sécurité du cloud en suivant les meilleures pratiques.', NULL, '5 jours — Formation structurée pour la certification PECB', NULL, NULL, NULL, NULL, NULL, 'Prêt à certifier votre expertise Cloud Security ?', 'De nombreuses sessions disponibles tout au long de l\'année. Inscrivez-vous à la date qui vous convient ou contactez-nous pour une formation sur mesure.', 'published', 77, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"S\'INSCRIRE\"},{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(196, 1, 3, 'Digital & Développement : Big Data et stratégie marketing, usages et mise en œuvre', 'digital-developpement-big-data-strategie-marketing', 'elearning', 'Comprenez l\'apport du Big Data, identifiez les cas d\'usage clés et cadrez votre stratégie de gouvernance des données.', '/assets/video/formations/dev.mp4', '2 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous permettra de comprendre l\'apport du Big Data pour les directions métiers et de cerner l\'importance de traiter les données structurées et non structurées.\r\n\r\nVous apprendrez à identifier les cas d\'usage clés, de la mesure de l\'e-réputation à l\'optimisation du parcours client, en passant par la segmentation et le calcul du ROI des campagnes.\r\n\r\nÀ l\'issue de cette formation, vous maîtriserez les méthodes de cadrage et de mise en place d\'une stratégie de gouvernance du Big Data performante. Associée à la certification DiGiTT, cette formation est éligible au CPF.', NULL, '2 jours — Apports théoriques, études de cas et travaux pratiques', NULL, NULL, NULL, NULL, NULL, 'Prêt à transformer votre stratégie marketing avec le Big Data ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs.', 'published', 78, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(197, 1, 3, 'Digital & Développement : Programmation Java', 'digital-developpement-java', 'elearning', 'Maîtrisez la syntaxe du langage Java et les principes de la Programmation Orientée Objet pour développer des applications robustes.', '/assets/video/formations/dev-app.mp4', '5 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation complète vous permettra de mettre en œuvre les principes fondamentaux de la Programmation Orientée Objet (POO) et de maîtriser la syntaxe du langage Java.\r\n\r\nVous apprendrez à manipuler les principales librairies standards Java, à gérer les exceptions, les entrées/sorties, et à créer des interfaces graphiques.\r\n\r\nÀ l\'issue de cette session, vous maîtriserez un environnement de développement intégré (IDE) pour programmer efficacement en Java, concevoir des hiérarchies de classes complexes et appliquer les concepts avancés tels que le polymorphisme et la généricité.', NULL, '5 jours — Formation approfondie avec mise en pratique continue', NULL, NULL, NULL, NULL, NULL, 'Prêt à démarrer la programmation Java ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs et à votre équipe.', 'published', 79, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}');
INSERT INTO `formation_courses` (`id`, `site_id`, `category_id`, `title`, `slug`, `course_type`, `subtitle`, `video_url`, `duration`, `modality_label`, `price`, `certification_label`, `reference_code`, `rncp_repertoire`, `is_cpf_eligible`, `is_alternance`, `rncp_code`, `rncp_title`, `rncp_level`, `rncp_url`, `presentation_title`, `presentation_text`, `presentation_image_url`, `programme_duration_total`, `debouches_title`, `debouches_subtitle`, `debouches_sectors`, `evaluation_title`, `evaluation_description`, `cta_title`, `cta_subtitle`, `status`, `sort_order`, `created_at`, `extra_json`) VALUES
(198, 1, 8, 'Management : Management situationnel, adapter son management à chaque collaborateur', 'management-situationnel', 'elearning', 'Développez votre impact personnel, diversifiez vos styles de leadership et adaptez-vous à chaque situation et profil.', '/assets/video/formations/manager.mp4', '3 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'La formation « Management situationnel » permet à toute personne en situation d\'encadrement qui souhaite développer son impact personnel et accroître l\'efficacité de ses collaborateurs, de diversifier ses styles de leadership.\r\n\r\nVous apprendrez à bien formuler un objectif, à accompagner vos collaborateurs dans le développement de leur motivation, et à traiter les situations difficiles en vous adaptant à chaque profil.\r\n\r\nManager, c\'est s\'adapter ! À l\'issue de cette formation, vous maîtriserez les outils pour identifier la maturité de vos équipes et ajuster votre posture managériale en conséquence.', NULL, '3 jours — Alternance d\'apports théoriques, d\'outils pratiques et de mises en situation', NULL, NULL, NULL, NULL, NULL, 'Prêt à faire évoluer votre posture managériale ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs et à votre équipe.', 'published', 80, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(199, 1, 8, 'Management : Intégrer la Responsabilité Sociétale de l\'Entreprise (RSE)', 'management-rse', 'elearning', 'Faites de la RSE un véritable levier de performance durable en l\'intégrant dans la culture et les processus de votre entreprise.', '/assets/video/formations/manager.mp4', '3 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Au-delà des obligations juridiques, les donneurs d\'ordre exigent que les entreprises investissent davantage dans le capital humain, l\'environnement et les relations avec leurs parties prenantes.\r\n\r\nCette formation RSE vous permettra d\'identifier l\'intérêt de la RSE pour votre entreprise, de découvrir la norme ISO 26000 et d\'agir pour améliorer votre image vis-à-vis de vos parties prenantes.\r\n\r\nÀ l\'issue de ces 3 jours, vous serez capable d\'identifier de nouveaux relais de croissance, de réduire vos coûts et de mobiliser vos équipes sur un projet porteur de sens.', NULL, '3 jours — Apports théoriques, mises en situation et méthodes pratiques', NULL, NULL, NULL, NULL, NULL, 'Prêt à faire de la RSE un levier de performance ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à votre entreprise et à vos équipes.', 'published', 81, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(200, 1, 8, 'Management : Réussir le management de projet, guide du gestionnaire', 'management-reussir-management-projet', 'elearning', 'Acquérez une véritable méthodologie de conduite de projet et maîtrisez les facteurs clés de succès, de l\'initialisation à la clôture.', '/assets/video/formations/dev_equipe.mp4', '10 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation complète de 10 jours vous permettra d’acquérir les compétences indispensables pour prendre conscience des facteurs clés de succès d\'un projet et en identifier les étapes incontournables.\r\n\r\nVous apprendrez à structurer une véritable méthodologie de conduite de projet : cadrage, planification, maîtrise des risques, construction de l\'équipe et pilotage au quotidien.\r\n\r\nÀ l\'issue de ce programme, vous serez capable d\'assurer le bon déroulement de vos projets, de gérer les situations complexes et d\'évaluer vos résultats pour capitaliser sur votre expérience.', NULL, '10 jours — Apports théoriques, études de cas et exercices d\'application', NULL, NULL, NULL, NULL, NULL, 'Prêt à professionnaliser votre gestion de projet ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs et à vos équipes.', 'published', 82, '2026-07-27 03:20:03', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(201, 1, 8, 'Management : Devenir un Manager Agile', 'management-devenir-manager-agile', 'elearning', 'Adoptez les postures du manager Agile, développez la coopération et adaptez votre management aux environnements complexes.', '/assets/video/formations/dev_equipe.mp4', '2 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation vous permettra d’acquérir les compétences indispensables pour adapter votre mode de management dans un environnement complexe et en constante évolution.\r\n\r\nVous apprendrez à développer les compétences d’agilité pour vous-même et pour votre équipe, en utilisant des méthodes et outils adaptés pour penser et agir avec agilité.\r\n\r\nÀ l\'issue de ces 2 jours, vous saurez adopter les postures du manager Agile, organiser le travail collaboratif et agir en tant que mentor pour soutenir vos équipes dans le changement.', NULL, '2 jours — Apports théoriques, mises en situation et jeux de rôle', NULL, NULL, NULL, NULL, NULL, 'Prêt à insuffler l\'Agilité dans votre management ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs et à votre équipe.', 'published', 83, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(202, 1, 8, 'Management : Management 3.0', 'management-management-3-0', 'elearning', 'Affinez votre leadership, renforcez la collaboration et favorisez l\'engagement et l\'apprentissage de vos équipes.', '/assets/video/formations/manager.mp4', '2 jours', 'E-learning', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation Management 3.0 est conçue pour vous permettre d’affiner vos compétences en leadership dans un environnement de travail en constante évolution.\r\n\r\nVous apprendrez à renforcer concrètement la collaboration et l\'engagement au sein de votre équipe, tout en développant de nouvelles approches pour stimuler la motivation.\r\n\r\nÀ l\'issue de ces 2 jours, vous disposerez des leviers nécessaires pour favoriser l\'apprentissage continu de vos collaborateurs et instaurer une véritable culture de l\'agilité managériale.', NULL, '2 jours — Programme adapté aux dynamiques de groupe', NULL, NULL, NULL, NULL, NULL, 'Prêt à passer au Management 3.0 ?', 'Formation disponible sur demande. Contactez-nous pour concevoir un programme personnalisé adapté à vos objectifs et à vos équipes.', 'published', 84, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"DEMANDER UNE FORMATION\"}]}}'),
(203, 1, 9, 'DevOps / DevSecOps : Devenez DevOps avec Docker', 'devops-devenez-devops-avec-docker', 'elearning', 'Maîtrisez les bases de Docker pour mettre en place un processus de déploiement continu fiable et efficace de vos applications.', '/assets/video/formations/infra-reseau.mp4', '15 heures (1 mois)', '100% en ligne (E-learning)', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Traditionnellement, le développement et les opérations étaient segmentés. Aujourd’hui, on privilégie la philosophie DevOps qui allie ces deux mondes pour plus de fluidité, de réactivité et d\'intelligence collective.\r\n\r\nDans ce contexte, Docker est un outil open source devenu incontournable : flexibilité dans la portabilité des applications, simplification de la création et maintenance assurée.\r\n\r\nGrâce à cette formation, vous ferez l\'acquisition de compétences particulièrement recherchées sur le marché de l\'emploi pour raccourcir les délais de commercialisation et maintenir la stabilité des systèmes développés.', NULL, '15 heures estimées (sur 1 mois) — Formation 100% en ligne sur plateforme dédiée', NULL, NULL, NULL, NULL, NULL, 'Prêt à maîtriser le déploiement continu avec Docker ?', 'Entrées ouvertes toute l\'année. Contactez nos conseillers pour élaborer votre dossier de financement et démarrer votre formation.', 'published', 85, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"RECEVOIR UNE DOCUMENTATION\"},{\"label\":\"S\'INSCRIRE\"}]}}'),
(204, 1, 11, 'Informatique : Administrer un environnement Windows Server', 'informatique-administration-windows-server', 'elearning', 'Maîtrisez l\'administration avancée de Windows Server : virtualisation, haute disponibilité, conteneurisation et sécurité.', '/assets/video/formations/technicien-sr.mp4', '15 heures (1 mois)', '100% en ligne (E-learning)', NULL, NULL, NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Windows Server s\'est imposé comme l\'OS de référence pour la gestion réseau. Ce système s’étoffe de version en version avec des fonctionnalités complémentaires qui en font un outil indispensable.\r\n\r\nMaîtriser l’administration de Windows Server vous permettra de simplifier votre gestion quotidienne des services applicatifs et réseaux, de protéger votre entreprise des activités malveillantes et d’optimiser les solutions de stockage.\r\n\r\nÀ la suite de cette formation technique et pratique, vous serez à même d’administrer efficacement et sur la durée un environnement Windows Server afin de répondre aux besoins précis de votre organisation.', NULL, '15 heures estimées (sur 1 mois) — Formation 100% en ligne sur plateforme dédiée', NULL, NULL, NULL, NULL, NULL, 'Prêt à maîtriser l\'administration sous Windows Server ?', 'Entrées ouvertes toute l\'année. Contactez nos conseillers pour élaborer votre dossier de financement et démarrer votre formation.', 'published', 86, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"RECEVOIR UNE DOCUMENTATION\"},{\"label\":\"S\'INSCRIRE\"}]}}'),
(205, 1, 13, 'Évaluation du niveau Excel — Certification TOSA', 'tosa-evaluation-niveau-excel', 'elearning', 'Avec Alt RH & formations, définissez un parcours personnalisé et préparez la certification TOSA Excel pour valider vos compétences bureautiques.', '/assets/video/formations/administration.mp4', NULL, 'E-learning', NULL, 'Certification TOSA — évaluation des compétences Excel (écosystème Microsoft Office)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation certifiante commence par une évaluation de votre niveau d\'utilisation d\'Excel : définition d\'objectifs particuliers et élaboration d\'un programme de formation personnalisé.\r\n\r\nVous prendrez vos repères dans l\'interface (ruban, barre d\'accès rapide, barre d\'état), maîtriserez les concepts de base, l\'organisation des feuilles et la conception de tableaux professionnels (formules, mise en forme, impression).\r\n\r\nLe test TOSA mesure les compétences sur les logiciels Microsoft Office (Word, Excel, PowerPoint). Les scores obtenus permettent de mesurer les progrès et l\'efficacité du parcours. Alt RH & formations vous accompagne sur le financement (CPF éligible) et la préparation aux épreuves.', '/assets/images/comptable_1.jpg', 'Parcours personnalisé — durée adaptée à votre niveau et à vos objectifs', NULL, NULL, NULL, 'Évaluation et certification TOSA', 'Le TOSA est un test standardisé qui mesure les compétences en bureautique Microsoft Office. Les scores constituent un outil précieux pour mesurer les progrès et l\'efficacité du programme.', 'Validez votre niveau Excel avec Alt RH & formations', 'Contactez nos conseillers pour un positionnement, un programme personnalisé et le montage de votre financement (CPF, OPCO, France Travail).', 'published', 87, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(206, 1, 13, 'PowerPoint basique — Certification TOSA', 'tosa-powerpoint-basique', 'elearning', 'Avec Alt RH & formations, créez des présentations professionnelles et préparez la certification TOSA PowerPoint.', '/assets/video/formations/administration.mp4', NULL, 'E-learning', NULL, 'Certification TOSA — évaluation des compétences PowerPoint (écosystème Microsoft Office)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation certifiante vous permet de concevoir des présentations PowerPoint claires et impactantes : méthode de rédaction, ligne graphique cohérente, enrichissement des diapositives et maîtrise du diaporama.\r\n\r\nVous apprendrez à structurer votre message, personnaliser thèmes et masques, intégrer visuels, tableaux et graphiques, puis animer et présenter votre diaporama avec assurance.\r\n\r\nLe test TOSA mesure les compétences sur les logiciels Microsoft Office (Word, Excel, PowerPoint). Alt RH & formations vous accompagne sur le financement (CPF éligible) et la préparation aux épreuves.', '/assets/images/comptable_1.jpg', 'Parcours certifiant — durée adaptée à votre niveau et à vos objectifs', NULL, NULL, NULL, 'Évaluation et certification TOSA', 'Le TOSA mesure les compétences en bureautique Microsoft Office. Les scores permettent de mesurer les progrès et l\'efficacité du programme.', 'Maîtrisez PowerPoint avec Alt RH & formations', 'Contactez nos conseillers pour votre parcours TOSA et le montage de votre financement (CPF, OPCO, France Travail).', 'published', 88, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}'),
(207, 1, 13, 'Personnaliser Word — Certification TOSA', 'tosa-personnaliser-word', 'elearning', 'Avec Alt RH & formations, maîtrisez Word pour des documents structurés, professionnels et certifiés TOSA.', '/assets/video/formations/administration.mp4', NULL, 'E-learning', NULL, 'Certification TOSA — évaluation des compétences Word (écosystème Microsoft Office)', NULL, NULL, 0, 0, NULL, NULL, NULL, NULL, 'Le métier', 'Cette formation certifiante vous permet de personnaliser et d\'automatiser vos documents Word : interface, styles, thèmes, modèles, structure avancée, illustrations et collaboration.\r\n\r\nVous apprendrez à construire des documents professionnels avec table des matières, numérotation des titres, tableaux, colonnes et suivi des modifications en équipe.\r\n\r\nLe test TOSA mesure les compétences sur Microsoft Office (Word, Excel, PowerPoint). Alt RH & formations vous accompagne sur le financement (CPF éligible) et la préparation aux épreuves.', '/assets/images/comptable_1.jpg', 'Parcours certifiant — durée adaptée à votre niveau et à vos objectifs', NULL, NULL, NULL, 'Évaluation et certification TOSA', 'Le TOSA mesure les compétences en bureautique Microsoft Office. Les scores permettent de mesurer les progrès et l\'efficacité du programme.', 'Maîtrisez Word avec Alt RH & formations', 'Contactez nos conseillers pour votre parcours TOSA et le montage de votre financement (CPF, OPCO, France Travail).', 'published', 89, '2026-07-27 03:20:04', '{\"ctaFinal\":{\"boutons\":[{\"label\":\"Contacter Alt RH & formations\",\"url\":\"/contact\"}]}}');

-- --------------------------------------------------------

--
-- Structure de la table `formation_course_stats`
--

CREATE TABLE `formation_course_stats` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `label` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `icon` varchar(100) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_course_stats`
--

INSERT INTO `formation_course_stats` (`id`, `course_id`, `label`, `value`, `icon`, `sort_order`) VALUES
(401, 119, 'Durée', '24 mois', NULL, 1),
(402, 119, 'Compétences clés', '+20 compétences clés', NULL, 2),
(403, 119, 'Certification', 'RNCP 37680 – Administrateur d’infrastructures sécurisées', NULL, 3),
(404, 120, 'Certification', 'Titre professionnel RNCP 37674 (niveau 5)', NULL, 1),
(405, 121, 'Durée', 'Durée', NULL, 1),
(406, 121, 'Certification', 'Titre professionnel RNCP 39111 (niveau 5)', NULL, 2),
(407, 122, 'Certification', 'Titre professionnel Concepteur·rice Développeur·euse d’Applications', NULL, 1),
(408, 123, 'Certification', 'Titre professionnel RNCP 37682 (niveau 5)', NULL, 1),
(409, 124, 'Compétences clés', '+20 compétences clés', NULL, 1),
(410, 124, 'Certification', 'Titre professionnel Lead Développeur·euse Web', NULL, 2),
(411, 125, 'Durée', '12 à 24 mois', NULL, 1),
(412, 125, 'Compétences clés', 'Recrutement, Paie, Droit', NULL, 2),
(413, 125, 'Certification', 'RNCP 41364 – Community manager', NULL, 3),
(414, 126, 'Durée', '12 mois', NULL, 1),
(415, 126, 'Compétences clés', 'Gestion administrative, Paie, Recrutement', NULL, 2),
(416, 126, 'Certification', 'Titre professionnel RNCP – niveau 5 (équivalent Bac+2)', NULL, 3),
(417, 127, 'Durée', '12 à 24 mois', NULL, 1),
(418, 127, 'Compétences clés', 'Recrutement, Paie, Droit', NULL, 2),
(419, 127, 'Certification', 'RNCP 36390 – Assistant de gestion et d’administration d’entreprise', NULL, 3),
(420, 128, 'Durée', '12 à 24 mois', NULL, 1),
(421, 128, 'Compétences clés', 'Recrutement, Paie, Droit', NULL, 2),
(422, 128, 'Certification', 'RNCP 41254 – Assistant commercial', NULL, 3),
(423, 129, 'Durée', '12 à 24 mois', NULL, 1),
(424, 129, 'Compétences clés', 'Bilan, TVA, Fiscalité', NULL, 2),
(425, 129, 'Certification', 'RNCP 36434 – Secrétaire comptable', NULL, 3),
(426, 130, 'Durée', '12 à 24 mois', NULL, 1),
(427, 130, 'Compétences clés', 'Recrutement, Paie, Droit', NULL, 2),
(428, 130, 'Certification', 'RNCP 35304 – Conseiller relation client à distance', NULL, 3),
(429, 131, 'Durée', 'Durée', NULL, 1),
(430, 131, 'Certification', 'Titre professionnel RNCP 36163 (niveau 6)', NULL, 2),
(431, 132, 'Durée', '24 mois', NULL, 1),
(432, 132, 'Compétences clés', '+20 compétences clés', NULL, 2),
(433, 132, 'Certification', 'RNCP 36061 – Administrateur système DevOps', NULL, 3),
(434, 133, 'Durée', '24 mois', NULL, 1),
(435, 133, 'Compétences clés', '+20 compétences clés', NULL, 2),
(436, 133, 'Certification', 'RNCP 39611 – Administrateur systèmes, réseaux et cybersécurité', NULL, 3),
(437, 134, 'Durée', '679 heures — 6 à 18 mois selon modalité', NULL, 1),
(438, 134, 'Stage (continue)', '140 h recommandées (non obligatoires)', NULL, 2),
(439, 134, 'Certification', 'Titre professionnel RNCP 37949 (niveau 5)', NULL, 3),
(440, 135, 'Durée', '12 à 24 mois', NULL, 1),
(441, 135, 'Compétences clés', 'Bilan, TVA, Fiscalité', NULL, 2),
(442, 135, 'Certification', 'RNCP 37121 – Comptable assistant', NULL, 3),
(443, 136, 'Certification', 'Titre professionnel RNCP 35634 – niveau 6', 'medal', 1),
(444, 136, 'Code CPF', '288395', 'trend', 2),
(445, 136, 'Salaire débutant', '32 000 – 35 000 € brut/an', 'users', 3),
(446, 137, 'Tarifs', '3 450 € à 12 314 €', NULL, 1),
(447, 137, 'Durée de l\'examen', '5h45', NULL, 2),
(448, 137, 'Certification', 'Titre professionnel RNCP 38667 (niveau 5)', NULL, 3),
(449, 138, 'Tarif de base', '9910 € (Finançable jusqu\'à 100%)', 'price', 1),
(450, 138, 'Durée estimée', '820 heures', 'clock', 2),
(451, 138, 'Accès plateforme', '12 mois', 'calendar', 3),
(452, 139, 'Durée', '672 heures de formation', NULL, 1),
(453, 139, 'Stage en entreprise', '350 heures en situation professionnelle', NULL, 2),
(454, 139, 'Certification', 'Titre professionnel RNCP 38666 (niveau 6)', NULL, 3),
(455, 140, 'Durée (continue)', '6 mois + 140 h de stage', NULL, 1),
(456, 140, 'Alternance', '12 à 24 mois (contrat pro ou apprentissage)', NULL, 2),
(457, 140, 'Certification', 'Titre professionnel RNCP 40989 (niveau 5)', NULL, 3),
(458, 141, 'Durée (continue)', '6 mois + 140 h de stage', NULL, 1),
(459, 141, 'Alternance', '12 à 24 mois (contrat pro ou apprentissage)', NULL, 2),
(460, 141, 'Certification', 'Titre professionnel RNCP 36964 (niveau 5)', NULL, 3),
(461, 142, 'Durée', '700 heures de formation', NULL, 1),
(462, 142, 'Stage (continue)', '385 heures obligatoires en structure', NULL, 2),
(463, 142, 'Certification', 'Titre professionnel RNCP 37274 (niveau 5)', NULL, 3),
(464, 143, 'Certification', 'Titre professionnel RNCP 37098 — niveau 4 (Bac)', NULL, 1),
(465, 143, 'Volume indicatif', '560 h — 2 blocs de compétences + dossier professionnel', NULL, 2),
(466, 143, 'Parcours continu', 'Environ 6 mois + 280 h de stage en entreprise', NULL, 3),
(467, 143, 'Alternance', '12 à 24 mois (contrat d’apprentissage ou de professionnalisation)', NULL, 4),
(468, 144, 'Durée', '70 heures', NULL, 1),
(469, 144, 'Niveau', 'Tous publics — sans prérequis de diplôme', NULL, 2),
(470, 144, 'Certification', 'RS 7525 — éligible CPF', NULL, 3),
(471, 145, 'Durée (continue)', '6 mois + 280 h de stage', NULL, 1),
(472, 145, 'Alternance', '12 à 24 mois (contrat pro ou apprentissage)', NULL, 2),
(473, 145, 'Certification', 'Titre professionnel RNCP 37099 (niveau 3)', NULL, 3),
(474, 146, 'Niveau', 'Titre professionnel — niveau 5 (Bac+2)', NULL, 1),
(475, 146, 'Certification', 'RNCP 39532 – Graphiste', NULL, 2),
(476, 146, 'Durée de l\'épreuve', '1 h 25', NULL, 3),
(477, 147, 'Niveau', 'Titre professionnel — niveau 5 (Bac+2)', NULL, 1),
(478, 147, 'Certification', 'RNCP 38752 — Monteur audiovisuel', NULL, 2),
(479, 147, 'Parcours type', 'BC1 + BC2 + coloration Analyste vidéo sport (100 h)', NULL, 3),
(480, 147, 'Session en cours', 'Formation mixte — août 2025 à juillet 2026', NULL, 4),
(481, 147, 'Durée de l\'épreuve', '5 h 40', NULL, 5),
(482, 148, 'Certification', 'Titre professionnel RNCP 38575 (niveau 5 · Bac+2)', NULL, 1),
(483, 148, 'Modalités possibles', 'Présentiel mixte · Visioconférence · Distanciel (e-learning), selon calendriers', NULL, 2),
(484, 148, 'Parcours', 'Formation continue environ 6 mois + 210 h de stage · alternance possible', NULL, 3),
(485, 148, 'Bloc(s)', '3 blocs de compétences + validation bloc par bloc possible', NULL, 4),
(486, 149, 'Certification', 'Titre professionnel RNCP 37948 (niveau 5)', NULL, 1),
(487, 149, 'Blocs RNCP', '2 blocs de compétences — validation bloc par bloc possible', NULL, 2),
(488, 149, 'Formation continue indicative', '~6 mois + stage conseillé 140 h (non obligatoire)', NULL, 3),
(489, 149, 'Alternance', 'En général ~12 mois (contrats 12 à 24 mois possibles)', NULL, 4),
(490, 150, 'Certification', 'Titre RNCP 40800 — niveau 4 (Bac), Ministère du Travail', NULL, 1),
(491, 150, 'Code CPF', '6650 — à confirmer sur Mon Compte Formation', NULL, 2),
(492, 150, 'Blocs RNCP', '2 blocs — capitalisation bloc par bloc possible', NULL, 3),
(493, 150, 'Formation continue indicative', '~6 mois ; MSP / stage conseillé ~126 h (non obligatoire au titre)', NULL, 4),
(494, 150, 'Alternance', 'Contrat de professionnalisation ou apprentissage 12 à 24 mois selon projet', NULL, 5),
(495, 150, 'E-learning tutoré', 'Entrées régulières ; durée indicative 6 à 18 mois selon convention', NULL, 6),
(496, 150, 'Indicateurs', 'Taux de réussite et d’emploi : consolidation en cours — votre conseiller vous communique les derniers suivis disponibles', NULL, 7),
(497, 151, 'Certification', 'Titre RNCP 41239 — niveau 4 (Bac), Ministère du Travail', NULL, 1),
(498, 151, 'Blocs RNCP', '2 blocs — validation globale ou bloc par bloc', NULL, 2),
(499, 151, 'Formation continue indicative', '~6 mois + stage conseillé ~133 h', NULL, 3),
(500, 151, 'Alternance', 'Contrat de professionnalisation ou apprentissage 12 à 24 mois', NULL, 4),
(501, 151, 'E-learning tutoré', 'Entrées régulières ; durée indicative 6 à 18 mois selon convention', NULL, 5),
(502, 151, 'Indicateurs', 'Taux de réussite et d’emploi : consolidation en cours — demandez les derniers suivis à votre conseiller', NULL, 6),
(503, 152, 'Référentiel RNCP', 'RNCP 40889 — enregistrement France Compétences au 25/06/2025', NULL, 1),
(504, 152, 'Niveau', 'Titre professionnel de niveau 6 (grade licence)', NULL, 2),
(505, 152, 'Durée indicative', '~490 h de formation (dont contraintes certificateur à respecter)', NULL, 3),
(506, 152, 'Entreprise', 'Au moins 210 h de présence en entreprise pour la certification', NULL, 4),
(507, 152, 'Blocs', '4 blocs de compétences à valider pour le titre complet', NULL, 5),
(508, 153, 'Durée', '3 jours', NULL, 1),
(509, 153, 'Modalité', 'Présentiel', NULL, 2),
(510, 153, 'Public visé', 'Professionnels IT', NULL, 3),
(511, 153, 'Tarif', '2 170 €', NULL, 4),
(512, 154, 'Durée', '2 jours', NULL, 1),
(513, 154, 'Modalité', 'Présentiel', NULL, 2),
(514, 154, 'Public visé', 'Professionnels IT', NULL, 3),
(515, 154, 'Tarif', '1 770 €', NULL, 4),
(516, 155, 'Durée', '14 h (2 jours)', NULL, 1),
(517, 155, 'Modalité', 'Classe virtuelle', NULL, 2),
(518, 155, 'Public', 'Toute personne concernée par la gestion d…', NULL, 3),
(519, 155, 'Tarif Inter', '712 € HT / pers.', NULL, 4),
(520, 156, 'Durée', '20 h', NULL, 1),
(521, 156, 'Modalité', 'Présentiel / distanciel / téléprésentiel', NULL, 2),
(522, 156, 'Public visé', 'Dev, DBA, architectes, exploitants SI', NULL, 3),
(523, 156, 'Tarif indicatif', '1 760 € HT (Inter)', NULL, 4),
(524, 157, 'Durée', '21 h', NULL, 1),
(525, 157, 'Modalité', 'Présentiel / distanciel / téléprésentiel', NULL, 2),
(526, 157, 'Public visé', 'Admin, exploitation, dev, architectes', NULL, 3),
(527, 157, 'Tarif indicatif', '1 770 € HT (Inter)', NULL, 4),
(528, 158, 'Durée', '21 h', NULL, 1),
(529, 158, 'Modalité', 'Présentiel / distanciel / téléprésentiel', NULL, 2),
(530, 158, 'Public visé', 'DSI, admins SI, ingénieurs réseaux', NULL, 3),
(531, 158, 'Tarif indicatif', '2 360 € HT (Inter)', NULL, 4),
(532, 159, 'Durée', '21 h', NULL, 1),
(533, 159, 'Modalités', 'Classe virtuelle / Présentiel', NULL, 2),
(534, 159, 'Tarif Inter', '970,02 € HT / pers. + 235 € HT cert.', NULL, 3),
(535, 160, 'Durée', '21 h', NULL, 1),
(536, 160, 'Modalités', 'Classe virtuelle / Présentiel', NULL, 2),
(537, 160, 'Tarif Inter', '960 € HT / pers. + 330 € HT cert.', NULL, 3),
(538, 161, 'Durée', '14 h (2 jours)', NULL, 1),
(539, 161, 'Modalité', 'Classe virtuelle', NULL, 2),
(540, 161, 'Tarif Inter', '642 € HT / pers. + 315 € HT cert.', NULL, 3),
(541, 162, 'Durée', '217 h', NULL, 1),
(542, 162, 'Modalité', '100 % classe virtuelle', NULL, 2),
(543, 162, 'Tarif Inter', '15 377 € HT / pers. + 370 € HT cert.', NULL, 3),
(544, 163, 'Durée', '35 h', NULL, 1),
(545, 163, 'Modalités', 'Présentiel / téléprésentiel / distanciel', NULL, 2),
(546, 163, 'Groupe', '1 à 12 stagiaires', NULL, 3),
(547, 164, 'Durée', '35 h', NULL, 1),
(548, 164, 'Modalités', 'Présentiel / téléprésentiel / distanciel', NULL, 2),
(549, 164, 'Tarif indicatif', '2 820 € HT', NULL, 3),
(550, 165, 'Durée', '1 jour (5 h à 7 h)', NULL, 1),
(551, 165, 'Modalité', 'Présentiel', NULL, 2),
(552, 165, 'Public', 'Étudiants, tout public', NULL, 3),
(553, 165, 'Tarif indicatif', '1 000 € HT (inter)', NULL, 4),
(554, 166, 'Durée', '5 jours', NULL, 1),
(555, 166, 'Modalité', 'Présentiel', NULL, 2),
(556, 166, 'Public visé', 'Développeurs, étudiants', NULL, 3),
(557, 166, 'Tarif indicatif', '3 000 € HT (inter)', NULL, 4),
(558, 167, 'Durée', '4 jours', NULL, 1),
(559, 167, 'Modalité', 'Présentiel', NULL, 2),
(560, 167, 'Public visé', 'Développeurs, chefs de projet', NULL, 3),
(561, 167, 'Tarif indicatif', '2 400 € HT (inter)', NULL, 4),
(562, 168, 'Durée', '3 jours', NULL, 1),
(563, 168, 'Modalité', 'Présentiel', NULL, 2),
(564, 168, 'Public visé', 'RSSI, DSI, consultants SSI', NULL, 3),
(565, 168, 'Tarif indicatif', '2 800 € HT (inter, certification incluse)', NULL, 4),
(566, 169, 'Durée', '3 jours', NULL, 1),
(567, 169, 'Modalité', 'Présentiel', NULL, 2),
(568, 169, 'Public visé', 'DSI, architectes IT, chefs de projet IT', NULL, 3),
(569, 169, 'Tarif indicatif', '2 500 € HT (inter, certification CTA incluse)', NULL, 4),
(570, 170, 'Durée', '5 jours', NULL, 1),
(571, 170, 'Modalité', 'Présentiel', NULL, 2),
(572, 170, 'Public visé', 'Techniciens et administrateurs systèmes e…', NULL, 3),
(573, 170, 'Tarif indicatif', '3 500 € HT (inter, certification incluse)', NULL, 4),
(574, 171, 'Durée', '2 jours', NULL, 1),
(575, 171, 'Modalité', 'Présentiel', NULL, 2),
(576, 171, 'Public visé', 'Architectes IT, resp. SI…', NULL, 3),
(577, 171, 'Tarif indicatif', '2 700 € HT (inter, certification PCSA incluse)', NULL, 4),
(578, 172, 'Durée', '2 jours', NULL, 1),
(579, 172, 'Modalité', 'Présentiel', NULL, 2),
(580, 172, 'Public visé', 'Consultants sécu., admins, développeurs', NULL, 3),
(581, 172, 'Tarif indicatif', '1 056 € HT (inter, certification incluse)', NULL, 4),
(582, 173, 'Durée', '2 jours', NULL, 1),
(583, 173, 'Modalité', 'Présentiel', NULL, 2),
(584, 173, 'Public visé', 'Profils IT, sécurité, agilité (Scrum)', NULL, 3),
(585, 173, 'Tarif indicatif', '2 000 € HT (inter, certification incluse)', NULL, 4),
(586, 174, 'Durée', '5 jours', NULL, 1),
(587, 174, 'Modalité', 'Présentiel', NULL, 2),
(588, 174, 'Public visé', 'Développeurs, ingénieurs…', NULL, 3),
(589, 174, 'Tarif indicatif', '3 000 € HT (inter)', NULL, 4),
(590, 175, 'Durée', '5 jours', NULL, 1),
(591, 175, 'Modalité', 'Présentiel', NULL, 2),
(592, 175, 'Public visé', 'Admins virtualisation, sécu. cloud…', NULL, 3),
(593, 175, 'Tarif indicatif', '2 399,20 € HT (inter, certification incluse)', NULL, 4),
(594, 176, 'Durée', '5 jours', NULL, 1),
(595, 176, 'Modalité', 'Présentiel', NULL, 2),
(596, 176, 'Public visé', 'Consultants sécu., architectes, CISO, DSI', NULL, 3),
(597, 176, 'Tarif indicatif', '3 120 € HT (inter, certification incluse)', NULL, 4),
(598, 177, 'Certification', 'Certification TOSA « Programmer et automatiser des tâches avec Python »', 'medal', 1),
(599, 177, 'Tarif de base', '1246 € (Finançable jusqu\'à 100%)', 'trend', 2),
(600, 177, 'Durée estimée', '30 heures', 'users', 3),
(601, 178, 'Tarif de base', '850 € (Finançable jusqu\'à 100%)', 'price', 1),
(602, 178, 'Durée estimée', '15 heures', 'clock', 2),
(603, 178, 'Accès plateforme', '1 mois', 'calendar', 3),
(604, 179, 'Tarif de base', '850 € (Finançable jusqu\'à 100%)', 'price', 1),
(605, 179, 'Durée estimée', '15 heures', 'clock', 2),
(606, 179, 'Accès plateforme', '1 mois', 'calendar', 3),
(607, 180, 'Tarif de base', '850 € (Finançable jusqu\'à 100%)', 'price', 1),
(608, 180, 'Durée estimée', '15 heures', 'clock', 2),
(609, 180, 'Accès plateforme', '1 mois', 'calendar', 3),
(610, 181, 'Tarif de base', '850 € (Finançable jusqu\'à 100%)', 'price', 1),
(611, 181, 'Durée estimée', '15 heures', 'clock', 2),
(612, 181, 'Accès plateforme', '1 mois', 'calendar', 3),
(613, 182, 'Tarif de base', '850 € (Finançable jusqu\'à 100%)', 'price', 1),
(614, 182, 'Durée estimée', '15 heures', 'clock', 2),
(615, 182, 'Accès plateforme', '1 mois', 'calendar', 3),
(616, 183, 'Durée', '7 heures (1 jour)', NULL, 1),
(617, 183, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(618, 183, 'Public', 'Tous profils métier', NULL, 3),
(619, 183, 'Tarif', 'Nous contacter', NULL, 4),
(620, 184, 'Durée', '2 jours (≈ 14 h)', NULL, 1),
(621, 184, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(622, 184, 'Public', 'Admins / techniciens systèmes & réseaux', NULL, 3),
(623, 184, 'Tarif indicatif', '1 590 € HT', NULL, 4),
(624, 185, 'Durée', '≈ 14 heures (2 jours intensifs)', NULL, 1),
(625, 185, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(626, 185, 'Public', 'Profils tech, produit & innovation', NULL, 3),
(627, 185, 'Tarif indicatif', '1 750 € HT', NULL, 4),
(628, 186, 'Durée', '14 heures (≈ 2 jours)', NULL, 1),
(629, 186, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(630, 186, 'Public', 'Développeur·euses web & logiciel', NULL, 3),
(631, 186, 'Tarif', 'Nous contacter', NULL, 4),
(632, 187, 'Durée', '21 heures (≈ 3 jours)', NULL, 1),
(633, 187, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(634, 187, 'Public', 'Développeur·euses, data, IT', NULL, 3),
(635, 187, 'Tarif', 'Nous contacter', NULL, 4),
(636, 188, 'Durée', '≈ 15 h 30 (2 jours)', NULL, 1),
(637, 188, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(638, 188, 'Public', 'Marketing & communication digitale', NULL, 3),
(639, 188, 'Tarif', 'Nous contacter', NULL, 4),
(640, 189, 'Durée', '≈ 35 h (5 jours)', NULL, 1),
(641, 189, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(642, 189, 'Public', 'Dev & concepteur·rice·s logiciels', NULL, 3),
(643, 189, 'Tarif', 'Nous contacter', NULL, 4),
(644, 190, 'Durée', '≈ 7 h (1 jour)', NULL, 1),
(645, 190, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(646, 190, 'Public', 'Tout public professionnel', NULL, 3),
(647, 190, 'Tarif', 'Nous contacter', NULL, 4),
(648, 191, 'Durée', '≈ 28 h (4 jours)', NULL, 1),
(649, 191, 'Modalités', 'Présentiel, téléprésentiel ou à distance', NULL, 2),
(650, 191, 'Public', 'Data science & développement', NULL, 3),
(651, 191, 'Tarif', 'Nous contacter', NULL, 4),
(652, 192, 'Durée', '4 jours', NULL, 1),
(653, 192, 'Modalité', 'E-learning', NULL, 2),
(654, 192, 'Public visé', 'Développeurs & Architectes', NULL, 3),
(655, 193, 'Durée', '2 jours', NULL, 1),
(656, 193, 'Modalité', 'E-learning', NULL, 2),
(657, 193, 'Public visé', 'Consultants, Admins & Développeurs', NULL, 3),
(658, 194, 'Durée', '5 jours', NULL, 1),
(659, 194, 'Modalité', 'E-learning', NULL, 2),
(660, 194, 'Public visé', 'Pentesters & Chercheurs en sécurité', NULL, 3),
(661, 195, 'Durée', '5 jours', NULL, 1),
(662, 195, 'Modalité', 'E-learning', NULL, 2),
(663, 195, 'Public visé', 'Professionnels Cloud, Managers & Consulta…', NULL, 3),
(664, 196, 'Durée', '2 jours', NULL, 1),
(665, 196, 'Modalité', 'E-learning', NULL, 2),
(666, 196, 'Public visé', 'Responsables webmarketing, Managers & Dir…', NULL, 3),
(667, 197, 'Durée', '5 jours', NULL, 1),
(668, 197, 'Modalité', 'E-learning', NULL, 2),
(669, 197, 'Public visé', 'Tout public & Étudiants', NULL, 3),
(670, 198, 'Durée', '3 jours', NULL, 1),
(671, 198, 'Modalité', 'E-learning', NULL, 2),
(672, 198, 'Public visé', 'Managers & Étudiants', NULL, 3),
(673, 199, 'Durée', '3 jours', NULL, 1),
(674, 199, 'Modalité', 'E-learning', NULL, 2),
(675, 199, 'Public visé', 'Dirigeants, cadres & managers', NULL, 3),
(676, 200, 'Durée', '10 jours', NULL, 1),
(677, 200, 'Modalité', 'E-learning', NULL, 2),
(678, 200, 'Public visé', 'Chefs de projet & Étudiants', NULL, 3),
(679, 201, 'Durée', '2 jours', NULL, 1),
(680, 201, 'Modalité', 'E-learning', NULL, 2),
(681, 201, 'Public visé', 'Managers & Étudiants', NULL, 3),
(682, 202, 'Durée', '2 jours', NULL, 1),
(683, 202, 'Modalité', 'E-learning', NULL, 2),
(684, 202, 'Public visé', 'Managers & Hauts potentiels', NULL, 3),
(685, 203, 'Durée', '15 heures (1 mois)', NULL, 1),
(686, 203, 'Modalité', '100% en ligne (E-learning)', NULL, 2),
(687, 203, 'Public visé', 'Professionnels du développement', NULL, 3),
(688, 204, 'Durée', '15 heures (1 mois)', NULL, 1),
(689, 204, 'Modalité', '100% en ligne (E-learning)', NULL, 2),
(690, 204, 'Public visé', 'Techniciens & Futurs administrateurs', NULL, 3),
(691, 205, 'Certification', 'TOSA Excel (Microsoft Office)', NULL, 1),
(692, 205, 'Modalité', 'E-learning', NULL, 2),
(693, 205, 'Code CPF', '135449', NULL, 3),
(694, 205, 'Public', 'Développer ou valider un niveau en bureau…', NULL, 4),
(695, 206, 'Certification', 'TOSA PowerPoint (Microsoft Office)', NULL, 1),
(696, 206, 'Modalité', 'E-learning', NULL, 2),
(697, 206, 'Code CPF', '135449', NULL, 3),
(698, 206, 'Public', 'Développer ou valider un niveau en bureau…', NULL, 4),
(699, 207, 'Certification', 'TOSA Word (Microsoft Office)', NULL, 1),
(700, 207, 'Modalité', 'E-learning', NULL, 2),
(701, 207, 'Code CPF', '135449', NULL, 3),
(702, 207, 'Public', 'Développer ou valider un niveau en bureau…', NULL, 4);

-- --------------------------------------------------------

--
-- Structure de la table `formation_info_blocks`
--

CREATE TABLE `formation_info_blocks` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `block_type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_info_blocks`
--

INSERT INTO `formation_info_blocks` (`id`, `course_id`, `block_type`, `title`, `sort_order`) VALUES
(279, 119, 'modalites', 'Modalités d\'apprentissage', 1),
(280, 119, 'prerequis', 'Public concerné & Prérequis', 2),
(281, 120, 'modalites', 'Modalités d\'apprentissage', 1),
(282, 120, 'prerequis', 'Public concerné & Prérequis', 2),
(283, 121, 'modalites', 'Modalités d\'apprentissage', 1),
(284, 121, 'prerequis', 'Public concerné & Prérequis', 2),
(285, 122, 'modalites', 'Modalités d\'apprentissage', 1),
(286, 122, 'prerequis', 'Public concerné & Prérequis', 2),
(287, 123, 'modalites', 'Modalités d\'apprentissage', 1),
(288, 123, 'prerequis', 'Public concerné & Prérequis', 2),
(289, 124, 'modalites', 'Modalités d\'apprentissage', 1),
(290, 124, 'prerequis', 'Public concerné & Prérequis', 2),
(291, 125, 'modalites', 'Modalités d\'apprentissage', 1),
(292, 125, 'prerequis', 'Public concerné & Prérequis', 2),
(293, 126, 'modalites', 'Modalités d\'apprentissage', 1),
(294, 126, 'prerequis', 'Public concerné & Prérequis', 2),
(295, 127, 'modalites', 'Modalités d\'apprentissage', 1),
(296, 127, 'prerequis', 'Public concerné & Prérequis', 2),
(297, 128, 'modalites', 'Modalités d\'apprentissage', 1),
(298, 128, 'prerequis', 'Public concerné & Prérequis', 2),
(299, 129, 'modalites', 'Modalités d\'apprentissage', 1),
(300, 129, 'prerequis', 'Public concerné & Prérequis', 2),
(301, 130, 'modalites', 'Modalités d\'apprentissage', 1),
(302, 130, 'prerequis', 'Public concerné & Prérequis', 2),
(303, 131, 'modalites', 'Modalités d\'apprentissage', 1),
(304, 131, 'prerequis', 'Public concerné & Prérequis', 2),
(305, 132, 'modalites', 'Modalités d\'apprentissage', 1),
(306, 132, 'prerequis', 'Public concerné & Prérequis', 2),
(307, 133, 'modalites', 'Modalités d\'apprentissage', 1),
(308, 133, 'prerequis', 'Public concerné & Prérequis', 2),
(309, 134, 'modalites', 'Organisation avec Alt RH & formations', 1),
(310, 134, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(311, 135, 'modalites', 'Modalités d\'apprentissage', 1),
(312, 135, 'prerequis', 'Public concerné & Prérequis', 2),
(313, 136, 'modalites', 'Modalités d\'apprentissage', 1),
(314, 136, 'prerequis', 'Public concerné & Prérequis', 2),
(315, 137, 'modalites', 'Modalités d\'apprentissage', 1),
(316, 137, 'prerequis', 'Public concerné & Prérequis', 2),
(317, 138, 'pour_qui', 'Public', 1),
(318, 139, 'modalites', 'Organisation avec Alt RH & formations', 1),
(319, 139, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(320, 140, 'modalites', 'Organisation avec Alt RH & formations', 1),
(321, 140, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(322, 141, 'modalites', 'Organisation avec Alt RH & formations', 1),
(323, 141, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(324, 142, 'modalites', 'Organisation avec Alt RH & formations', 1),
(325, 142, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(326, 143, 'modalites', 'Modalités avec Alt RH & formations', 1),
(327, 143, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(328, 144, 'modalites', 'Organisation avec Alt RH & formations', 1),
(329, 144, 'prerequis', 'Prérequis', 2),
(330, 145, 'modalites', 'Organisation avec Alt RH & formations', 1),
(331, 145, 'prerequis', 'Pour qui ? Quelles conditions d\'accès ?', 2),
(332, 146, 'modalites', 'Modalités d\'apprentissage et de certification', 1),
(333, 146, 'prerequis', 'Profil des bénéficiaires et prérequis', 2),
(334, 147, 'modalites', 'Organisation Alt RH & certification', 1),
(335, 147, 'prerequis', 'Profil attendu — prérequis', 2),
(336, 148, 'modalites', 'Modalités avec Alt RH & formations', 1),
(337, 148, 'prerequis', 'Pour qui ? Quelles conditions ?', 2),
(338, 149, 'modalites', 'Modalités, certification Qualiopi & questions fréquentes', 1),
(339, 149, 'prerequis', 'Profil conseillé & compétences transversales', 2),
(340, 150, 'modalites', 'Modalités, certification Qualiopi & FAQ fréquentes', 1),
(341, 150, 'prerequis', 'Profil conseillé & exigences du métier', 2),
(342, 151, 'modalites', 'Modalités, Qualiopi & évaluation du titre', 1),
(343, 151, 'prerequis', 'Prérequis et profil', 2),
(344, 152, 'modalites', 'Organisation, suivi et certification', 1),
(345, 152, 'prerequis', 'Profil des bénéficiaires', 2),
(346, 153, 'modalites', 'Modalités pratiques', 1),
(347, 153, 'prerequis', 'Prérequis', 2),
(348, 153, 'evaluation_etapes', 'Évaluation & Progression', 3),
(349, 154, 'modalites', 'Modalités pratiques', 1),
(350, 154, 'prerequis', 'Prérequis', 2),
(351, 154, 'evaluation_etapes', 'Évaluation & Progression', 3),
(352, 155, 'modalites', 'Modalités pratiques', 1),
(353, 155, 'prerequis', 'Prérequis', 2),
(354, 155, 'evaluation_etapes', 'Évaluation', 3),
(355, 156, 'modalites', 'Modalités pratiques', 1),
(356, 156, 'prerequis', 'Prérequis', 2),
(357, 156, 'evaluation_etapes', 'Évaluation des acquis', 3),
(358, 157, 'modalites', 'Modalités pratiques', 1),
(359, 157, 'prerequis', 'Prérequis', 2),
(360, 157, 'evaluation_etapes', 'Évaluation des acquis', 3),
(361, 158, 'modalites', 'Modalités pratiques', 1),
(362, 158, 'prerequis', 'Prérequis', 2),
(363, 158, 'evaluation_etapes', 'Évaluation des acquis', 3),
(364, 159, 'modalites', 'Modalités pratiques', 1),
(365, 159, 'prerequis', 'Prérequis', 2),
(366, 159, 'evaluation_etapes', 'Évaluation', 3),
(367, 160, 'modalites', 'Modalités pratiques', 1),
(368, 160, 'prerequis', 'Prérequis', 2),
(369, 160, 'evaluation_etapes', 'Évaluation', 3),
(370, 161, 'modalites', 'Modalités pratiques', 1),
(371, 161, 'prerequis', 'Prérequis', 2),
(372, 161, 'evaluation_etapes', 'Évaluation', 3),
(373, 162, 'modalites', 'Modalités pratiques', 1),
(374, 162, 'prerequis', 'Prérequis', 2),
(375, 162, 'evaluation_etapes', 'Évaluation des acquis', 3),
(376, 163, 'modalites', 'Modalités pratiques', 1),
(377, 163, 'prerequis', 'Prérequis', 2),
(378, 163, 'evaluation_etapes', 'Évaluation des acquis', 3),
(379, 164, 'modalites', 'Modalités pratiques', 1),
(380, 164, 'prerequis', 'Prérequis', 2),
(381, 164, 'evaluation_etapes', 'Évaluation des acquis', 3),
(382, 165, 'modalites', 'Modalités pratiques', 1),
(383, 165, 'prerequis', 'Prérequis', 2),
(384, 165, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(385, 166, 'modalites', 'Modalités pratiques', 1),
(386, 166, 'prerequis', 'Prérequis', 2),
(387, 166, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(388, 167, 'modalites', 'Modalités pratiques', 1),
(389, 167, 'prerequis', 'Prérequis', 2),
(390, 167, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(391, 168, 'modalites', 'Modalités pratiques', 1),
(392, 168, 'prerequis', 'Prérequis', 2),
(393, 168, 'evaluation_etapes', 'Évaluation des acquis', 3),
(394, 169, 'modalites', 'Modalités pratiques', 1),
(395, 169, 'prerequis', 'Prérequis', 2),
(396, 169, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(397, 170, 'modalites', 'Modalités pratiques', 1),
(398, 170, 'prerequis', 'Prérequis', 2),
(399, 170, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(400, 171, 'modalites', 'Modalités pratiques', 1),
(401, 171, 'prerequis', 'Prérequis', 2),
(402, 171, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(403, 172, 'modalites', 'Modalités pratiques', 1),
(404, 172, 'prerequis', 'Prérequis', 2),
(405, 172, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(406, 173, 'modalites', 'Modalités pratiques', 1),
(407, 173, 'prerequis', 'Prérequis', 2),
(408, 173, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(409, 174, 'modalites', 'Modalités pratiques', 1),
(410, 174, 'prerequis', 'Prérequis', 2),
(411, 174, 'evaluation_etapes', 'Évaluation de la formation et de votre progression', 3),
(412, 175, 'modalites', 'Modalités pratiques', 1),
(413, 175, 'prerequis', 'Prérequis', 2),
(414, 175, 'evaluation_etapes', 'Objectifs et évaluation', 3),
(415, 176, 'modalites', 'Modalités pratiques', 1),
(416, 176, 'prerequis', 'Prérequis', 2),
(417, 176, 'evaluation_etapes', 'Objectifs et évaluation', 3),
(418, 177, 'prerequis', 'Pr?requis', 1),
(419, 177, 'pour_qui', 'Public', 2),
(420, 178, 'pour_qui', 'Public', 1),
(421, 179, 'pour_qui', 'Public', 1),
(422, 180, 'pour_qui', 'Public', 1),
(423, 181, 'pour_qui', 'Public', 1),
(424, 182, 'pour_qui', 'Public', 1),
(425, 183, 'modalites', 'Modalités pratiques', 1),
(426, 183, 'prerequis', 'Prérequis', 2),
(427, 183, 'evaluation_etapes', 'Évaluation des acquis & certification', 3),
(428, 184, 'modalites', 'Modalités pratiques', 1),
(429, 184, 'prerequis', 'Prérequis', 2),
(430, 184, 'evaluation_etapes', 'Évaluation des acquis', 3),
(431, 185, 'modalites', 'Modalités pratiques', 1),
(432, 185, 'prerequis', 'Prérequis', 2),
(433, 185, 'evaluation_etapes', 'Évaluation des acquis', 3),
(434, 186, 'modalites', 'Modalités pratiques', 1),
(435, 186, 'prerequis', 'Prérequis', 2),
(436, 186, 'evaluation_etapes', 'Évaluation des acquis', 3),
(437, 187, 'modalites', 'Modalités pratiques', 1),
(438, 187, 'prerequis', 'Prérequis', 2),
(439, 187, 'evaluation_etapes', 'Évaluation des acquis', 3),
(440, 188, 'modalites', 'Modalités pratiques', 1),
(441, 188, 'prerequis', 'Prérequis', 2),
(442, 188, 'evaluation_etapes', 'Évaluation des acquis', 3),
(443, 189, 'modalites', 'Modalités pratiques', 1),
(444, 189, 'prerequis', 'Prérequis', 2),
(445, 189, 'evaluation_etapes', 'Évaluation des acquis', 3),
(446, 190, 'modalites', 'Modalités pratiques', 1),
(447, 190, 'prerequis', 'Prérequis', 2),
(448, 190, 'evaluation_etapes', 'Évaluation des acquis', 3),
(449, 191, 'modalites', 'Modalités pratiques', 1),
(450, 191, 'prerequis', 'Prérequis', 2),
(451, 191, 'evaluation_etapes', 'Évaluation des acquis', 3),
(452, 192, 'modalites', 'Modalités pratiques', 1),
(453, 192, 'prerequis', 'Prérequis', 2),
(454, 193, 'modalites', 'Modalités pratiques', 1),
(455, 193, 'prerequis', 'Prérequis', 2),
(456, 194, 'modalites', 'Modalités pratiques', 1),
(457, 194, 'prerequis', 'Prérequis', 2),
(458, 195, 'modalites', 'Modalités pratiques', 1),
(459, 195, 'prerequis', 'Prérequis', 2),
(460, 196, 'modalites', 'Modalités pratiques', 1),
(461, 196, 'prerequis', 'Prérequis', 2),
(462, 197, 'modalites', 'Modalités pratiques', 1),
(463, 197, 'prerequis', 'Prérequis', 2),
(464, 198, 'modalites', 'Modalités pratiques', 1),
(465, 198, 'prerequis', 'Prérequis', 2),
(466, 199, 'modalites', 'Modalités pratiques', 1),
(467, 199, 'prerequis', 'Prérequis', 2),
(468, 200, 'modalites', 'Modalités pratiques', 1),
(469, 200, 'prerequis', 'Prérequis', 2),
(470, 201, 'modalites', 'Modalités pratiques', 1),
(471, 201, 'prerequis', 'Prérequis', 2),
(472, 202, 'modalites', 'Modalités pratiques', 1),
(473, 202, 'prerequis', 'Prérequis', 2),
(474, 203, 'modalites', 'Modalités pratiques', 1),
(475, 203, 'prerequis', 'Prérequis', 2),
(476, 204, 'modalites', 'Modalités pratiques', 1),
(477, 204, 'prerequis', 'Prérequis', 2),
(478, 205, 'modalites', 'Organisation avec Alt RH & formations', 1),
(479, 205, 'prerequis', 'Prérequis', 2),
(480, 205, 'evaluation_etapes', 'Évaluation et certification TOSA', 3),
(481, 206, 'modalites', 'Organisation avec Alt RH & formations', 1),
(482, 206, 'prerequis', 'Prérequis', 2),
(483, 206, 'evaluation_etapes', 'Évaluation et certification TOSA', 3),
(484, 207, 'modalites', 'Organisation avec Alt RH & formations', 1),
(485, 207, 'prerequis', 'Prérequis', 2),
(486, 207, 'evaluation_etapes', 'Évaluation et certification TOSA', 3);

-- --------------------------------------------------------

--
-- Structure de la table `formation_info_points`
--

CREATE TABLE `formation_info_points` (
  `id` int(11) NOT NULL,
  `block_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_info_points`
--

INSERT INTO `formation_info_points` (`id`, `block_id`, `content`, `sort_order`) VALUES
(1453, 279, 'Formation accessible en formation continue ou alternance.', 1),
(1454, 279, 'Entrées possibles selon calendrier.', 2),
(1455, 279, 'Financement : CPF', 3),
(1456, 279, 'Financement : Alternance', 4),
(1457, 279, 'Financement : Financements selon situation (à étudier)', 5),
(1458, 280, 'Personnes en reconversion vers les métiers de l’IT.', 1),
(1459, 280, 'Technicien·ne·s souhaitant monter en compétences.', 2),
(1460, 280, 'Profils attirés par les systèmes, réseaux et la sécurité.', 3),
(1461, 280, 'Motivation, rigueur et intérêt pour l’informatique requis.', 4),
(1462, 281, 'Dossier de candidature', 1),
(1463, 281, 'Entretien de positionnement', 2),
(1464, 281, 'Validation du projet professionnel', 3),
(1465, 281, 'Financement : CPF', 4),
(1466, 281, 'Financement : Financement entreprise', 5),
(1467, 281, 'Financement : Dispositifs selon statut (salarié, demandeur d’emploi)', 6),
(1468, 282, 'Personnes en reconversion professionnelle', 1),
(1469, 282, 'Salarié·e·s souhaitant évoluer dans le numérique', 2),
(1470, 282, 'Demandeur·euse·s d’emploi', 3),
(1471, 282, 'Jeunes adultes attiré·e·s par les métiers du web et du mobile', 4),
(1472, 283, 'Demandeur·euse·s d’emploi', 1),
(1473, 283, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1474, 283, 'Jeunes adultes souhaitant accéder aux métiers du numérique', 3),
(1475, 283, 'Toute personne intéressée par le développement multimédia', 4),
(1476, 283, 'Financement : CPF', 5),
(1477, 283, 'Financement : Alternance', 6),
(1478, 283, 'Financement : Financements selon situation (à étudier)', 7),
(1479, 284, 'Demandeur·euse·s d’emploi', 1),
(1480, 284, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1481, 284, 'Jeunes adultes souhaitant accéder aux métiers du numérique', 3),
(1482, 284, 'Toute personne intéressée par le développement multimédia', 4),
(1483, 285, 'Étude du dossier de candidature', 1),
(1484, 285, 'Entretien de positionnement', 2),
(1485, 285, 'Validation du projet professionnel', 3),
(1486, 285, 'Financement : CPF', 4),
(1487, 285, 'Financement : Alternance', 5),
(1488, 285, 'Financement : Financement entreprise', 6),
(1489, 285, 'Financement : Dispositifs selon le statut', 7),
(1490, 286, 'Demandeur·euse·s d’emploi', 1),
(1491, 286, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1492, 286, 'Personnes souhaitant accéder aux métiers du développement applicatif', 3),
(1493, 287, 'Dossier de candidature', 1),
(1494, 287, 'Entretien de positionnement', 2),
(1495, 287, 'Validation du projet professionnel', 3),
(1496, 287, 'Financement : CPF', 4),
(1497, 287, 'Financement : Alternance', 5),
(1498, 287, 'Financement : Financement entreprise', 6),
(1499, 287, 'Financement : Dispositifs selon le statut', 7),
(1500, 288, 'Demandeur·euse·s d’emploi', 1),
(1501, 288, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1502, 288, 'Personnes souhaitant accéder aux métiers des systèmes et réseaux', 3),
(1503, 289, 'Personnes souhaitant évoluer vers des fonctions techniques avancées', 1),
(1504, 289, 'Profils attirés par le développement web et la gestion de projet', 2),
(1505, 289, 'Candidat·e·s en reconversion ou en évolution professionnelle', 3),
(1506, 289, 'Financement : Alternance', 4),
(1507, 289, 'Financement : Financements selon situation (à étudier)', 5),
(1508, 290, 'Personnes souhaitant évoluer vers des fonctions techniques avancées', 1),
(1509, 290, 'Profils attirés par le développement web et la gestion de projet', 2),
(1510, 290, 'Candidat·e·s en reconversion ou en évolution professionnelle', 3),
(1511, 291, 'Dossier de candidature', 1),
(1512, 291, 'Entretien de positionnement', 2),
(1513, 291, 'Validation du projet professionnel', 3),
(1514, 291, 'Financement : CPF', 4),
(1515, 291, 'Financement : Alternance', 5),
(1516, 291, 'Financement : Financement entreprise', 6),
(1517, 291, 'Financement : Dispositifs selon le statut', 7),
(1518, 292, 'Bac ou équivalent, goût pour les relations humaines et organisation.', 1),
(1519, 292, 'Aisance avec les outils informatiques.', 2),
(1520, 292, 'Motivation et capacité d\'adaptation.', 3),
(1521, 293, 'Formation accessible en formation continue ou alternance.', 1),
(1522, 293, 'Entrées possibles selon le calendrier.', 2),
(1523, 293, 'Financement : CPF', 3),
(1524, 293, 'Financement : Alternance ou Contrat de professionnalisation', 4),
(1525, 294, 'Titulaire d\'un diplôme de niveau Bac minimum.', 1),
(1526, 294, 'Aptitude à la communication orale et écrite.', 2),
(1527, 294, 'Rigueur, sens de la confidentialité et de l\'organisation.', 3),
(1528, 294, 'Personnes en reconversion vers les métiers administratifs et RH.', 4),
(1529, 295, 'Formation accessible en continue ou en alternance.', 1),
(1530, 295, 'Financement : CPF', 2),
(1531, 295, 'Financement : Contrat d\'apprentissage / professionnalisation', 3),
(1532, 296, 'Bac ou équivalent, goût pour les relations humaines et organisation.', 1),
(1533, 296, 'Aisance avec les outils informatiques.', 2),
(1534, 296, 'Motivation et capacité d\'adaptation.', 3),
(1535, 297, 'CPF', 1),
(1536, 297, 'Plan de développement des compétences', 2),
(1537, 297, 'Financement entreprise', 3),
(1538, 297, 'Autres dispositifs selon statut', 4),
(1539, 297, 'Financement : CPF', 5),
(1540, 297, 'Financement : Alternance', 6),
(1541, 297, 'Financement : Financements selon situation (à étudier)', 7),
(1542, 298, 'Bac ou équivalent, goût pour les relations humaines et organisation.', 1),
(1543, 298, 'Aisance avec les outils informatiques.', 2),
(1544, 298, 'Motivation et capacité d\'adaptation.', 3),
(1545, 299, 'Formation en alternance ou en initiale.', 1),
(1546, 299, 'Financement : CPF', 2),
(1547, 299, 'Dispositifs Pôle Emploi ou OPCO', 3),
(1548, 300, 'Bac ou équivalent, rigueur et goût pour les chiffres.', 1),
(1549, 300, 'Aisance avec les outils informatiques.', 2),
(1550, 300, 'Motivation et capacité d\'adaptation.', 3),
(1551, 301, 'Formation continue ou en alternance.', 1),
(1552, 301, 'Financement : CPF', 2),
(1553, 301, 'Financement entreprise ou Pôle Emploi', 3),
(1554, 302, 'Bac ou équivalent, goût pour les relations humaines et organisation.', 1),
(1555, 302, 'Aisance avec les outils informatiques.', 2),
(1556, 302, 'Motivation et capacité d\'adaptation.', 3),
(1557, 303, 'Demandeur·euse·s d’emploi', 1),
(1558, 303, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1559, 303, 'Jeunes souhaitant accéder aux métiers du numérique', 3),
(1560, 303, 'Toute personne intéressée par les métiers des réseaux informatiques', 4),
(1561, 303, 'Financement : CPF', 5),
(1562, 303, 'Financement : Alternance', 6),
(1563, 303, 'Financement : Financement Pôle emploi selon situation', 7),
(1564, 303, 'Financement : Financement entreprise', 8),
(1565, 304, 'Demandeur·euse·s d’emploi', 1),
(1566, 304, 'Salarié·e·s en reconversion ou évolution professionnelle', 2),
(1567, 304, 'Jeunes souhaitant accéder aux métiers du numérique', 3),
(1568, 304, 'Toute personne souhaitant se spécialiser dans l’administration réseau', 4),
(1569, 305, 'Formation accessible en formation continue ou alternance.', 1),
(1570, 305, 'Entrées possibles selon calendrier.', 2),
(1571, 305, 'Financement : CPF', 3),
(1572, 305, 'Financement : Alternance', 4),
(1573, 305, 'Financement : Financements selon situation (à étudier)', 5),
(1574, 306, 'Personnes en reconversion vers les métiers de l’IT.', 1),
(1575, 306, 'Technicien·ne·s souhaitant monter en compétences.', 2),
(1576, 306, 'Profils attirés par les systèmes, réseaux et la sécurité.', 3),
(1577, 306, 'Motivation, rigueur et intérêt pour l’informatique requis.', 4),
(1578, 307, 'Formation accessible en formation continue ou alternance.', 1),
(1579, 307, 'Entrées possibles selon calendrier.', 2),
(1580, 307, 'Financement : CPF', 3),
(1581, 307, 'Financement : Alternance', 4),
(1582, 307, 'Financement : Financements selon situation (à étudier)', 5),
(1583, 308, 'Personnes en reconversion vers les métiers de l’IT.', 1),
(1584, 308, 'Technicien·ne·s souhaitant monter en compétences.', 2),
(1585, 308, 'Profils attirés par les systèmes, réseaux et la sécurité.', 3),
(1586, 308, 'Motivation, rigueur et intérêt pour l’informatique requis.', 4),
(1587, 309, 'Présentiel mixte — rentrées mars & sept. (centre + visio)', 1),
(1588, 309, '100 % visioconférence — rentrées de mars et septembre', 2),
(1589, 309, '100 % e-learning — 7 rentrées / an, entrée tous les 2 mois, 6 à 18 mois', 3),
(1590, 309, 'Alternance : 12 à 24 mois (contrat de professionnalisation ou apprentis…', 4),
(1591, 309, 'Formation continue : 6 mois intensifs + 140 h de stage en entreprise (f…', 5),
(1592, 309, 'Prochaines sessions : du 15/06/2026 ou du 14/09/2026 au 26/02/2027', 6),
(1593, 309, 'Examen de certification en présentiel obligatoire (lieu selon votre ses…', 7),
(1594, 309, 'Accompagnement personnalisé Alt RH & formations : projet…', 8),
(1595, 309, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 9),
(1596, 309, 'Évaluation : mise en situation, dossier professionnel…', 10),
(1597, 309, 'Financement demandeur d\'emploi : AIF, Conseil régional, CPF…', 11),
(1598, 309, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 12),
(1599, 309, 'Financement entreprise : OPCO, alternance (apprentissage / professionna…', 13),
(1600, 310, 'Niveau Bac (général, technologique ou professionnel comptabilité) ou ex…', 1),
(1601, 310, 'Passage d\'un test de capacité d\'apprentissage avec Alt RH & formations', 2),
(1602, 310, 'Rigueur, sens de l\'organisation et appétence pour les chiffres et les o…', 3),
(1603, 310, 'Titre professionnel RNCP n° 37949 – niveau 5 (Bac+2)…', 4),
(1604, 311, 'Formation initiale ou en contrat d\'alternance.', 1),
(1605, 311, 'Financement : CPF', 2),
(1606, 311, 'Financement : Pôle Emploi', 3),
(1607, 312, 'Bac ou équivalent, rigueur et goût pour les chiffres.', 1),
(1608, 312, 'Aisance avec les outils informatiques.', 2),
(1609, 312, 'Motivation et capacité d\'adaptation.', 3),
(1610, 313, 'Formation accessible en formation continue ou alternance.', 1),
(1611, 313, 'Entrées possibles selon calendrier.', 2),
(1612, 313, 'Financement : CPF (Code 288395)', 3),
(1613, 313, 'Financement : Alternance', 4),
(1614, 313, 'Financement : Dispositifs selon situation (à étudier)', 5),
(1615, 314, 'Personnes en reconversion vers les métiers du design numérique.', 1),
(1616, 314, 'Profils créatifs souhaitant structurer leurs compétences graphiques et…', 2),
(1617, 314, 'Intérêt pour les interfaces numériques, l\'UX/UI et les outils web.', 3),
(1618, 314, 'Motivation, curiosité et sens esthétique requis.', 4),
(1619, 315, 'Formations mixtes : en présentiel ou en distanciel (sur Zoom).', 1),
(1620, 315, 'Méthode d\'apprentissage : démonstrative, interrogative…', 2),
(1621, 315, 'Ateliers de simulation d\'entretien et accompagnement post-formation pen…', 3),
(1622, 315, 'Financement : CPF, Contrat de Professionnalisation (CP).', 4),
(1623, 315, 'Financement : France Travail, PSE, PDV ou CSP.', 5),
(1624, 316, 'Tout Public (salarié·e·s, demandeur·euse·s d\'emploi…', 1),
(1625, 316, 'Connaissances de l\'outil informatique et du français obligatoire.', 2),
(1626, 316, 'Connaissances en anglais niveau intermédiaire fortement conseillées.', 3),
(1627, 316, 'Locaux accessibles aux personnes handicapées (Franconville…', 4),
(1628, 317, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"Professionnel·le·s de l’informatique ou du numérique souhaitant accéder à des fonctions à haute responsabilité dans la conception, le développement et le pilotage de projets logiciels complexes.\"]}', 1),
(1629, 318, 'Formation 100 % e-learning, avec sessions d\'entrée en janvier, février…', 1),
(1630, 318, 'Parcours en formation continue avec 350 h de stage en entreprise', 2),
(1631, 318, 'Prochaines sessions : du 13/04/2026, du 15/06/2026 ou du 14/09/2026 au…', 3),
(1632, 318, 'Accompagnement personnalisé par un·e conseiller·ère Alt RH & formations…', 4),
(1633, 318, 'Organisme certifié Qualiopi – centre accessible aux personnes en situat…', 5),
(1634, 318, 'Financement demandeur d\'emploi : AIF (France Travail), Conseil régional…', 6),
(1635, 318, 'Financement salarié : Projet de Transition Professionnelle, Pro-A…', 7),
(1636, 318, 'Financement entreprise : OPCO, alternance (apprentissage ou professionn…', 8),
(1637, 318, 'Évaluation : mise en situation, dossier professionnel…', 9),
(1638, 319, 'Titulaires d\'un Bac+2 ou profils justifiant d\'une expérience profession…', 1),
(1639, 319, 'Test de positionnement pédagogique réalisé avec Alt RH & formations ava…', 2),
(1640, 319, 'Salarié·e·s, demandeur·euse·s d\'emploi, entrepreneurs : un conseiller é…', 3),
(1641, 319, 'Titre professionnel inscrit au RNCP n° 38666 – diplôme du Ministère du…', 4),
(1642, 320, 'Présentiel mixte — rentrées de mars et septembre', 1),
(1643, 320, 'Visioconférence — rentrées de mars et septembre', 2),
(1644, 320, 'E-learning — rentrées en janvier, février, mars, avril, juin…', 3),
(1645, 320, 'Alternance possible sur toutes les rentrées (contrat de professionnalis…', 4),
(1646, 320, 'Formation continue : 6 mois de cours + 140 h de stage en entreprise', 5),
(1647, 320, 'Examen de certification en présentiel obligatoire (centres et partenair…', 6),
(1648, 320, 'Accompagnement personnalisé Alt RH & formations : projet…', 7),
(1649, 320, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 8),
(1650, 320, 'Évaluation : mise en situation, dossier professionnel…', 9),
(1651, 320, 'Financement : CPF, OPCO, France Travail (AIF), plan de développement…', 10),
(1652, 321, 'Niveau Bac ou équivalent, ou expérience professionnelle significative', 1),
(1653, 321, 'Profils en reconversion, jeunes diplômé·e·s ou salarié·e·s souhaitant é…', 2),
(1654, 321, 'Motivation pour les métiers administratifs et relationnels du secteur', 3),
(1655, 321, 'Titre professionnel RNCP n° 40989 – niveau 5 européen (Bac+2)…', 4),
(1656, 322, 'Présentiel mixte — rentrées de mars et septembre', 1),
(1657, 322, 'Visioconférence — rentrées de mars et septembre', 2),
(1658, 322, 'E-learning — rentrées en janvier, février, mars, avril, juin…', 3),
(1659, 322, 'Alternance possible sur toutes les rentrées (contrat de professionnalis…', 4),
(1660, 322, 'Formation continue : 6 mois de cours + 140 h de stage en entreprise', 5),
(1661, 322, 'Examen de certification en présentiel obligatoire (lieu selon votre ses…', 6),
(1662, 322, 'Accompagnement personnalisé Alt RH & formations : projet…', 7),
(1663, 322, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 8),
(1664, 322, 'Évaluation : mise en situation, dossier professionnel…', 9),
(1665, 322, 'Financement : CPF (code 245783), OPCO, France Travail (AIF)…', 10),
(1666, 323, 'Niveau Bac ou équivalent, ou expérience professionnelle significative', 1),
(1667, 323, 'Aisance ou motivation pour travailler en français et en anglais', 2),
(1668, 323, 'Profils en reconversion, jeunes diplômé·e·s ou salarié·e·s visant le co…', 3),
(1669, 323, 'Titre professionnel RNCP n° 36964 – niveau 5 (Bac+2)…', 4),
(1670, 324, 'Présentiel mixte — rentrées de mars et septembre', 1),
(1671, 324, 'Visioconférence — rentrées de mars et septembre', 2),
(1672, 324, 'E-learning — rentrées en janvier, février, mars, avril, juin…', 3),
(1673, 324, 'Alternance possible sur toutes les rentrées (contrat de professionnalis…', 4),
(1674, 324, 'Formation continue : 8 mois + 385 h de stage obligatoire en structure d…', 5),
(1675, 324, 'Prochaines sessions : du 13/04/2026, du 15/06/2026 ou du 14/09/2026 au…', 6),
(1676, 324, 'Examen de certification en présentiel obligatoire (lieu selon votre ses…', 7),
(1677, 324, 'Accompagnement personnalisé Alt RH & formations : projet…', 8),
(1678, 324, 'Organisme certifié Qualiopi — centre accessible aux personnes en situat…', 9),
(1679, 324, 'Évaluation : mise en situation, dossier professionnel…', 10),
(1680, 324, 'Financement demandeur d\'emploi : AIF, Conseil régional, CPF…', 11),
(1681, 324, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 12),
(1682, 324, 'Financement entreprise : OPCO, alternance (apprentissage / professionna…', 13),
(1683, 325, 'Niveau Bac ou équivalent, ou expérience professionnelle significative', 1),
(1684, 325, 'Sens de l\'écoute, intérêt pour l\'accompagnement et les politiques d\'ins…', 2),
(1685, 325, 'Profils en reconversion vers l\'emploi accompagné, le social ou l\'ESS', 3),
(1686, 325, 'Titre professionnel RNCP n° 37274 – niveau 5 (Bac+2)…', 4),
(1687, 326, 'Trois grands modes d’organisation peuvent être proposés : présentiel mi…', 1),
(1688, 326, 'L’alternance reste envisageable sur les principales rentrées lorsque vo…', 2),
(1689, 326, 'Parcours en formation continue : durée indicative d’environ six mois pl…', 3),
(1690, 326, 'Évaluation par jury : les compétences sont jugées sur la base d’une mis…', 4),
(1691, 326, 'Validation du titre : indépendamment de la modalité pédagogique suivie…', 5),
(1692, 326, 'Accompagnement personnalisé : projet, financement et suivi pédagogique…', 6),
(1693, 326, 'Démarche qualité Qualiopi : les process sont alignés sur le référentiel…', 7),
(1694, 326, 'Accessibilité : parcours ouvrables aux personnes en situation de handic…', 8),
(1695, 326, 'Financements possibles selon votre statut : CPF avec éventuels cofinanc…', 9),
(1696, 327, 'Niveau CAP ou BEP, ou expériences professionnelles mobilisables en vent…', 1),
(1697, 327, 'Un test ou entretien de positionnement peut être proposé en amont lorsq…', 2),
(1698, 327, 'Goût du contact client, dynamisme et aisance relationnelle', 3),
(1699, 327, 'Profils jeunes, en reconversion ou salarié·e·s visant métiers de vente…', 4),
(1700, 327, 'Titre professionnel RNCP 37098 — niveau 4 (Bac)…', 5),
(1701, 328, 'Formation — 70 heures', 1),
(1702, 328, 'Formats possibles : présentiel à Lyon, visioconférence (selon sessions)', 2),
(1703, 328, 'Public : tous publics, sans niveau spécifique requis', 3),
(1704, 328, 'Tarif indicatif : 1 480 € (selon modalité pédagogique)', 4),
(1705, 328, 'Référence certification : RS 7525', 5),
(1706, 328, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 6),
(1707, 328, 'Accompagnement au montage du dossier de financement', 7),
(1708, 328, 'Financement demandeur d\'emploi : AIF, Conseil régional, CPF…', 8),
(1709, 328, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 9),
(1710, 328, 'Financement entreprise : OPCO', 10),
(1711, 329, 'Aucun diplôme requis — formation ouverte à tous les publics', 1),
(1712, 329, 'Savoir utiliser un ordinateur et naviguer sur internet', 2),
(1713, 329, 'Motivation pour créer et administrer un site web', 3),
(1714, 330, 'Présentiel mixte — rentrées de mars et septembre', 1),
(1715, 330, 'Visioconférence — rentrées de mars et septembre', 2),
(1716, 330, 'E-learning — rentrées en janvier, février, mars, avril, juin…', 3),
(1717, 330, 'Alternance possible sur toutes les rentrées (contrat de professionnalis…', 4),
(1718, 330, 'Formation continue : 6 mois + 280 h de stage en entreprise', 5),
(1719, 330, 'Examen de certification en présentiel obligatoire (lieu selon votre ses…', 6),
(1720, 330, 'Accompagnement personnalisé Alt RH & formations : projet…', 7),
(1721, 330, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 8),
(1722, 330, 'Évaluation : mise en situation, dossier professionnel…', 9),
(1723, 330, 'Financement : CPF, OPCO, France Travail (AIF), plan de développement…', 10),
(1724, 331, 'Niveau 3ème ou équivalent, ou expérience professionnelle significative', 1),
(1725, 331, 'Motivation pour le contact client et le travail en magasin', 2),
(1726, 331, 'Profils jeunes, en reconversion ou salarié·e·s souhaitant entrer dans l…', 3),
(1727, 331, 'Titre professionnel RNCP n° 37099 – niveau 3 (CAP/BEP)…', 4),
(1728, 332, 'Formation accessible en formation continue ou alternance.', 1),
(1729, 332, 'Modalité d\'obtention : avoir validé tous les blocs de compétences.', 2),
(1730, 332, 'Présentation d\'un projet réalisé en amont de la session (50 min) : comm…', 3),
(1731, 332, 'Préparation de la présentation : 10 min — présentation projet print (30…', 4),
(1732, 332, 'Entretien technique : 20 min — à l\'issue de la présentation du projet.', 5),
(1733, 332, 'Entretien final : 15 min — dont échange sur le dossier professionnel.', 6),
(1734, 332, 'Durée totale de l\'épreuve pour le candidat : 1 h 25.', 7),
(1735, 332, 'Équipe pédagogique pluridisciplinaire (formateurs expérimentés et inter…', 8),
(1736, 332, 'Ressources : extranet dédié, supports en ligne après la formation…', 9),
(1737, 332, 'Formations accessibles aux personnes en situation de handicap — référen…', 10),
(1738, 332, 'Financement : CPF, alternance, dispositifs selon situation (à étudier).', 11),
(1739, 333, 'Demandeurs d\'emploi, salarié·e·s, jeunes de moins de 29 ans…', 1),
(1740, 333, 'Avoir entre 16 et 29 ans révolus.', 2),
(1741, 333, 'Être titulaire du baccalauréat ou d\'un diplôme/titre équivalent.', 3),
(1742, 333, 'Motivation pour la création visuelle et la communication.', 4),
(1743, 334, 'Formation mixte : session calée d’août 2025 à juillet 2026 (rythme comm…', 1),
(1744, 334, 'Obtention par certification du Ministère du Travail — possibilité de va…', 2),
(1745, 334, 'Délai d’accès : 4 semaines (référentiel certificateur ministériel — pré…', 3),
(1746, 334, 'Mise en situation professionnelle (4 h max) — consigne écrite de portra…', 4),
(1747, 334, 'Entretien technique (40 min au total pour le jury) — 10 min : vous prés…', 5),
(1748, 334, 'Questionnement sur productions (40 min) — quatre exports PAD attendus a…', 6),
(1749, 334, 'Entretien final (20 min) — temps d’échange dossier professionnel + véri…', 7),
(1750, 334, 'Durée cumulée de l’épreuve pour le candidat : 5 h 40.', 8),
(1751, 334, 'Suivi pédagogique : feuilles de présence, évaluations formatives orales…', 9),
(1752, 334, 'Équipe pluridisciplinaire : formateurs terrain et intervenants pros ; r…', 10),
(1753, 334, 'Ressources : extranet dédié, supports PDF/vidéo et prolongements post-f…', 11),
(1754, 334, 'Accessibilité handicap : parcours ouvrables sous aménagement raisonnabl…', 12),
(1755, 334, 'Financement étudié dossier par dossier (CPF, employeur / OPCO…', 13),
(1756, 335, 'Publics habituels : demandeurs d’emploi, salarié·e·s…', 1),
(1757, 335, 'Diplôme ou niveau assimilé au baccalauréat général professionnel ou tec…', 2),
(1758, 335, 'Âge légal minimal 16 ans à l’entrée.', 3),
(1759, 335, 'Appétence forte pour narration image/son, régularité personnelle aux tr…', 4),
(1760, 336, 'Possibilités de mise en œuvre : présentiel en centre lorsque nous plani…', 1),
(1761, 336, 'Le titre reste aussi accessible sous contrat d’alternance lorsque nous…', 2),
(1762, 336, 'Vous pouvez choisir de valider tout le titre ou seulement un ou plusieu…', 3),
(1763, 336, 'La certification nationale exige généralement un passage physique devan…', 4),
(1764, 336, 'Évaluation : dossier décrivant les pratiques professionnelles complété…', 5),
(1765, 336, 'Organisme visant la certification Qualiopi — équipe handicap à votre di…', 6),
(1766, 336, 'Financement : nous vous aidons dans la lecture des dispositifs mobilisa…', 7),
(1767, 336, 'Pour en savoir plus : téléphone Alt RH au 01 60 43 94 32 et e-mail form…', 8),
(1768, 337, 'Niveau Bac ou équivalent et/ou plusieurs années d’expérience profession…', 1),
(1769, 337, 'Profils en montée en responsabilité vers des fonctions de direction opé…', 2),
(1770, 337, 'Autonomie sur les usages numériques et le français tant à l’oral qu’à l…', 3),
(1771, 337, 'Public large : tout type et toute taille d’organisation d’origine — ent…', 4),
(1772, 338, 'Vous préparez le titre professionnel « Gestionnaire de paie » (RNCP 379…', 1),
(1773, 338, 'Référentiel Qualiopi : Alt RH engage une gestion formalisée de la forma…', 2),
(1774, 338, 'Modalités : présentiel mixte, visioconférence en direct ou apprentissag…', 3),
(1775, 338, 'Conditions d’accès : bac ou équivalent ou expérience professionnelle si…', 4),
(1776, 338, 'Stage en formation hors alternance : non obligatoire au titre officiel…', 5),
(1777, 338, 'Équipes : consultants en droit social, intervenants issus du terrain (e…', 6),
(1778, 338, 'Examen : quel que soit le format du parcours…', 7),
(1779, 338, 'Handicap ou contraintes particulières : contact préalable conseillé Alt…', 8),
(1780, 338, 'Financement : CPF (contrôler code et abondements sur moncompteformation…', 9),
(1781, 339, 'Sens du secret professionnel très élevé (données salariales sensibles).', 1),
(1782, 339, 'Bonne aptitude au raisonnement chiffré : tableurs maîtrisés ou applicat…', 2),
(1783, 339, 'Curiosité pour la veille réglementaire : barèmes et accords peuvent êtr…', 3),
(1784, 339, 'Sens du service : vulgariser une fiche de paie complexe tout en gardant…', 4),
(1785, 340, 'Certification : cette formation prépare au titre professionnel « Secrét…', 1),
(1786, 340, 'Construire votre parcours : plusieurs modalités — présentiel mixte (cou…', 2),
(1787, 340, 'Présentiel mixte : vous combinez présence en centre et séances à distan…', 3),
(1788, 340, '100 % visioconférence : tous les cours à distance en synchrone ; intera…', 4),
(1789, 340, 'E‑learning tutoré : apprentissage en ligne avec ressources interactives…', 5),
(1790, 340, 'Prérequis : niveau CAP/BEP ou expérience professionnelle mobilisable ;…', 6),
(1791, 340, 'Équipe pédagogique : consultants experts, intervenants issus des struct…', 7),
(1792, 340, 'MSP et stages : la formation peut inclure des mises en situation profes…', 8),
(1793, 340, 'Évaluation : quelle que soit la modalité pédagogique…', 9),
(1794, 340, 'Accessibilité : étude des besoins pour les personnes en situation de ha…', 10),
(1795, 340, 'Financement : France Travail (AIF), Conseil régional…', 11),
(1796, 340, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com — n…', 12),
(1797, 341, 'Respect strict du secret médical et du cadre légal sur les données de s…', 1),
(1798, 341, 'Rigueur dans la mise à jour des dossiers administratifs et médicaux.', 2),
(1799, 341, 'Aisance relationnelle avec les patient·es et les équipes soignantes.', 3),
(1800, 341, 'Capacité à prioriser et à gérer plusieurs tâches (accueil, planning…', 4),
(1801, 341, 'Bon niveau sur les outils bureautiques et volonté de maintenir une docu…', 5),
(1802, 342, 'Modalités proposées : présentiel mixte (rentrées types mars et septembr…', 1),
(1803, 342, 'Découvrir nos modalités détaillées : votre conseiller Alt RH vous envoi…', 2),
(1804, 342, 'Évaluation du titre : les compétences sont jugées par un jury au vu d’u…', 3),
(1805, 342, 'Examen en présentiel : quelle que soit la modalité pédagogique suivie…', 4),
(1806, 342, 'Plateforme e‑learning : accès aux ressources numériques…', 5),
(1807, 342, 'Pourquoi Alt RH & formations : organismes sous certification Qualiopi l…', 6),
(1808, 342, 'Accessibilité : études des besoins pour les personnes en situation de h…', 7),
(1809, 342, 'Centres et territorialité : nos implantations et partenaires vous sont…', 8),
(1810, 342, 'Financement : France Travail (AIF), Conseil régional…', 9),
(1811, 342, '*Tarifs selon modalités pédagogiques et conventionnement — montants com…', 10),
(1812, 343, 'Niveau CAP/BEP ou expérience professionnelle mobilisable vers les fonct…', 1),
(1813, 343, 'Passage d’un test de positionnement ou entretien pour valider la capaci…', 2),
(1814, 343, 'Aisances relationnelles et rédactionnelles pour traiter simultanément f…', 3),
(1815, 343, 'Bon usage des outils bureautiques et messagerie ; rigueur dans le class…', 4),
(1816, 344, 'Publics visés : demandeurs et demandeuses d’emploi, salarié·e·s…', 1),
(1817, 344, 'Équipe pédagogique pluridisciplinaire : formateurs expérimentés et inte…', 2),
(1818, 344, 'Suivi de l’exécution : feuilles de présence…', 3),
(1819, 344, 'Ressources : extranet ou espace dédié à la formation ; mise à dispositi…', 4),
(1820, 344, 'Mises en situations professionnelles et travaux de mise en application…', 5),
(1821, 344, 'Modalités d’obtention du titre (éléments types selon référentiel et jur…', 6),
(1822, 344, 'Contrôles continus, mises en situation professionnelle reconstituée…', 7),
(1823, 344, 'Les jurys et modalités définitives sont ceux du certificateur agréé et…', 8),
(1824, 344, 'Accessibilité : formations ouvrables aux personnes en situation de hand…', 9),
(1825, 344, 'Financement : CPF, France Travail, régions, employeurs / OPCO…', 10),
(1826, 345, 'Motivation pour les fonctions commerciales…', 1),
(1827, 345, 'Aisance avec les outils numériques et les environnements hybrides (prés…', 2),
(1828, 345, 'Capacité à analyser des données marché et à communiquer avec des partie…', 3),
(1829, 345, 'Expérience professionnelle préalable appréciable pour contextualiser le…', 4),
(1830, 346, 'Durée : 3 jours', 1),
(1831, 346, 'Format : Présentiel', 2),
(1832, 346, 'Tarif standard : 2 170 €', 3),
(1833, 346, 'Prix avec certification : 2 170 €', 4),
(1834, 346, 'Public visé : professionnels IT et services numériques', 5),
(1835, 346, 'Disponible en Inter-Entreprise et Intra-Entreprise', 6),
(1836, 346, 'Formation disponible sur demande', 7),
(1837, 346, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 8),
(1838, 346, 'Lieux : Bailly-Romainvilliers & Serris (77)', 9),
(1839, 346, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 10),
(1840, 346, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 11),
(1841, 347, 'Aucune connaissance particulière requise.', 1),
(1842, 347, 'Notions Agile, Scrum, Lean et ITSM appréciées.', 2),
(1843, 348, 'Avant la session : cadrage de vos objectifs et auto-positionnement sur les thématiques.', 1),
(1844, 348, 'Pendant la session : points de reprise avec le formateur sur forces et axes de progrès.', 2),
(1845, 348, 'En fin de parcours : validation par QCM et/ou ateliers selon le dispositif retenu.', 3),
(1846, 348, 'Questionnaire de satisfaction à chaud.', 4),
(1847, 348, 'À distance dans le temps : possibilité de bilan à froid pour mesurer l’impact en entreprise.', 5),
(1848, 349, 'Durée : 2 jours', 1),
(1849, 349, 'Format : Présentiel', 2),
(1850, 349, 'Tarif standard : 1 770 €', 3),
(1851, 349, 'Public visé : Toute personne voulant faire carrière en DevOps', 4),
(1852, 349, 'Disponible en Inter-Entreprise et Intra-Entreprise', 5),
(1853, 349, 'Formation disponible sur demande', 6),
(1854, 349, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 7),
(1855, 349, 'Lieux : Bailly-Romainvilliers & Serris (77)', 8),
(1856, 349, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 9),
(1857, 349, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 10),
(1858, 350, 'Connaissance des services IT.', 1),
(1859, 350, 'Capacité de communiquer.', 2),
(1860, 351, 'Avant la session : cadrage de vos objectifs et auto-positionnement sur les thématiques.', 1),
(1861, 351, 'Pendant la session : points de reprise avec le formateur sur forces et axes de progrès.', 2),
(1862, 351, 'En fin de parcours : validation par QCM et/ou ateliers selon le dispositif retenu.', 3),
(1863, 351, 'Questionnaire de satisfaction à chaud.', 4),
(1864, 351, 'À distance dans le temps : possibilité de bilan à froid pour mesurer l’impact en entreprise.', 5),
(1865, 352, 'Durée : 14 heures sur 2 jours', 1),
(1866, 352, 'Format : classe virtuelle (distanciel synchrone, visioconférence)', 2),
(1867, 352, 'Inter-entreprises : 712 € HT / personne (certification obligatoire incl…', 3),
(1868, 352, 'Intra-entreprise : 3 970 € HT / groupe (minimum 4 stagiaires…', 4),
(1869, 352, 'Référence indicative : ISO/IEC 27035 Foundation — préparation PECB', 5),
(1870, 352, 'Sessions : calendrier inter/intra sur demande', 6),
(1871, 352, 'Les dispositifs mobilisables varient selon les profils — nous examinons…', 7),
(1872, 352, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 8),
(1873, 352, 'Lieux : Bailly-Romainvilliers & Serris (77)', 9),
(1874, 352, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 10),
(1875, 352, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 11),
(1876, 353, 'Aucun prérequis technique obligatoire pour suivre la formation Foundati…', 1),
(1877, 353, 'Une première exposition aux concepts de sécurité de l\'information ou au…', 2),
(1878, 354, 'Questionnaires d’auto-évaluation pour cadrer vos acquis.', 1),
(1879, 354, 'Attestation de compétences et attestation de fin de parcours selon le déroulé.', 2),
(1880, 354, 'Accompagnement vers l’examen PECB ISO/IEC 27035 Foundation.', 3),
(1881, 355, 'Durée : 20 heures', 1),
(1882, 355, 'Tarif indicatif Inter : 1 760 € HT à distance (contactez-nous pour prés…', 2),
(1883, 355, 'Effectifs : sessions de 1 à 12 stagiaires (effectif moyen favorable au…', 3),
(1884, 355, 'Modalités possibles : présentiel en salle…', 4),
(1885, 355, 'Support : poste de travail adapté, supports et manuel numérique ou papi…', 5),
(1886, 355, 'Inscriptions : jusqu\'à 48 h avant le début en général ; financement CPF…', 6),
(1887, 355, 'Sessions indicatives : juin, septembre, octobre…', 7),
(1888, 355, 'CPF et certification RS7205 : dates d’examen et formalités détaillées a…', 8),
(1889, 355, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 9),
(1890, 355, 'Lieux : Bailly-Romainvilliers & Serris (77)', 10),
(1891, 355, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 11),
(1892, 355, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 12),
(1893, 356, 'Maîtriser l\'outil informatique.', 1),
(1894, 356, 'Savoir exploiter et organiser des données dans l\'entreprise.', 2),
(1895, 357, 'Auto-évaluation en amont et en fin de parcours pour cadrer la progression.', 1),
(1896, 357, 'Retours du formateur (non évalué → acquis) via QCM, exercices, quiz et mises en situation.', 2),
(1897, 357, 'Préparation aux modalités de certification RS7205 lorsque vous vous engagez sur ce parcours ; rappel des obligations CPF si elles s’appliquent.', 3),
(1898, 357, 'Feuille de présence, questionnaire de satisfaction et attestation de fin de formation.', 4),
(1899, 358, 'Durée : 21 heures', 1),
(1900, 358, 'Tarif indicatif Inter : 1 770 € HT à distance (devis pour présentiel et…', 2),
(1901, 358, 'Effectifs : 1 à 12 stagiaires par session (effectif moyen orienté accom…', 3),
(1902, 358, 'Formats : présentiel en salle, salle immersive / téléprésentiel…', 4),
(1903, 358, 'Supports : poste adapté, cours et manuel numérique ou papier selon sess…', 5),
(1904, 358, 'Inscriptions : jusqu\'à 48 h avant le démarrage en général ; financement…', 6),
(1905, 358, 'Sessions indicatives : juin, octobre, décembre — à distance ou villes p…', 7),
(1906, 358, 'Certification RS6425 : calendrier d’examen et formalités précisés lors…', 8),
(1907, 358, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 9),
(1908, 358, 'Lieux : Bailly-Romainvilliers & Serris (77)', 10),
(1909, 358, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 11),
(1910, 358, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 12),
(1911, 359, 'Exploiter un système Linux ou Windows.', 1),
(1912, 359, 'Connaître les bases des réseaux TCP/IP.', 2),
(1913, 359, 'Utiliser la ligne de commande et les scripts Shell sous Linux.', 3),
(1914, 360, 'Auto-évaluation en début et en fin de parcours pour objectiver vos progrès.', 1),
(1915, 360, 'Retour du formateur (non évalué à acquis) via QCM, TPs, quiz et mises en situation.', 2),
(1916, 360, 'Préparation à l’examen ; rappel des obligations CPF lorsqu’elles s’appliquent au parcours retenu.', 3),
(1917, 360, 'Feuille de présence, questionnement qualitatif de clôture, attestation de fin de formation.', 4),
(1918, 361, 'Durée : 21 heures', 1),
(1919, 361, 'Tarif indicatif Inter : 2 360 € HT à distance (devis présentiel et intr…', 2),
(1920, 361, 'Effectifs : 1 à 12 stagiaires par session', 3),
(1921, 361, 'Formats : présentiel, salle immersive / téléprésentiel…', 4),
(1922, 361, 'Supports : poste adapté, cours et manuel numérique ou papier', 5),
(1923, 361, 'Inscriptions : jusqu\'à 48 h avant le début ; CPF : délai légal d\'au moi…', 6),
(1924, 361, 'Sessions indicatives : mai, septembre, décembre — à distance ou villes…', 7),
(1925, 361, 'Certification / examen : selon le financement retenu…', 8),
(1926, 361, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 9),
(1927, 361, 'Lieux : Bailly-Romainvilliers & Serris (77)', 10),
(1928, 361, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 11),
(1929, 361, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 12),
(1930, 362, 'Appréhender le protocole TCP/IP et les fondamentaux réseau.', 1),
(1931, 362, 'Connaître les systèmes d\'exploitation courants (Windows et/ou Linux).', 2),
(1932, 363, 'Auto-évaluation en début et fin de session.', 1),
(1933, 363, 'Retours du formateur sur quatre niveaux d’acquisition via QCM, exercices, quiz et cas.', 2),
(1934, 363, 'Préparation aux éventuelles suites certifiantes prévues dans votre parcours (modalités communiquées à l’inscription).', 3),
(1935, 363, 'Feuille de présence, bilan qualitatif, attestation de fin de formation.', 4),
(1936, 364, 'Durée : 21 heures', 1),
(1937, 364, 'Formats : classe virtuelle, présentiel ; Inter ou Intra', 2),
(1938, 364, 'Inter : 970,02 € HT / personne + certification obligatoire 235 € HT / p…', 3),
(1939, 364, 'Intra : 3 970,02 € HT / groupe + certification obligatoire 235 € HT / p…', 4),
(1940, 364, 'Sessions inter ou intra : calendrier communiqué lors de votre échange a…', 5),
(1941, 364, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 6),
(1942, 364, 'Lieux : Bailly-Romainvilliers & Serris (77)', 7),
(1943, 364, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 8),
(1944, 364, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 9),
(1945, 365, 'Une connaissance de base des processus de développement logiciel et des…', 1),
(1946, 366, 'Contrôles de connaissances types QCM et cas guidés pour consolider chaque jour.', 1),
(1947, 366, 'Restitution des attentes d’examen (gestion du temps, lecture des énoncés).', 2),
(1948, 366, 'Passage de la certification ISTQB Fondation selon le créneau convenu avec le certificateur.', 3),
(1949, 367, 'Durée : 21 heures (3 jours)', 1),
(1950, 367, 'Formats : classe virtuelle, présentiel — Inter ou Intra', 2),
(1951, 367, 'Inter : 960 € HT / personne + certification obligatoire 330 € HT / pers…', 3),
(1952, 367, 'Intra : 4 620 € HT / groupe + certification obligatoire 330 € HT / pers…', 4),
(1953, 367, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(1954, 367, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(1955, 367, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(1956, 367, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 8),
(1957, 368, 'Certification ISTQB niveau Fondation (obligatoire).', 1),
(1958, 368, 'Expérience préalable en tests logiciels et connaissance des principes A…', 2),
(1959, 369, 'Attestation de fin de formation après la session présentielle ou distancielle.', 1),
(1960, 369, 'Examen ISTQB Testeur Agile : 1 h, 40 QCM, 65 % de réussite requise pour la certification.', 2),
(1961, 370, 'Durée : 14 heures (2 jours)', 1),
(1962, 370, 'Format : classe virtuelle — Inter ou Intra', 2),
(1963, 370, 'Inter : 642 € HT / personne + certification obligatoire 315 € HT / pers…', 3),
(1964, 370, 'Intra : 3 040 € HT / groupe + certification obligatoire 315 € HT / pers…', 4),
(1965, 370, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(1966, 370, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(1967, 370, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(1968, 370, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 8),
(1969, 371, 'Certification ISTQB niveau Fondation (obligatoire).', 1),
(1970, 371, 'Expérience ou sensibilisation aux processus de validation fonctionnelle…', 2),
(1971, 372, 'Contrôles interactifs (questions orales/écrites, QCM, mises en situation).', 1),
(1972, 372, 'Examen blanc commenté puis certification : 40 questions en 1 h, 65 % minimum de bonnes réponses.', 2),
(1973, 373, 'Volume : 217 heures (7 axes)', 1),
(1974, 373, 'Déroulé : 100 % classe virtuelle — créneaux communiqués à l’inscription…', 2),
(1975, 373, 'Inter : 15 377 € HT / personne + certification obligatoire 370 € HT / p…', 3),
(1976, 373, 'Intra : 75 920 € HT / groupe + certification obligatoire 370 € HT / per…', 4),
(1977, 373, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(1978, 373, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(1979, 373, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(1980, 373, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 8),
(1981, 374, 'Justifier d’un diplôme ou d’une certification de niveau 5 (ex. : BTS SI…', 1),
(1982, 374, 'OU justifier d’une expérience au sein de la DSI d’une entreprise ou d’u…', 2),
(1983, 375, 'Quiz, travaux pratiques et cas tout au long des sept axes.', 1),
(1984, 375, 'Constitution d’un dossier professionnel individuel.', 2),
(1985, 375, 'Soutenance orale : présentation du dossier et échanges avec le jury.', 3),
(1986, 375, 'Travaux pratiques guidés sur environnements immersifs fournis dans le cadre du parcours.', 4),
(1987, 376, 'Durée indicative : 35 heures', 1),
(1988, 376, 'Effectifs : 1 à 12 personnes (souvent 5 à 6 en moyenne)', 2),
(1989, 376, 'Inscriptions : jusqu’à 48 h avant le début en général ; CPF : 11 jours…', 3),
(1990, 376, 'Intra-entreprise : sur devis', 4),
(1991, 376, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(1992, 376, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(1993, 376, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(1994, 376, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 8),
(1995, 377, 'Savoir mettre en œuvre l’algorithmique dans un langage de programmation', 1),
(1996, 377, 'OU avoir suivi la formation T410-010 « Algorithmique — Initiation à la…', 2),
(1997, 378, 'Auto-évaluation en début et fin de parcours.', 1),
(1998, 378, 'Retour du formateur (non évalué → acquis) via QCM, TP, quiz, cas ou mises en situation.', 2),
(1999, 378, 'Feuille de présence demi-journées ; questionnaire de fin analysé par l’équipe pédagogique ; attestation.', 3),
(2000, 378, 'Certification Éditions ENI « Créer et mettre en forme des pages web (HTML5 et CSS3) » : examen pour candidats volontaires ; travail personnel recommandé en complément du temps encadré.', 4),
(2001, 379, 'Durée : 35 heures', 1),
(2002, 379, 'Lieux types : distanciel ou villes partenaires — détail communiqué à l’…', 2),
(2003, 379, 'Inscriptions : jusqu’à 48 h avant le début en général ; CPF : 11 jours…', 3),
(2004, 379, 'Intra-entreprise : sur devis', 4),
(2005, 379, 'Accessibilité : signalez vos besoins à Alt RH Formations pour étude pré…', 5),
(2006, 379, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 6),
(2007, 379, 'Lieux : Bailly-Romainvilliers & Serris (77)', 7),
(2008, 379, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 8),
(2009, 379, 'Inscriptions : nos conseillers vous accompagnent (dossier, format).', 9),
(2010, 380, 'Programmer dans un langage structuré.', 1),
(2011, 380, 'Avoir suivi la formation TACNUM1-1A « Conception et programmation objet…', 2),
(2012, 381, 'Auto-évaluation en début et fin de session.', 1),
(2013, 381, 'Retour du formateur (non évalué à acquis) via QCM, TP, quiz, cas ou mises en situation.', 2),
(2014, 381, 'Feuille de présence ; questionnaire de fin analysé par l’équipe pédagogique ; attestation.', 3),
(2015, 381, 'Examen RS6701 pour les parcours concernés ; rappel de l’obligation d’examen en CPF ; travail personnel complémentaire recommandé.', 4),
(2016, 382, 'Durée : 1 jour — volume pédagogique équivalent 5 h à 7 h selon effectif…', 1),
(2017, 382, 'Format : présentiel — inter-entreprise ou intra sur demande', 2),
(2018, 382, 'Tarif indicatif inter : 1 000 € HT (devis intra sur mesure)', 3),
(2019, 382, 'Référence : NUM_DIGIT_06', 4),
(2020, 382, 'Aucune session fixe à date : formation sur demande — nous consulter pou…', 5),
(2021, 382, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 6),
(2022, 382, 'Lieux : Bailly-Romainvilliers & Serris (77)', 7),
(2023, 382, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 8),
(2024, 382, 'Inscriptions et programme personnalisé : nos conseillers vous répondent…', 9),
(2025, 383, 'Aucune connaissance particulière requise.', 1),
(2026, 384, 'Avant la formation : questionnaire pour exprimer vos objectifs personnels et estimer votre niveau sur les thématiques abordées.', 1),
(2027, 384, 'Pendant la formation : observation de vos pratiques par le formateur et conseils personnalisés (points forts et axes de vigilance).', 2),
(2028, 384, 'En fin de formation : questionnaire (QCM et/ou ateliers et exercices pratiques) pour valider les compétences et la progression vers vos objectifs ; questionnaire de satisfaction.', 3),
(2029, 384, 'À froid (6 à 9 mois après) : auto-évaluation proposée pour mesurer les bénéfices, les efforts restants et votre satisfaction.', 4),
(2030, 385, 'Durée : 5 jours présentiel', 1),
(2031, 385, 'Inter-entreprise ou intra-entreprise sur devis', 2),
(2032, 385, 'Tarif indicatif inter : 3 000 € HT', 3),
(2033, 385, 'Référence : NUM_DEV_21', 4),
(2034, 385, 'Sessions : sur demande (aucun calendrier fixe) — contact pour proposer…', 5),
(2035, 385, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 6),
(2036, 385, 'Lieux : Bailly-Romainvilliers & Serris (77)', 7),
(2037, 385, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 8),
(2038, 385, 'Demande de formation sur mesure : réponse sous 48 h ouvrées en moyenne.', 9),
(2039, 386, 'Bonnes connaissances en programmation.', 1),
(2040, 386, 'Bases des concepts objet.', 2),
(2041, 386, 'Expérience en développement avec un langage de type C/C++ ou Java.', 3),
(2042, 387, 'Avant la formation : questionnaire d’objectifs et d’auto-positionnement sur les thématiques du programme.', 1),
(2043, 387, 'Pendant la formation : observation des pratiques et retours personnalisés du formateur.', 2),
(2044, 387, 'En fin de formation : QCM et/ou ateliers et exercices pratiques ; questionnaire de satisfaction.', 3),
(2045, 387, 'À froid (6 à 9 mois) : auto-évaluation proposée sur les bénéfices et la satisfaction.', 4),
(2046, 388, 'Durée : 4 jours présentiel', 1),
(2047, 388, 'Inter-entreprise ou intra sur devis', 2),
(2048, 388, 'Tarif indicatif inter : 2 400 € HT', 3),
(2049, 388, 'Référence : NUM_DEV_01', 4),
(2050, 388, 'Sessions sur demande — calendrier communiqué à l’inscription', 5),
(2051, 388, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 6),
(2052, 388, 'Lieux : Bailly-Romainvilliers & Serris (77)', 7),
(2053, 388, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 8),
(2054, 388, 'Demande sur mesure : réponse sous 48 h ouvrées en moyenne.', 9),
(2055, 389, 'Connaissances de base en conception d’applications et en développement…', 1),
(2056, 390, 'Avant : questionnaire d’objectifs et d’auto-positionnement.', 1),
(2057, 390, 'Pendant : observation et conseils personnalisés du formateur.', 2),
(2058, 390, 'Fin : QCM et/ou ateliers pratiques ; questionnaire de satisfaction.', 3),
(2059, 390, 'À froid (6 à 9 mois) : auto-évaluation sur bénéfices et satisfaction.', 4),
(2060, 391, 'Durée : 3 jours présentiel (inter ou intra sur demande)', 1),
(2061, 391, 'Tarif indicatif inter : 2 800 € HT — certification incluse au même mont…', 2),
(2062, 391, 'Calendrier inter : sessions en général sur trois jours ouvrés consécuti…', 3),
(2063, 391, 'Places limitées par session — réservation recommandée 3 semaines à l’av…', 4),
(2064, 391, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2065, 391, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2066, 391, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2067, 391, 'Formation sur mesure possible pour votre équipe (intra) : même référent…', 8),
(2068, 392, 'Expérience en informatique ou participation à des missions SSI.', 1),
(2069, 393, 'Avant la session : questionnaire d’objectifs et de positionnement.', 1),
(2070, 393, 'Pendant : retours du formateur sur vos pratiques et cas issus de votre contexte.', 2),
(2071, 393, 'En fin de formation : QCM et/ou ateliers pratiques ; questionnaire de satisfaction.', 3),
(2072, 393, 'À froid : possibilité d’auto-évaluation quelques mois après pour mesurer l’impact en organisation.', 4),
(2073, 394, 'Durée : 3 jours présentiel', 1),
(2074, 394, 'Inter-entreprise ou intra sur devis', 2),
(2075, 394, 'Tarif indicatif inter : 2 500 € HT — certification CTA incluse au même…', 3),
(2076, 394, 'Aucune session inter fixe pour le moment : dates organisées sur demande…', 4),
(2077, 394, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2078, 394, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2079, 394, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2080, 394, 'Formation sur mesure possible pour votre équipe (intra) : programme aju…', 8),
(2081, 395, 'Connaissances de base des architectures techniques et du management du…', 1),
(2082, 395, 'Expérience des technologies Web d’au moins six mois', 2),
(2083, 396, 'Avant la formation : questionnaire pour exprimer vos objectifs personnels et évaluer votre niveau sur les thèmes du programme.', 1),
(2084, 396, 'Pendant la formation : le formateur observe vos pratiques et vous oriente sur vos points forts et les axes de vigilance.', 2),
(2085, 396, 'En fin de formation : QCM et/ou ateliers et exercices pratiques pour mesurer les acquis ; questionnaire de satisfaction ; passage de la certification CTA.', 3),
(2086, 396, '6 à 9 mois après : questionnaire d’auto-évaluation à froid sur les bénéfices, les efforts restants et la satisfaction vis-à-vis de la formation.', 4),
(2087, 397, 'Durée : 5 jours présentiel', 1),
(2088, 397, 'Inter-entreprise ou intra sur devis', 2),
(2089, 397, 'Tarif indicatif inter : 3 500 € HT — prix avec certification : même mon…', 3),
(2090, 397, 'Aucune session inter fixe pour le moment : dates sur demande', 4),
(2091, 397, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2092, 397, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2093, 397, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2094, 397, 'Formation sur mesure possible pour votre équipe (intra)', 8),
(2095, 398, 'Bonnes connaissances du domaine des réseaux', 1),
(2096, 399, 'Avant : questionnaire d’objectifs personnels et d’auto-positionnement sur les thématiques du programme.', 1),
(2097, 399, 'Pendant : observation de vos pratiques par le formateur et conseils personnalisés (points forts et axes de vigilance).', 2);
INSERT INTO `formation_info_points` (`id`, `block_id`, `content`, `sort_order`) VALUES
(2098, 399, 'En fin de formation : QCM et/ou ateliers et exercices pratiques ; questionnaire de satisfaction ; préparation à l’examen de certification.', 3),
(2099, 399, '6 à 9 mois après : auto-évaluation à froid sur bénéfices, effort résiduel et satisfaction.', 4),
(2100, 400, 'Durée : 2 jours présentiel', 1),
(2101, 400, 'Inter-entreprise ou intra sur devis', 2),
(2102, 400, 'Tarif indicatif inter : 2 700 € HT — certification PCSA incluse au même…', 3),
(2103, 400, 'Aucune session inter fixe pour le moment : dates sur demande', 4),
(2104, 400, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2105, 400, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2106, 400, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2107, 400, 'Formation sur mesure possible pour votre équipe (intra)', 8),
(2108, 401, 'Connaissances cloud de base souhaitables, ou équivalent aux contenus du…', 1),
(2109, 402, 'Avant : questionnaire d’objectifs personnels et de positionnement sur les thèmes du programme.', 1),
(2110, 402, 'Pendant : observation de vos pratiques et conseils personnalisés du formateur.', 2),
(2111, 402, 'En fin de formation : QCM et/ou ateliers pratiques ; satisfaction ; préparation et passage de la certification PCSA.', 3),
(2112, 402, '6 à 9 mois après : questionnaire d’auto-évaluation à froid (bénéfices, efforts restants, satisfaction).', 4),
(2113, 403, 'Durée : 2 jours présentiel — inter-entreprise ou intra sur devis', 1),
(2114, 403, 'Tarif indicatif inter : 1 056 € HT — certification « Audit sécurité d’a…', 2),
(2115, 403, 'Public : consultants en sécurité, administrateurs système ou réseau…', 3),
(2116, 403, 'Calendrier inter : sessions en présentiel sur l’année — dates et lieux…', 4),
(2117, 403, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2118, 403, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2119, 403, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2120, 403, 'Formation sur mesure possible pour votre équipe (intra)', 8),
(2121, 404, 'Aucun prérequis nécessaire pour participer à cette formation', 1),
(2122, 405, 'Avant : questionnaire d’objectifs personnels et de positionnement sur les thèmes du programme.', 1),
(2123, 405, 'Pendant : observation de vos pratiques par le formateur et conseils personnalisés (points forts et axes de vigilance).', 2),
(2124, 405, 'En fin de formation : QCM et/ou ateliers et exercices pratiques ; questionnaire de satisfaction.', 3),
(2125, 405, '6 à 9 mois après : auto-évaluation à froid sur bénéfices, suites possibles et satisfaction.', 4),
(2126, 406, 'Durée : 2 jours présentiel', 1),
(2127, 406, 'Inter-entreprise ou intra sur devis', 2),
(2128, 406, 'Tarif indicatif inter : 2 000 € HT — certification DevSecOps Engineerin…', 3),
(2129, 406, 'Aucune session inter fixe pour le moment : dates sur demande', 4),
(2130, 406, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2131, 406, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2132, 406, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2133, 406, 'Formation sur mesure possible pour votre équipe (intra)', 8),
(2134, 407, 'Connaissance des services IT en général, notamment de la sécurité et de…', 1),
(2135, 408, 'Avant : questionnaire d’objectifs personnels et de positionnement sur les thématiques.', 1),
(2136, 408, 'Pendant : observation par le formateur et conseils personnalisés (forces et axes de vigilance).', 2),
(2137, 408, 'En fin de formation : QCM et/ou ateliers pratiques ; questionnaire de satisfaction.', 3),
(2138, 408, '6 à 9 mois après : auto-évaluation à froid sur bénéfices, efforts restants et satisfaction.', 4),
(2139, 409, 'Durée : 5 jours présentiel', 1),
(2140, 409, 'Inter-entreprise ou intra sur devis', 2),
(2141, 409, 'Tarif indicatif inter : 3 000 € HT', 3),
(2142, 409, 'Aucune session inter fixe pour le moment : dates sur demande', 4),
(2143, 409, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 5),
(2144, 409, 'Lieux : Bailly-Romainvilliers & Serris (77)', 6),
(2145, 409, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 7),
(2146, 409, 'Formation sur mesure possible pour votre équipe (intra)', 8),
(2147, 410, 'Bonnes connaissances d’un langage de type C, Java, C#, VB.NET ou PHP', 1),
(2148, 411, 'Avant : questionnaire d’objectifs personnels et de positionnement sur les thèmes du programme.', 1),
(2149, 411, 'Pendant : observation de vos pratiques et retours personnalisés du formateur.', 2),
(2150, 411, 'En fin de formation : QCM et/ou ateliers pratiques ; questionnaire de satisfaction.', 3),
(2151, 411, '6 à 9 mois après : auto-évaluation à froid sur bénéfices, suites de progression et satisfaction.', 4),
(2152, 412, 'Durée : 5 jours présentiel — inter-entreprise ou intra sur devis', 1),
(2153, 412, 'Tarif indicatif inter : 2 399,20 € HT — certification C-DFE incluse au…', 2),
(2154, 412, 'Calendrier inter indicatif (France, présentiel) : 8–12 juin, 15–19 juin…', 3),
(2155, 412, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 4),
(2156, 412, 'Lieux : Bailly-Romainvilliers & Serris (77)', 5),
(2157, 412, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 6),
(2158, 412, 'Formation sur mesure possible pour votre équipe (intra)', 7),
(2159, 413, 'Au minimum 1 an d’expérience en environnement informatique', 1),
(2160, 413, 'Avoir suivi la formation Mile2 C)SP (Certified Security Principles) ou…', 2),
(2161, 413, 'Mile2 Foundational Course Pack (pack de cours fondamentaux Mile2)', 3),
(2162, 414, 'Positionnement sur les objectifs personnels et le socle criminalistique avant la session', 1),
(2163, 414, 'Mises en situation et travaux pratiques tout au long des 5 jours', 2),
(2164, 414, 'Bilan de fin de parcours et préparation ciblée à l’épreuve C-DFE', 3),
(2165, 414, 'Questionnaire de satisfaction et pistes de consolidation après la formation', 4),
(2166, 415, 'Durée : 5 jours présentiel — inter-entreprise ou intra sur devis', 1),
(2167, 415, 'Tarif indicatif inter : 3 120 € HT — certification ISC2 CISSP incluse a…', 2),
(2168, 415, 'Calendrier inter indicatif (France, présentiel) : 1–5 juin, 8–12 juin…', 3),
(2169, 415, 'Contact Alt RH Formations : 01 60 43 94 32 — formations@altrh.com', 4),
(2170, 415, 'Lieux : Bailly-Romainvilliers & Serris (77)', 5),
(2171, 415, 'Horaires d\'accueil : lundi au vendredi, 9h00 – 18h00', 6),
(2172, 415, 'Formation sur mesure possible pour votre équipe (intra)', 7),
(2173, 416, 'Notions solides de réseaux et de systèmes d’exploitation…', 1),
(2174, 416, 'Notions d’audit et de continuité d’activité (business continuity)', 2),
(2175, 417, 'Avant : cadrage des objectifs personnels et du niveau sur les 8 domaines', 1),
(2176, 417, 'Pendant : apports, études de cas et questions types inspirées de l’examen', 2),
(2177, 417, 'En fin de session : bilan des acquis et axes de révision pour l’épreuve CISSP', 3),
(2178, 417, 'Questionnaire de satisfaction et pistes de consolidation après la formation', 4),
(2179, 418, 'Aucun prérequis technique exigé.', 1),
(2180, 418, 'Bonne maîtrise de l’environnement informatique.', 2),
(2181, 418, 'Appétence pour la logique de programmation.', 3),
(2182, 419, '{\"titre\":\"Pour qui ?\",\"description\":\"Ce cycle s’adresse aux professionnel·le·s souhaitant acquérir des compétences solides en programmation Python, qu’il s’agisse de profils techniques débutants, de professionnel·le·s de la donnée, ou de métiers souhaitant automatiser des tâches ou développer des outils internes.\"}', 1),
(2183, 420, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"Webmasters\",\"Webdesigners\",\"Chef·fe·s de projets web\",\"Chef·fe·s de produits\",\"Responsables communication\",\"Responsables Web Marketing\",\"Infographistes\",\"Tout·e professionnel·le souhaitant acquérir les bonnes pratiques du RWD\"]}', 1),
(2184, 421, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"Toute personne souhaitant acquérir des compétences en communication digitale\",\"Développeur·euse web\",\"Webdesigner\",\"Graphiste web\",\"Directeur·rice Artistique Web\",\"Chef·fe·s de projets web\",\"Webmaster\"]}', 1),
(2185, 422, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"Tous les profils souhaitant être sensibilisés aux enjeux de la cybersécurité\",\"Personnes sans connaissances techniques ou autres prérequis\"]}', 1),
(2186, 423, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"DSI\",\"Administrateur·rice·s Sécurité\",\"Technicien·ne·s Sécurité\",\"Analystes Cybersécurité\",\"Spécialistes et Évaluateur·rice·s Sécurité\",\"Professionnel·le·s en charge de la sécurité d\'un système d\'information\"]}', 1),
(2187, 424, '{\"titre\":\"Pour qui ?\",\"public_cible\":[\"Futur·e·s technicien·ne·s informatiques\",\"Technicien·ne·s systèmes et réseaux\",\"Technicien·ne·s sécurité\"]}', 1),
(2188, 425, 'Durée : 7 heures (1 jour).', 1),
(2189, 425, 'Formats : présentiel en salle, téléprésentiel immersif…', 2),
(2190, 425, 'Groupes de 1 à 12 stagiaires (5 à 6 en moyenne)…', 3),
(2191, 425, 'Inscriptions possibles jusqu’à 48 h avant le début de la formation.', 4),
(2192, 425, 'Financement CPF : délai minimal de 11 jours ouvrés entre l’envoi de la…', 5),
(2193, 425, 'Sessions inter-entreprise et sur mesure en intra-entreprise (devis).', 6),
(2194, 425, 'Accessibilité aux personnes en situation de handicap : adaptations étud…', 7),
(2195, 425, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 8),
(2196, 426, 'Connaissance de base de Microsoft 365.', 1),
(2197, 426, 'Maîtrise des usages bureautiques courants (Word, Excel, Outlook, Teams).', 2),
(2198, 426, 'Compréhension des processus métier standards dans son environnement pro…', 3),
(2199, 427, 'En début et en fin de formation : auto-évaluation des connaissances et compétences par rapport aux objectifs pédagogiques.', 1),
(2200, 427, 'Pendant la formation : évaluation par le formateur sur l’atteinte des objectifs (QCM, exercices pratiques, quiz, étude de cas, etc.).', 2),
(2201, 427, 'Les stagiaires qui le souhaitent peuvent se présenter à l’examen de certification Microsoft ; le suivi de la formation seul ne garantit pas la réussite à l’épreuve.', 3),
(2202, 427, 'Attestation de fin de formation et questionnaire de satisfaction.', 4),
(2203, 428, 'Durée : 2 jours (environ 14 heures) — présentiel…', 1),
(2204, 428, 'Groupes de 1 à 12 stagiaires (5 à 6 en moyenne)…', 2),
(2205, 428, 'Inscriptions possibles jusqu’à 48 h avant le début de la session.', 3),
(2206, 428, 'Financement CPF : délai minimal de 11 jours ouvrés entre la proposition…', 4),
(2207, 428, 'Inter-entreprise et intra-entreprise sur devis.', 5),
(2208, 428, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2209, 428, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2210, 429, 'Maîtrise des fondamentaux des systèmes Windows et Linux.', 1),
(2211, 429, 'Connaissance de base des réseaux TCP/IP.', 2),
(2212, 429, 'Familiarité avec les scripts (PowerShell, Bash).', 3),
(2213, 429, 'Notions d’outils de supervision et de gestion de parc.', 4),
(2214, 430, 'En début et en fin de parcours : auto-évaluation par rapport aux objectifs pédagogiques.', 1),
(2215, 430, 'Évaluation continue par le formateur (QCM, ateliers, cas pratiques, quiz, études de cas).', 2),
(2216, 430, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2217, 431, 'Durée indicative : environ 14 heures sur 2 jours — présentiel…', 1),
(2218, 431, 'Groupes de 1 à 12 participant·e·s ; supports numériques remis aux parti…', 2),
(2219, 431, 'Création d’un compte Google (gratuit) recommandée avant la formation po…', 3),
(2220, 431, 'Inscriptions possibles jusqu’à 48 h avant le début de la session.', 4),
(2221, 431, 'Financement CPF : prévoir un délai minimal de 11 jours ouvrés entre la…', 5),
(2222, 431, 'Sessions inter-entreprise et intra-entreprise sur devis.', 6),
(2223, 431, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 7),
(2224, 431, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 8),
(2225, 432, 'Bonne maîtrise de l’environnement informatique.', 1),
(2226, 432, 'Bases de programmation fortement recommandées (quel que soit le langage…', 2),
(2227, 432, 'Compte Google (gratuit) à créer avant la formation pour réaliser certai…', 3),
(2228, 433, 'Auto-évaluation en début et en fin de formation.', 1),
(2229, 433, 'Évaluation par le formateur tout au long du parcours (QCM, ateliers, quiz, cas pratiques).', 2),
(2230, 433, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2231, 434, 'Durée : 14 heures — présentiel, téléprésentiel immersif ou distanciel.', 1),
(2232, 434, 'Groupes de 1 à 12 stagiaires ; support de cours fourni au format numéri…', 2),
(2233, 434, 'Inscriptions possibles jusqu’à 48 h avant le début de la session.', 3),
(2234, 434, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 4),
(2235, 434, 'Sessions inter-entreprise et intra-entreprise (devis).', 5),
(2236, 434, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2237, 434, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2238, 435, 'Connaissances de base en programmation et en développement web front-en…', 1),
(2239, 435, 'Maîtrise d’au moins un langage back-end (Python, PHP, Java, etc.).', 2),
(2240, 435, 'Création d’un compte ChatGPT (chat.openai.com) et d’un compte développe…', 3),
(2241, 435, 'Prévoir un budget pour l’accès aux offres ChatGPT / crédits API OpenAI…', 4),
(2242, 436, 'Auto-évaluation en début et en fin de formation.', 1),
(2243, 436, 'Évaluation par le formateur (QCM, livrables du projet, exercices pratiques).', 2),
(2244, 436, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2245, 437, 'Durée : 21 heures — présentiel, téléprésentiel immersif ou distanciel.', 1),
(2246, 437, 'Travaux pratiques sous forme de notebooks ; support de cours numérique…', 2),
(2247, 437, 'Groupes de 1 à 12 participant·e·s.', 3),
(2248, 437, 'Inscriptions possibles jusqu’à 48 h avant le début de la session.', 4),
(2249, 437, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 5),
(2250, 437, 'Inter-entreprise et intra sur devis.', 6),
(2251, 437, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 7),
(2252, 437, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 8),
(2253, 438, 'Aucune expérience préalable en IA n’est exigée.', 1),
(2254, 438, 'Connaissances de base en programmation et en développement web front-en…', 2),
(2255, 438, 'Maîtrise d’au moins un langage back-end (Python, PHP, Java, etc.).', 3),
(2256, 438, 'Création préalable d’un compte sur la plateforme OpenAI et d’un compte…', 4),
(2257, 439, 'Auto-évaluation en début et en fin de parcours.', 1),
(2258, 439, 'Évaluation continue : livrables issus des ateliers et du projet d’intégration.', 2),
(2259, 439, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2260, 440, 'Durée indicative : environ 15 h 30 sur 2 jours — présentiel…', 1),
(2261, 440, 'Groupes de 1 à 12 participant·e·s ; support numérique fourni.', 2),
(2262, 440, 'Inscriptions possibles jusqu’à 48 h avant le début.', 3),
(2263, 440, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 4),
(2264, 440, 'Inter / intra sur devis — accès aux outils d’IA tiers éventuellement so…', 5),
(2265, 440, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2266, 440, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2267, 441, 'Maîtriser les bases du webmarketing et de la communication digitale.', 1),
(2268, 441, 'Être à l’aise avec les outils numériques courants (bureautique…', 2),
(2269, 442, 'Auto-évaluation en début et en fin de formation.', 1),
(2270, 442, 'Évaluation par le formateur : QCM, livrables d’ateliers, mises en situation.', 2),
(2271, 442, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2272, 443, 'Durée indicative : environ 35 h sur 5 jours — présentiel…', 1),
(2273, 443, 'Groupes de 1 à 12 participant·e·s ; support pédagogique numérique ou pa…', 2),
(2274, 443, 'Inscriptions possibles jusqu’à 48 h avant le début.', 3),
(2275, 443, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 4),
(2276, 443, 'Inter / intra sur devis — environnement logiciel (Python ou équivalent)…', 5),
(2277, 443, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2278, 443, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2279, 444, 'Connaissances de base en programmation dans au moins un langage utilisé…', 1),
(2280, 444, 'Notions d’algèbre linéaire (matrices, dérivées) et de statistiques fort…', 2),
(2281, 445, 'Auto-évaluation en début et en fin de formation.', 1),
(2282, 445, 'Évaluation par le formateur : QCM, livrables de TP, études de cas ou quiz interactif.', 2),
(2283, 445, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2284, 446, 'Durée indicative : environ 7 h sur 1 jour — présentiel…', 1),
(2285, 446, 'Groupes de 1 à 12 participant·e·s ; support numérique selon session.', 2),
(2286, 446, 'Inscriptions possibles jusqu’à 48 h avant le début.', 3),
(2287, 446, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 4),
(2288, 446, 'Inter / intra sur devis.', 5),
(2289, 446, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2290, 446, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2291, 447, 'Aucun prérequis technique — ouvert à tout public professionnel souhaita…', 1),
(2292, 448, 'Auto-évaluation en début et en fin de formation.', 1),
(2293, 448, 'Évaluation par le formateur : QCM, quiz ou mise en situation selon le format retenu.', 2),
(2294, 448, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2295, 449, 'Durée indicative : environ 28 h sur 4 jours — présentiel…', 1),
(2296, 449, 'Groupes de 1 à 12 participant·e·s ; support pédagogique numérique selon…', 2),
(2297, 449, 'Inscriptions possibles jusqu’à 48 h avant le début.', 3),
(2298, 449, 'Financement CPF : délai minimal de 11 jours ouvrés entre proposition et…', 4),
(2299, 449, 'Inter / intra sur devis — usage d’outils / bibliothèques open source se…', 5),
(2300, 449, 'Accessibilité des personnes en situation de handicap : étude des besoin…', 6),
(2301, 449, 'Contact Alt RH & formations : 01 60 43 94 32 — formations@altrh.com', 7),
(2302, 450, 'Connaissances de base en programmation.', 1),
(2303, 450, 'Notions d’algèbre linéaire (matrices, dérivées) et de statistiques fort…', 2),
(2304, 450, 'Avoir suivi notre formation « Machine learning — fondamentaux (intensif…', 3),
(2305, 451, 'Auto-évaluation en début et en fin de formation.', 1),
(2306, 451, 'Évaluation par le formateur : QCM, livrables de TP, mini-projets ou quiz interactif.', 2),
(2307, 451, 'Attestation de fin de formation et questionnaire de satisfaction.', 3),
(2308, 452, 'Durée : 4 jours', 1),
(2309, 452, 'Format : E-learning', 2),
(2310, 452, 'Référence : Num_emb_02', 3),
(2311, 452, 'Public visé : Étudiants, Architectes, Développeurs', 4),
(2312, 452, 'Méthodes : présentations + travaux pratiques', 5),
(2313, 452, 'Formation disponible sur demande', 6),
(2314, 453, 'Bonnes connaissances en C et Linux', 1),
(2315, 453, 'Équivalent stages Linux (LXT) et BSP U-Boot (BLE)', 2),
(2316, 454, 'Durée : 2 jours', 1),
(2317, 454, 'Format : E-learning', 2),
(2318, 454, 'Public visé : Consultants en sécurité, Administrateurs systèm…', 3),
(2319, 454, 'Modalité : Inter-Entreprise et Intra-Entreprise', 4),
(2320, 455, 'Aucun prérequis nécessaire pour participer à cette formation', 1),
(2321, 456, 'Durée : 5 jours', 1),
(2322, 456, 'Format : E-learning', 2),
(2323, 456, 'Public visé : cybersécurité, pentesters, développeurs', 3),
(2324, 456, 'Disponible en inter-entreprise et intra-entreprise', 4),
(2325, 456, 'Formation également disponible sur demande', 5),
(2326, 457, 'Familiarité avec les débogueurs tels que WinDbg, ImmunityDBG ou OllyDBG', 1),
(2327, 457, 'Connaissances de base en exploitation sur architecture 32 bits', 2),
(2328, 457, 'Compétences en programmation, notamment en Python 3', 3),
(2329, 458, 'Durée : 5 jours', 1),
(2330, 458, 'Format : E-learning', 2),
(2331, 458, 'Public visé : pros sécurité, managers, consultants cloud', 3),
(2332, 458, 'Modalité : Inter-Entreprise et Intra-Entreprise', 4),
(2333, 459, 'Compréhension fondamentale des normes ISO/IEC 27017 et ISO/IEC 27018', 1),
(2334, 459, 'Connaissance générale des concepts du cloud computing', 2),
(2335, 460, 'Durée : 2 jours', 1),
(2336, 460, 'Format : E-learning', 2),
(2337, 460, 'Référence : NUM_DIGIT_10', 3),
(2338, 460, 'Public visé : marketing digital, dirigeants, managers…', 4),
(2339, 460, 'Financement : CPF (DiGiTT), entreprise ou France Travail possible', 5),
(2340, 460, 'Méthodes : Constructions participatives, simulations, jeux de rôle', 6),
(2341, 460, 'Formation sur demande (aucune session planifiée pour le moment)', 7),
(2342, 461, 'Aucune connaissance particulière requise.', 1),
(2343, 462, 'Durée : 5 jours', 1),
(2344, 462, 'Format : E-learning', 2),
(2345, 462, 'Référence : NUM_DEV_27', 3),
(2346, 462, 'Public visé : Tout public voulant découvrir la programmation…', 4),
(2347, 462, 'Méthodes : Constructions participatives, apports théoriques…', 5),
(2348, 462, 'Formation sur demande (aucune session planifiée pour le moment)', 6),
(2349, 463, 'Connaissances de base en technologies Objet et architectures multinivea…', 1),
(2350, 464, 'Durée : 3 jours', 1),
(2351, 464, 'Format : E-learning', 2),
(2352, 464, 'Référence : NUM_mngt_15', 3),
(2353, 464, 'Public visé : Toute personne en situation d\'encadrement, étud…', 4),
(2354, 464, 'Méthodes : Constructions participatives, simulations, jeux de rôle', 5),
(2355, 464, 'Formation sur demande (aucune session planifiée pour le moment)', 6),
(2356, 465, 'Connaissances de base en gestion des systèmes d\'information.', 1),
(2357, 466, 'Durée : 3 jours', 1),
(2358, 466, 'Format : E-learning', 2),
(2359, 466, 'Référence : NUM_mngt_19', 3),
(2360, 466, 'Public visé : Dirigeants, cadres, managers…', 4),
(2361, 466, 'Méthodes : Constructions participatives, simulations, jeux de rôle', 5),
(2362, 466, 'Formation sur demande (aucune session planifiée pour le moment)', 6),
(2363, 467, 'Connaissances de base en gestion des systèmes d\'information.', 1),
(2364, 468, 'Durée : 10 jours', 1),
(2365, 468, 'Format : E-learning', 2),
(2366, 468, 'Référence : NUM_mngt_17', 3),
(2367, 468, 'Public visé : Chefs de projet débutants ou confirmés, toute p…', 4),
(2368, 468, 'Méthodes : Constructions participatives, simulations, jeux de rôle', 5),
(2369, 468, 'Formation sur demande (aucune session planifiée pour le moment)', 6),
(2370, 469, 'Connaissances de base en gestion des systèmes d\'information.', 1),
(2371, 470, 'Durée : 2 jours', 1),
(2372, 470, 'Format : E-learning', 2),
(2373, 470, 'Référence : NUM_mngt_13', 3),
(2374, 470, 'Public visé : Managers souhaitant développer l’agilité dans l…', 4),
(2375, 470, 'Modalité : Inter-Entreprise et Intra-Entreprise', 5),
(2376, 470, 'Méthodes : Constructions participatives, simulations, jeux de rôle', 6),
(2377, 470, 'Formation sur demande (aucune session planifiée pour le moment)', 7),
(2378, 471, 'Connaissances de base en gestion des systèmes d\'information.', 1),
(2379, 472, 'Durée : 2 jours', 1),
(2380, 472, 'Format : E-learning', 2),
(2381, 472, 'Référence : NUM_mngt_11', 3),
(2382, 472, 'Public visé : Managers, hauts potentiels, étudiants', 4),
(2383, 472, 'Méthodes : Constructions participatives, apports théoriques…', 5),
(2384, 472, 'Formation sur demande (aucune session planifiée pour le moment)', 6),
(2385, 473, 'Connaissances de base en gestion des systèmes d\'information.', 1),
(2386, 474, 'Durée estimée : 15 heures (cycle d\'environ 1 mois)', 1),
(2387, 474, 'Format : 100% en ligne (Plateforme Digital Learning)', 2),
(2388, 474, 'Public visé : Tout professionnel du développement souhaitant…', 3),
(2389, 474, 'Suivi pédagogique : Accompagnement individuel synchrone et asynchrone p…', 4),
(2390, 474, 'Matériel requis : Ordinateur, connexion Internet (casque audio recomman…', 5),
(2391, 474, 'Accessibilité : Accompagnement spécifique pour les Personnes en Situati…', 6),
(2392, 475, 'Des connaissances de base en développement web sont requises.', 1),
(2393, 476, 'Durée estimée : 15 heures (cycle d\'environ 1 mois)', 1),
(2394, 476, 'Format : 100% en ligne (Plateforme Digital Learning)', 2),
(2395, 476, 'Public visé : Techniciens systèmes réseau, techniciens inform…', 3),
(2396, 476, 'Suivi pédagogique : Accompagnement individuel synchrone et asynchrone p…', 4),
(2397, 476, 'Matériel requis : Ordinateur, connexion Internet (casque audio recomman…', 5),
(2398, 476, 'Accessibilité : Accompagnement spécifique pour les Personnes en Situati…', 6),
(2399, 476, 'Bonus : Ce module est également dispensé dans le cadre du cycle long di…', 7),
(2400, 477, 'Des connaissances de base sur la configuration d’un environnement Windo…', 1),
(2401, 477, 'Recommandation : avoir suivi au préalable la formation « Installer et c…', 2),
(2402, 478, 'Format : E-learning — parcours à distance avec accompagnement pédagogiq…', 1),
(2403, 478, 'Formation certifiante TOSA — programme personnalisé selon votre niveau', 2),
(2404, 478, 'Code CPF : 135449', 3),
(2405, 478, 'Public : développer des compétences en bureautique ou valider un niveau…', 4),
(2406, 478, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 5),
(2407, 478, 'Accompagnement au montage du dossier de financement', 6),
(2408, 478, 'Financement demandeur d\'emploi : AIF (France Travail), Conseil régional…', 7),
(2409, 478, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 8),
(2410, 478, 'Financement entreprise : OPCO, alternance (apprentissage / professionna…', 9),
(2411, 478, 'Attention aux délais de montage du dossier — rapprochez-vous d\'un conse…', 10),
(2412, 479, 'Savoir utiliser un ordinateur sous Windows ou équivalent', 1),
(2413, 479, 'Aucun niveau Excel minimum requis — le parcours est adapté après évalua…', 2),
(2414, 479, 'Motivation pour structurer et valoriser ses compétences bureautiques', 3),
(2415, 480, 'Positionnement initial pour définir le parcours personnalisé', 1),
(2416, 480, 'Évaluations formatives tout au long de la formation', 2),
(2417, 480, 'Tests blancs et mini-tests en conditions proches de l\'épreuve', 3),
(2418, 480, 'Passage de la certification TOSA Excel', 4),
(2419, 481, 'Format : E-learning — parcours à distance avec accompagnement pédagogiq…', 1),
(2420, 481, 'Formation certifiante TOSA PowerPoint — niveau basique', 2),
(2421, 481, 'Code CPF : 135449', 3),
(2422, 481, 'Public : développer des compétences en bureautique ou valider un niveau…', 4),
(2423, 481, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 5),
(2424, 481, 'Accompagnement au montage du dossier de financement', 6),
(2425, 481, 'Financement demandeur d\'emploi : AIF (France Travail), Conseil régional…', 7),
(2426, 481, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 8),
(2427, 481, 'Financement entreprise : OPCO, alternance (apprentissage / professionna…', 9),
(2428, 481, 'Attention aux délais de montage du dossier — rapprochez-vous d\'un conse…', 10),
(2429, 482, 'Savoir utiliser un ordinateur sous Windows ou équivalent', 1),
(2430, 482, 'Aucun prérequis PowerPoint avancé — niveau basique visé', 2),
(2431, 482, 'Motivation pour créer des présentations professionnelles', 3),
(2432, 483, 'Positionnement sur les compétences PowerPoint de base', 1),
(2433, 483, 'Évaluations formatives au fil du parcours', 2),
(2434, 483, 'Tests blancs et mini-tests en conditions proches de l\'épreuve', 3),
(2435, 483, 'Passage de la certification TOSA PowerPoint', 4),
(2436, 484, 'Format : E-learning — parcours à distance avec accompagnement pédagogiq…', 1),
(2437, 484, 'Formation certifiante TOSA Word — personnalisation et documents structu…', 2),
(2438, 484, 'Code CPF : 135449', 3),
(2439, 484, 'Public : développer des compétences en bureautique ou valider un niveau…', 4),
(2440, 484, 'Organisme certifié Qualiopi — accessible aux personnes en situation de…', 5),
(2441, 484, 'Accompagnement au montage du dossier de financement', 6),
(2442, 484, 'Financement demandeur d\'emploi : AIF (France Travail), Conseil régional…', 7),
(2443, 484, 'Financement salarié : PTP, Démissionnaire, Pro-A, plan de développement…', 8),
(2444, 484, 'Financement entreprise : OPCO, alternance (apprentissage / professionna…', 9),
(2445, 484, 'Attention aux délais de montage du dossier — rapprochez-vous d\'un conse…', 10),
(2446, 485, 'Savoir utiliser un ordinateur sous Windows ou équivalent', 1),
(2447, 485, 'Notions de base sur un traitement de texte recommandées', 2),
(2448, 485, 'Motivation pour produire des documents professionnels', 3),
(2449, 486, 'Positionnement sur les compétences Word', 1),
(2450, 486, 'Évaluations formatives au fil du parcours', 2),
(2451, 486, 'Tests blancs et mini-tests en conditions proches de l\'épreuve', 3),
(2452, 486, 'Passage de la certification TOSA Word', 4);

-- --------------------------------------------------------

--
-- Structure de la table `formation_jobs`
--

CREATE TABLE `formation_jobs` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `salary_min` int(11) DEFAULT NULL,
  `salary_max` int(11) DEFAULT NULL,
  `salary_label` varchar(100) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_jobs`
--

INSERT INTO `formation_jobs` (`id`, `course_id`, `title`, `salary_min`, `salary_max`, `salary_label`, `sort_order`) VALUES
(541, 119, 'Administrateur·rice systèmes et réseaux', NULL, NULL, 'Selon expérience', 1),
(542, 119, 'Administrateur·rice d’infrastructures sécurisées', NULL, NULL, 'Selon expérience', 2),
(543, 119, 'Technicien·ne systèmes & réseaux confirmé·e', NULL, NULL, 'Selon expérience', 3),
(544, 119, 'Technicien·ne sécurité informatique', NULL, NULL, 'Selon expérience', 4),
(545, 119, 'Administrateur·rice cloud junior', NULL, NULL, 'Selon expérience', 5),
(546, 120, 'Développeur·euse Web', NULL, NULL, 'Selon expérience', 1),
(547, 120, 'Développeur·euse Web Mobile', NULL, NULL, 'Selon expérience', 2),
(548, 120, 'Intégrateur·rice Web', NULL, NULL, 'Selon expérience', 3),
(549, 120, 'Développeur·euse Front-end / Back-end', NULL, NULL, 'Selon expérience', 4),
(550, 120, 'Développeur·euse Full Stack junior', NULL, NULL, 'Selon expérience', 5),
(551, 121, 'Développeur·euse d’applications multimédia', NULL, NULL, 'Selon expérience', 1),
(552, 121, 'Développeur·euse front-end', NULL, NULL, 'Selon expérience', 2),
(553, 121, 'Intégrateur·rice multimédia', NULL, NULL, 'Selon expérience', 3),
(554, 121, 'Développeur·euse web ou mobile orienté·e UX', NULL, NULL, 'Selon expérience', 4),
(555, 121, 'Chargé·e de projets numériques interactifs', NULL, NULL, 'Selon expérience', 5),
(556, 122, 'Concepteur·rice Développeur·euse d’Applications', NULL, NULL, 'Selon expérience', 1),
(557, 122, 'Développeur·euse d’applications', NULL, NULL, 'Selon expérience', 2),
(558, 122, 'Développeur·euse back-end / full stack', NULL, NULL, 'Selon expérience', 3),
(559, 122, 'Analyste programmeur·euse', NULL, NULL, 'Selon expérience', 4),
(560, 122, 'Développeur·euse logiciel', NULL, NULL, 'Selon expérience', 5),
(561, 123, 'Technicien·ne systèmes et réseaux', NULL, NULL, 'Selon expérience', 1),
(562, 123, 'Administrateur·rice systèmes junior', NULL, NULL, 'Selon expérience', 2),
(563, 123, 'Technicien·ne support informatique', NULL, NULL, 'Selon expérience', 3),
(564, 123, 'Technicien·ne réseau', NULL, NULL, 'Selon expérience', 4),
(565, 123, 'Assistant·e administrateur·rice IT', NULL, NULL, 'Selon expérience', 5),
(566, 124, 'Lead Développeur·euse Web', NULL, NULL, 'Selon expérience', 1),
(567, 124, 'Développeur·euse Web senior', NULL, NULL, 'Selon expérience', 2),
(568, 124, 'Chef·fe de projet technique', NULL, NULL, 'Selon expérience', 3),
(569, 124, 'Responsable technique web', NULL, NULL, 'Selon expérience', 4),
(570, 125, 'Community Manager', NULL, NULL, '24K€ - 35K€ brut/an', 1),
(571, 125, 'Assistant·e de direction / RH', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(572, 126, 'Assistant·e Ressources Humaines', NULL, NULL, 'Selon expérience', 1),
(573, 126, 'Assistant·e de gestion du personnel', NULL, NULL, 'Selon expérience', 2),
(574, 126, 'Chargé·e de recrutement junior', NULL, NULL, 'Selon expérience', 3),
(575, 126, 'Assistant·e formation', NULL, NULL, 'Selon expérience', 4),
(576, 127, 'Assistant·e Administratif·ve', NULL, NULL, '24K€ - 35K€ brut/an', 1),
(577, 127, 'Assistant·e de direction / RH', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(578, 128, 'Assistant·e Commercial·e', NULL, NULL, '24K€ - 35K€ brut/an', 1),
(579, 128, 'Assistant·e de direction / RH', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(580, 129, 'Secrétaire Comptable', NULL, NULL, '26K€ - 38K€ brut/an', 1),
(581, 129, 'Assistant·e de direction / COMPTABILITE', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(582, 130, 'Conseiller·ère Relation Client à Distance', NULL, NULL, '24K€ - 35K€ brut/an', 1),
(583, 130, 'Assistant·e de direction / RH', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(584, 131, 'Administrateur·rice réseaux', NULL, NULL, 'Selon expérience', 1),
(585, 131, 'Administrateur·rice systèmes et réseaux', NULL, NULL, 'Selon expérience', 2),
(586, 131, 'Ingénieur·e NetOps', NULL, NULL, 'Selon expérience', 3),
(587, 131, 'Administrateur·rice infrastructures cloud', NULL, NULL, 'Selon expérience', 4),
(588, 131, 'Ingénieur·e réseaux datacenter', NULL, NULL, 'Selon expérience', 5),
(589, 131, 'Consultant·e infrastructures IT', NULL, NULL, 'Selon expérience', 6),
(590, 132, 'Administrateur·rice systèmes et réseaux', NULL, NULL, 'Selon expérience', 1),
(591, 132, 'Administrateur·rice d’infrastructures sécurisées', NULL, NULL, 'Selon expérience', 2),
(592, 132, 'Technicien·ne systèmes & réseaux confirmé·e', NULL, NULL, 'Selon expérience', 3),
(593, 132, 'Technicien·ne sécurité informatique', NULL, NULL, 'Selon expérience', 4),
(594, 132, 'Administrateur·rice cloud junior', NULL, NULL, 'Selon expérience', 5),
(595, 133, 'Administrateur·rice systèmes et réseaux', NULL, NULL, 'Selon expérience', 1),
(596, 133, 'Administrateur·rice d’infrastructures sécurisées', NULL, NULL, 'Selon expérience', 2),
(597, 133, 'Technicien·ne systèmes & réseaux confirmé·e', NULL, NULL, 'Selon expérience', 3),
(598, 133, 'Technicien·ne sécurité informatique', NULL, NULL, 'Selon expérience', 4),
(599, 133, 'Administrateur·rice cloud junior', NULL, NULL, 'Selon expérience', 5),
(600, 134, 'Comptable gestionnaire ou comptable unique', NULL, NULL, 'Environ 29 700 € brut/an en début de carrière', 1),
(601, 134, 'Comptable général·e ou collaborateur·rice de cabinet', NULL, NULL, '30 K€ – 40 K€ brut/an', 2),
(602, 134, 'Chef·fe comptable ou responsable comptable', NULL, NULL, '38 K€ – 52 K€ brut/an', 3),
(603, 134, 'Responsable comptable et financier·ère (après expérience)', NULL, NULL, '45 K€ – 65 K€ brut/an', 4),
(604, 135, 'Comptable Assistant·e', NULL, NULL, '26K€ - 38K€ brut/an', 1),
(605, 135, 'Assistant·e de direction / COMPTABILITE', NULL, NULL, '22K€ - 30K€ brut/an', 2),
(606, 136, 'Concepteur·rice Designer UI', NULL, NULL, '32 000 – 35 000 € brut/an (junior)', 1),
(607, 136, 'UI Designer', NULL, NULL, '+ 40 000 € brut/an (après 5 ans)', 2),
(608, 136, 'UX/UI Designer', NULL, NULL, 'Selon expérience', 3),
(609, 136, 'Intégrateur·rice Web', NULL, NULL, 'Selon expérience', 4),
(610, 136, 'Webdesigner', NULL, NULL, 'Selon expérience', 5),
(611, 136, 'Expert·e UI Designer', NULL, NULL, '+ 50 000 € brut/an', 6),
(612, 137, 'Assistant·e de Direction', NULL, NULL, 'Selon expérience', 1),
(613, 137, 'Office Manager', NULL, NULL, 'Selon expérience', 2),
(614, 137, 'Attaché·e de Direction', NULL, NULL, 'Selon expérience', 3),
(615, 139, 'Gérant·e de magasin', NULL, NULL, '35 K€ – 55 K€ brut/an selon enseigne et expérience', 1),
(616, 139, 'Gestionnaire de centre de profit', NULL, NULL, '40 K€ – 60 K€ brut/an', 2),
(617, 139, 'Directeur·rice de magasin ou de supermarché', NULL, NULL, '45 K€ – 70 K€ brut/an', 3),
(618, 139, 'Directeur·rice de grande surface ou de drive', NULL, NULL, '50 K€ – 80 K€ brut/an', 4),
(619, 139, 'Directeur·rice de supermarché de proximité', NULL, NULL, '42 K€ – 65 K€ brut/an', 5),
(620, 140, 'Assistant·e commercial·e transaction', NULL, NULL, '24 K€ – 32 K€ brut/an', 1),
(621, 140, 'Assistant·e ou agent·e de gestion locative', NULL, NULL, '25 K€ – 34 K€ brut/an', 2),
(622, 140, 'Chargé·e de gestion locative', NULL, NULL, '28 K€ – 38 K€ brut/an', 3),
(623, 140, 'Assistant·e de gestion immobilière ou syndic', NULL, NULL, '26 K€ – 36 K€ brut/an', 4),
(624, 140, 'Assistant·e de copropriété ou juridique immobilier', NULL, NULL, '27 K€ – 40 K€ brut/an', 5),
(625, 141, 'Assistant·e import-export ou commerce international', NULL, NULL, '26 K€ – 35 K€ brut/an', 1),
(626, 141, 'Assistant·e commercial·e export', NULL, NULL, '27 K€ – 38 K€ brut/an', 2),
(627, 141, 'Assistant·e administration des ventes export', NULL, NULL, '28 K€ – 40 K€ brut/an', 3),
(628, 141, 'Coordinateur·rice commercial·e et administratif·ve export', NULL, NULL, '30 K€ – 42 K€ brut/an', 4),
(629, 141, 'Gestionnaire logistique ou assistant·e service logistique', NULL, NULL, '28 K€ – 40 K€ brut/an', 5),
(630, 141, 'Assistant·e achat ou négoce international', NULL, NULL, '27 K€ – 38 K€ brut/an', 6),
(631, 142, 'Conseiller·ère en insertion professionnelle (CIP)', NULL, NULL, '28 K€ – 38 K€ brut/an', 1),
(632, 142, 'Conseiller·ère en insertion sociale et professionnelle', NULL, NULL, '28 K€ – 40 K€ brut/an', 2),
(633, 142, 'Conseiller·ère emploi formation ou à l\'emploi', NULL, NULL, '27 K€ – 38 K€ brut/an', 3),
(634, 142, 'Chargé·e d\'accompagnement social et professionnel', NULL, NULL, '26 K€ – 36 K€ brut/an', 4),
(635, 142, 'Chargé·e de projet d\'insertion professionnelle', NULL, NULL, '30 K€ – 42 K€ brut/an', 5),
(636, 142, 'Accompagnateur·rice socioprofessionnel·le', NULL, NULL, '25 K€ – 35 K€ brut/an', 6),
(637, 143, 'Vendeur·se', NULL, NULL, 'Selon convention, ancienneté et enseigne', 1),
(638, 143, 'Vendeur·se expert·e ou vendeur·se-conseil', NULL, NULL, 'Selon convention, ancienneté et enseigne', 2),
(639, 143, 'Vendeur·se technique', NULL, NULL, 'Selon convention, ancienneté et enseigne', 3),
(640, 143, 'Conseiller·ère de vente', NULL, NULL, 'Selon convention, ancienneté et enseigne', 4),
(641, 144, 'Webmaster / gestionnaire de site web', NULL, NULL, 'Selon projet et expérience', 1),
(642, 144, 'Chargé·e de communication digitale', NULL, NULL, '26 K€ – 38 K€ brut/an', 2),
(643, 144, 'Assistant·e marketing digital', NULL, NULL, '24 K€ – 34 K€ brut/an', 3),
(644, 144, 'Entrepreneur·e ou indépendant·e', NULL, NULL, 'Variable', 4),
(645, 145, 'Employé·e de libre-service ou de rayon', NULL, NULL, '20 K€ – 26 K€ brut/an', 1),
(646, 145, 'Employé·e commercial·e ou polyvalent·e', NULL, NULL, '21 K€ – 28 K€ brut/an', 2),
(647, 145, 'Vendeur·se en alimentation ou produits alimentaires', NULL, NULL, '20 K€ – 27 K€ brut/an', 3),
(648, 145, 'Caissier·ère ou hôte·sse de caisse', NULL, NULL, '19 K€ – 25 K€ brut/an', 4),
(649, 145, 'Employé·e en approvisionnement de rayon', NULL, NULL, '20 K€ – 26 K€ brut/an', 5),
(650, 146, 'Graphiste', NULL, NULL, 'Selon expérience', 1),
(651, 146, 'Infographiste', NULL, NULL, 'Selon expérience', 2),
(652, 146, 'Webdesigner', NULL, NULL, 'Selon expérience', 3),
(653, 146, 'Maquettiste', NULL, NULL, 'Selon expérience', 4),
(654, 146, 'Designer graphique', NULL, NULL, 'Selon expérience', 5),
(655, 146, 'Directeur·rice artistique', NULL, NULL, 'Selon expérience', 6),
(656, 146, 'Illustrateur·rice', NULL, NULL, 'Selon expérience', 7),
(657, 146, 'Motion designer', NULL, NULL, 'Selon expérience', 8),
(658, 146, 'Concepteur·rice multimédia', NULL, NULL, 'Selon expérience', 9),
(659, 146, 'Intégrateur·rice web', NULL, NULL, 'Selon expérience', 10),
(660, 147, 'Monteur·euse adjoint·e', NULL, NULL, 'Selon expérience', 1),
(661, 147, 'Assistant·e monteur·euse', NULL, NULL, 'Selon expérience', 2),
(662, 147, 'Monteur·euse', NULL, NULL, 'Selon expérience', 3),
(663, 147, 'Monteur·euse vidéo', NULL, NULL, 'Selon expérience', 4),
(664, 147, 'Monteur·euse audiovisuel·le', NULL, NULL, 'Selon expérience', 5),
(665, 147, 'Analyste vidéo sport', NULL, NULL, 'Selon expérience', 6),
(666, 148, 'Responsable ou directeur·rice de petite structure', NULL, NULL, 'Selon expérience et secteur', 1),
(667, 148, 'Chef·fe d’agence, de centre ou d’unité', NULL, NULL, 'Selon expérience et secteur', 2),
(668, 148, 'Directeur·rice ou directeur·rice adjoint·e de PME ou PMI', NULL, NULL, 'Selon expérience et secteur', 3),
(669, 148, 'Manageur·euse de proximité', NULL, NULL, 'Selon expérience et secteur', 4),
(670, 148, 'Directeur·rice ou responsable dans une association', NULL, NULL, 'Selon expérience et secteur', 5),
(671, 149, 'Gestionnaire de paie', NULL, NULL, 'Selon ancienneté ; fourchettes salariales librement publiées varient régulièrement', 1),
(672, 149, 'Collaborateur·rice ou technicien·ne paie', NULL, NULL, 'Selon ancienneté et taille de l’organisation', 2),
(673, 149, 'Gestionnaire paie — administration du personnel', NULL, NULL, 'Selon ancienneté et taille de l’organisation', 3),
(674, 149, 'Comptable spécialisé·e paie', NULL, NULL, 'Souvent évolution après double compétences compta / social.', 4),
(675, 149, 'Responsable paie ou chargé·e paie sociale', NULL, NULL, 'À viser après expérience terrain.', 5),
(676, 149, 'Assistant paie ou assistant RH social', NULL, NULL, 'Pont d’entrée possible avant titre complet.', 6),
(677, 150, 'Secrétaire médical·e', NULL, NULL, 'Fourchette indicative souvent citée ~1 590 € à ~2 500 € brut/mois ; médiane ~1 958 € (~23 500 € brut', 1),
(678, 150, 'Secrétaire assistant·e médical·e', NULL, NULL, 'Selon structure, ancienneté et convention collective', 2),
(679, 150, 'Secrétaire administratif·ve et médical·e', NULL, NULL, 'Selon structure et territorialité', 3),
(680, 150, 'Assistant·e médico-administratif·ve', NULL, NULL, 'Selon structure ; évolutions possibles avec expérience', 4),
(681, 150, 'Secrétaire médical·e', NULL, NULL, NULL, 5),
(682, 150, 'Secrétaire assistant·e médical·e', NULL, NULL, NULL, 6),
(683, 150, 'Secrétaire administratif·ve et médical·e', NULL, NULL, NULL, 7),
(684, 150, 'Assistant·e médico-administratif·ve', NULL, NULL, NULL, 8),
(685, 151, 'Assistant·e administratif·ve', NULL, NULL, 'Selon structure, ancienneté et convention collective', 1),
(686, 151, 'Secrétaire administratif·ve', NULL, NULL, 'Selon structure et bassin d’emploi', 2),
(687, 151, 'Chargé·e d’accueil', NULL, NULL, 'Souvent évolutions vers coordination d’accueil après expérience', 3),
(688, 151, 'Secrétaire d’accueil', NULL, NULL, 'Selon secteur (services, retail, santé hors titre médical dédié, etc.)', 4),
(689, 151, 'Assistant·e administratif·ve', NULL, NULL, NULL, 5),
(690, 151, 'Secrétaire administratif·ve', NULL, NULL, NULL, 6),
(691, 151, 'Chargé·e d’accueil', NULL, NULL, NULL, 7),
(692, 151, 'Secrétaire d’accueil', NULL, NULL, NULL, 8),
(693, 152, 'Responsable du développement', NULL, NULL, 'Selon secteur, taille d’organisation et expérience', 1),
(694, 152, 'Responsable régional·e', NULL, NULL, 'Souvent évolution après consolidation terrain', 2),
(695, 152, 'Chargé·e du développement', NULL, NULL, 'Selon base fixe et variable éventuelle', 3),
(696, 152, 'Responsable d’un centre de profit / business unit', NULL, NULL, 'Selon périmètre et résultats', 4),
(697, 152, 'Responsable du développement', NULL, NULL, NULL, 5),
(698, 152, 'Responsable régional·e', NULL, NULL, NULL, 6),
(699, 152, 'Chargé·e du développement', NULL, NULL, NULL, 7),
(700, 152, 'Responsable de centre de profit', NULL, NULL, NULL, 8),
(701, 153, 'Développeur / Ingénieur logiciel', NULL, NULL, NULL, 1),
(702, 153, 'Administrateur systèmes & réseaux', NULL, NULL, NULL, 2),
(703, 153, 'Chef de projet IT', NULL, NULL, NULL, 3),
(704, 153, 'Architecte solutions', NULL, NULL, NULL, 4),
(705, 153, 'Responsable IT / DSI', NULL, NULL, NULL, 5),
(706, 154, 'Développeur / Ingénieur logiciel', NULL, NULL, NULL, 1),
(707, 154, 'Chef de projet IT', NULL, NULL, NULL, 2),
(708, 154, 'Scrum Master / Coach Agile', NULL, NULL, NULL, 3),
(709, 154, 'Responsable IT / DSI', NULL, NULL, NULL, 4),
(710, 154, 'Toute personne impliquée dans une transformation DevOps', NULL, NULL, NULL, 5),
(711, 155, 'Responsable sécurité des systèmes d\'information (RSSI)', NULL, NULL, NULL, 1),
(712, 155, 'Analyste SOC / réponse aux incidents', NULL, NULL, NULL, 2),
(713, 155, 'Consultant cybersécurité / SMSI', NULL, NULL, NULL, 3),
(714, 155, 'Administrateur sécurité', NULL, NULL, NULL, 4),
(715, 155, 'Managers et directions soumis aux exigences de résilience SI', NULL, NULL, NULL, 5),
(716, 156, 'Développeur applicatif', NULL, NULL, NULL, 1),
(717, 156, 'Architecte logiciel / données', NULL, NULL, NULL, 2),
(718, 156, 'Administrateur de bases de données', NULL, NULL, NULL, 3),
(719, 156, 'Exploitant / équipe production SI', NULL, NULL, NULL, 4),
(720, 156, 'Chef de projet technique', NULL, NULL, NULL, 5),
(721, 156, 'Analyste métier ou décisionnel amené à interroger des bases', NULL, NULL, NULL, 6),
(722, 157, 'Administrateur systèmes et réseaux', NULL, NULL, NULL, 1),
(723, 157, 'Responsable exploitation / production', NULL, NULL, NULL, 2),
(724, 157, 'Chef de projet IT', NULL, NULL, NULL, 3),
(725, 157, 'Développeur', NULL, NULL, NULL, 4),
(726, 157, 'Architecte technique', NULL, NULL, NULL, 5),
(727, 157, 'Toute personne amenée à industrialiser le déploiement applicatif', NULL, NULL, NULL, 6),
(728, 158, 'Responsable informatique / DSI adjoint', NULL, NULL, NULL, 1),
(729, 158, 'Responsable sécurité du SI', NULL, NULL, NULL, 2),
(730, 158, 'Administrateur systèmes et réseaux', NULL, NULL, NULL, 3),
(731, 158, 'Ingénieur réseau ou sécurité', NULL, NULL, NULL, 4),
(732, 158, 'Chef de projet sécurité', NULL, NULL, NULL, 5),
(733, 158, 'Toute personne en charge d\'un système d\'information d\'entreprise', NULL, NULL, NULL, 6),
(734, 159, 'Testeur logiciel', NULL, NULL, NULL, 1),
(735, 159, 'Ingénieur qualité / QA', NULL, NULL, NULL, 2),
(736, 159, 'Analyste de tests', NULL, NULL, NULL, 3),
(737, 159, 'Chef de projet', NULL, NULL, NULL, 4),
(738, 159, 'Responsable qualité', NULL, NULL, NULL, 5),
(739, 160, 'Testeur logiciel', NULL, NULL, NULL, 1),
(740, 160, 'Ingénieur qualité', NULL, NULL, NULL, 2),
(741, 160, 'Analyste de tests', NULL, NULL, NULL, 3),
(742, 160, 'Chef de projet en mode Agile', NULL, NULL, NULL, 4),
(743, 161, 'Testeur / ingénieur test', NULL, NULL, NULL, 1),
(744, 161, 'Responsable qualité', NULL, NULL, NULL, 2),
(745, 161, 'Maîtrise d’ouvrage (MOA)', NULL, NULL, NULL, 3),
(746, 161, 'Analyste métier', NULL, NULL, NULL, 4),
(747, 162, 'Technicien / ingénieur systèmes et réseaux', NULL, NULL, NULL, 1),
(748, 162, 'Technicien support en ESN', NULL, NULL, NULL, 2),
(749, 162, 'Référent cybersécurité en DSI', NULL, NULL, NULL, 3),
(750, 162, 'Futur pilote RSSI / responsable sécurité SI (selon expérience)', NULL, NULL, NULL, 4),
(751, 162, 'Consultant en sécurité des systèmes d’information', NULL, NULL, NULL, 5),
(752, 163, 'Concepteur développeur Web', NULL, NULL, NULL, 1),
(753, 163, 'Intégrateur Web', NULL, NULL, NULL, 2),
(754, 163, 'Développeur front-end', NULL, NULL, NULL, 3),
(755, 164, 'Développeur', NULL, NULL, NULL, 1),
(756, 164, 'Ingénieur logiciel', NULL, NULL, NULL, 2),
(757, 164, 'Chef de projet technique', NULL, NULL, NULL, 3),
(758, 165, 'Étudiant·e en reconversion ou en complément de cursus', NULL, NULL, NULL, 1),
(759, 165, 'Collaborateur·rice en transition vers des projets digitaux', NULL, NULL, NULL, 2),
(760, 165, 'Futur community manager, chef de produit web ou rôles transverses numérique', NULL, NULL, NULL, 3),
(761, 165, 'Manager ou encadrant·e devant fédérer une culture digitale en équipe', NULL, NULL, NULL, 4),
(762, 166, 'Développeur .NET / C#', NULL, NULL, NULL, 1),
(763, 166, 'Développeur full-stack orienté Microsoft', NULL, NULL, NULL, 2),
(764, 166, 'Étudiant·e en informatique visant l’entreprise .NET', NULL, NULL, NULL, 3),
(765, 166, 'Technicien·ne ou intégrateur·rice cherchant à passer à la plateforme .NET', NULL, NULL, NULL, 4),
(766, 167, 'Développeur·se concevant ou codant en paradigme objet', NULL, NULL, NULL, 1),
(767, 167, 'Chef·fe de projet technique ou fonctionnel orienté delivery logiciel', NULL, NULL, NULL, 2),
(768, 167, 'Architecte logiciel en devenir', NULL, NULL, NULL, 3),
(769, 167, 'Étudiant·e préparant des rôles conception / développement', NULL, NULL, NULL, 4),
(770, 168, 'Futur ou actuel RSSI / responsable cybersécurité', NULL, NULL, NULL, 1),
(771, 168, 'Ingénieur·e sécurité du SI', NULL, NULL, NULL, 2),
(772, 168, 'Directeur·rice des systèmes d’information (vision RSSI)', NULL, NULL, NULL, 3),
(773, 168, 'Consultant·e en cybersécurité / SSI', NULL, NULL, NULL, 4),
(774, 169, 'Directeur·rice des systèmes d’information (DSI)', NULL, NULL, NULL, 1),
(775, 169, 'Architecte IT', NULL, NULL, NULL, 2),
(776, 169, 'Chef·fe de projet IT', NULL, NULL, NULL, 3),
(777, 169, 'Tout profil souhaitant des bases solides sur le cloud computing', NULL, NULL, NULL, 4),
(778, 170, 'Technicien·ne systèmes et réseaux', NULL, NULL, NULL, 1),
(779, 170, 'Administrateur·rice réseau', NULL, NULL, NULL, 2),
(780, 170, 'Profil IT en montée en compétences vers des rôles Cisco / réseau d’entreprise', NULL, NULL, NULL, 3),
(781, 171, 'Architecte IT', NULL, NULL, NULL, 1),
(782, 171, 'Responsable des systèmes d’information', NULL, NULL, NULL, 2),
(783, 171, 'Directeur·rice des systèmes d’information (DSI)', NULL, NULL, NULL, 3),
(784, 171, 'Consultant·e en stratégie SI / cloud', NULL, NULL, NULL, 4),
(785, 172, 'Consultant·e en cybersécurité', NULL, NULL, NULL, 1),
(786, 172, 'Administrateur·rice système ou réseau', NULL, NULL, NULL, 2),
(787, 172, 'Développeur·se', NULL, NULL, NULL, 3),
(788, 172, 'Auditeur·rice sécurité mobile / pentesteur·rice Android', NULL, NULL, NULL, 4),
(789, 173, 'Ingénieur·e DevOps / DevSecOps', NULL, NULL, NULL, 1),
(790, 173, 'Responsable sécurité applicative ou produit', NULL, NULL, NULL, 2),
(791, 173, 'Scrum Master / coach agile impliqué dans la qualité et la sécurité', NULL, NULL, NULL, 3),
(792, 173, 'Architecte ou chef·fe de projet livrant en mode agile', NULL, NULL, NULL, 4),
(793, 174, 'Développeur·se / ingénieur·e logiciel', NULL, NULL, NULL, 1),
(794, 174, 'Chef·fe de projet technique proche du développement', NULL, NULL, NULL, 2),
(795, 174, 'Profil souhaitant industrialiser ou consolider des compétences C++ orienté objet', NULL, NULL, NULL, 3),
(796, 175, 'Administrateur·rice virtualisation', NULL, NULL, NULL, 1),
(797, 175, 'Responsable sécurité cloud (Cloud Security Officer)', NULL, NULL, NULL, 2),
(798, 175, 'Directeur·rice des systèmes d’information (DSI / CIO)', NULL, NULL, NULL, 3),
(799, 175, 'Auditeur·rice virtualisation et cloud', NULL, NULL, NULL, 4),
(800, 175, 'Responsable conformité virtualisation et cloud', NULL, NULL, NULL, 5),
(801, 176, 'Consultant·e en cybersécurité', NULL, NULL, NULL, 1),
(802, 176, 'Responsable sécurité', NULL, NULL, NULL, 2),
(803, 176, 'Directeur·rice ou manager IT', NULL, NULL, NULL, 3),
(804, 176, 'Auditeur·rice sécurité', NULL, NULL, NULL, 4),
(805, 176, 'Architecte sécurité', NULL, NULL, NULL, 5),
(806, 176, 'Analyste sécurité', NULL, NULL, NULL, 6),
(807, 176, 'Ingénieur·e systèmes de sécurité', NULL, NULL, NULL, 7),
(808, 176, 'Chief Information Security Officer (CISO)', NULL, NULL, NULL, 8),
(809, 176, 'Directeur·rice sécurité', NULL, NULL, NULL, 9),
(810, 176, 'Architecte réseau', NULL, NULL, NULL, 10),
(811, 183, 'Utilisateur·rice professionnel·le Microsoft 365', NULL, NULL, NULL, 1),
(812, 183, 'Assistant·e administratif·ve / Office manager', NULL, NULL, NULL, 2),
(813, 183, 'Chargé·e de projet / Chef·fe de projet', NULL, NULL, NULL, 3),
(814, 183, 'Manager d’équipe', NULL, NULL, NULL, 4),
(815, 183, 'Tout profil souhaitant gagner en productivité avec l’IA dans Microsoft 365', NULL, NULL, NULL, 5),
(816, 184, 'Technicien·ne systèmes et réseaux', NULL, NULL, NULL, 1),
(817, 184, 'Administrateur·rice système ou réseau', NULL, NULL, NULL, 2),
(818, 184, 'Technicien·ne support / gestion de parc', NULL, NULL, NULL, 3),
(819, 184, 'Professionnel·le en charge du SI (maintenance, supervision)', NULL, NULL, NULL, 4),
(820, 185, 'Développeur·euse / ingénieur·e logiciel', NULL, NULL, NULL, 1),
(821, 185, 'Chef·fe de produit ou de projet digital', NULL, NULL, NULL, 2),
(822, 185, 'Consultant·e, entrepreneur·euse, créatif·ve', NULL, NULL, NULL, 3),
(823, 185, 'Cadre ou décideur·euse orienté·e innovation', NULL, NULL, NULL, 4),
(824, 186, 'Développeur·euse logiciel', NULL, NULL, NULL, 1),
(825, 186, 'Développeur·euse web & web mobile', NULL, NULL, NULL, 2),
(826, 186, 'Tout profil technique souhaitant accélérer la qualité et la sécurité du code avec l’IA', NULL, NULL, NULL, 3),
(827, 187, 'Développeur·euse d’applications', NULL, NULL, NULL, 1),
(828, 187, 'Data scientist / ingénieur·e en machine learning', NULL, NULL, NULL, 2),
(829, 187, 'Professionnel·le IT souhaitant industrialiser des usages de l’API ChatGPT', NULL, NULL, NULL, 3),
(830, 188, 'Responsable communication / marketing digital', NULL, NULL, NULL, 1),
(831, 188, 'Chargé·e de contenus ou community manager', NULL, NULL, NULL, 2),
(832, 188, 'Entrepreneur·euse ou professionnel·le du digital', NULL, NULL, NULL, 3),
(833, 188, 'Consultant·e en stratégie et présence en ligne', NULL, NULL, NULL, 4),
(834, 189, 'Développeur·euse / concepteur·rice logiciel', NULL, NULL, NULL, 1),
(835, 189, 'Data scientist / ingénieur·e data', NULL, NULL, NULL, 2),
(836, 189, 'Professionnel·le IT évoluant vers la data et le ML', NULL, NULL, NULL, 3),
(837, 190, 'Manager, chef·fe de projet ou responsable métier', NULL, NULL, NULL, 1),
(838, 190, 'Professionnel·le en transformation digitale', NULL, NULL, NULL, 2),
(839, 190, 'Toute personne en veille sur l’IA et ses enjeux sectoriels', NULL, NULL, NULL, 3),
(840, 191, 'Data scientist / ingénieur·e data', NULL, NULL, NULL, 1),
(841, 191, 'Concepteur·rice / développeur·euse', NULL, NULL, NULL, 2),
(842, 191, 'Professionnel·le data souhaitant se spécialiser en NLP', NULL, NULL, NULL, 3),
(843, 192, 'Développeur embarqué / BSP', NULL, NULL, NULL, 1),
(844, 192, 'Ingénieur logiciel embarqué', NULL, NULL, NULL, 2),
(845, 192, 'Architecte systèmes embarqués', NULL, NULL, NULL, 3),
(846, 192, 'Développeur Android (système)', NULL, NULL, NULL, 4),
(847, 193, 'Pentesteur / Testeur d\'intrusion Web', NULL, NULL, NULL, 1),
(848, 193, 'Consultant en cybersécurité', NULL, NULL, NULL, 2),
(849, 193, 'Administrateur systèmes & réseaux', NULL, NULL, NULL, 3),
(850, 193, 'Développeur sécurité (DevSecOps)', NULL, NULL, NULL, 4),
(851, 194, 'Chercheur en vulnérabilités (Vulnerability Researcher)', NULL, NULL, NULL, 1),
(852, 194, 'Développeur d\'exploits', NULL, NULL, NULL, 2),
(853, 194, 'Pentesteur offensif avancé', NULL, NULL, NULL, 3),
(854, 194, 'Analyste en sécurité offensive (Red Team)', NULL, NULL, NULL, 4),
(855, 195, 'Cloud Security Manager', NULL, NULL, NULL, 1),
(856, 195, 'Responsable sécurité du SI (RSSI)', NULL, NULL, NULL, 2),
(857, 195, 'Consultant en sécurité cloud', NULL, NULL, NULL, 3),
(858, 195, 'Manager cybersécurité / Directeur IT', NULL, NULL, NULL, 4),
(859, 196, 'Data Analyst / Data Scientist Marketing', NULL, NULL, NULL, 1),
(860, 196, 'Responsable marketing digital', NULL, NULL, NULL, 2),
(861, 196, 'Chef de projet Data', NULL, NULL, NULL, 3),
(862, 196, 'Directeur commercial ou CRM', NULL, NULL, NULL, 4),
(863, 197, 'Développeur Java / Back-end', NULL, NULL, NULL, 1),
(864, 197, 'Ingénieur logiciel', NULL, NULL, NULL, 2),
(865, 197, 'Développeur d\'applications d\'entreprise', NULL, NULL, NULL, 3),
(866, 197, 'Développeur Java EE / Spring', NULL, NULL, NULL, 4),
(867, 198, 'Manager d\'équipe / Responsable hiérarchique', NULL, NULL, NULL, 1),
(868, 198, 'Chef de projet', NULL, NULL, NULL, 2),
(869, 198, 'Responsable RH ou formation', NULL, NULL, NULL, 3),
(870, 198, 'Team Leader / Coordinateur', NULL, NULL, NULL, 4),
(871, 199, 'Responsable RSE / Développement durable', NULL, NULL, NULL, 1),
(872, 199, 'Chargé de mission RSE', NULL, NULL, NULL, 2),
(873, 199, 'Manager QHSE', NULL, NULL, NULL, 3),
(874, 199, 'Consultant en développement durable', NULL, NULL, NULL, 4),
(875, 200, 'Chef de projet / Directeur de programme', NULL, NULL, NULL, 1),
(876, 200, 'Coordinateur de projet', NULL, NULL, NULL, 2),
(877, 200, 'Consultant en management de projet', NULL, NULL, NULL, 3),
(878, 200, 'PMO (Project Management Officer)', NULL, NULL, NULL, 4),
(879, 201, 'Manager Agile', NULL, NULL, NULL, 1),
(880, 201, 'Scrum Master / Coach Agile', NULL, NULL, NULL, 2),
(881, 201, 'Responsable d\'équipe en transformation', NULL, NULL, NULL, 3),
(882, 201, 'Chef de projet en environnement Agile', NULL, NULL, NULL, 4),
(883, 202, 'Manager / Directeur d\'équipe', NULL, NULL, NULL, 1),
(884, 202, 'Leader & Coach managérial', NULL, NULL, NULL, 2),
(885, 202, 'Responsable de Business Unit', NULL, NULL, NULL, 3),
(886, 202, 'Cadre dirigeant en transformation', NULL, NULL, NULL, 4),
(887, 203, 'Ingénieur DevOps', NULL, NULL, NULL, 1),
(888, 203, 'Développeur back-end / full-stack DevOps', NULL, NULL, NULL, 2),
(889, 203, 'Administrateur systèmes & infrastructure', NULL, NULL, NULL, 3),
(890, 203, 'Ingénieur CI/CD', NULL, NULL, NULL, 4),
(891, 204, 'Administrateur systèmes Windows', NULL, NULL, NULL, 1),
(892, 204, 'Technicien systèmes & réseaux', NULL, NULL, NULL, 2),
(893, 204, 'Ingénieur infrastructure IT', NULL, NULL, NULL, 3),
(894, 204, 'Administrateur réseau & sécurité', NULL, NULL, NULL, 4),
(895, 205, 'Assistant·e administratif·ve', NULL, NULL, NULL, 1),
(896, 205, 'Secrétaire', NULL, NULL, NULL, 2),
(897, 205, 'Comptable assistant·e', NULL, NULL, NULL, 3),
(898, 205, 'Chargé·e de gestion', NULL, NULL, NULL, 4),
(899, 205, 'Tout professionnel utilisant Excel au quotidien', NULL, NULL, NULL, 5),
(900, 206, 'Assistant·e administratif·ve', NULL, NULL, NULL, 1),
(901, 206, 'Secrétaire', NULL, NULL, NULL, 2),
(902, 206, 'Chargé·e de communication', NULL, NULL, NULL, 3),
(903, 206, 'Formateur·rice', NULL, NULL, NULL, 4),
(904, 206, 'Tout professionnel créant des présentations', NULL, NULL, NULL, 5),
(905, 207, 'Assistant·e administratif·ve', NULL, NULL, NULL, 1),
(906, 207, 'Secrétaire', NULL, NULL, NULL, 2),
(907, 207, 'Rédacteur·rice', NULL, NULL, NULL, 3),
(908, 207, 'Chargé·e de gestion', NULL, NULL, NULL, 4),
(909, 207, 'Tout professionnel produisant des documents Word', NULL, NULL, NULL, 5);

-- --------------------------------------------------------

--
-- Structure de la table `formation_modules`
--

CREATE TABLE `formation_modules` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_modules`
--

INSERT INTO `formation_modules` (`id`, `course_id`, `title`, `description`, `duration`, `sort_order`) VALUES
(649, 119, 'Fondamentaux systèmes & réseaux', 'Module 1 de la formation.', 'À définir', 1),
(650, 119, 'Sécurité des infrastructures informatiques', 'Module 2 de la formation.', 'À définir', 2),
(651, 119, 'Virtualisation & environnements serveurs', 'Module 3 de la formation.', 'À définir', 3),
(652, 119, 'Réseaux avancés et services', 'Module 4 de la formation.', 'À définir', 4),
(653, 119, 'Supervision, maintenance et continuité de service', 'Module 5 de la formation.', 'À définir', 5),
(654, 119, 'Projets professionnels et mises en situation', 'Module 6 de la formation.', 'À définir', 6),
(655, 120, '(aperçu – contenu détaillé dans la brochure)', 'Module 1 de la formation.', 'À définir', 1),
(656, 120, 'Environnement de travail HTML / CSS Notions d’ergonomie et d’accessibilité', 'Module 2 de la formation.', 'À définir', 2),
(657, 120, 'JavaScript Interfaces interactives Responsive design', 'Module 3 de la formation.', 'À définir', 3),
(658, 120, 'Logique serveur Bases de données Sécurisation des échanges', 'Module 4 de la formation.', 'À définir', 4),
(659, 120, 'Applications mobiles Adaptation multi-supports Optimisation des performances', 'Module 5 de la formation.', 'À définir', 5),
(660, 120, 'Mise en situation réelle Travail en équipe Présentation de projet', 'Module 6 de la formation.', 'À définir', 6),
(661, 121, 'Bases du développement web et applicatif Langages et environnements de développement Architecture des applications', 'Module 1 de la formation.', 'À définir', 1),
(662, 121, 'Intégration d’éléments graphiques et visuels Gestion des contenus audio et vidéo Animations et interactions utilisateur', 'Module 2 de la formation.', 'À définir', 2),
(663, 121, 'Ergonomie et UX/UI Conception d’interfaces interactives Responsive design et accessibilité', 'Module 3 de la formation.', 'À définir', 3),
(664, 121, 'Réalisation de projets multimédia concrets Travail en équipe Présentation et soutenance de projets', 'Module 4 de la formation.', 'À définir', 4),
(665, 122, '(aperçu – programme détaillé dans la brochure)', 'Module 1 de la formation.', 'À définir', 1),
(666, 122, 'Analyse des besoins utilisateurs', 'Module 2 de la formation.', 'À définir', 2),
(667, 122, 'Modélisation applicative', 'Module 3 de la formation.', 'À définir', 3),
(668, 122, 'Architecture logicielle', 'Module 4 de la formation.', 'À définir', 4),
(669, 122, 'Développement front-end', 'Module 5 de la formation.', 'À définir', 5),
(670, 122, 'Développement back-end', 'Module 6 de la formation.', 'À définir', 6),
(671, 122, 'Gestion des données', 'Module 7 de la formation.', 'À définir', 7),
(672, 122, 'Tests applicatifs', 'Module 8 de la formation.', 'À définir', 8),
(673, 122, 'Sécurisation des applications', 'Module 9 de la formation.', 'À définir', 9),
(674, 122, 'Optimisation des performances', 'Module 10 de la formation.', 'À définir', 10),
(675, 122, 'Projet applicatif complet', 'Module 11 de la formation.', 'À définir', 11),
(676, 122, 'Travail en équipe', 'Module 12 de la formation.', 'À définir', 12),
(677, 122, 'Présentation et soutenance', 'Module 13 de la formation.', 'À définir', 13),
(678, 123, '(aperçu – programme détaillé dans la brochure)', 'Module 1 de la formation.', 'À définir', 1),
(679, 123, 'Installation et configuration des systèmes', 'Module 2 de la formation.', 'À définir', 2),
(680, 123, 'Gestion des utilisateurs et des droits', 'Module 3 de la formation.', 'À définir', 3),
(681, 123, 'Supervision des serveurs', 'Module 4 de la formation.', 'À définir', 4),
(682, 123, 'Architecture réseau', 'Module 5 de la formation.', 'À définir', 5),
(683, 123, 'Configuration des équipements', 'Module 6 de la formation.', 'À définir', 6),
(684, 123, 'Sécurisation des flux', 'Module 7 de la formation.', 'À définir', 7),
(685, 123, 'Sauvegarde et restauration', 'Module 8 de la formation.', 'À définir', 8),
(686, 123, 'Sécurité des systèmes et réseaux', 'Module 9 de la formation.', 'À définir', 9),
(687, 123, 'Gestion des incidents', 'Module 10 de la formation.', 'À définir', 10),
(688, 123, 'Mise en situation réelle', 'Module 11 de la formation.', 'À définir', 11),
(689, 123, 'Projet d’infrastructure', 'Module 12 de la formation.', 'À définir', 12),
(690, 123, 'Présentation et validation', 'Module 13 de la formation.', 'À définir', 13),
(691, 124, 'Module 1 – Méthodes de gestion de projet', 'Module 1 de la formation.', 'À définir', 1),
(692, 124, 'Principes fondamentaux de la gestion de projet', 'Module 2 de la formation.', 'À définir', 2),
(693, 124, 'Organisation, planification et coordination', 'Module 3 de la formation.', 'À définir', 3),
(694, 124, 'Module 2 – Développement Front-End', 'Module 4 de la formation.', 'À définir', 4),
(695, 124, 'HTML5 / CSS3', 'Module 5 de la formation.', 'À définir', 5),
(696, 124, 'JavaScript et jQuery', 'Module 6 de la formation.', 'À définir', 6),
(697, 124, 'Framework Bootstrap', 'Module 7 de la formation.', 'À définir', 7),
(698, 124, 'Interfaces web responsives et interactives', 'Module 8 de la formation.', 'À définir', 8),
(699, 124, 'Module 3 – Développement Back-End', 'Module 9 de la formation.', 'À définir', 9),
(700, 124, 'Bases de données MySQL', 'Module 10 de la formation.', 'À définir', 10),
(701, 124, 'Langage SQL', 'Module 11 de la formation.', 'À définir', 11),
(702, 124, 'Interaction application / base de données', 'Module 12 de la formation.', 'À définir', 12),
(703, 124, '👉 Le programme détaillé est disponible dans la brochure officielle.', 'Module 13 de la formation.', 'À définir', 13),
(704, 125, 'Droit du travail et veille sociale', 'Comprendre les fondamentaux juridiques.', '35 heures', 1),
(705, 125, 'Administration du personnel', 'Contrats, absences, et gestion quotidienne.', '49 heures', 2),
(706, 125, 'Recrutement et intégration', 'Sourcing, entretiens, et onboarding.', '35 heures', 3),
(707, 125, 'Gestion de la paie', 'Éléments variables, DSN, et bulletins.', '70 heures', 4),
(708, 125, 'Développement des compétences', 'GPEC et ingénierie de formation.', '35 heures', 5),
(709, 126, 'Administration du personnel', 'Gérer les contrats, les absences, les congés et les dossiers salarié·e·s.', 'Module 1', 1),
(710, 126, 'Processus de recrutement', 'Rédiger des annonces, trier les CV, participer aux entretiens et à l\'intégration.', 'Module 2', 2),
(711, 126, 'Développement des compétences', 'Organiser la formation interne et suivre le plan de développement.', 'Module 3', 3),
(712, 126, 'Préparation de la paie', 'Collecter et vérifier les éléments variables pour la transmission à la paie.', 'Module 4', 4),
(713, 127, 'Droit du travail et veille sociale', 'Comprendre les fondamentaux juridiques.', '35 heures', 1),
(714, 127, 'Administration du personnel', 'Contrats, absences, et gestion quotidienne.', '49 heures', 2),
(715, 127, 'Recrutement et intégration', 'Sourcing, entretiens, et onboarding.', '35 heures', 3),
(716, 127, 'Gestion de la paie', 'Éléments variables, DSN, et bulletins.', '70 heures', 4),
(717, 127, 'Développement des compétences', 'GPEC et ingénierie de formation.', '35 heures', 5),
(718, 128, 'Droit du travail et veille sociale', 'Comprendre les fondamentaux juridiques.', '35 heures', 1),
(719, 128, 'Administration du personnel', 'Contrats, absences, et gestion quotidienne.', '49 heures', 2),
(720, 128, 'Recrutement et intégration', 'Sourcing, entretiens, et onboarding.', '35 heures', 3),
(721, 128, 'Gestion de la paie', 'Éléments variables, DSN, et bulletins.', '70 heures', 4),
(722, 128, 'Développement des compétences', 'GPEC et ingénierie de formation.', '35 heures', 5),
(723, 129, 'Comptabilité générale et opérations courantes', 'Maîtrise des écritures de base.', '70 heures', 1),
(724, 129, 'Fiscalité de l\'entreprise', 'TVA, impôts sur les sociétés, liasses fiscales.', '49 heures', 2),
(725, 129, 'Travaux d\'inventaire et Bilan', 'Amortissements, provisions, et clôture.', '70 heures', 3),
(726, 129, 'Gestion financière et trésorerie', 'Analyse financière et suivi bancaire.', '35 heures', 4),
(727, 129, 'Numérisation de la fonction comptable', 'Maîtrise de Sage, Cegid et autres ERP.', '21 heures', 5),
(728, 130, 'Droit du travail et veille sociale', 'Comprendre les fondamentaux juridiques.', '35 heures', 1),
(729, 130, 'Administration du personnel', 'Contrats, absences, et gestion quotidienne.', '49 heures', 2),
(730, 130, 'Recrutement et intégration', 'Sourcing, entretiens, et onboarding.', '35 heures', 3),
(731, 130, 'Gestion de la paie', 'Éléments variables, DSN, et bulletins.', '70 heures', 4),
(732, 130, 'Développement des compétences', 'GPEC et ingénierie de formation.', '35 heures', 5),
(733, 131, 'Module principal', 'Contenu détaillé disponible sur demande.', 'À définir', 1),
(734, 132, 'Fondamentaux systèmes & réseaux', 'Module 1 de la formation.', 'À définir', 1),
(735, 132, 'Sécurité des infrastructures informatiques', 'Module 2 de la formation.', 'À définir', 2),
(736, 132, 'Virtualisation & environnements serveurs', 'Module 3 de la formation.', 'À définir', 3),
(737, 132, 'Réseaux avancés et services', 'Module 4 de la formation.', 'À définir', 4),
(738, 132, 'Supervision, maintenance et continuité de service', 'Module 5 de la formation.', 'À définir', 5),
(739, 132, 'Projets professionnels et mises en situation', 'Module 6 de la formation.', 'À définir', 6),
(740, 133, 'Fondamentaux systèmes & réseaux', 'Module 1 de la formation.', 'À définir', 1),
(741, 133, 'Sécurité des infrastructures informatiques', 'Module 2 de la formation.', 'À définir', 2),
(742, 133, 'Virtualisation & environnements serveurs', 'Module 3 de la formation.', 'À définir', 3),
(743, 133, 'Réseaux avancés et services', 'Module 4 de la formation.', 'À définir', 4),
(744, 133, 'Supervision, maintenance et continuité de service', 'Module 5 de la formation.', 'À définir', 5),
(745, 133, 'Projets professionnels et mises en situation', 'Module 6 de la formation.', 'À définir', 6),
(746, 134, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 37949, méthodologie du dossier de pratiques professionnelles et préparation à la certification devant jury.', 'Accompagnement tout au long du parcours', 1),
(747, 134, 'Bloc 1 – Arrêtés comptables périodiques et annuels', 'Déterminer les opérations d\'inventaire pour l\'arrêté des comptes, réviser et valider les comptes annuels (bilan, compte de résultat). Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 2),
(748, 134, 'Bloc 2 – Déclarations fiscales', 'Établir, contrôler et valider les déclarations fiscales périodiques et annuelles. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 3),
(749, 134, 'Bloc 3 – Analyse et prévisions financières', 'Analyser les états comptables de synthèse, établir et présenter des budgets et prévisions financières. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 4),
(750, 135, 'Comptabilité générale et opérations courantes', 'Maîtrise des écritures de base.', '70 heures', 1),
(751, 135, 'Fiscalité de l\'entreprise', 'TVA, impôts sur les sociétés, liasses fiscales.', '49 heures', 2),
(752, 135, 'Travaux d\'inventaire et Bilan', 'Amortissements, provisions, et clôture.', '70 heures', 3),
(753, 135, 'Gestion financière et trésorerie', 'Analyse financière et suivi bancaire.', '35 heures', 4),
(754, 135, 'Numérisation de la fonction comptable', 'Maîtrise de Sage, Cegid et autres ERP.', '21 heures', 5),
(755, 136, 'AT1 – Concevoir les éléments graphiques d\'une interface et de supports de communication', 'Réalisation d\'illustrations, graphismes, visuels, interfaces graphiques, prototypes et animations. Création de supports de communication.', 'À définir', 1),
(756, 136, 'AT2 – Contribuer à la gestion et au suivi d\'un projet de communication numérique', 'Mise en œuvre d\'une stratégie webmarketing. Veille professionnelle et développement des compétences collectives de l\'équipe.', 'À définir', 2),
(757, 136, 'AT3 – Réaliser, améliorer et animer des sites Web', 'Intégration de pages web, adaptation de CMS, optimisation continue des sites web et interfaces.', 'À définir', 3),
(758, 137, 'Assister la direction au quotidien', 'Organisation des agendas, gestion des emails, accueil et filtrage.', 'À définir', 1),
(759, 137, 'Organisation des réunions et événements', 'Préparation, logistique, rédaction des comptes rendus.', 'À définir', 2),
(760, 137, 'Traitement et gestion de l\'information', 'Maîtrise des outils numériques, rédaction professionnelle et veille.', 'À définir', 3),
(761, 137, 'Préparation à l\'examen final (5h45)', 'Mise en situation professionnelle, entretien technique et présentation du dossier au jury.', 'À définir', 4),
(762, 139, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 38666, méthodologie de rédaction du dossier professionnel (pratiques en situation réelle) et préparation à l\'examen devant jury.', 'Accompagnement tout au long du parcours', 1),
(763, 139, 'Bloc 1 – Piloter l\'activité commerciale du magasin', 'Organiser la chaîne d\'approvisionnement, construire et ajuster l\'offre commerciale, concevoir une expérience client différenciante. Évaluations formatives consignées dans le livret remis au jury.', 'Bloc certifiable à part', 2),
(764, 139, 'Bloc 2 – Performance économique et contribution stratégique', 'Participer aux orientations de l\'enseigne, élaborer les prévisionnels de l\'établissement, analyser les indicateurs de performance et proposer des plans d\'action correctifs.', 'Bloc certifiable à part', 3),
(765, 139, 'Bloc 3 – Manager et fédérer les équipes', 'Conduire le recrutement et l\'intégration, développer la performance individuelle et collective, animer le quotidien du point de vente et porter les projets transverses avec les équipes.', 'Bloc certifiable à part', 4),
(766, 139, 'Accompagnement emploi Alt RH & formations', 'Ateliers gratuits : optimisation du CV et de la lettre de motivation, techniques de recherche d\'emploi et de stage, valorisation du profil sur LinkedIn et les réseaux professionnels.', 'Inclus dans le parcours', 5),
(767, 140, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 40989, méthodologie de rédaction du dossier professionnel (pratiques en situation réelle) et préparation à la certification.', 'Accompagnement tout au long du parcours', 1),
(768, 140, 'Bloc 1 – Transactions immobilières (vente et location)', 'Constituer le dossier de mise en vente ou en location, promouvoir le bien, finaliser le dossier jusqu\'à l\'avant-contrat et traiter les opérations spécifiques (VEFA, viager…). Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 2),
(769, 140, 'Bloc 2 – Gestion locative', 'Monter le dossier locatif jusqu\'à la signature du bail, assurer la gestion courante du bien et prendre en charge les spécificités du logement social. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 3),
(770, 140, 'Bloc 3 – Copropriété', 'Faciliter la gestion administrative courante, participer à l\'élaboration du budget, organiser l\'assemblée générale des copropriétaires. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 4),
(771, 140, 'Préparation à l\'épreuve certificative', 'Entraînement à la mise en situation professionnelle, consolidation des attendus du jury et révision des productions attendues (36 h intégrées aux blocs).', '36 heures', 5),
(772, 140, 'Accompagnement emploi Alt RH & formations', 'Ateliers gratuits : CV et lettre de motivation, techniques de recherche d\'emploi et de stage, présence professionnelle sur LinkedIn et les réseaux.', 'Inclus dans le parcours', 6),
(773, 141, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 36964, méthodologie de rédaction du dossier professionnel et préparation à la certification devant jury.', 'Accompagnement tout au long du parcours', 1),
(774, 141, 'Bloc 1 – Ventes et achats à l\'international', 'Élaborer une offre à l\'international et en assurer le suivi, traiter les commandes, gérer la relation client ou fournisseur à l\'étranger. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 2),
(775, 141, 'Bloc 2 – Logistique internationale', 'Coordonner les opérations d\'acheminement, traiter les litiges transport et logistique, suivre les opérations administratives de dédouanement. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 3),
(776, 141, 'Bloc 3 – Support au développement commercial', 'Promouvoir l\'image de l\'entreprise à l\'international, contribuer à l\'optimisation des achats et au développement des ventes, élaborer et actualiser des tableaux de bord commerciaux. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 4),
(777, 141, 'Préparation à l\'épreuve certificative', 'Entraînement à la mise en situation professionnelle, consolidation des attendus du jury et révision des productions en français et en anglais (42 h intégrées aux blocs).', '42 heures', 5),
(778, 141, 'Accompagnement emploi Alt RH & formations', 'Ateliers gratuits : CV et lettre de motivation, techniques de recherche d\'emploi et de stage, présence professionnelle sur LinkedIn et les réseaux.', 'Inclus dans le parcours', 6),
(779, 142, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 37274, méthodologie de rédaction du dossier professionnel (pratiques en situation réelle) et préparation à l\'examen devant jury.', 'Accompagnement tout au long du parcours', 1),
(780, 142, 'Bloc 1 – Accueillir et analyser la demande', 'Informer sur les ressources d\'insertion et les services dématérialisés, analyser la demande et poser les bases d\'un diagnostic partagé, exercer une veille adaptée au public, travailler en réseau et réaliser les écrits professionnels en environnement numérique. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 2),
(781, 142, 'Bloc 2 – Accompagner le parcours d\'insertion', 'Contractualiser et suivre le parcours, accompagner l\'élaboration et la réalisation du projet professionnel, concevoir et animer des ateliers thématiques, analyser sa pratique professionnelle. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 3),
(782, 142, 'Bloc 3 – Mobiliser les employeurs du territoire', 'Prospecter les employeurs pour favoriser l\'insertion, apporter un appui technique au recrutement, faciliter l\'intégration et le maintien en poste, inscrire ses actes dans une démarche durable et inclusive. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 4),
(783, 142, 'Accompagnement emploi Alt RH & formations', 'Ateliers gratuits : méthodologie CV et lettre de motivation, techniques de recherche de stage, valorisation du profil sur LinkedIn et les réseaux professionnels.', 'Inclus dans le parcours', 5),
(784, 143, 'Programme, temps de rédaction du dossier professionnel', 'Présentation du référentiel ministériel et du parcours ; méthodes pour construire votre dossier professionnel (pratiques en situation réelle) à remettre au jury.', 'Tout au long du parcours', 1),
(785, 143, 'Bloc 1 — Contribuer à l’efficacité commerciale de l’unité marchande (omnicanal)', 'Veille professionnelle et commerciale ; gestion des flux marchands ; contribution au merchandising ; analyse des performances commerciales et restitution aux équipes ou à la hiérarchie. Évaluations en cours de formation avec livret d’évaluation remis au jury lorsque votre parcours le prévoit.', 'Bloc certifiable à part', 2),
(786, 143, 'Bloc 2 — Améliorer l’expérience client (omnicanal)', 'Représenter l’unité marchande et contribuer à l’image de la marque ; conduire l’entretien de vente et conseiller ; assurer le suivi des ventes ; fidéliser en consolidant l’expérience client bout en bout. Livret d’évaluation remis au jury lorsque votre parcours le prévoit.', 'Bloc certifiable à part', 3),
(787, 143, 'Préparation aux épreuves (gratuit)', 'Découverte du métier dans le cadre officiel (« votre métier, votre référentiel »), travail méthodologique pour l’oral de certification et consolidation des attendus ministériels du jury.', 'Inclus Alt RH', 4),
(788, 143, 'Accompagnement emploi (gratuit)', 'CV et lettre de motivation, techniques de recherche d’emploi ou de stage, usage des réseaux professionnels type LinkedIn — sur le périmètre Alt RH.', 'Inclus Alt RH', 5),
(789, 144, 'Compétence clé 1 — HTML et application de création web', 'Maîtriser le langage HTML et une application de création web. Comprendre le rôle du W3C et ses recommandations. Exploiter le code source et la vue de conception, définir les options et préférences de l\'application.', 'Module 1', 1),
(790, 144, 'Compétence clé 2 — Le langage CSS', 'Maîtriser le CSS : création et modification de règles, formatage de texte, objets graphiques et mise en page des contenus web.', 'Module 2', 2),
(791, 144, 'Compétence clé 3 — Optimiser son site web', 'Appliquer les bonnes pratiques de contenu, optimiser la vitesse de chargement, vérifier et corriger une page web, maîtriser les techniques de référencement pour les moteurs de recherche.', 'Module 3', 3),
(792, 144, 'Compétence clé 4 — Exploitation de WordPress', 'Utiliser les fonctionnalités avancées de WordPress, HTML et CSS pour enrichir le contenu, gérer les réglages via le tableau de bord, personnaliser le site avec thèmes et extensions.', 'Module 4', 4),
(793, 145, 'Cadrage du parcours et dossier professionnel', 'Présentation du référentiel RNCP 37099, méthodologie de rédaction du dossier professionnel et préparation à la certification devant jury.', 'Accompagnement tout au long du parcours', 1),
(794, 145, 'Bloc 1 – Mise à disposition des produits en omnicanal', 'Approvisionner l\'unité marchande, assurer la présentation marchande, contribuer à la gestion et l\'optimisation des stocks, traiter les commandes clients. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 2),
(795, 145, 'Bloc 2 – Accueil et service client en omnicanal', 'Accueillir, renseigner et servir les clients, contribuer à l\'amélioration de l\'expérience d\'achat, tenir un poste de caisse et superviser les caisses libre-service. Livret d\'évaluation remis au jury.', 'Bloc certifiable à part', 3),
(796, 145, 'Préparation à l\'épreuve certificative', 'Entraînement à la mise en situation professionnelle et consolidation des attendus du jury (42 h intégrées aux blocs).', '42 heures', 4),
(797, 145, 'Accompagnement emploi Alt RH & formations', 'Ateliers gratuits : CV et lettre de motivation, techniques de recherche de stage, valorisation du profil sur LinkedIn et les réseaux professionnels.', 'Inclus dans le parcours', 5),
(798, 146, 'BC1 – Concevoir et réaliser des compositions graphiques', 'Appliquer et intégrer des techniques simples et avancées de mise en page et d\'illustration. Mener une veille créative et artistique.', 'Bloc de compétences', 1),
(799, 146, 'BC2 – Développer des solutions visuelles innovantes et multimédia', 'Concevoir des designs pour packaging, PLV et signalétique. Créer des contenus en motion design et vidéo. Mener une veille technologique et s\'adapter aux innovations.', 'Bloc de compétences', 2),
(800, 146, 'BC3 – Gérer et coordonner des projets de communication visuelle', 'Comprendre et traduire les besoins clients. Gérer un projet en collaboration avec clients, prestataires et partenaires. Assurer le suivi technique et la qualité des livrables.', 'Bloc de compétences', 3),
(801, 147, 'BC1 — Préparer et effectuer le montage de productions courtes', 'Configurer la station de montage et les périphériques. Importer et organiser rushs audio, médias graphiques et plans. Produire des sujets d’information courts, des formats publicitaires courts et des fictions courtes conformément aux briefs ; ajuster montage image/son au fil des retours. Habillage graphique léger lorsque prévu dans le projet. Enregistrer un projet exploitable (PAD) et préparer livrables de contrôle qualité.', 'Bloc de compétences', 1),
(802, 147, 'BC2 — Techniques avancées du montage', 'Étalonnage sur séquences narratives ou documentaires ; compositing (incrustations, calques dynamiques…). Chaîne son multipiste : synchro pistes, niveaux relatifs et préparation cohérente pour mixage aval en studio ou poste hors site.', 'Bloc de compétences', 2),
(803, 147, 'Coloration — Analyste vidéo sport (100 h)', 'Captations sur le terrain avec cadrages adaptés (plans fixes ou dynamiques « lecture » tactique…). Découpage et annotations logiciel spécialisé (zones d’attention, comportements joueurs équipe adverse…). Sélection ordonnancement de clips pour narration coach. Concevoir présentations pour staff : analyses collectives/individuelles, retours de performance. Narration courte type « storytelling » sport sans surenchère production. Injection de données chiffrées ou graphiques animés lorsque pertinent pour faire parler une action.', '100 h', 3),
(804, 148, 'Programme, dossier professionnel et feuilles de route', 'Cadrage du référentiel RNCP 38575 ; rédiger et préparer votre dossier professionnel à présenter au jury avec appui méthodologique.', 'Tout au long du parcours', 1),
(805, 148, 'Bloc 1 — Diriger une structure avec une équipe', 'Développer une vision systémique dans l’environnement de la structure ; inscrire la structure dans son territoire ; manager et animer une équipe. Livret d’évaluation en cours de formation à remettre au jury lorsque votre parcours le prévoit.', 'Bloc de compétences', 2),
(806, 148, 'Bloc 2 — Mettre en œuvre l’objet social de la structure', 'Adapter l’offre aux besoins du marché ; organiser et développer la diffusion de l’offre ; organiser la production (biens ou services). Livret d’évaluation en cours de formation lorsque votre parcours le prévoit.', 'Bloc de compétences', 3),
(807, 148, 'Bloc 3 — Établir et présenter le rapport d’activité', 'Analyser le bilan de la structure ; analyser le compte de résultat ; rédiger le rapport d’activité destiné aux instances de pilotage ou à la hiérarchie. Livret d’évaluation en cours de formation lorsque votre parcours le prévoit.', 'Bloc de compétences', 4),
(808, 148, 'Préparation à l’épreuve collective', 'Travail de consolidation avant certification (dont une enveloppe indicative d’environ 42 h intégrée au périmètre officiel du titre — précisions au moment de votre inscription selon votre organisme dispensateur).', 'Intégré au titre', 5),
(809, 148, 'Orientation emploi (ateliers proposés en complément)', 'Méthodologie CV et lettre de motivation, techniques pour décrocher une période en entreprise ou un emploi, usage pertinent des réseaux professionnels (LinkedIn etc.) — gratuit dans le périmètre habituel Alt RH & formations.', 'Module offert Alt RH', 6),
(810, 149, 'Entrée en formation & dossier de pratiques', 'Sensibilisation au cadre légal ministériel RNCP ; organisation des preuves de compétences et accompagnements pour constituer le dossier remis lors des jurys officiels lorsque votre parcours le nécessite.', 'Tutorat dans la durée', 1),
(811, 149, 'Bloc 1 — Gestion administrative, juridique & bulletins de paie', 'Collecter et contrôler les informations nécessaires à la rémunération brute ; garantir le calcul correct des cotisations sociales puis le traitement des éléments impactant la rémunération nette ; produire et contrôler les bulletins ainsi que les transmissions réglementaires (DSN…) dans le cadre légal français.', 'Bloc certifiable RNCP à part.', 2),
(812, 149, 'Bloc 2 — Valoriser en paie la vie professionnelle', 'Évaluer et saisir en paie les événements liés au temps de travail, aux absences et aux primes particulières ; gérer correctement les sorties de personnel (soldes et attestations…) ; contrôler la cohérence des données issues du dossier jusqu’aux interfaces comptables ou sociales.', 'Bloc certifiable RNCP à part.', 3),
(813, 150, 'Entrée en formation — titre RNCP 40800 et organisation du parcours', 'Présentation du référentiel officiel France Compétences, du livret d’apprentissage et des modalités de certification ; définition du calendrier, du positionnement et des mises en situation professionnelle.', 'Tutorat dans la durée', 1),
(814, 150, 'Bloc 1 — Assurer l’accueil du patient et les activités administratives courantes d’une structure médicale', 'Compétences visées : accueillir, renseigner et orienter un patient ; gérer les plannings et agendas des professionnels de santé ; réaliser la prise en charge administrative et financière du patient ; transmettre par écrit des informations administratives et médicales à l’interne et à l’externe.', 'Bloc certifiable RNCP — capitalisation possible', 2),
(815, 150, 'Bloc 2 — Assister les professionnels de santé dans le suivi et la coordination du parcours patient', 'Compétences visées : renseigner et orienter le public dans un service sanitaire, médico-social ou social ; transcrire, vérifier et mettre en forme des documents médicaux ; renseigner sur l’accès au dossier médical du patient ou préparer les éléments nécessaires dans le cadre légal.', 'Bloc certifiable RNCP — capitalisation possible', 3),
(816, 150, 'Insertion professionnelle et préparation aux épreuves du titre', 'Ateliers CV et lettres de motivation, simulations d’entretien, préparation aux jurys et aux mises en situation ; lien avec les MSP et stages conseillés pour sécuriser l’employabilité.', 'Sur la durée du parcours', 4),
(817, 151, 'Programme et dossier professionnel', 'Présentation du titre RNCP 41239 et du déroulé ; méthodes pour rédiger et tenir à jour le dossier professionnel à remettre au jury ; temps tutoré dédié à la rédaction du DP.', 'Sur tout le parcours', 1),
(818, 151, 'Bloc de compétences 1 — Assurer les activités d’accueil d’une structure', 'Assurer l’accueil physique et téléphonique ; gérer des situations complexes à l’accueil ; traiter les flux d’information internes et externes. Évaluations en cours de formation — livret d’évaluation à remettre au jury lorsque votre parcours le prévoit.', 'Bloc certifiable — capitalisation possible', 2),
(819, 151, 'Bloc de compétences 2 — Gérer les activités administratives d’une structure', 'Prendre en charge les activités administratives courantes ; assurer le traitement administratif des dossiers ; traiter les réclamations courantes. Évaluations en cours de formation — livret d’évaluation à remettre au jury lorsque votre parcours le prévoit.', 'Bloc certifiable — capitalisation possible', 3),
(820, 151, 'Accompagnement insertion — recherche d’emploi et stages', 'Ateliers inclus dans le parcours : méthodologie CV et lettre de motivation, techniques de recherche de stage ou d’emploi, réseaux sociaux professionnels (LinkedIn et équivalents).', 'Modules ponctuels — gratuit dans le cadre du parcours Alt RH lorsque prévu à la convention', 4),
(821, 152, 'BC1 — Contribuer à la stratégie de développement de l’organisation', 'Conduire une veille stratégique et appréhender l’environnement externe ; réaliser un diagnostic interne et identifier les opportunités de développement ; proposer un projet de développement durable et responsable avec la direction.', 'Bloc de compétences', 1),
(822, 152, 'BC2 — Définir et planifier des actions marketing et de développement', 'Développer de nouveaux marchés dans le cadre de la stratégie définie ; mettre en œuvre le plan marketing omnicanal ; participer à la mise en place d’un plan de communication RSE.', 'Bloc de compétences', 2),
(823, 152, 'BC3 — Piloter un projet de développement', 'Planifier et lancer un projet de développement ; conduire et promouvoir le projet avec les parties prenantes ; suivre opérationnellement et évaluer les dispositifs déployés.', 'Bloc de compétences', 3),
(824, 152, 'BC4 — Manager durablement une équipe à proximité et à distance', 'Organiser l’équipe pour soutenir le développement de l’organisation ; manager dans des contextes interculturels et intergénérationnels ; piloter la performance de l’équipe en contexte de transition numérique.', 'Bloc de compétences', 4),
(825, 153, 'Introduction à DevOps', 'Histoire, émergence, fondamentaux et avantages. Transformation numérique et DevOps. Les clés d\'une analyse de rentabilité. Domaines de compétences, de connaissances et cadre de compétences. DevOps Agile Skills Association (DASA).', '0,5 jour', 1),
(826, 153, 'Culture DevOps', 'Organisation autour d\'un concept d\'équipes. Aspects culturels d\'une équipe. Mentalité et qualité de service à la source. Éléments clés : équipes motivées, gestion visuelle, amélioration continue, résolution de problèmes, mentalité Kaizen. Leadership dans un environnement DevOps. Leadership et rétroaction. Mise en place d\'une culture DevOps. Changement culturel.', '0,5 jour', 2),
(827, 153, 'Organisation DevOps', 'Modèles organisationnels. Impacts. Alignement du modèle organisationnel avec l\'IT. Importance des versions hybrides DevOps. Équipes autonomes. Loi Conway et architecture des organisations. Architecture et conception pour DevOps. Relation complexité/qualité. Micro Services Architecture (MSA). Architecture pour la résilience systémique. Gouvernance DevOps.', '0,5 jour', 3),
(828, 153, 'Processus', 'Bases de processus. DevOps par rapport à ITSM. Avantages de l\'agile. Agile et Scrum. Fondamentaux du Lean. Les huit types de gaspillage. Cartographie de flux de valeur. Optimisation de la valeur commerciale et analyse de métier. Rôle d\'un produit viable minimal dans un processus Agile. Rôle des tranches dans la cartographie des besoins.', '0,5 jour', 4),
(829, 153, 'Automatisation', 'Automatisation pour la livraison de logiciels. Automatisation de la livraison continue : définition, objectifs, avantages. Automatisation de la distribution continue. Impacts. DevOps versus livraison continue. Émergence du Cloud et impacts dans les organisations DevOps. Approvisionnement automatisé. Appliquer les concepts de Cloud dans une organisation.', '0,5 jour', 5),
(830, 153, 'Mesure et amélioration', 'Besoin de mesure et de rétroaction. Choisir les bonnes métriques. Bonnes pratiques (MTTR). Les cinq principaux indicateurs de la performance IT. Surveillance et enregistrement. Surveillance optimisée pour DevOps. Culture de rétroaction.', '0,5 jour', 6),
(831, 153, 'Conclusion et passage de l\'examen', 'Examen blanc et révisions. Passage de l\'examen de certification DASA DevOps Fundamentals.', '0,5 jour', 7),
(832, 154, 'DevOps : les fondamentaux', 'Les mutations engendrées par la (r)évolution digitale. Les nouveaux challenges. Les solutions : les Méthodes Agiles et DevOps. Leur positionnement parmi les frameworks et normes de la production de services IT. Les fondements du mouvement DevOps.', '0,5 jour', 1),
(833, 154, 'Culture/Partage : de la coordination à l\'intelligence collective', 'Accompagner l\'évolution. Constituer des équipes pluridisciplinaires, mettre en place l\'apprentissage continu. Stades de maturité d\'une équipe. Adapter la gouvernance : passer d\'une structure mécanique à une structure innovante. L\'engagement de tous, le vrai défi pour les managers. Faire évoluer les postures. TP : ateliers collaboratifs pour mettre en pratique l\'auto-gouvernance, établir les bases d\'une communication efficace et développer l\'intelligence collective.', '0,5 jour', 2),
(834, 154, 'Automatisation : dégager de la valeur sur la chaîne de production logicielle', 'Les choix d\'architecture. La gestion des exigences produit et les outils associés. La gestion des environnements, de version, la livraison continue, l\'automatisation des tests et le déploiement continu. Le passage à l\'échelle. TP : définir un \'Backlog DevOps\' permettant de construire une chaîne de déploiement continu, priorisation et définition du plan d\'itérations.', '0,5 jour', 3),
(835, 154, 'Mesure : collecter du feedback et s\'améliorer en continu', 'Définitions essentielles et exemples de métriques. Les différentes sources de données. Les étapes clés à considérer. Focus sur l\'approche Lean Start Up. La surveillance continue et les outils associés. Le dashboard DevOps comme support au management visuel. TP : définition des métriques, spécification du Dashboard d\'équipe, mise à jour du Backlog DevOps.', '0,5 jour', 4),
(836, 155, 'Jour 1 — Introduction et ISO/IEC 27035 (vue d\'ensemble)', 'Sections 1 à 9 : objectifs et déroulé de la formation ; famille ISO/IEC 27000 et série 27035 ; concepts CID, événements vs incidents, vulnérabilités et menaces ; objectifs et bonnes pratiques de gestion des incidents ; politiques et procédures ; gestion des risques (contexte, analyse, traitement, surveillance) ; plan de gestion des incidents et revue des processus ; équipe de gestion des incidents et coordinateur ; relations internes/externes et communication.', '7 h', 1),
(837, 155, 'Section 1 — Objectifs et structure de la formation (0h20)', 'Introduction, informations générales, objectifs d\'apprentissage, approche pédagogique, examen et certification, présentation de PECB.', '20 min', 2),
(838, 155, 'Section 2 — Normes et cadres réglementaires (0h40)', 'Rôle de l\'ISO ; famille ISO/IEC 27000 ; série ISO/IEC 27035 et articulation 27035-1, 27035-2, 27035-3 ; autres normes et réglementations connexes. Activité : quiz.', '40 min', 3),
(839, 155, 'Section 3 — Concepts fondamentaux de la gestion des incidents (1h)', 'Sécurité de l\'information, triade CID, vulnérabilité et menace, risques, événements et incidents, gestion des incidents, plan de réponse, vie privée, classification des contrôles. Activité : quiz.', '1 h', 4),
(840, 155, 'Section 4 — Gestion des incidents de sécurité de l\'information (0h50)', 'Objectifs, bonnes pratiques, lien avec le SMSI, approche structurée de gestion des incidents. Activité : quiz.', '50 min', 5),
(841, 155, 'Section 5 — Politiques et procédures (0h40)', 'Politiques, plans et processus ; politique de gestion des incidents ; rédaction et communication. Activité : quiz.', '40 min', 6),
(842, 155, 'Section 6 — Gestion des risques (1h10)', 'Contexte, identification, analyse, évaluation et hiérarchisation des risques ; traitement, plan de traitement, concertation, rapports, surveillance et revue. Activité : quiz.', '1 h 10', 7),
(843, 155, 'Section 7 — Plan de gestion des incidents (1h)', 'Contenu du plan, rôles et responsabilités, revue des processus documentés. Activité : quiz et exercice 1.', '1 h', 8),
(844, 155, 'Section 8 — Équipe de gestion des incidents (0h40)', 'Constitution de l\'équipe, rôles, coordinateur d\'incidents, compétences et structure de l\'équipe de réponse. Activité : quiz.', '40 min', 9),
(845, 155, 'Section 9 — Relations internes et externes (0h40)', 'Relations avec les directions et parties externes, partage d\'informations avec des tiers, communication interne et externe. Activité : quiz.', '40 min', 10),
(846, 155, 'Jour 2 — Processus de gestion des incidents et certification', 'Sections 10 à 20 : sensibilisation et formation ; tests et préparation ; surveillance réseau et systèmes ; détection et classification ; collecte de preuves et rapport ; évaluation et priorisation ; résolution ; contention, éradication et reprise ; retours d\'expérience ; surveillance et indicateurs ; clôture et schéma de certification PECB.', '7 h', 11),
(847, 155, 'Section 10 — Sensibilisation et formation (0h40)', 'Programmes de sensibilisation, développement des compétences et évaluation. Activité : quiz.', '40 min', 12),
(848, 155, 'Section 11 — Tests (0h50)', 'Tests des systèmes, techniques, étapes, préparation documentaire, activités post-tests. Activité : quiz.', '50 min', 13),
(849, 155, 'Section 12 — Surveillance des systèmes et réseaux (0h50)', 'Capacités de surveillance, surveillance réseau et systèmes, ISCM, indicateurs et évaluation des performances. Activité : quiz.', '50 min', 14),
(850, 155, 'Section 13 — Détection et alerte (0h50)', 'Mécanismes de détection, méthodologie attaquants, signes d\'incident, classification et niveaux. Activité : quiz.', '50 min', 15),
(851, 155, 'Section 14 — Collecte et rapport des événements (0h50)', 'Sources d\'information, collecte de preuves, signalement, analyse, documentation des impacts, rapport. Activité : quiz.', '50 min', 16),
(852, 155, 'Section 15 — Évaluation des événements (0h40)', 'Évaluation et décision, priorisation des incidents. Activité : quiz.', '40 min', 17),
(853, 155, 'Section 16 — Résolution des incidents (0h30)', 'Rôles pendant la phase de réponse, réponse aux incidents. Activité : quiz.', '30 min', 18),
(854, 155, 'Section 17 — Contention, éradication et reprise (0h50)', 'Stratégie de confinement, isolement, indicateurs de compromission, preuves, sauvegardes. Activité : quiz et exercice 2.', '50 min', 19),
(855, 155, 'Section 18 — Retours d\'expérience (0h30)', 'Axes d\'amélioration du plan et de l\'équipe IMT, contrôles SI et revue de direction. Activité : quiz.', '30 min', 20),
(856, 155, 'Section 19 — Surveillance, mesure et analyse (0h40)', 'Objectifs de mesure, indicateurs de performance pour la gestion des incidents, fréquence et reporting. Activité : quiz.', '40 min', 21),
(857, 155, 'Section 20 — Clôture et certification PECB (0h20)', 'Schéma et processus de certification PECB ISO/IEC 27035.', '20 min', 22),
(858, 156, 'Généralités sur les bases relationnelles', 'Modèle client/serveur ; structure d\'une base (base, schéma, tables) ; panorama des principaux SGBDR.', '2 h', 1),
(859, 156, 'Présentation du langage SQL', 'Le langage SQL ; types d\'instructions DDL, DML, DCL ; éléments de syntaxe ; lien avec l\'algèbre relationnelle.', '1 h', 2),
(860, 156, 'Manipulation des données', 'Insertions (INSERT), modifications (UPDATE), suppressions (DELETE/TRUNCATE) ; clause RETURNING ou OUTPUT selon le SGBDR utilisé.', '4 h', 3),
(861, 156, 'Interrogation des données (SELECT, agrégations, sous-requêtes)', 'Structure de SELECT ; alias ; WHERE ; LIKE, SIMILAR TO, IS NULL, IN ; agrégats ; GROUP BY, HAVING, ORDER BY ; LIMIT ; OFFSET/FETCH selon moteur. Sous-requêtes simples et corrélées ; EXISTS ; vues ; CTE (WITH) ; UNION, INTERSECT ; EXCEPT/MINUS selon SGBDR ; fonctions sur chaînes et dates ; tables temporaires selon environnement.', '3 h', 4),
(862, 156, 'Jointures et requêtes multi-tables', 'Produit cartésien ; jointures internes ; jointure naturelle ; ON ; USING ; équi-jointure ; auto-jointure ; jointures externes gauche, droite et complète selon le SGBDR utilisé.', '8 h', 5),
(863, 156, 'Fonctions de fenêtrage', 'Intérêt analytique ; principales fonctions ; OVER() ; ORDER BY et PARTITION BY ; ROW/RANGE BETWEEN selon le SGBDR.', '2 h', 6),
(864, 157, 'Introduction à Docker', 'Historique et intérêt des conteneurs ; architecture Docker ; installation sur Linux, Windows et macOS. Travaux pratiques : installation sous Windows (conteneurs Linux) et sous Linux.', '2 h', 1),
(865, 157, 'Docker en production — conteneurs et images', 'Manipuler les conteneurs et les images ; récupération et exécution d\'applications. Travaux pratiques : déployer une application Web avec Docker.', '3 h 30', 2),
(866, 157, 'Conception de conteneur', 'Écriture et bonnes pratiques de Dockerfile ; registres et Docker Hub ; builds automatisés. Travaux pratiques : créer un Dockerfile et publier une image.', '3 h 30', 3),
(867, 157, 'Exploitation réseau et stockage', 'Configuration réseau Docker ; volumes persistants ; mise en production d\'un conteneur. Travaux pratiques : création et gestion de réseaux et de volumes.', '3 h 30', 4),
(868, 157, 'Docker Compose — applications multi-conteneurs', 'Présentation de Compose ; liaison et orchestration légère de services. Travaux pratiques : composer une application multi-conteneurs.', '3 h 30', 5),
(869, 157, 'Orchestration avec Docker Swarm', 'Concepts Swarm ; constitution d\'un cluster ; déploiement et scalabilité ; mises à jour rolling ; gestion des nœuds (ajout, mise à jour, suppression). Travaux pratiques : mise en place d\'un cluster et déploiement d\'applications.', '3 h 30', 6),
(870, 157, 'Pour aller plus loin — sécurité et outillage', 'Vue d\'ensemble d\'un outil de gestion graphique ; sécuriser Docker et les données ; introduction à l\'API Docker. Travaux pratiques : durcissement de base d\'un conteneur et des données ; prise en main d\'un outil graphique.', '1 h 30', 7),
(871, 158, 'Introduction et enjeux de sécurité', 'Cyberattaques et menaces ; écosystème des attaquants ; Cyber Kill Chain, TTPs, DDoS ; compétences et moyens nécessaires pour se défendre.', '2 h', 1),
(872, 158, 'Réseaux industriels et IoT', 'Domaines et usages industriels ; vulnérabilités, vecteurs d\'attaque et risques spécifiques.', '2 h', 2),
(873, 158, 'Principes généraux de sécurité', 'Protection de l\'information ; services et critères de sécurité ; axes et méthodes pour aborder la SSI.', '4 h', 3),
(874, 158, 'Analyse et gestion des risques', 'Vue normative ISO 27005 / ISO 27001 ; méthode EBIOS pour structurer l\'analyse et le traitement du risque.', '2 h', 4),
(875, 158, 'Gouvernance de la SSI', 'Politique de sécurité (PSSI), veille sécurité, tableaux de bord ; cadres LPM, NIS, OIV, rapport Bockel ; qualifications ANSSI (PDIS, PRIS).', '3 h', 5),
(876, 158, 'Threat anticipation et audits', 'Choix et préparation d\'audits (PASSI), démarche d\'audit ; exercice type cyber-range Red Team / Blue Team selon configuration de session.', '3 h', 6),
(877, 158, 'SOC et Threat Intelligence', 'Services SOC modernes ; détection, corrélation et incidents ; identification d\'attaques et partage d\'IOC.', '2 h', 7),
(878, 158, 'Architectures de sécurité', 'Défense en profondeur ; cloisonnement ; routage ; pare-feu réseau et applicatif ; diode et passerelles unidirectionnelles ; IDS et honeypots ; proxy et reverse-proxy ; VPN IPsec et SSL ; durcissement du poste (EDR, antivirus, firewall local) ; authentification forte ; cryptographie et PKI.', '3 h', 8),
(879, 159, 'Jour 1 — Fondamentaux, cycle de vie et tests statiques', 'Accueil et déroulement. Fondamentaux : enjeux, vocabulaire, objectifs, test vs débogage, 7 principes, processus, psychologie, code éthique ; révisions QCM. Cycle de vie logiciel : modèles (V, itératif…), niveaux de test, approches et types, régression ; révisions QCM. Techniques statiques : revues, revue formelle, analyse statique et outils ; révisions QCM.', '7 h', 1),
(880, 159, 'Jour 2 — Techniques de conception de tests', 'Quiz de rappel du jour 1. Conception : conditions et cas de test, traçabilité, catégories de techniques. Boîte noire : équivalence, limites, décision, états… Boîte blanche : couverture chemins, branches, décisions, conditions. Techniques basées sur l’expérience et sélection des techniques. Révisions QCM.', '7 h', 2),
(881, 159, 'Jour 3 — Gestion, outils et examen ISTQB Fondation', 'Gestion des tests : organisation, plan, estimation, suivi, configuration, risques, incidents ; révisions QCM. Outils : gestion, statique, spécification, exécution, performance, bénéfices/risques, introduction en organisation. Bloc certification : révision syllabus, simulations QCM et cas, gestion du temps, passage de l’examen officiel. Conclusion.', '7 h', 3),
(882, 160, 'Jour 1 — Développement logiciel Agile (1 et 2)', 'Manifeste Agile et développements logiciels Agile ; approche d’équipe intégrée ; feedback au plus tôt et fréquent. Approches de développement Agile ; rédaction collaborative de user stories ; rétrospectives ; intégration continue ; planification de release et d’itérations.', '7 h', 1),
(883, 160, 'Jour 2 — Principes / pratiques / processus et méthodes de test Agile (1)', 'Différences de tests entre approches traditionnelles et Agile ; statuts du test dans les projets Agile ; rôles et compétences du testeur en équipe Agile. Méthodes de test Agile ; évaluation des risques qualité ; estimation de l’effort de test.', '7 h', 2),
(884, 160, 'Jour 3 — Techniques, outils et certification ISTQB Testeur Agile', 'Techniques de test dans les projets Agile ; outils pour les projets Agile. Conseils et révisions ; examen blanc officiel ISTQB avec correction commentée ; passage de la certification « ISTQB Testeur Agile » (dernier jour de la formation ou ultérieurement en ligne) : 1 h, QCM 40 questions, 65 % minimum.', '7 h', 3),
(885, 161, 'Jour 1 — Fondations, critères d’acceptation et modélisation métier', 'Introduction : relations besoins métier, analyse métier et tests d’acceptation ; critères d’acceptation ; conception ; approches fondées sur l’expérience. Travaux pratiques : tests d’acceptation ATDD et BDD, tests exploratoires ; QCM (5 questions) et correction en groupe. Après-midi : modélisation des processus et règles métier (BPMN, DMN) ; tests d’acceptation à partir des modèles ; TP création de processus en BPMN ; QCM et correction.', '7 h', 1),
(886, 161, 'Jour 2 — Exigences non fonctionnelles, collaboration et certification', 'Tests d’acceptation pour exigences non fonctionnelles : qualité à l’usage, facilité d’utilisation et expérience utilisateur, performance, sécurité ; QCM et correction. Tests d’acceptation en collaboration : activités et outillage ; TP sur métriques de gestion des tests ; QCM et correction. Après-midi : dispositif d’examen (présentiel ou à distance) ; examen blanc complet avec correction commentée ; conseils pour réussir un QCM. Examen de certification : 40 questions en français, 65 % de bonnes réponses minimum (26/40), durée 1 h ; temps additionnel possible sous conditions (français non langue maternelle, RQTH). Passage possible sur tablette ou papier en fin de présentiel, ou à distance à date choisie si formation à distance ou souhait du candidat.', '7 h', 2),
(887, 162, 'Axe 1 — Fondamentaux sécurité des systèmes et des réseaux (35 h)', 'Sécurisation des réseaux (21 h) : attaques sur protocoles et équipements, démonstrations et contre-mesures ; attaques couche 2 et commutateurs ; cibles routeurs et VPN ; pare-feu, IDS/IPS, proxy, etc. Sécurisation Linux (14 h) : durcissement, noyau, droits, mots de passe, protections contre dépassements de tampon, bonnes pratiques des services courants, isolation, automatisation et déploiement de configuration.', '5 jours', 1),
(888, 162, 'Axe 2 — Réglementation cybersécurité (7 h)', 'Enjeux de conformité et cybercriminalité ; RGPD (principes, DPO, sanctions) ; articulation ISO 27001, 27005 et RGPD ; panorama NIS2, DORA, obligations OIV/OSE ; travaux pratiques : évaluation de conformité, plans d’atténuation.', '1 jour', 2);
INSERT INTO `formation_modules` (`id`, `course_id`, `title`, `description`, `duration`, `sort_order`) VALUES
(889, 162, 'Axe 3 — Pilotage d’un plan d’action cybersécurité / SMSI (70 h)', 'Management d’un ISMS selon ISO 27001 et contrôles ISO 27002 ; alignement sur ISO 10006, 27003, 27004, 27005. Derniers jours (14 h) : cybersécurité dans la conception et le management de projets — cartographie des risques, security by design, gouvernance, validation des acquis (QCM) ; TP : maturité, tableaux de bord, plan stratégique.', '10 jours', 3),
(890, 162, 'Axe 4 — Analyse et évaluation des risques (42 h)', 'Gestion des risques pour la sécurité de l’information avec ISO/IEC 27005 et méthode EBIOS Risk Manager (ANSSI) ; exercices et cas pour évaluation et suivi du risque dans le cycle de vie ; mise en perspective avec ISO/IEC 27001.', '6 jours', 4),
(891, 162, 'Axe 5 — Optimisation et coordination des réponses à incidents (14 h)', 'Introduction à la gestion d’incidents de sécurité ; organisation de la réponse ; cadre de gouvernance et normes ; processus opérationnels ; communication et facteurs humains ; mise en pratique sur cas d’usage.', '2 jours', 5),
(892, 162, 'Axe 6 — Mise en œuvre d’actions de contrôle (21 h)', 'Design, déploiement et gestion des contrôles de sécurité ; types et objectifs des contrôles ; cadres d’assurance ; processus de gestion d’audit.', '3 jours', 6),
(893, 162, 'Axe 7 — Sensibilisation et formation des équipes (28 h)', 'Stratégie de formation et de sensibilisation cyber pour utilisateurs finaux ; place dans la stratégie cyber globale ; actions possibles ; plan d’action adapté aux risques ; pilotage et mesure d’impact.', '4 jours', 7),
(894, 163, 'Introduction', 'Création de contenus pour le Web ; HTML, CSS, JavaScript ; organisation d’un site ; navigateurs et compatibilité HTML5/CSS3 ; outils de production.', '2 h', 1),
(895, 163, 'Notions fondamentales HTML5', 'Syntaxe XML, balises, attributs et événements, structure du document, entête ; TP : structure de page, contenus (titres, listes, images), liens de navigation.', '3 h', 2),
(896, 163, 'CSS — bases', 'Feuilles de style, sélecteurs simples et CSS3, héritage, cascades, couleurs, unités (px, in, %, em) ; TP : feuille de style et application multi-pages.', '3 h', 3),
(897, 163, 'Intégration et mise en forme de contenus', 'Texte, paragraphes, listes, espaces, inline/bloc, dimensions, marges, bordures et fonds ; TP : mise en forme texte et mise en page.', '3 h', 4),
(898, 163, 'Structure fluide et positionnement', 'Conteneurs HTML5 (nav, section, main, header, footer), unités avancées (% vh vw calc), positionnements relatif/absolu, habillage ; TP : bandeau d’en-tête.', '2 h', 5),
(899, 163, 'Tableaux de données', 'Table, lignes et cellules, mise en forme ; TP : tableau HTML et habillage CSS.', '1 h', 6),
(900, 163, 'Formulaires HTML5', 'Form, fieldset, label, input, listes de valeurs, output/progress/meter, validation et boutons ; TP : formulaire structuré et stylé.', '1 h', 7),
(901, 163, 'Responsive Web Design', 'Principes, mobile first, media queries, résolutions et viewport ; TP : pages responsive (structure fixe et fluide).', '2 h', 8),
(902, 163, 'Positionnement Flexbox', 'Axes, alignement, flex-grow/shrink, ordre ; TP : mise en page fluide en Flexbox.', '2 h', 9),
(903, 163, 'Fondamentaux JavaScript', 'Fonctions, tableaux, objets, fonctions anonymes et encapsulation, prototype, apports ES6 ; TP : fichiers JS intégrés aux pages.', '4 h', 10),
(904, 163, 'Interaction avec le DOM', 'querySelector / querySelectorAll, parcours et modification du DOM, addEventListener ; TP : objets métiers via formulaire, affichage dans un tableau HTML.', '4 h', 11),
(905, 163, 'Requêtes AJAX — XMLHttpRequest', 'API REST, XMLHttpRequest, JSON, événement progress ; TP : données distantes avec XHR.', '2 h', 12),
(906, 163, 'Fetch API et Promise', 'Requêtes fetch, promesses, synchronisation ; TP : données distantes avec Fetch.', '3 h', 13),
(907, 163, 'Communication temps réel — WebSocket', 'Ouverture/fermeture, émission et réception de messages ; TP : partie cliente d’une communication bidirectionnelle.', '3 h', 14),
(908, 164, 'Introduction au langage Python', 'Présentation et historique ; installation de la distribution ; PyCharm ; environnements virtuels ; documentation officielle.', '1 h', 1),
(909, 164, 'Éléments de base du langage', 'Structure d’un programme, variables et typage dynamique, opérateurs, E/S, contrôles de flux, collections (list, tuple, dict) ; TP : nombre aléatoire à deviner.', '2 h 30', 2),
(910, 164, 'Fonctions, modules et packages', 'Fonctions, retours multiples, *args, paramètres nommés et optionnels, modules, import, packages ; TP : jour de Noël pour une année donnée.', '3 h 30', 3),
(911, 164, 'Programmation orientée objet', 'Classes, attributs, propriétés, méthodes, constructeurs/destructeurs, encapsulation, instanciation, membres de classe, héritage, polymorphisme, méthodes magiques ; TP : Compte et CompteEpargne.', '7 h', 4),
(912, 164, 'Gestion des exceptions', 'Exceptions, levée, try/except, finalisation, classes d’exception personnalisées ; TP : intégration dans Compte.', '3 h 30', 5),
(913, 164, 'Tests unitaires', 'unittest, TestCase, assertions, exécution et lecture des résultats ; TP : tests sur Compte et CompteEpargne.', '3 h 30', 6),
(914, 164, 'Scripts et bibliothèque standard', 'sys et os, commandes système, dates, expressions régulières, fichiers texte ; TP : persistance d’objets Compte dans un fichier.', '7 h', 7),
(915, 164, 'Interfaces graphiques avec Tkinter', 'Principes, widgets, menus, placement, événements ; TP : IHM pour l’application bancaire.', '7 h', 8),
(916, 165, 'Appréhender la révolution digitale', 'Digital : définition, chiffres clés et cibles. Web et principaux acteurs (GAFA, autres grandes plateformes). Médias sociaux (Twitter, Facebook…). Picture marketing : Instagram, Pinterest… Messageries instantanées : Messenger, WhatsApp, Snapchat… Outils collaboratifs : forums, blogs, wikis, cloud. Grandes tendances : impression 3D, réalité virtuelle, IA, IoT, Big Data, machine learning… Exercice : quiz sur tendances, définitions et chiffres du digital.', '≈ 2 h', 1),
(917, 165, 'Ses pratiques et l’impact du digital sur le travail et l’économie', 'Faire le point : où en suis-je avec le digital ? E-business et business digital : crowdfunding, marketplaces, social commerce, French Tech et exemples d’entreprises. Marketing produit : buzz, canaux, inbound marketing, brand content, social brand. E-réputation, économie du partage, employee advocacy. Réglementation et risques : protection des données, neutralité d’Internet… Étude de cas : transformation digitale d’une entreprise. Vidéos sur le digital et la culture d’entreprise.', '≈ 2 h', 2),
(918, 165, 'Identifier les grands métiers du digital', 'Panorama : chef digital / CDO, growth hackers (ex. Dropbox…), lead generation manager, traffic manager, Chief Happiness Officer, community manager, social media manager, data scientist, architecte Big Data, chef de produit web et mobile, développeur d’applications mobiles, brand content manager, UX designer, RSSI, DPO… Exercice : jeu « Qui est-ce ? » sur les métiers du digital.', '≈ 1 h 30', 3),
(919, 165, 'Digitaliser les modes de travail et d’apprentissage', 'Transformation du système d’information : cloud, BYOD, dématérialisation. Aménagement et espaces de travail : télétravail, bureau partagé, nomadisation, fab lab, hackathon… Formation : LMS, e-learning, serious game, mobile learning. Outils de partage : réseaux sociaux, cloud, mobile, tablette. Management et accompagnement. Sécurité et réglementation : droit à la déconnexion, charte d’utilisation des outils. Étude de cas : accompagner des collaborateurs dans la digitalisation.', '≈ 2 h', 4),
(920, 166, 'La plateforme .NET', 'Principes et architecture .NET ; CLR, BCL, CLS (support multilingue). Panorama des types d’applications multicibles. Structure d’une application : espaces de noms. Outils et IDE. CIL : langage intermédiaire, compilation JIT. Assemblies, métadonnées, déploiement ; assemblies privées et partagées, signature, GAC. .NET Core, open source et multiplateforme. TP : premier programme C# minimal, exécution managée, utilisation de Visual Studio pour l’écriture et le débogage.', '1 jour', 1),
(921, 166, 'Syntaxe C# : données, expressions, instructions', 'Variables, expressions, constantes, opérateurs, types anonymes et dynamiques. Common Type System, System.Object, transtypage, types valeur vs référence. Tableaux, structures de contrôle. Nouveautés C# 6 (opérateur null-conditionnel, propriétés automatiques, expression-bodied members…). Nouveautés C# 7 (out var, tuples, pattern matching, retour par référence…). TP : programmes C# illustrant des algorithmes classiques.', '1 jour', 2),
(922, 166, 'Exceptions et introduction à la POO', 'Philosophie des exceptions ; throw ; traitement centralisé des erreurs. TP : gestion d’erreurs de saisie. Rappels POO : classes et objets, champs, méthodes, propriétés, héritage, polymorphisme, interfaces (héritage multiple).', '≈ 0,5 jour', 3),
(923, 166, 'Classes, objets et mécanismes avancés en C#', 'Définition de classes et objets ; visibilité ; espaces de noms ; constructeurs, destructeur ; Garbage Collector ; surcharge (constructeurs, méthodes, opérateurs) ; dérivation et polymorphisme ; interfaces ; attributs et métadonnées ; régions, classes partielles ; génériques ; délégués, covariance, contravariance, événements ; propriétés, indexeurs, énumérateurs à la manière du framework ; documentation. TP : classes de base, dérivation, interface, polymorphisme.', '1,5 jour', 4),
(924, 166, 'Classes de base du framework .NET', 'Notion de framework ; hiérarchie de classes. Dates et durées. Chaînes : StringBuilder, expressions régulières. Classes utiles : fichiers, Math, Random, etc. Collections, dictionnaires, tables de hachage ; collections génériques ; introduction à LINQ to Objects. TP : expressions régulières, table de hachage ; rendre une collection interrogable en LINQ.', '0,5 jour', 5),
(925, 166, 'Types d’applications .NET et données', 'Bibliothèques de classes réutilisables. Principes et exemple WPF. Principes et exemple ASP.NET MVC (contrôleur, page Razor, données). Services web ASP.NET. Introduction accès données : ADO.NET ou Entity Framework et LINQ. TP : formulaire Windows interrogeant une base ; démonstrations MVC et service web simple.', '0,5 jour', 6),
(926, 167, 'Pourquoi l’approche objet ?', 'Intérêt des technologies objet. Défis : modularité (plug-ins), réutilisabilité, évolutivité, bibliothèques de composants. Comment l’objet y répond. État d’esprit pour aborder un problème objet. Croisement avec d’autres domaines de l’informatique et d’autres disciplines.', '0,5 jour', 1),
(927, 167, 'Concepts de base et interactions', 'Dualité données / procédure. Classes : structure et comportement ; instances. Méthodes et messages : envoi, interprétation. Héritage ; typage des variables dans les langages fortement typés (ex. C++, Java).', '0,5 jour', 2),
(928, 167, 'UML : diagrammes et outillage', 'Diagrammes de classes, diagrammes de séquence et usage en conception. Outils de modélisation du marché : prise en main d’un modeleur.', '0,5 jour', 3),
(929, 167, 'Principes et démarche de conception objet', 'Réification : que mettre sous forme d’objet ? Critères et pièges. Modularité et découpage de domaines. Structuration de classes : abstraction, classification. Encapsulation, autonomie, analyse des communications dans les systèmes complexes. Bonnes hiérarchies : critères et erreurs fréquentes. Démarche : spirale, incrémental, identification des entités et des interactions. Réutilisation et évolutivité. Concevoir objet ≠ seulement utiliser un outil : erreurs à éviter.', '1 jour', 4),
(930, 167, 'De la conception à l’implémentation et au distribué', 'Traduire diagrammes de classes UML vers des langages et des bases de données. Mise en œuvre d’applications objet. Importance du distribué ; modèles client-serveur. Panorama .NET et plateforme Java / Jakarta EE : forces et limites. Bibliothèques de classes, langages et assemblage de composants.', '1 jour', 5),
(931, 167, 'Frameworks, composants et design patterns', 'Cycle de vie, évolution et maintenance ; intérêt des frameworks et composants. Concevoir rapidement à partir d’artefacts réutilisables : intégration, construction de frameworks, transformation d’une application existante. Grandes familles de frameworks et modèles de composants. Design patterns : typologies, exemples, avantages et limites ; mise en pratique.', '0,5 jour', 6),
(932, 168, 'Jour 1 — Gouvernance SSI et ISO/IEC 27001', 'Rôle du RSSI et panorama de la gouvernance SSI. Principes et structure d’un SMSI aligné sur ISO/IEC 27001 : contexte, leadership, planification, support, exploitation, évaluation et amélioration. Exigences clés, documentation et indicateurs. Mise en perspective avec le cycle PDCA et les interactions avec les métiers, la DSI et la direction.', '1 jour', 1),
(933, 168, 'Jour 2 — Analyse de risques et audit (EBIOS RM, ISO/IEC 27005)', 'ISO/IEC 27005 : principes de gestion du risque SSI. Méthode EBIOS Risk Manager : ateliers, scénarios, évaluation et traitement du risque. Préparation à l’expression du besoin en sécurité et au suivi du plan de traitement. Rappels sur la démarche d’audit interne ou tiers et la lecture des écarts dans un SMSI.', '1 jour', 2),
(934, 168, 'Jour 3 — Stratégie SSI, réglementation et acteurs', 'Alignement stratégique cybersécurité / métier : objectifs, budget, feuille de route. Panorama réglementaire et normatif utile au RSSI (NIS2, RGPD en lien avec SSI, obligations sectorielles selon contexte). Lectures ANSSI et bonnes pratiques pour durcir la posture. Coordination avec RSSI-adjoint, DPO, SOC, prestataires et comités de direction ; communication et sensibilisation.', '1 jour', 3),
(935, 169, 'Jour 1 — Cloud computing et virtualisation : fondamentaux', 'Cloud et virtualisation : concepts et principaux défis techniques. Applications cloud et introduction aux modèles de service. Limites de l’informatique traditionnelle. Définitions selon ISO, Gartner et NIST ; avantages, limites et évolutions illustrées par des cas concrets. Caractéristiques des modèles de services et de déploiement ; taxonomie NIST. Introduction à la virtualisation comme socle du cloud : historique, concepts, défis, avantages et limites ; rôle et types d’hyperviseurs ; panorama du marché ; virtualisation serveur, stockage, réseau et poste de travail.', '1 jour', 1),
(936, 169, 'Jour 2 — Panorama technologique, sécurité et gouvernance', 'Vue d’ensemble des usages : BYOD (concepts, atouts et limites), MDM et EMM, NFV et lien avec le SDN, bases de la Big Data et de la data analytics, IoT (principes et concepts essentiels), mise en perspective métiers / IT. Puis sécurité, risques et conformité : terminologie, gestion du risque, conformité et audits, impacts des modèles de service et de déploiement sur la gouvernance (vision DSI), vecteurs d’attaque courants et mesures de contrôle.', '1 jour', 2),
(937, 169, 'Jour 3 — Mise en œuvre, CSM et certification CTA', 'Matin : mise en œuvre du cloud (étapes, architectures, rôle des fournisseurs, approches de migration), puis Cloud Service Management (principes, cycle de vie, acteurs, support, configuration, portabilité, interopérabilité, familles de produits). Après-midi : examen blanc avec correction commentée et passage de l’examen CTA selon le dispositif du certificateur.', '1 jour', 3),
(938, 170, 'Concepts des réseaux', 'Panorama des réseaux et classification des types de réseaux. Modèle de référence OSI. Famille TCP/IP et réseaux LAN.', '1 jour', 1),
(939, 170, 'Création d’un réseau simple', 'Fonctions des réseaux et modèle de communications hôte à hôte. Introduction aux LAN. IOS Cisco et interface en ligne de commande (CLI). Démarrage d’un commutateur. Ethernet et commutation ; dépannage des problèmes de commutation liés aux médias. Travaux pratiques : mettre en œuvre un réseau, utiliser l’IOS et un switch, vérifier le fonctionnement, maîtriser la CLI.', '1 jour', 2),
(940, 170, 'Établissement de la connectivité interne', 'Couche Internet du modèle TCP/IP. Adressage IP et sous-réseaux. Couche transport (TCP/IP). Fonctions de routage. Configuration d’un routeur Cisco. Processus de délivrance des paquets. Routage statique. Gestion du trafic avec des access-lists. Accès à Internet. Travaux pratiques : routage, gestion du trafic, routeur Cisco, routage statique.', '1 jour', 3),
(941, 170, 'Création d’un réseau de taille moyenne', 'Spanning tree. VLAN et trunk ; routage inter-VLAN. Utiliser un périphérique Cisco comme serveur DHCP. Introduction aux protocoles de routage dynamique et aux technologies WAN. Travaux pratiques : VLAN et trunk, serveur DHCP sur équipement Cisco.', '1 jour', 4),
(942, 170, 'Sécurité des périphériques et introduction IPv6', 'Sécurisation des accès administratifs, durcissement (« device hardening »), journalisation des messages système, gestion des équipements Cisco. Travaux pratiques sur la journalisation. Puis bases IPv6, fonctionnement, configuration de routes statiques IPv6. Rappels pour la préparation à l’examen 200-301.', '1 jour', 5),
(943, 171, 'Jour 1 — Historique du cloud et de ses impacts', 'Émergence du cloud et passage de la virtualisation au cloud ; impacts pour les entreprises. Modèles liés au cloud (SOA, architecture d’entreprise). Nouvelles opportunités et modèles informatiques. Risque, sécurité et problématiques juridiques inhérents au cloud.', '0,5 jour', 1),
(944, 171, 'Jour 1 — Ingénierie et architecture du cloud computing', 'Évolution des technologies ayant permis le cloud. Implications technologiques du modèle « as a service ». Systèmes d’ingénierie dans l’architecture des solutions cloud. Virtualisation versus cloud ; perspectives consommateurs et fournisseurs. Vues d’architecture et métadonnées pour IaaS, PaaS et SaaS ; panorama des offres XaaS.', '0,5 jour', 2),
(945, 171, 'Jour 2 — Cycles de vie, transition et mise en œuvre', 'Concepts et cycles de vie des services cloud : identification et application des phases ; caractéristiques des étapes ; critères d’architecture pour sélection et livraison d’un service cloud. Transition vers le cloud : enjeux, transformation des métiers, stratégies pour réduire les freins à l’adoption. Perspectives métier d’une architecture de solution cloud, regard fournisseur et étapes clés de configuration d’un environnement cloud. Écosystème : IoT et IoE, langage de conception des écosystèmes cloud.', 'Matinée', 3),
(946, 171, 'Jour 2 — Cibler la solution, business case et certification PCSA', 'Définir les spécifications d’une solution d’architecture cloud ; construire un business case ; esquisser une roadmap de mise en œuvre. Examen blanc et révisions. Passage de l’examen PCSA EXIN (organisation selon dispositif certificateur et session).', 'Après-midi', 4),
(947, 172, 'Jour 1 : Tests d’intrusion mobiles', 'Concepts et mise en place des tests d’intrusion mobiles ; analyse statique des applications Android.', '1 jour', 1),
(948, 172, 'Jour 2 : Analyse réseau et analyse dynamique', 'Analyse réseau des applications Android ; analyse dynamique et prolongements utiles à l’audit.', '1 jour', 2),
(949, 173, 'Jour 1 — Fondations, culture et stratégie', 'Introduction : objectifs, déroulé, exercice de schématisation de pipeline CI/CD. Pourquoi DevSecOps : terminologie, enjeux, trois façons d’articuler sécurité et DevOps, principes. Culture et management : incitation, résilience, culture organisationnelle, générativité (Erickson, Westrum, LaLoux) ; exercice d’influence culturelle. Stratégie et risques : niveau de sécurité « suffisant », modélisation de la menace, contexte, risque à grande vitesse ; exercice « mesurer le succès ». Sécurité générale : éviter la case à cocher, hygiène, architecture, identité fédérée, journaux.', '1 jour', 1),
(950, 173, 'Jour 2 — IAM, applicatif, opérations, GRC et examen', 'IAM : concepts, mise en œuvre, automatisation, pièges courants ; exercice IAM. Sécurité applicative : AST, techniques et priorisation, gestion des problèmes, menaces, automatisation. Sécurité opérationnelle ; exercice d’intégration de contrôles dans le pipeline CI/CD. GRC et audit : fondamentaux, politiques et policy-as-code, shift left, mythes sur la séparation des tâches ; exercice conformité. Journalisation, surveillance, réponse, menace et partage d’informations. Préparation certification DSOE : critères d’examen, pondération, lexique, exemples d’épreuve.', '1 jour', 2),
(951, 174, 'Jour 1 — Syntaxe C++ et environnement', 'Différences C / C++ : données, initialisation, types ; expressions, références, casts ; opérateurs (::, new, delete) ; fonctions (passage et retour par référence, défauts, inline, surcharge) ; intégration de code C ; types constants ; espaces de noms ; auto (C++11). Travaux pratiques : prise en main de l’IDE et premier programme.', '1 jour', 1),
(952, 174, 'Jour 2 — Approche objet et amorçage des classes', 'Principes objet ; C++ et l’objet ; introduction aux méthodologies objet et à UML (statique, dynamique, coopération, scénarios). Classes : champs, méthodes, constructeurs, contrôle d’accès, autoréférence, statiques, friend ; tableaux dynamiques d’objets ; conception de classes ; constructeurs de copie et de déplacement, délégation (C++11) ; introduction pile / tas / gestion mémoire. Travaux pratiques : étude de cas fil rouge.', '1 jour', 2),
(953, 174, 'Jour 3 — Héritage, polymorphisme et factorisation', 'Dérivation : syntaxe, constructeurs, contrôle d’accès ; fonctions virtuelles et polymorphisme ; classes abstraites et interfaces/héritage multiple ; factorisation du code. Travaux pratiques : hiérarchie de classes et polymorphisme sur l’étude de cas.', '1 jour', 3),
(954, 174, 'Jour 4 — Exceptions, surcharge d’opérateurs et modèles', 'Exceptions : try/catch, hiérarchie et bonnes pratiques ; surcharge d’opérateurs (binaires, [], (), conversion, gestion mémoire, << >>). Modèles de classe et de fonction : principes, surcharge, spécialisations ; lien avec opérateurs et dérivation ; apports C++11 en appui. Travaux pratiques : exceptions, opérateurs et templates.', '1 jour', 4),
(955, 174, 'Jour 5 — I/O, STL et conclusion', 'Entrées/sorties : streams et hiérarchie de classes ; aperçu STL : objectifs, conteneurs, itérateurs, boucle sur intervalle (C++11). Conclusion : tests, intégration, mise en production ; interactions avec d’autres environnements ; analyse critique et évolution de C++.', '1 jour', 5),
(956, 175, 'Jour 1 — Incidents, démarche, outils et stockages (modules 1 à 5)', 'Incidents de criminalistique informatique ; théorie de l’investigation ; processus d’investigation ; outils d’acquisition et d’analyse numérique ; disques et stockages.', '1 jour', 1),
(957, 175, 'Jour 2 — Acquisitions et criminalistique systèmes (modules 6 à 9)', 'Acquisitions à chaud (live) ; criminalistique Windows ; criminalistique Linux ; criminalistique macOS.', '1 jour', 2),
(958, 175, 'Jour 3 — Preuves, protocoles et laboratoire (modules 10 à 13)', 'Protocoles d’examen criminalistique ; protocoles sur la preuve numérique ; présentation de la preuve numérique ; protocoles du laboratoire criminalistique.', '1 jour', 3),
(959, 175, 'Jour 4 — Artefacts, recherche et eDiscovery (modules 14 à 16)', 'Récupération d’artefacts spécialisés ; chaînes de recherche avancées et signatures de fichiers ; eDiscovery et ESI.', '1 jour', 4),
(960, 175, 'Jour 5 — Mobile, incidents et rapports (modules 17 à 19)', 'Criminalistique mobile ; gestion d’incidents ; reporting et restitution.', '1 jour', 5),
(961, 176, 'Domaine 1 — Security and Risk Management', 'Gouvernance, gestion du risque, conformité et cadre sécurité de l’organisation (équivalent sécurité et gestion des risques au sens CISSP).', 'Intégré au parcours 5 jours', 1),
(962, 176, 'Domaine 2 — Asset Security', 'Classification, propriété, cycle de vie et protection des actifs informationnels.', 'Intégré au parcours 5 jours', 2),
(963, 176, 'Domaine 3 — Security Architecture and Engineering', 'Principes de conception, modèles, vulnérabilités courantes et mitigation dans l’ingénierie sécurité.', 'Intégré au parcours 5 jours', 3),
(964, 176, 'Domaine 4 — Communication and Network Security', 'Architectures réseau, protocoles, segments et contrôles pour sécuriser les communications (aligné OSI couches 1 à 7 selon besoins).', 'Intégré au parcours 5 jours', 4),
(965, 176, 'Domaine 5 — Identity and Access Management (IAM)', 'Modèles d’accès, gestion des identités, SSO, fédération et contrôles logiques.', 'Intégré au parcours 5 jours', 5),
(966, 176, 'Domaine 6 — Security Assessment and Testing', 'Évaluation, audits, tests de sécurité et validation des dispositifs de contrôle.', 'Intégré au parcours 5 jours', 6),
(967, 176, 'Domaine 7 — Security Operations', 'Exploitation sécurité, détection, réponse à incident, PRA/PCA et bonnes pratiques opérationnelles.', 'Intégré au parcours 5 jours', 7),
(968, 176, 'Domaine 8 — Software Development Security', 'Cycle de vie du développement, menaces applicatives et intégration de la sécurité dans le logiciel.', 'Intégré au parcours 5 jours', 8),
(969, 177, 'Maîtriser l’environnement de développement et les fondamentaux', NULL, NULL, 1),
(970, 177, 'Travailler avec les structures de données et l’orienté objet', NULL, NULL, 2),
(971, 177, 'Utiliser les modules, packages et bibliothèques spécifiques', NULL, NULL, 3),
(972, 177, 'Assurer la qualité, l’optimisation et l’automatisation', NULL, NULL, 4),
(973, 178, 'Panorama du web mobile', NULL, NULL, 1),
(974, 178, 'Définitions du Responsive Web Design', NULL, NULL, 2),
(975, 178, 'Les principes fondamentaux', NULL, NULL, 3),
(976, 178, 'Créer une grille d’affichage flexible', NULL, NULL, 4),
(977, 178, 'Utiliser des médias flexibles', NULL, NULL, 5),
(978, 178, 'Appliquer des Media Queries', NULL, NULL, 6),
(979, 178, 'Javascript pour le Responsive Web Design', NULL, NULL, 7),
(980, 178, 'Les frameworks Responsive Web Design', NULL, NULL, 8),
(981, 178, 'Tester son site responsive', NULL, NULL, 9),
(982, 179, 'Introduction aux langages du Web', NULL, NULL, 1),
(983, 179, 'Introduction au Web Dynamique', NULL, NULL, 2),
(984, 179, 'Introduction à PHP', NULL, NULL, 3),
(985, 179, 'La structure du langage PHP', NULL, NULL, 4),
(986, 179, 'Les types de données & opérateurs', NULL, NULL, 5),
(987, 179, 'Les structures de contrôle', NULL, NULL, 6),
(988, 179, 'Les fonctions', NULL, NULL, 7),
(989, 179, 'Les chaînes de caractères', NULL, NULL, 8),
(990, 179, 'Les tableaux', NULL, NULL, 9),
(991, 179, 'La programmation orientée-objet', NULL, NULL, 10),
(992, 179, 'La gestion « date & heure »', NULL, NULL, 11),
(993, 179, 'Utilisation conjointe à HTTP', NULL, NULL, 12),
(994, 179, 'Gestion des entrées/sorties de données', NULL, NULL, 13),
(995, 179, 'La connexion à une base de donnée MySQL', NULL, NULL, 14),
(996, 179, 'La gestion des erreurs', NULL, NULL, 15),
(997, 179, 'Composer et la gestion de dépendances', NULL, NULL, 16),
(998, 179, 'Les web services', NULL, NULL, 17),
(999, 179, 'La sécurité', NULL, NULL, 18),
(1000, 179, 'Les frameworks de développement PHP (Laravel, Symfony, Zend, etc.)', NULL, NULL, 19),
(1001, 180, 'L\'informatique et internet', NULL, NULL, 1),
(1002, 180, 'Les Cybercriminels', NULL, NULL, 2),
(1003, 180, 'Le Cybercrime', NULL, NULL, 3),
(1004, 180, 'La Cybersécurité', NULL, NULL, 4),
(1005, 180, 'Le Phishing', NULL, NULL, 5),
(1006, 180, 'La sécurité sur les sites internet', NULL, NULL, 6),
(1007, 180, 'La sécurité des mots de passe', NULL, NULL, 7),
(1008, 180, 'Les arnaques et fraudes', NULL, NULL, 8),
(1009, 180, 'Les téléchargements et virus', NULL, NULL, 9),
(1010, 180, 'Les pièges sur les réseaux sociaux', NULL, NULL, 10),
(1011, 180, 'Les paiements en ligne', NULL, NULL, 11),
(1012, 180, 'Sécurité des smartphones, tablettes et objets connectés', NULL, NULL, 12),
(1013, 180, 'La sécurité en voyage', NULL, NULL, 13),
(1014, 180, 'Réagir à un acte cybercriminel', NULL, NULL, 14),
(1015, 180, 'Pour aller plus loin', NULL, NULL, 15),
(1016, 181, 'Les systèmes d\'informations', NULL, NULL, 1),
(1017, 181, 'Les cyber-attaques contre des entreprises', NULL, NULL, 2),
(1018, 181, 'Paysage institutionnel de la cybersécurité', NULL, NULL, 3),
(1019, 181, 'Implémenter la cybersécurité en entreprise', NULL, NULL, 4),
(1020, 181, 'Organisation de la cybersécurité', NULL, NULL, 5),
(1021, 181, 'Sensibiliser les collaborateurs à la cybersécurité', NULL, NULL, 6),
(1022, 181, 'Sécuriser l\'accès aux ressources', NULL, NULL, 7),
(1023, 181, 'Sauvegarder les données', NULL, NULL, 8),
(1024, 181, 'Sécuriser un réseau informatique', NULL, NULL, 9),
(1025, 181, 'Maintenir un parc à jour', NULL, NULL, 10),
(1026, 181, 'Sécuriser les postes de travail', NULL, NULL, 11),
(1027, 181, 'Sécuriser un site web', NULL, NULL, 12),
(1028, 181, 'Réagir à un incident de cybersécurité', NULL, NULL, 13),
(1029, 181, 'Souscrire une assurance cyber', NULL, NULL, 14),
(1030, 181, 'Faire appel à des prestations de cybersécurité', NULL, NULL, 15),
(1031, 181, 'Effectuer une veille cybersécurité', NULL, NULL, 16),
(1032, 182, 'Introduction au cours', NULL, NULL, 1),
(1033, 182, 'Les équipements réseaux', NULL, NULL, 2),
(1034, 182, 'Téléchargement et installation de Packet Tracer', NULL, NULL, 3),
(1035, 182, 'Prise en main de l\'environnement Cisco Packet Tracer', NULL, NULL, 4),
(1036, 182, 'Téléchargement et installation de Cisco Modeling Lab', NULL, NULL, 5),
(1037, 182, 'Prise en main de l\'environnement Cisco Modeling Lab', NULL, NULL, 6),
(1038, 182, 'Accès et navigation au sein de l’IOS Cisco', NULL, NULL, 7),
(1039, 182, 'Structure des commandes IOS', NULL, NULL, 8),
(1040, 182, 'Configuration initiale des équipements Cisco', NULL, NULL, 9),
(1041, 182, 'Comment administrer les équipements réseaux à distance', NULL, NULL, 10),
(1042, 182, 'Les fichiers de configuration', NULL, NULL, 11),
(1043, 182, 'La structure d’un réseau', NULL, NULL, 12),
(1044, 182, 'Configuration des interfaces d’un équipement', NULL, NULL, 13),
(1045, 182, 'Concepts et fondamentaux des VLANs', NULL, NULL, 14),
(1046, 182, 'Configuration des VLANs sur un commutateur', NULL, NULL, 15),
(1047, 182, 'Routage inter-VLAN', NULL, NULL, 16),
(1048, 182, 'Administration centralisée des VLANs avec VTP', NULL, NULL, 17),
(1049, 182, 'Configuration de l’agent relais et du serveur DHCP', NULL, NULL, 18),
(1050, 182, 'Services d’Infrastructure Réseau – Journalisation, Synchronisation et Sauvegarde', NULL, NULL, 19),
(1051, 182, 'Protocoles de découverte de voisinage (CDP et LLDP)', NULL, NULL, 20),
(1052, 182, 'Prévention des boucles de couche 2 : STP, RSTP et MSTP', NULL, NULL, 21),
(1053, 182, 'Mise en place du NAT', NULL, NULL, 22),
(1054, 182, 'Introduction au routage', NULL, NULL, 23),
(1055, 182, 'Routage statique et routage par défaut', NULL, NULL, 24),
(1056, 182, 'Routage dynamique, présentation et configuration', NULL, NULL, 25),
(1057, 182, 'Conclusion', NULL, NULL, 26),
(1058, 183, 'Qu’est-ce que l’IA générative ?', 'Comprendre le concept d’IA générative et ses usages métiers. Principes de l’IA responsable. Découvrir Microsoft 365 Copilot et ses capacités.', '1 h', 1),
(1059, 183, 'Utiliser Copilot Chat comme assistant IA', 'Fonctionnement de Copilot Chat, invites efficaces, automatisation des tâches, gestion des conversations et des invites, agents et bonnes pratiques.', '1 h 15', 2),
(1060, 183, 'Rédiger et affiner du contenu professionnel', 'Copilot dans Word, Outlook et PowerPoint : génération et amélioration de contenu, synthèse d’informations, agent Recherche.', '1 h 15', 3),
(1061, 183, 'Analyser et visualiser des données', 'Copilot dans Excel : analyse de données, visualisations, agent Analyste.', '1 h 15', 4),
(1062, 183, 'Gérer les réunions et la collaboration', 'Copilot dans Outlook et Teams : résumés de réunions, suivis, blocs-notes et Copilot Page.', '1 h 15', 5),
(1063, 183, 'Définir le rôle de Copilot dans les processus métier', 'Scénarios métiers, automatisation des tâches, adaptation de Copilot aux besoins de l’équipe et de l’entreprise.', '1 h', 6),
(1064, 184, 'Jour 1 — Comprendre l’IA générative et premières applications système', 'Introduction à l’IA : définitions (ML, IA générative, LLM, NLP, RAG), fonctionnement d’un LLM, ce que l’IA peut ou ne peut pas faire, prompt engineering appliqué aux tâches IT. Limites et risques : hallucinations, biais, cybermenaces, confidentialité et RGPD. Atelier : analyse critique de réponses IA. Cas d’usage transverses : rédaction, traduction, synthèse de documents techniques, plannings d’intervention. Atelier : IA comme assistant de communication technique.', 'Jour 1', 1),
(1065, 184, 'Automatiser et diagnostiquer avec l’IA', 'Tâches récurrentes (comptes, supervision, tickets). Génération assistée de scripts PowerShell / Bash et documentation de scripts. Atelier : automatiser une tâche système avec un assistant IA. Aide au diagnostic : analyse de logs et d’événements Windows/Linux. Atelier : diagnostic assisté via logs.', 'Jour 1 (suite)', 2),
(1066, 184, 'Jour 2 — Réseaux, cybersécurité et supervision', 'Usages pour réseaux et cybersécurité : topologie, adressage IP, configurations d’équipements, connectivité, règles pare-feu / proxy, scripts de tests (ping, traceroute, Nmap, etc.), analyse de logs et aide à la détection d’anomalies. Atelier : génération de règles de sécurité commentées.', 'Jour 2', 3),
(1067, 184, 'Documentation, supervision et synthèse de données', 'Génération de fiches d’incidents, comptes rendus, procédures, FAQ, modèles de communication. Atelier : créer une fiche d’incident structurée. Supervision : tableaux de bord et synthèses à partir de logs ou exports. Atelier : synthèse d’un export de supervision.', 'Jour 2 (suite)', 4),
(1068, 184, 'Atelier de clôture : assistant IA personnalisé', 'Élaborer un prompt réutilisable adapté à un besoin réel (automatisation, diagnostic, supervision). Mise en commun et discussion pour la transposition en situation professionnelle.', 'Fin Jour 2', 5),
(1069, 185, 'Historique, panorama et architecture', 'Panorama des outils : ChatGPT, familles GPT, Stable Diffusion, Midjourney, Bard, Llama, AutoGPT, etc. Fonctionnement, architecture, deep learning, LLM, transformers. NLP, NLU, NLG. Acteurs du marché (éditeurs et cloud) et usages professionnels.', '1 h 50', 1),
(1070, 185, 'Usages sectoriels et analyses', 'Exemples en finance, éducation, santé, R&D, droit, programmation, médias : rapports, analyse de données, contenus, recommandations. Exercices : création et analyse de rapports, comparatifs, détection d’anomalies.', '2 h 25', 2),
(1071, 185, 'Devenir efficace en prompts (« prompt artist »)', 'Prompts avancés pour illustrations et tâches créatives ; Chaînes d’outils avec ChatGPT et solutions spécialisées ; notions d’outpainting / inpainting avec diffusion ; travaux guidés de la description au rendu et à l’optimisation.', '2 h 25', 3),
(1072, 185, 'LLM, transformers et automatisation', 'Approches no-code / low-code avec LLM ; scripts et automatisation ; sandbox et API ; notebooks (ex. environnements type Colab / Kaggle). Exercices : synthèses multi-sources vers tableaux structurés ou analyse de journaux.', '2 h 25', 4),
(1073, 185, 'Créer et connecter un chatbot', 'Principes d’un chatbot : intents, entités, jeu d’entraînement ; webhooks ; connexion aux API de modèles conversationnels ; lien avec une messagerie. Exercices : brancher un chatbot sur un webhook et des API.', '2 h 25', 5),
(1074, 185, 'Alternatives open source et hors ligne', 'Écosystème open source (familles Bert, outils NLTK, modèles locaux, ressources type Hugging Face). NLU, analyse de sentiments, FAQ avec modèles ouverts ; chatbot hors ligne. Exercices : analyse d’émotions et FAQ hors ligne avec des outils libres.', '2 h 25', 6),
(1075, 186, 'Introduction et fondamentaux', 'IA générative et ChatGPT : historique, architecture, utilités et exemples d’applications. Présentation de l’API OpenAI (fonctionnalités, envoi de requêtes, interprétation des réponses, usages au-delà du simple texte). Installation des dépendances, configuration de l’authentification API, premier script d’appel et analyse des réponses — avec exercices pour prendre en main l’API.', '2 h 30', 1),
(1076, 186, 'Projet fil rouge : développement web assisté par l’IA', 'À travers une application web en couches (front-end et back-end) : assistance à la génération, refactorisation, optimisation et nettoyage du code ; aide à la détection et correction de vulnérabilités ; aide au débogage et à la montée en qualité. Travaux pratiques sur l’ensemble du cycle.', '9 h 30', 2),
(1077, 186, 'Sécurité, éthique, limites et prospective', 'Risques de sécurité, limites des modèles, bonnes pratiques d’usage responsable. Réflexion sur l’évolution des IA génératives, des outils et l’impact sur le métier de développeur (enjeux éthiques et sociétaux).', '2 h', 3),
(1078, 187, 'Introduction à ChatGPT et à l’API', 'Capacités conversationnelles, cas d’usage, scénarios d’intégration. Compte OpenAI, clés et jetons, configuration de l’environnement. Requêtes de base, analyse et formatage des réponses, gestion des erreurs et limites. Travaux pratiques sur la configuration et les premiers appels.', '7 h', 1),
(1079, 187, 'Fonctionnalités avancées et optimisation des dialogues', 'Paramètres et personnalisation du comportement, instructions additionnelles. Conversations multi-tours, maintien du contexte et de l’historique. Optimisation du nombre de requêtes, longueur des échanges, techniques de prompt pour plus de précision. Ateliers : jeux de paramètres et dialogues cohérents.', '7 h', 2),
(1080, 187, 'Déploiement, intégration et responsabilité', 'Intégration dans le web et le mobile (ex. Python, JavaScript), bonnes pratiques d’architecture et de sécurité. Choix d’infrastructure, mise en production, supervision des performances et disponibilité. Éthique, biais, confidentialité et usage responsable. Restitution de mini-projets d’intégration et échanges de bonnes pratiques.', '7 h', 3),
(1081, 188, 'Introduction à l’IA générative', 'Histoire récente et principes de fonctionnement ; opportunités et risques pour la communication. Déploiement dans la production et la communication interne/externe, valeur ajoutée, cadre légal et propriété intellectuelle. Panorama d’outils (assistants conversationnels, génération d’images, vidéo, etc.). Posture et démarche pour les professionnel·le·s et les organisations.', '2 h', 1),
(1082, 188, 'L’art d’écrire un prompt', 'Règles de base, délégation de tâches, maintien du fil de discussion, exemples de référence, ton et rôle. Lien avec les concepts clés du webmarketing. Atelier : génération et affinage de prompts.', '2 h', 2),
(1083, 188, 'IA pour la stratégie webmarketing', 'Stratégies, niches, positionnement, cibles, indicateurs, visibilité, veille concurrentielle. Atelier : mise en œuvre avec un assistant conversationnel pour esquisser une stratégie.', '1 h 30', 3),
(1084, 188, 'IA pour les contenus éditoriaux', 'Trames éditoriales, modèles de pages, traduction, enrichissement, correction, cohérence de ton, relecture. Atelier : planning éditorial assisté.', '1 h 30', 4),
(1085, 188, 'IA et SEO', 'Production et optimisation de textes, balises title et meta description, plan éditorial orienté SEO. Atelier : plan de contenu optimisé techniquement.', '1 h 30', 5),
(1086, 188, 'Relations médias et presse', 'Communiqués de presse, stratégies RP, personnalisation, identification de médias et partenaires. Atelier : rédaction d’un communiqué assistée.', '1 h 30', 6),
(1087, 188, 'E-réputation, veille et réseaux sociaux', 'Publications sociales, scénarios, planning, modération. Atelier : plan d’action de veille.', '1 h 30', 7),
(1088, 188, 'Animation marketing & création visuelle', 'Annonces, jeux et animations. Atelier : création d’annonces visuelles avec des outils de génération d’images.', '1 h', 8),
(1089, 188, 'Expérience utilisateur & formats multimédias', 'Application au site, à l’app ou au support web. Atelier : initiation à la production de vidéo assistée par IA (ex. outils type avatar / synthèse vidéo selon disponibilité).', '1 h 30', 9),
(1090, 189, 'Introduction et fondamentaux du machine learning', 'Définition et grands champs du machine learning. Formuler correctement un problème : données, cible, métriques. Chaîne complète : prétraitement des données, apprentissage d’un modèle, évaluation, exploitation pour des décisions ou livrables actionnables. Prise en main de l’environnement et des bibliothèques selon le langage retenu.', '1 jour', 1),
(1091, 189, 'Apprentissage supervisé', 'Régression linéaire et régression logistique, forêts aléatoires, réseaux de neurones (bases, convolution, réseaux récurrents selon besoins), SVM. Mise en œuvre, réglage des hyperparamètres et diagnostic d’erreur. Travaux pratiques sur cas réels.', '1,5 jour', 2),
(1092, 189, 'Apprentissage non supervisé et représentations', 'Réduction de dimensionnalité, clustering K-means, embeddings (ex. word2vec), détection d’anomalies. Introduction aux réseaux adverses (GAN). Travaux pratiques : explorer la structure des données et les incohérences.', '1,5 jour', 3),
(1093, 189, 'Systèmes de recommandation et filtrage collaboratif', 'Principes des moteurs de recommandation, filtrage collaboratif, combinaison avec signaux explicites / implicites. Travaux pratiques : modéliser un problème de recommandation et évaluer la pertinence.', '1 jour', 4),
(1094, 190, 'Introduction à l’IA et panorama technique', 'Court historique de l’intelligence artificielle. Problématiques actuelles (données, biais, réglementation, usage responsable). Possibilités offertes par l’IA : vision par ordinateur, traitement des langues, prédictions sur données temporelles, raisonnement et agents. Démonstration pratique pour illustrer les concepts.', '2 h 30', 1),
(1095, 190, 'Acteurs, recherche et tendances', 'Panorama des grands industriels et de leurs axes de développement. Contributions des équipes académiques majeures. Tendances récentes de la recherche et secteurs porteurs de l’industrie (données massives, modèles génératifs, edge computing, etc.).', '2 h', 2),
(1096, 190, 'Transformation par l’IA et transition métier', 'Études de cas dans plusieurs secteurs : transport, santé, informatique / services numériques. Comment l’IA bouleverse chaînes de valeur et organisations. Échanges sur les conditions d’une transition vers l’IA : gouvernance, compétences, données, risques et opportunités.', '2 h 30', 3),
(1097, 191, 'Introduction au deep learning et au NLP', 'Présentation du deep learning et positionnement par rapport au machine learning classique. Chaîne de traitement du texte (normalisation, tokenisation, vocabulaires). Panorama des approches et des usages en entreprise.', '1 jour', 1),
(1098, 191, 'Fondamentaux des réseaux de neurones', 'Architecture des réseaux, rétropropagation du gradient, non-linéarités, initialisation et premières intuitions sur l’optimisation.', '0,5 jour', 2),
(1099, 191, 'Architectures pour le langage', 'Réseaux récurrents ; briques LSTM, GRU, softmax ; embeddings. Mécanismes d’attention et de mémoire ; lecture d’architectures récentes (dont transformeurs selon le programme retenu). Travaux pratiques guidés.', '1,5 jour', 3),
(1100, 191, 'Applications NLP', 'Traduction automatique, résumé, génération de texte, classification, détection de polarité, modélisation de topics. Mise en relation avec des jeux de données réels.', '0,5 jour', 4),
(1101, 191, 'Ingénierie et conduite d’expériences', 'Collecte et choix de métriques, analyse des courbes d’apprentissage, stratégies de recherche d’hyperparamètres, diagnostic d’échecs d’entraînement.', '0,5 jour', 5),
(1102, 192, 'Introduction à Android', 'Historique d\'Android, présentation des différents acteurs (Google, Linaro…), architecture générale du système Android.', '0,5 jour', 1),
(1103, 192, 'Le système de fabrication d\'Android (BUILD)', 'Utilisation de GIT pour accéder aux sources, outils de compilation, émulateur Android et fabrication d\'une première image. TP : utilisation de la chaîne de compilation et de l\'émulateur.', '0,5 jour', 2),
(1104, 192, 'Le noyau Linux pour Android', 'Rappels sur le développement du noyau Linux, licences (GPL, Linux, Android, tiers), configuration et compilation, spécifications du boot d\'Android. TP : configuration et fabrication d\'un noyau Android, boot sur l\'émulateur.', '1 jour', 3),
(1105, 192, 'Outils de debug', 'ADB : debugger et commandes à distance, usage des logs, système de fichiers d\'Android et accès aux composants. TP : utilisation de ADB pour gérer les logs et transférer des fichiers.', '0,5 jour', 4),
(1106, 192, 'Ajout d\'un périphérique', 'Architecture des makefiles et fichiers de configuration, étapes de compilation, modification des informations système (Build ID, écrans de boot). TP : ajouter un périphérique, modifier les infos système et l\'écran de boot.', '0,5 jour', 5),
(1107, 192, 'Le rootfs et les applications', 'Structure du système de fichiers, services standard et fournisseurs (service/contenu), interface JNI (Java Native Interface) et bibliothèques matérielles. TP : personnalisation du rootfs et implémentation d\'une interface Java/bibliothèque.', '0,5 jour', 6),
(1108, 192, 'Application et packages Android', 'Packaging des applications (.apk), accès aux services depuis les applications, cycle de vie d\'une application. TP : intégration d\'un package accédant à un périphérique via JNI.', '0,5 jour', 7),
(1109, 193, 'Jour 1 : Infrastructure, Collecte et XSS', 'Connaissance des applications web et infrastructure, collecte d’information, contournement d’autorisation, Cross-Site Scripting (XSS).', '1 jour', 1),
(1110, 193, 'Jour 2 : Injections, JWT et CSRF', 'Injections (SQL, etc.), téléchargement non sécurisé, attaques sur les tokens JWT, failles de type CSRF.', '1 jour', 2),
(1111, 194, 'Introduction à WinDbg', 'Prise en main du débogueur WinDbg pour l\'analyse et l\'exploitation de binaires Windows.', NULL, 1),
(1112, 194, 'Débordements de tampon (Stack Buffer Overflows)', 'Compréhension et exploitation des débordements de tampon sur la pile en environnement Windows.', NULL, 2),
(1113, 194, 'Exploitation des SEH Overflows', 'Techniques d\'exploitation des débordements liés au Structured Exception Handler (SEH).', NULL, 3),
(1114, 194, 'Introduction à IDA Pro (version gratuite)', 'Utilisation d\'IDA Pro pour le reverse engineering de binaires et l\'identification de vulnérabilités.', NULL, 4),
(1115, 194, 'Contournement des restrictions d\'espace : Egghunters', 'Mise en œuvre de techniques egghunter pour contourner les restrictions d\'espace mémoire disponible.', NULL, 5),
(1116, 194, 'Création de shellcode personnalisé', 'Écriture et encodage de shellcode sur mesure adapté aux contraintes des cibles.', NULL, 6),
(1117, 194, 'Reverse engineering de bugs', 'Application de techniques avancées de reverse engineering pour identifier et analyser des vulnérabilités binaires.', NULL, 7),
(1118, 194, 'Bypass des protections DEP/ASLR avec des chaînes ROP', 'Développement de chaînes ROP (Return-Oriented Programming) pour contourner DEP et ASLR.', NULL, 8),
(1119, 194, 'Attaques de type format string', 'Compréhension et exploitation des vulnérabilités de type format string.', NULL, 9),
(1120, 195, 'Jour 1 : Introduction et Initiation', 'Introduction aux normes ISO/IEC 27017 et ISO/ IEC 27018 et à l’initiation d’un programme de sécurité du cloud.', '1 jour', 1),
(1121, 195, 'Jour 2 : Gestion des risques Cloud', 'Gestion des risques de sécurité du cloud computing et mesures spécifiques au cloud.', '1 jour', 2),
(1122, 195, 'Jour 3 : Sensibilisation et Information documentée', 'Gestion de l’information documentée, sensibilisation et formation à la sécurité du cloud.', '1 jour', 3),
(1123, 195, 'Jour 4 : Incidents et Amélioration continue', 'Gestion des incidents de sécurité du cloud, tests, surveillance et amélioration continue.', '1 jour', 4),
(1124, 195, 'Jour 5 : Examen de certification', 'Passage de l\'examen de certification PECB CERTIFIED Lead Cloud Security Manager.', '1 jour', 5),
(1125, 196, 'Comprendre les origines et les enjeux du Big Data', 'Croissance et diversité des données, définition du Big Data, création de valeur pour l\'entreprise, et différences entre BI et Big Data. (Réflexion collective incluse)', '0,5 jour', 1),
(1126, 196, 'Traiter les données et les analyser', 'Gestion des données structurées et non structurées. Méthodes d\'analyse : Datamining, description, classification, estimation, prévision, régression linéaire. Étude de cas via le logiciel R.', '0,5 jour', 2),
(1127, 196, 'Identifier les cas d\'usage liés au Big Data', 'Data Visualisation, mesure de l\'e-réputation, satisfaction client, segmentation, ROI influenceurs et campagnes marketing. Études de cas pratiques.', '0,5 jour', 3),
(1128, 196, 'Cadrer la stratégie Big Data', 'Facteurs de succès, risques, maturité de l\'entreprise, définition des objectifs métiers, pilotage et veille technologique. TP : Création de visualisations dynamiques.', '0,5 jour', 4),
(1129, 197, 'Les techniques Objet', 'Principes généraux de la modélisation et POO. Abstraction, encapsulation, interfaces, héritage, polymorphisme. Introduction à la modélisation UML. TP : Spécification UML d\'une étude de cas.', NULL, 1),
(1130, 197, 'Les constructions de base du langage', 'Variables, typage, méthodes, expressions, instructions de contrôle (conditions, boucles, branchements), tableaux, types énumérés, autoboxing, unités de compilation et packages, imports statiques.', NULL, 2),
(1131, 197, 'La définition et l\'instanciation des classes', 'Classes et objets, champs, constructeurs, autoréférence, membres statiques, méthodes à nombre variable d\'arguments. Méthodologie de conception des classes.', NULL, 3),
(1132, 197, 'L\'héritage et la généricité', 'Extension, implémentation, polymorphisme, hiérarchies de classes, factorisation (classes abstraites). TP : Conception d\'une hiérarchie de classes/interfaces avec polymorphisme et généricité.', NULL, 4),
(1133, 197, 'Les exceptions', 'Blocs Try/Catch, génération d\'exceptions, algorithme de sélection. Méthodologie : construction d\'une hiérarchie d\'exceptions.', NULL, 5);
INSERT INTO `formation_modules` (`id`, `course_id`, `title`, `description`, `duration`, `sort_order`) VALUES
(1134, 197, 'La programmation des entrées/sorties', 'Hiérarchie des classes d\'E/S, manipulation des systèmes de fichiers, flots de bytes et de char, E/S clavier. TP : Lecture/écriture dans des fichiers.', NULL, 6),
(1135, 197, 'La programmation graphique et classes utilitaires', 'Visualisation et gestion des événements (depuis jdk1.1), conteneurs, layouts, composants graphiques (labels, boutons...), listeners et adapters. Classes système et conteneurs. TP : Construction d\'une IHM.', NULL, 7),
(1136, 198, 'Se positionner comme leader', 'Définir le champ d\'action et la mission du manager (expertise vs management). Les 3 rôles du manager. Déterminer les sources de pouvoir et les comportements du leader. Outil : le cercle d\'or du manager.', NULL, 1),
(1137, 198, 'Identifier le niveau de maturité des collaborateurs', 'Distinguer mission, tâche et activité. Évaluer la compétence et la motivation pour identifier les niveaux de maturité. Outil : la matrice managériale. Étude de cas et exercices pratiques.', NULL, 2),
(1138, 198, 'Adapter son leadership', 'Définir les comportements centrés sur la tâche ou la relation. Autodiagnostic des styles préférentiels. Les 4 styles de leadership. Mises en situation et quiz de validation.', NULL, 3),
(1139, 198, 'Développer les compétences', 'Mettre en place un cycle progressif. Le manager comme catalyseur de compétences et de motivation. Réagir face à la dynamique de régression. Outil : le cycle de régression.', NULL, 4),
(1140, 198, 'Utiliser la dynamique du management situationnel', 'Déléguer pour motiver, obtenir l\'engagement et utiliser les signes de reconnaissance. Agir pour remotiver (indicateurs de démotivation, entretien de re-motivation). Définition d\'un plan d\'action personnel.', NULL, 5),
(1141, 199, 'Les enjeux de la Responsabilité Sociale, Environnementale et Économique', 'Le développement durable et l\'entreprise (Stratégie RSE, Achats responsables, RH). Investissement socialement responsable (ISR) et notation. Droit de l\'environnement, enjeux climatiques (eau, énergie, biodiversité, air) et économie circulaire (ESS).', NULL, 1),
(1142, 199, 'La relation avec les parties prenantes et le management de l’information', 'Rapport RSE et reporting réglementaire. Plan de communication DD. Cartographie et gouvernance des parties prenantes. Techniques d\'enquête quantitatives et qualitatives.', NULL, 2),
(1143, 199, 'Les outils opérationnels de la RSE', 'Réalisation d\'une matrice de matérialité. Animations d\'équipes, réunions, entretiens. Conduite du changement et accompagnement des acteurs. Management intégré QHSE.', NULL, 3),
(1144, 199, 'Développement des habiletés transversales', 'Projet professionnel et valorisation de l\'expérience. Gestion de projets appliqués au développement durable. Anglais.', NULL, 4),
(1145, 199, 'Missions d\'apprentissage (Cas pratiques)', 'Reporting RSE, stratégie ISO 26000 / ISO 14001, bilan carbone, charte éthique, benchmarking RSE, cartographie des parties prenantes et assistance au service Compliance.', NULL, 5),
(1146, 200, 'Appréhender les spécificités d\'une organisation projet', 'Définir le management de projet, gérer un projet (enjeux et spécificités), identifier les acteurs et les instances. Partage d\'expériences sur les causes d\'échec fréquentes.', NULL, 1),
(1147, 200, 'Réussir le cadrage et le lancement du projet', 'Initialiser le projet : cahier des charges, lettre de mission, note de cadrage, briefing et contrat commercial. Cerner les enjeux et objectifs. Exercice : rédaction de la note de cadrage.', NULL, 2),
(1148, 200, 'Planifier et sécuriser le projet en amont', 'Découpage en tâches, délais réalistes, planning, marges et tâches critiques. Évaluer la faisabilité financière, identifier les risques et répartir les rôles. Exercices sur la planification et la maîtrise des risques.', NULL, 3),
(1149, 200, 'Construire l\'équipe projet', 'Contribution du chef de projet, identification des compétences indispensables, gestion de la relation avec la hiérarchie et répartition des tâches. Jeu de rôles : l\'entretien de contribution.', NULL, 4),
(1150, 200, 'Piloter le déroulement du projet au quotidien', 'Réussir la réunion de lancement (règles, rôles, organisation). Mettre en place des outils de mesure d\'avancement physique (indicateurs, tableau de bord). Gérer les situations complexes.', NULL, 5),
(1151, 200, 'Clôturer et capitaliser le projet', 'Identifier les phases finales, capitaliser l\'expérience et évaluer le projet. Plan d\'action personnel. Vidéo : Asseoir son management transversal.', NULL, 6),
(1152, 201, 'Définir son modèle d’agilité managériale', 'Définir sa vision cible de l’organisation Agile. Identifier les principes de l’organisation Agile. Comprendre et gérer dans la complexité.', NULL, 1),
(1153, 201, 'Développer les compétences d’agilité pour soi et son équipe', 'Définir les rôles et postures du manager agile. Identifier les compétences stratégiques pour favoriser l’agilité de l’équipe. Être un manager pédagogue et force d’exemple pour promouvoir l’Agilité.', NULL, 2),
(1154, 201, 'Organiser son équipe selon le mode Agile', 'Utiliser les 4 leviers du travail collaboratif : confiance, cohésion, convivialité, créativité. Définir les rôles et responsabilités des membres des équipes Agiles. Utiliser les outils de gestion adéquats pour le fonctionnement Agile.', NULL, 3),
(1155, 201, 'Valoriser la flexibilité et la coopération', 'Soutenir les équipes \"Agiles\" : accompagner dans le changement, identifier les leaders \"Agiles\" dans l’équipe. Agir en mentor : accompagner en fonction des profils et valoriser les progrès.', NULL, 4),
(1156, 202, 'Développement du leadership et engagement', 'Contenu détaillé du programme construit autour de l\'affinage des compétences en leadership, du renforcement de la collaboration et des leviers de motivation des collaborateurs. (Détails spécifiques sur demande).', NULL, 1),
(1157, 203, 'Introduction à DevOps et Docker', 'Qu’est qu’un DevOps ? Introduction à Docker et installation de l\'environnement.', NULL, 1),
(1158, 203, 'Maîtrise des fondamentaux de Docker', 'Gestion des images Docker, lancement et gestion des conteneurs, utilisation des volumes et des réseaux Docker.', NULL, 2),
(1159, 203, 'Sécurité et automatisation avancée', 'Utiliser des secrets. Utilisation des fichiers Dockerfile et maîtrise des instructions avancées dans un Dockerfile.', NULL, 3),
(1160, 203, 'Infrastructure As Code avec Docker Compose', 'Infrastructure As Code avec Docker Compose et fonctionnalités avancées pour aller plus loin sur Docker Compose.', NULL, 4),
(1161, 203, 'Registres et orchestration avec Docker Swarm', 'Utiliser Docker Hub, création d’un registre privé. Introduction à Docker Swarm, création d\'un cluster, partage de données entre serveurs et mise à l\'échelle de l\'infrastructure.', NULL, 5),
(1162, 203, 'CI/CD et ouverture vers Kubernetes', 'Comprendre l’intégration continue et le déploiement continu. L’intégration continue avec Docker et Github. Passer au niveau supérieur : introduction à Kubernetes.', NULL, 6),
(1163, 204, 'Point sur les fonctions avancées et implémentation Hyper-V', 'Déterminer la configuration matérielle/logicielle. Installer, configurer et manipuler les services Hyper-V et les machines virtuelles (VM). Importer/exporter une VM et configurer les clichés.', NULL, 1),
(1164, 204, 'Implémenter la Haute disponibilité (HA)', 'Implémenter une infrastructure de haute disponibilité avec 2 serveurs. Installer un serveur iSCSI.', NULL, 2),
(1165, 204, 'Implémenter un conteneur', 'Comprendre l\'intérêt et les limites de la conteneurisation. Utiliser, installer et configurer des conteneurs dans Windows Server.', NULL, 3),
(1166, 204, 'Implémenter le bureau à distance', 'Comprendre les services de bureau à distance. Installer et configurer les services TSE/RDS.', NULL, 4),
(1167, 204, 'Implémenter les services de mises à jour et déploiement', 'Installer et configurer WSUS (Windows Server Update Services). Déployer des applications avec WSUS et WPP. Déployer WDS (Windows Deployment Services) et installer un Windows Server Core.', NULL, 5),
(1168, 205, 'Évaluation et cadrage du parcours', 'Définition des objectifs particuliers de la formation. Élaboration d\'un programme de formation personnalisé selon votre niveau et vos besoins.', 'Phase initiale', 1),
(1169, 205, 'Prendre ses repères dans Excel', 'Utiliser le ruban, la barre d\'accès rapide et la barre d\'état. Enregistrer et modifier un classeur. Découverte de la barre d\'outils et de la feuille Excel.', 'Module 1', 2),
(1170, 205, 'Concepts de base et organisation', 'Identifier les concepts de base. Insérer, déplacer et copier une ou plusieurs feuilles. Modifier plusieurs feuilles simultanément. Lier des données entre tableaux.', 'Module 2', 3),
(1171, 205, 'Concevoir, présenter et imprimer un tableau', 'Saisir données et formules. Formater cellules (chiffres, texte, titres), modifier les largeurs de colonnes. Définir une mise en forme conditionnelle. Imprimer l\'intégralité ou une partie du tableau, titrer et paginer.', 'Module 3', 4),
(1172, 205, 'Méthodes, entraînement et certification TOSA', 'Apports théoriques, échanges et questions-réponses avec un formateur qualifié. Entraînement aux épreuves TOSA par des tests blancs et mini-tests. Passage de la certification TOSA.', 'Module 4', 5),
(1173, 206, 'Concevoir une présentation', 'Identifier les points clés d\'une présentation réussie. Procéder avec méthode : objectifs, résultat attendu, délai de rédaction. Mettre au point son plan.', 'Module 1', 1),
(1174, 206, 'Définir la ligne graphique', 'Utiliser les thèmes pour la cohérence visuelle. Modifier couleurs, polices et effets. Exploiter les masques, insérer un logo sur toutes les diapositives. Modifier puces, alignement, interligne. Appliquer un style d\'arrière-plan.', 'Module 2', 2),
(1175, 206, 'Organiser ses diapositives', 'Exploiter le mode Trieuse de diapositives. Supprimer, déplacer, dupliquer ou masquer des diapositives.', 'Module 3', 3),
(1176, 206, 'Enrichir le contenu de chaque diapositive', 'Choisir une disposition adaptée. Insérer et personnaliser une photo. Construire un tableau, créer un graphique. Ajouter du texte WordArt. Positionner, aligner et répartir les objets. Dissocier, grouper et fusionner des objets.', 'Module 4', 4),
(1177, 206, 'Diaporama, projection et certification TOSA', 'Appliquer des effets de transition et animer texte et objets. Exécuter le diaporama (navigation, zoom, pointeur laser, pause). Exploiter le mode présentateur. Apports théoriques, échanges avec formateur qualifié, tests blancs et mini-tests TOSA.', 'Module 5', 5),
(1178, 207, 'Personnaliser Word', 'Personnaliser la barre d\'accès rapide, le ruban, les raccourcis clavier et la police. Enrichir la correction automatique. Exploiter les outils de traduction.', 'Module 1', 1),
(1179, 207, 'Automatiser la présentation des documents', 'Repérer les mises en forme répétitives. Créer, appliquer, modifier et enchaîner les styles. Créer un thème. Créer des modèles.', 'Module 2', 2),
(1180, 207, 'Construire un document structuré', 'Utiliser le mode plan et créer une table des matières. Créer des styles pour listes à puces, numérotées et hiérarchisées. Personnaliser les styles de titres. Numéroter automatiquement les titres et insérer le sommaire.', 'Module 3', 3),
(1181, 207, 'Intégrer des illustrations', 'Définir l\'habillage du texte autour des images. Insérer un tableau, un graphique Excel, un diagramme SmartArt. Maîtriser le positionnement des objets.', 'Module 4', 4),
(1182, 207, 'Tableaux, colonnes et collaboration', 'Dessiner un tableau (gomme, stylo, fusionner et fractionner). Créer un tableau de mise en page. Présenter le texte en colonnes. Suivre les modifications, insérer des commentaires, partager le document en ligne.', 'Module 5', 5),
(1183, 207, 'Méthodes, entraînement et certification TOSA', 'Apports théoriques, échanges et questions-réponses avec un formateur qualifié. Entraînement aux épreuves TOSA par tests blancs et mini-tests. Passage de la certification.', 'Module 6', 6);

-- --------------------------------------------------------

--
-- Structure de la table `formation_objectives`
--

CREATE TABLE `formation_objectives` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_objectives`
--

INSERT INTO `formation_objectives` (`id`, `course_id`, `content`, `sort_order`) VALUES
(267, 138, '[object Object]', 1),
(268, 153, 'S’approprier les concepts et principes structurants du DevOps', 1),
(269, 153, 'Relier prestation de services, organisation et indicateurs', 2),
(270, 153, 'Identifier les leviers d’automatisation et de livraison continue pertinents pour votre SI', 3),
(271, 153, 'Préparer l’examen DASA DevOps Fundamentals dans de bonnes conditions', 4),
(272, 154, 'Situer l’historique et les leviers du mouvement DevOps', 1),
(273, 154, 'Définir les transitions culturelles utiles dans une équipe IT', 2),
(274, 154, 'Structurer une vision de la livraison continue adaptée à votre contexte', 3),
(275, 154, 'Donner du sens aux métriques et aux boucles de feedback', 4),
(276, 154, 'Prioriser des étapes réalistes pour avancer après la formation', 5),
(277, 155, 'Construire un plan de gestion des incidents aligné sur ISO/IEC 27035', 1),
(278, 155, 'Relier incidents, SMSI et exigences de la norme', 2),
(279, 155, 'Comparer ISO/IEC 27035 aux autres référentiels utiles', 3),
(280, 155, 'Mettre en œuvre une démarche processus pour traiter les incidents de sécurité de l’information', 4),
(281, 156, 'Décrypter les concepts SGBDR et l’algèbre relationnelle derrière vos requêtes SQL', 1),
(282, 156, 'S’appuyer sur un environnement SQL en confiance pour vos futurs scripts', 2),
(283, 156, 'Produire des extractions fiables et des mises à jour conformes au modèle', 3),
(284, 156, 'Manipuler les données avec INSERT, UPDATE, DELETE ou TRUNCATE selon le besoin', 4),
(285, 156, 'Relier plusieurs tables par jointures et agrégations pertinentes', 5),
(286, 156, 'Utiliser fonctions courantes et fonctions de fenêtrage pour des analyses avancées', 6),
(287, 157, 'Cadrer le positionnement de Docker et des conteneurs dans vos projets', 1),
(288, 157, 'Mettre en œuvre Docker et son écosystème pour livrer vite sans perdre le contrôle', 2),
(289, 157, 'Piloter la CLI pour créer, surveiller et dépanner des conteneurs', 3),
(290, 157, 'Assurer l’exploitation de conteneurs dans des scénarios proches du terrain', 4),
(291, 157, 'Relever les risques Docker et choisir des contremesures adaptées', 5),
(292, 158, 'Décrire les étapes types d’une attaque et les comportements adverses récurrents', 1),
(293, 158, 'Connaître les TTPs fréquemment observées sur le terrain', 2),
(294, 158, 'Repérer les vulnérabilités majeures d’une architecture et de ses briques', 3),
(295, 158, 'Réduire la surface d’attaque en combinant détection et mécanismes de déception', 4),
(296, 158, 'Aligner une politique de sécurité sur le risque métier réel', 5),
(297, 158, 'Exploiter la Threat Intelligence sans se noyer dans les flux', 6),
(298, 158, 'Expliciter les principes de défense en profondeur applicables à votre SI', 7),
(299, 159, 'Lire et utiliser les principes fondamentaux des tests ISTQB', 1),
(300, 159, 'Cartographier les activités de test sur un cycle de développement', 2),
(301, 159, 'Exploiter les revues et analyses statiques comme levier qualité', 3),
(302, 159, 'Enchaîner analyse, conception et exécution de tests de façon traçable', 4),
(303, 159, 'Tirer parti des indicateurs de pilotage d’une campagne de tests', 5),
(304, 159, 'Cerner le rôle des outils et leurs limites', 6),
(305, 159, 'Aborder l’examen de certification ISTQB Fondation en connaissance de cause', 7),
(306, 160, 'Relier les pratiques de développement Agile aux enjeux de test', 1),
(307, 160, 'Comparer principes, rituels et cadres courants d’un projet Agile', 2),
(308, 160, 'Mettre en œuvre méthodes et techniques de test adaptées à l’itération', 3),
(309, 160, 'Préparer et réussir l’examen ISTQB Testeur Agile', 4),
(310, 161, 'Relier besoins métiers, exigences et jeux de tests d’acceptation', 1),
(311, 161, 'Utiliser des familles de tests d’acceptation (exploratoire, bêta, etc.)', 2),
(312, 161, 'Modéliser un processus (BPMN, DMN) pour en dériver des tests', 3),
(313, 161, 'Couvrir les exigences non fonctionnelles en phase d’acceptation', 4),
(314, 161, 'Organiser la collaboration entre métiers, QA et MOA', 5),
(315, 161, 'Réussir l’examen ISTQB Tests d’acceptation', 6),
(316, 162, 'Bâtir une stratégie cyber à partir d’une analyse de risque structurée', 1),
(317, 162, 'Durcir réseaux, protocoles, terminaux et serveurs Linux', 2),
(318, 162, 'Piloter le déploiement et le suivi d’une stratégie cyber transverse', 3),
(319, 163, 'Construire des pages Web en HTML5', 1),
(320, 163, 'Habiller et mettre en forme des pages Web avec CSS3', 2),
(321, 163, 'Créer des formulaires avancés et des tableaux de données', 3),
(322, 163, 'Créer des menus de navigation', 4),
(323, 163, 'Utiliser les techniques CSS de positionnement et dimensionnement pour adapter la présentation aux différents appareils (smartphone, tablette, PC)', 5),
(324, 163, 'Parcourir et modifier la structure d’une page en JavaScript', 6),
(325, 163, 'Gérer des événements utilisateur', 7),
(326, 163, 'Intégrer des appels à des services Web REST et WebSockets en JavaScript', 8),
(327, 164, 'Décrire la philosophie de Python et identifier ses domaines d’application', 1),
(328, 164, 'Mettre en place un environnement de développement', 2),
(329, 164, 'Utiliser les éléments de base du langage', 3),
(330, 164, 'Définir et utiliser des fonctions et des modules pour la structuration des programmes', 4),
(331, 164, 'Concevoir des classes en respectant les bonnes pratiques de la programmation objet', 5),
(332, 164, 'Mettre en œuvre l’héritage', 6),
(333, 164, 'Réaliser et exécuter des scripts en utilisant les fonctionnalités de la bibliothèque standard', 7),
(334, 164, 'Concevoir des interfaces graphiques', 8),
(335, 164, 'Réaliser des tests pour valider le bon fonctionnement du code', 9),
(336, 165, 'Définir la culture digitale et son impact sur l’économie', 1),
(337, 165, 'Identifier les nouveaux usages et comportements face au digital', 2),
(338, 165, 'Comprendre la transformation des métiers et des organisations', 3),
(339, 165, 'Partager un vocabulaire commun autour du digital et des technologies du Web', 4),
(340, 165, 'Identifier les outils du digital et leurs valeurs ajoutées', 5),
(341, 166, 'Découvrir les principales technologies du framework .NET', 1),
(342, 166, 'Maîtriser la syntaxe du langage C#', 2),
(343, 166, 'Mettre en œuvre la programmation orientée objet avec C#', 3),
(344, 166, 'Utiliser l’environnement de développement intégré Visual Studio', 4),
(345, 167, 'Comprendre les principes et les spécificités de la conception par objets', 1),
(346, 167, 'Passer d’une approche fonctionnelle à une approche objet', 2),
(347, 167, 'Modéliser un logiciel objet à l’aide de la notation UML', 3),
(348, 167, 'Traduire le modèle UML dans un langage objet', 4),
(349, 167, 'Décrire les approches par frameworks et par composants', 5),
(350, 167, 'Savoir mettre en œuvre des design patterns', 6),
(351, 168, 'Assumer efficacement le rôle de RSSI dans la gouvernance SSI de l’organisation', 1),
(352, 168, 'Structurer un SMSI selon l’ISO/IEC 27001 et piloter sa mise en œuvre', 2),
(353, 168, 'Appliquer les méthodes d’analyse de risques via EBIOS RM et ISO/IEC 27005', 3),
(354, 168, 'Intégrer les bonnes pratiques de l’ANSSI pour renforcer la posture SSI', 4),
(355, 168, 'Définir une stratégie cybersécurité en phase avec les enjeux métier et réglementaires', 5),
(356, 169, 'Identifier les concepts du cloud computing et de la virtualisation', 1),
(357, 169, 'Évaluer les différents types de cloud et les technologies associées', 2),
(358, 169, 'Comprendre la valeur ajoutée du cloud pour les métiers et l’IT', 3),
(359, 169, 'Définir les besoins en sécurité, les risques et les mesures d’atténuation', 4),
(360, 169, 'Préciser les impacts du cloud sur la gouvernance du SI et mieux accompagner la transition', 5),
(361, 170, 'Comprendre les mécanismes intervenant dans les communications réseaux', 1),
(362, 170, 'Construire des réseaux LAN simples', 2),
(363, 170, 'Configurer les commutateurs Cisco pour la mise en place d’un réseau LAN simple', 3),
(364, 171, 'Découvrir les fondamentaux du cloud et leur impact sur l’architecture des entreprises', 1),
(365, 171, 'Savoir utiliser l’infrastructure, les plateformes et les applications « as a service »', 2),
(366, 171, 'Évaluer l’impact du cloud sur la gestion des services informatiques de l’entreprise', 3),
(367, 171, 'Évaluer une architecture cloud computing', 4),
(368, 171, 'Structurer une démarche de migration vers un environnement cloud', 5),
(369, 172, 'Comprendre les enjeux et le déroulement d’un audit de sécurité sur application Android', 1),
(370, 172, 'Mettre en place et exploiter un environnement de tests d’intrusion mobiles (concepts, outillage, analyse statique)', 2),
(371, 172, 'Analyser les communications et le comportement dynamique d’une application Android dans un scénario d’audit', 3),
(372, 173, 'Maîtriser les objectifs, avantages, concepts et vocabulaire DevSecOps', 1),
(373, 173, 'Comparer les pratiques de sécurité en contexte DevOps aux autres approches de sécurité', 2),
(374, 173, 'Décliner des stratégies de sécurité alignées sur les enjeux d’entreprise', 3),
(375, 173, 'Comprendre et mettre en œuvre les principes issus des sciences de la sécurité et des données', 4),
(376, 173, 'Exploiter les apports des équipes rouges et bleues dans une démarche structurante', 5),
(377, 173, 'Intégrer la sécurité dans les flux de travail et pipelines de livraison continue', 6),
(378, 173, 'Positionner les rôles DevSecOps dans la culture et l’organisation DevOps', 7),
(379, 174, 'Maîtriser la syntaxe du langage C++', 1),
(380, 174, 'Mettre en œuvre les concepts de la conception orientée objet', 2),
(381, 174, 'Utiliser les outils de développement associés au langage C++', 3),
(382, 174, 'Maîtriser les ajouts majeurs de la norme C++11 utiles au quotidien', 4),
(383, 175, 'Établir des standards de criminalistique numérique acceptés par l’industrie et des politiques alignées sur les bonnes pratiques actuelles', 1),
(384, 175, 'Préparer efficacement l’examen Mile2 Certified Digital Forensics Examiner (C-DFE)', 2),
(385, 176, 'Appliquer les concepts fondamentaux des domaines information technology et sécurité', 1),
(386, 176, 'Aligner les objectifs opérationnels de l’organisation avec les fonctions et mises en œuvre sécurité', 2),
(387, 176, 'Identifier comment protéger les actifs de l’organisation tout au long de leur cycle de vie', 3),
(388, 176, 'Maîtriser les principes, structures et standards pour concevoir, déployer, superviser et sécuriser systèmes d’exploitation, équipements, réseaux et applications (CIA)', 4),
(389, 176, 'Appliquer les principes de sécurité pour choisir des mitigations pertinentes selon l’architecture et les types de systèmes d’information', 5),
(390, 176, 'Expliquer le rôle de la cryptographie et des services de sécurité à l’ère numérique', 6),
(391, 176, 'Évaluer la sécurité physique et les exigences de sécurité de l’information', 7),
(392, 176, 'Évaluer la communication et la sécurité réseau au regard des besoins information security', 8),
(393, 176, 'S’appuyer sur concepts et architectures (dont modèle OSI couches 1 à 7) pour répondre aux besoins de sécurité', 9),
(394, 176, 'Déterminer des modèles de contrôle d’accès adaptés aux exigences métier', 10),
(395, 176, 'Mettre en œuvre des contrôles d’accès physique et logique', 11),
(396, 176, 'Différencier les approches de conception et validation des stratégies de test et d’audit', 12),
(397, 176, 'Appliquer contrôles et contre-mesures pour soutenir la performance opérationnelle', 13),
(398, 176, 'Évaluer les risques des systèmes d’information pour les activités de l’organisation', 14),
(399, 177, '[object Object]', 1),
(400, 178, '[object Object]', 1),
(401, 179, '[object Object]', 1),
(402, 180, '[object Object]', 1),
(403, 181, '[object Object]', 1),
(404, 182, '[object Object]', 1),
(405, 183, 'Expliquer les concepts fondamentaux de l’intelligence artificielle générative', 1),
(406, 183, 'Identifier les usages métiers de Microsoft 365 Copilot', 2),
(407, 183, 'Utiliser Copilot Chat pour automatiser des tâches professionnelles', 3),
(408, 183, 'Rédiger et améliorer du contenu à l’aide de Copilot dans Word, Outlook et PowerPoint', 4),
(409, 183, 'Analyser et visualiser des données avec Copilot dans Excel', 5),
(410, 183, 'Optimiser la collaboration et la gestion des réunions avec Copilot dans Outlook et Teams', 6),
(411, 183, 'Intégrer Copilot dans les processus métier de son organisation', 7),
(412, 184, 'Comprendre les fondamentaux de l’IA et ses usages', 1),
(413, 184, 'Identifier les cas d’usage pertinents de l’IA générative dans l’environnement professionnel IT', 2),
(414, 184, 'Utiliser des outils d’IA pour générer, corriger, commenter ou documenter des scripts', 3),
(415, 184, 'Interagir efficacement avec un LLM pour résoudre des problèmes systèmes et réseaux', 4),
(416, 184, 'Automatiser certaines tâches administratives ou documentaires à l’aide de l’IA générative', 5),
(417, 184, 'Appliquer une méthode d’expérimentation de prompts adaptée à un usage technique', 6),
(418, 184, 'Identifier les enjeux éthiques, juridiques et organisationnels liés à l’usage de l’IA', 7),
(419, 184, 'Adopter une posture critique face aux résultats produits par l’IA', 8),
(420, 185, 'Appréhender le fonctionnement et l’architecture des outils d’IA générative', 1),
(421, 185, 'Identifier et analyser les usages de l’IA générative dans divers secteurs d’activité', 2),
(422, 185, 'Créer et optimiser des illustrations automatisées avec des prompts avancés', 3),
(423, 185, 'Utiliser des LLM et des transformers pour automatiser des tâches avec l’IA', 4),
(424, 185, 'Utiliser l’IA générative pour créer des synthèses à partir de diverses sources d’information', 5),
(425, 185, 'Concevoir et connecter un chatbot à des services d’API d’IA générative', 6),
(426, 185, 'Exploiter les outils libres et open source comme alternatives aux plateformes propriétaires', 7),
(427, 185, 'Développer un chatbot fonctionnel en mode hors ligne avec des outils open source', 8),
(428, 186, 'Comprendre le fonctionnement des modèles génératifs comme ChatGPT', 1),
(429, 186, 'Maîtriser l’interaction avec l’API OpenAI et l’utilisation de ChatGPT pour la génération, la refactorisation, l’optimisation et le nettoyage du code', 2),
(430, 186, 'Utiliser l’IA pour la détection et la correction de failles de sécurité', 3),
(431, 186, 'Comprendre les limitations, les risques et les évolutions possibles des IA génératives', 4),
(432, 187, 'Comprendre le fonctionnement et les capacités de l’API ChatGPT', 1),
(433, 187, 'Configurer un environnement de développement pour l’API', 2),
(434, 187, 'Maîtriser l’envoi de requêtes à l’API et l’analyse de ses réponses', 3),
(435, 187, 'Expérimenter avec différents paramètres pour obtenir des réponses personnalisées', 4),
(436, 187, 'Gérer des conversations multi-tours et maintenir un état de dialogue cohérent', 5),
(437, 187, 'Intégrer l’API dans des applications web et mobiles tout en respectant les bonnes pratiques de sécurité', 6),
(438, 187, 'Déployer l’API sur différentes plateformes d’hébergement', 7),
(439, 187, 'Respecter les considérations éthiques et les politiques de confidentialité lors de l’utilisation de l’API', 8),
(440, 188, 'Utiliser des IA génératives dans les processus de production et de communication', 1),
(441, 188, 'Rédiger des prompts efficaces pour guider l’IA dans la conversation', 2),
(442, 188, 'Élaborer des stratégies de webmarketing en s’appuyant sur l’IA', 3),
(443, 188, 'Produire des contenus éditoriaux avec l’IA', 4),
(444, 188, 'Optimiser les contenus pour le référencement naturel (SEO) avec l’IA', 5),
(445, 188, 'Rédiger des communiqués de presse et définir des stratégies de relations publiques avec l’IA', 6),
(446, 188, 'Générer des publications pour les réseaux sociaux avec l’IA', 7),
(447, 188, 'Créer des annonces et supports marketing avec l’IA', 8),
(448, 189, 'Identifier un problème pouvant être traité par machine learning', 1),
(449, 189, 'Repérer les outils et bibliothèques adaptés au contexte', 2),
(450, 189, 'Prétraiter et préparer des données pour l’apprentissage', 3),
(451, 189, 'Construire des modèles d’apprentissage non supervisés', 4),
(452, 189, 'Construire des modèles d’apprentissage supervisés', 5),
(453, 189, 'Mesurer et interpréter la performance des modèles', 6),
(454, 189, 'Repérer les barrières techniques du machine learning sur un cas donné', 7),
(455, 189, 'Identifier des méthodes pour améliorer les performances (régularisation, features, etc.)', 8),
(456, 189, 'Transformer les sorties du modèle en résultats exploitables métier', 9),
(457, 189, 'Appliquer le machine learning au traitement d’images', 10),
(458, 189, 'Appliquer le machine learning au traitement de texte', 11),
(459, 189, 'Traiter un problème de recommandation', 12),
(460, 190, 'Identifier les capacités réelles — et les limites — des systèmes d’IA actuels', 1),
(461, 190, 'Cerner les principaux acteurs du marché et les dynamiques de la recherche', 2),
(462, 190, 'Décrire les effets de l’intégration de l’IA dans des systèmes métiers et les conditions d’une transition raisonnée', 3),
(463, 191, 'Prétraiter et vectoriser des données textuelles', 1),
(464, 191, 'Concevoir et entraîner des réseaux profonds pour le langage', 2),
(465, 191, 'Repérer les verrous techniques du deep learning sur un cas donné', 3),
(466, 191, 'Utiliser les principaux mécanismes de régularisation', 4),
(467, 191, 'Mettre en œuvre la traduction automatique de documents', 5),
(468, 191, 'Détecter la polarité / le sentiment dans des textes', 6),
(469, 191, 'Produire des résumés automatiques de documents', 7),
(470, 191, 'Générer du texte (assistants conversationnels / chatbots)', 8),
(471, 191, 'Interpréter les métriques et produire des résultats actionnables', 9),
(472, 205, 'Définir des objectifs de formation personnalisés à partir d\'un positionnement initial', 1),
(473, 205, 'Maîtriser l\'interface Excel et les fonctions de base', 2),
(474, 205, 'Organiser feuilles et classeurs, lier des données entre tableaux', 3),
(475, 205, 'Concevoir, formater et imprimer des tableaux avec formules et mise en forme conditionnelle', 4),
(476, 205, 'S\'entraîner aux épreuves TOSA via tests blancs et mini-tests', 5),
(477, 205, 'Valider son niveau avec la certification TOSA', 6),
(478, 206, 'Concevoir une présentation en définissant objectifs, résultat attendu et plan', 1),
(479, 206, 'Définir une ligne graphique cohérente (thèmes, masques, logo, styles)', 2),
(480, 206, 'Organiser et gérer les diapositives avec le mode Trieuse', 3),
(481, 206, 'Enrichir les diapositives : médias, tableaux, graphiques, WordArt et mise en page des objets', 4),
(482, 206, 'Maîtriser transitions, animations et mode présentateur', 5),
(483, 206, 'S\'entraîner et valider son niveau avec la certification TOSA PowerPoint', 6),
(484, 207, 'Personnaliser l\'interface Word et les outils de correction', 1),
(485, 207, 'Automatiser la mise en forme avec styles, thèmes et modèles', 2),
(486, 207, 'Construire un document structuré (plan, sommaire, listes hiérarchisées)', 3),
(487, 207, 'Intégrer illustrations, tableaux, graphiques et SmartArt', 4),
(488, 207, 'Présenter l\'information en tableaux et colonnes', 5),
(489, 207, 'Collaborer et valider son niveau avec la certification TOSA Word', 6);

-- --------------------------------------------------------

--
-- Structure de la table `formation_skills`
--

CREATE TABLE `formation_skills` (
  `id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_skills`
--

INSERT INTO `formation_skills` (`id`, `course_id`, `name`, `sort_order`) VALUES
(709, 119, 'Administration systèmes (Windows / Linux).', 1),
(710, 119, 'Gestion des réseaux et services associés.', 2),
(711, 119, 'Sécurisation des infrastructures et des accès.', 3),
(712, 119, 'Virtualisation et haute disponibilité.', 4),
(713, 119, 'Supervision, maintenance et gestion des incidents.', 5),
(714, 119, 'Documentation technique et bonnes pratiques IT.', 6),
(715, 120, 'Maîtrise des langages du web (HTML, CSS, JavaScript)', 1),
(716, 120, 'Développement front-end et back-end', 2),
(717, 120, 'Gestion des bases de données', 3),
(718, 120, 'Utilisation de frameworks et outils modernes', 4),
(719, 120, 'Méthodologie de projet et travail en équipe', 5),
(720, 120, 'Mise en production et maintenance applicative', 6),
(721, 121, 'Développement front-end et interaction utilisateur', 1),
(722, 121, 'Programmation applicative multimédia', 2),
(723, 121, 'Intégration de médias numériques', 3),
(724, 121, 'Animation et interactivité', 4),
(725, 121, 'Gestion de projet multimédia', 5),
(726, 121, 'Tests, maintenance et optimisation des applications', 6),
(727, 122, 'Analyse des besoins fonctionnels', 1),
(728, 122, 'Conception d’architectures applicatives', 2),
(729, 122, 'Développement front-end et back-end', 3),
(730, 122, 'Gestion des bases de données', 4),
(731, 122, 'Tests, déploiement et maintenance', 5),
(732, 122, 'Travail en équipe projet', 6),
(733, 123, 'Administration des systèmes d’exploitation', 1),
(734, 123, 'Gestion des réseaux locaux et étendus', 2),
(735, 123, 'Sécurité des systèmes et des réseaux', 3),
(736, 123, 'Supervision et maintenance informatique', 4),
(737, 123, 'Assistance et support technique', 5),
(738, 123, 'Documentation et procédures IT', 6),
(739, 124, 'Maîtrise des langages web (HTML, CSS, JavaScript)', 1),
(740, 124, 'Développement front-end et back-end', 2),
(741, 124, 'Utilisation des frameworks et outils modernes', 3),
(742, 124, 'Gestion de bases de données (MySQL / SQL)', 4),
(743, 124, 'Organisation et pilotage de projet', 5),
(744, 124, 'Coordination d’équipe et communication technique', 6),
(745, 124, 'Respect des normes de sécurité et de performance', 7),
(746, 125, 'Gestion de l\'administration du personnel', 1),
(747, 125, 'Élaboration et suivi du plan de formation', 2),
(748, 125, 'Maîtrise du cadre légal et droit du travail', 3),
(749, 125, 'Recrutement et intégration des talents', 4),
(750, 125, 'Communication interne et relations sociales', 5),
(751, 125, 'Préparation et gestion des éléments de paie', 6),
(752, 126, 'Assurer l\'administration courante du personnel.', 1),
(753, 126, 'Préparer les éléments de la paie.', 2),
(754, 126, 'Contribuer au processus de recrutement.', 3),
(755, 126, 'Participer au développement des compétences.', 4),
(756, 126, 'Assurer la communication interne RH.', 5),
(757, 127, 'Gestion de l\'administration du personnel', 1),
(758, 127, 'Élaboration et suivi du plan de formation', 2),
(759, 127, 'Maîtrise du cadre légal et droit du travail', 3),
(760, 127, 'Recrutement et intégration des talents', 4),
(761, 127, 'Communication interne et relations sociales', 5),
(762, 127, 'Préparation et gestion des éléments de paie', 6),
(763, 128, 'Gestion de l\'administration du personnel', 1),
(764, 128, 'Élaboration et suivi du plan de formation', 2),
(765, 128, 'Maîtrise du cadre légal et droit du travail', 3),
(766, 128, 'Recrutement et intégration des talents', 4),
(767, 128, 'Communication interne et relations sociales', 5),
(768, 128, 'Préparation et gestion des éléments de paie', 6),
(769, 129, 'Saisie des écritures comptables courantes', 1),
(770, 129, 'Établissements des déclarations fiscales (TVA, IS)', 2),
(771, 129, 'Préparation du bilan et du compte de résultat', 3),
(772, 129, 'Suivi de la trésorerie et rapprochements bancaires', 4),
(773, 129, 'Traitement de la comptabilité fournisseurs et clients', 5),
(774, 129, 'Utilisation des ERP et logiciels comptables', 6),
(775, 130, 'Gestion de l\'administration du personnel', 1),
(776, 130, 'Élaboration et suivi du plan de formation', 2),
(777, 130, 'Maîtrise du cadre légal et droit du travail', 3),
(778, 130, 'Recrutement et intégration des talents', 4),
(779, 130, 'Communication interne et relations sociales', 5),
(780, 130, 'Préparation et gestion des éléments de paie', 6),
(781, 131, 'Administration et configuration d’infrastructures réseau Automatisation des déploiements réseau', 1),
(782, 131, 'Gestion et supervision des infrastructures informatiques', 2),
(783, 131, 'Sécurisation des systèmes et des flux réseau', 3),
(784, 131, 'Gestion d’architectures cloud et datacenter', 4),
(785, 131, 'Diagnostic et résolution d’incidents réseau', 5),
(786, 132, 'Administration systèmes (Windows / Linux).', 1),
(787, 132, 'Gestion des réseaux et services associés.', 2),
(788, 132, 'Sécurisation des infrastructures et des accès.', 3),
(789, 132, 'Virtualisation et haute disponibilité.', 4),
(790, 132, 'Supervision, maintenance et gestion des incidents.', 5),
(791, 132, 'Documentation technique et bonnes pratiques IT.', 6),
(792, 133, 'Administration systèmes (Windows / Linux).', 1),
(793, 133, 'Gestion des réseaux et services associés.', 2),
(794, 133, 'Sécurisation des infrastructures et des accès.', 3),
(795, 133, 'Virtualisation et haute disponibilité.', 4),
(796, 133, 'Supervision, maintenance et gestion des incidents.', 5),
(797, 133, 'Documentation technique et bonnes pratiques IT.', 6),
(798, 134, 'Enregistrer et contrôler les opérations comptables et fiscales', 1),
(799, 134, 'Établir et présenter les comptes annuels et les états prévisionnels', 2),
(800, 134, 'Renseigner et contrôler les déclarations fiscales périodiques et annuelles', 3),
(801, 134, 'Suivre la trésorerie et les flux financiers de l\'entreprise', 4),
(802, 134, 'Produire des tableaux de bord et indicateurs de synthèse', 5),
(803, 134, 'Maîtriser les normes comptables, la fiscalité et les outils bureautiques / logiciels de gestion', 6),
(804, 135, 'Saisie des écritures comptables courantes', 1),
(805, 135, 'Établissements des déclarations fiscales (TVA, IS)', 2),
(806, 135, 'Préparation du bilan et du compte de résultat', 3),
(807, 135, 'Suivi de la trésorerie et rapprochements bancaires', 4),
(808, 135, 'Traitement de la comptabilité fournisseurs et clients', 5),
(809, 135, 'Utilisation des ERP et logiciels comptables', 6),
(810, 136, 'Création de chartes graphiques et visuels (suite Adobe CC : Photoshop, Illustrator, InDesign, Premiere, After Effects).', 1),
(811, 136, 'Conception d\'interfaces UX/UI et prototypes interactifs.', 2),
(812, 136, 'Intégration web : HTML / CSS, JavaScript, PHP/MySQL.', 3),
(813, 136, 'Gestion et personnalisation de CMS (WordPress).', 4),
(814, 136, 'Référencement naturel (SEO) et marketing digital.', 5),
(815, 136, 'Stratégie réseaux sociaux.', 6),
(816, 136, 'Optimisation de l\'expérience utilisateur et tests d\'ergonomie.', 7),
(817, 136, 'Veille technologique et créative.', 8),
(818, 137, 'Organisation et planification des activités de la direction.', 1),
(819, 137, 'Conception et rédaction de documents professionnels.', 2),
(820, 137, 'Communication interne et externe fluide.', 3),
(821, 137, 'Soutien à la gestion administrative et RH.', 4),
(822, 137, 'Maîtrise des outils collaboratifs (Zoom, Pack Office...).', 5),
(823, 138, 'Architecture logicielle avancée', 1),
(824, 138, 'Gestion de projets agiles', 2),
(825, 138, 'Développement Fullstack expert', 3),
(826, 139, 'Piloter la chaîne d\'approvisionnement et l\'assortiment commercial du point de vente', 1),
(827, 139, 'Concevoir une expérience client engageante et mesurer la fidélisation', 2),
(828, 139, 'Contribuer à la stratégie de l\'enseigne et construire des prévisionnels fiables', 3),
(829, 139, 'Lire les tableaux de bord, identifier les écarts et déployer des actions correctives', 4),
(830, 139, 'Recruter, intégrer et faire progresser les collaborateurs de l\'établissement', 5),
(831, 139, 'Animer le quotidien du magasin et porter les projets collectifs avec les équipes', 6),
(832, 140, 'Constituer et finaliser les dossiers administratifs de vente ou de location', 1),
(833, 140, 'Promouvoir un bien et gérer les opérations spécifiques (VEFA, viager…)', 2),
(834, 140, 'Monter et suivre les dossiers de gestion locative, y compris en logement social', 3),
(835, 140, 'Assurer le suivi courant des baux et des relations locataires', 4),
(836, 140, 'Participer à la gestion administrative et budgétaire d\'une copropriété', 5),
(837, 140, 'Organiser une assemblée générale et préparer les documents syndicaux', 6),
(838, 141, 'Élaborer et suivre des offres commerciales à l\'international', 1),
(839, 141, 'Traiter les commandes et la relation client / fournisseur à l\'étranger', 2),
(840, 141, 'Coordonner les opérations logistiques et d\'acheminement', 3),
(841, 141, 'Gérer les litiges transport et les formalités de dédouanement', 4),
(842, 141, 'Contribuer au développement des ventes et à l\'optimisation des achats export', 5),
(843, 141, 'Construire et actualiser des tableaux de bord commerciaux en français et en anglais', 6),
(844, 142, 'Accueillir, informer et analyser la demande des personnes en difficulté d\'insertion', 1),
(845, 142, 'Construire un diagnostic partagé et travailler en réseau avec les partenaires', 2),
(846, 142, 'Contractualiser et suivre un parcours d\'insertion professionnelle individualisé', 3),
(847, 142, 'Accompagner l\'élaboration et la mise en œuvre d\'un projet professionnel', 4),
(848, 142, 'Concevoir et animer des ateliers favorisant l\'insertion', 5),
(849, 142, 'Prospecter les employeurs et faciliter l\'embauche et le maintien en poste', 6),
(850, 143, 'Réaliser une veille concurrentielle et garder ses argumentaires produits à jour.', 1),
(851, 143, 'Participer à la mise en rayon, aux flux marchands et au merchandising du linéaire ou du showroom.', 2),
(852, 143, 'Lire et commenter ses indicateurs commerciaux pour ajuster posture et résultats.', 3),
(853, 143, 'Représenter l’enseigne avec professionnalisme en magasin comme sur les canaux connectés utilisés dans le poste.', 4),
(854, 143, 'Pilote l’entretien de vente jusqu’à la conclusion et conseille avec méthode adaptée au produit et au client.', 5),
(855, 143, 'Assurer le suivi après-vente, la fidélisation et la satisfaction client dans une logique d’expérience continue.', 6),
(856, 144, 'Maîtriser HTML et une application de création web', 1),
(857, 144, 'Créer et modifier des feuilles de style CSS', 2),
(858, 144, 'Optimiser les pages web (performance et SEO)', 3),
(859, 144, 'Administrer un site WordPress (contenu, thèmes, extensions)', 4),
(860, 144, 'Analyser le trafic et les données de son site', 5),
(861, 144, 'Publier un site internet sur le web', 6),
(862, 145, 'Approvisionner l\'unité marchande et assurer la présentation des produits', 1),
(863, 145, 'Contribuer à la gestion et à l\'optimisation des stocks', 2),
(864, 145, 'Traiter les commandes de produits des clients', 3),
(865, 145, 'Accueillir, renseigner et servir les clients en omnicanal', 4),
(866, 145, 'Contribuer à l\'amélioration de l\'expérience d\'achat', 5),
(867, 145, 'Tenir un poste de caisse et superviser les caisses libre-service', 6),
(868, 146, 'Concevoir et réaliser des compositions graphiques (mise en page, illustration).', 1),
(869, 146, 'Développer des solutions visuelles innovantes et multimédia (packaging, PLV, signalétique, motion design).', 2),
(870, 146, 'Gérer et coordonner des projets de communication visuelle avec clients et partenaires.', 3),
(871, 146, 'Mener une veille créative, artistique et technologique.', 4),
(872, 146, 'Assurer le suivi technique et la qualité des livrables.', 5),
(873, 147, 'Structurer projet de montage court : brief, planning interne mini, choix médias entrants.', 1),
(874, 147, 'Maîtriser workflow station de montage : organisation bins, nomenclatures, sauvegardes.', 2),
(875, 147, 'Produire sujets courts information / pub / fictions très courtes et itérations qualité sous délais donnés.', 3),
(876, 147, 'Étalonnage créatif sobre, compositing 2D/2,5D courant, chaîne son multipiste vers mixage.', 4),
(877, 147, 'Captation terrain sportif utile à l’analyse ; segmentation et annotation logicielle ; montage final orienté staff.', 5),
(878, 147, 'Intégrer layers data ou graphismes animés pour étayer propos visuel.', 6),
(879, 148, 'Assurer une vision globale et un ancrage territorial de la petite structure.', 1),
(880, 148, 'Manager au quotidien une équipe par objectifs tout en gardant une veille environnementale.', 2),
(881, 148, 'Ajuster puis diffuser une offre de biens ou de services conforme à la stratégie et au marché.', 3),
(882, 148, 'Orchestrer une production ou des prestations en respectant budgets et délais réalistes.', 4),
(883, 148, 'Lecture du bilan économique et social et du compte de résultat ; élaboration d’un rapport d’activité clair.', 5),
(884, 148, 'Préparation du dossier professionnel et mise en valeur des compétences devant jury de certification nationale.', 6),
(885, 149, 'Contrôler la qualité et la légalité des données de paie avant production des bulletins et des déclarations.', 1),
(886, 149, 'Manipuler avec rigueur un logiciel de paie ou un ERP social et les outils bureautiques associés.', 2),
(887, 149, 'Appliquer le droit du travail et la législation sociale courante, avec une veille sur les évolutions.', 3),
(888, 149, 'Assurer la confidentialité, l’organisation et la traçabilité des dossiers salariés liés à la paie.', 4),
(889, 149, 'Communiquer avec clarté auprès des salarié·es, des managers et des organismes externes (URSSAF, caisses, etc.).', 5),
(890, 149, 'Produire des synthèses ou indicateurs utiles au service RH pour le pilotage social.', 6),
(891, 150, 'Maîtriser les outils bureautiques et les faire évoluer pour garantir conformité et sécurité des informations, ainsi que la gestion rigoureuse des écrits médicaux et administratifs.', 1),
(892, 150, 'Organiser les priorités : gestion administrative, plannings et dossiers médicaux, dans le respect du secret médical.', 2),
(893, 150, 'Faire preuve de précision et de vigilance dans la mise à jour des dossiers administratifs et médicaux.', 3),
(894, 150, 'Communiquer efficacement avec les patient·es et les équipes médicales.', 4),
(895, 150, 'Piloter plusieurs tâches et situations variées avec professionnalisme pour un fonctionnement fluide et structuré du service.', 5),
(896, 150, 'Appliquer en permanence les règles de confidentialité et de secret professionnel propres au secteur santé.', 6),
(897, 151, 'Organiser et sécuriser l’accueil physique et téléphonique dans des situations simples ou complexes.', 1),
(898, 151, 'Circuler l’information entre services internes et partenaires externes de façon traçable.', 2),
(899, 151, 'Réaliser les tâches administratives courantes et tenir les dossiers à jour.', 3),
(900, 151, 'Qualifier et traiter les réclamations courantes selon les procédures de la structure.', 4),
(901, 151, 'Construire et présenter son dossier professionnel pour le jury dans les formats attendus.', 5),
(902, 151, 'Mobiliser les techniques de recherche d’emploi et de stage pour sécuriser l’insertion.', 6),
(903, 152, 'Analyser l’environnement concurrentiel et réglementaire pour éclairer la stratégie de développement.', 1),
(904, 152, 'Formaliser des axes de développement durable et les présenter à la direction.', 2),
(905, 152, 'Construire et décliner des plans marketing omnicanal alignés sur les objectifs.', 3),
(906, 152, 'Piloter budgétalement et opérationnellement un projet de développement avec parties prenantes.', 4),
(907, 152, 'Manager une équipe en présentiel ou à distance dans des contextes diversifiés.', 5),
(908, 152, 'Suivre la performance à partir d’indicateurs et ajuster les plans d’actions.', 6),
(909, 153, 'Expliquer les principes et enjeux culturels du DevOps', 1),
(910, 153, 'Lire une organisation et ses flux de valeur côté delivery', 2),
(911, 153, 'Positionner Agile, Scrum et Lean dans une démarche outillée', 3),
(912, 153, 'Identifier des actions d’automatisation de la chaîne de livraison', 4),
(913, 153, 'Choisir des pistes de mesure pour piloter la performance IT', 5),
(914, 153, 'Entrer dans la préparation à l’examen DASA DevOps Fundamentals', 6),
(915, 154, 'Expliquer l’évolution du mouvement DevOps et ses fondations', 1),
(916, 154, 'Profiter des ateliers pour tester des modes de collaboration', 2),
(917, 154, 'Esquisser une chaîne de déploiement adaptée à votre SI', 3),
(918, 154, 'Assembler tests, livraison et déploiement dans une vision cohérente', 4),
(919, 154, 'Utiliser des métriques pour décider et ajuster', 5),
(920, 154, 'Sortir avec un backlog DevOps et une vision tableau de bord', 6),
(921, 155, 'Poser les bases d’une réponse structurée aux incidents SI', 1),
(922, 155, 'Relier ISO/IEC 27035 aux autres documents ISO/IEC 27000', 2),
(923, 155, 'Enchaîner détection, analyse, traitement et revue post-incident', 3),
(924, 155, 'Rédiger et faire vivre un plan de réponse coordonnée', 4),
(925, 155, 'Organiser la communication avec les parties prenantes', 5),
(926, 155, 'Aborder l’examen PECB ISO/IEC 27035 Foundation avec des repères clairs', 6),
(927, 156, 'Identifier les concepts des SGBDR et les fondements relationnels du SQL', 1),
(928, 156, 'Naviguer dans un environnement SQL et produire des scripts lisibles', 2),
(929, 156, 'Écrire des requêtes de lecture et des ordres de mise à jour fiables', 3),
(930, 156, 'Combiner tables par jointures et agrégations adaptées', 4),
(931, 156, 'Exploiter sous-requêtes, vues et CTE pour structurer les traitements', 5),
(932, 156, 'Utiliser les fonctions de fenêtrage pour des analyses avancées', 6),
(933, 156, 'Consolider les bonnes pratiques avant la certification RS7205', 7),
(934, 157, 'Expliquer le rôle de Docker et des conteneurs dans la chaîne de livraison', 1),
(935, 157, 'Installer et configurer Docker sur les environnements courants', 2),
(936, 157, 'Créer, exécuter et administrer des conteneurs et des images', 3),
(937, 157, 'Rédiger des Dockerfiles et exploiter un registre d\'images', 4),
(938, 157, 'Configurer réseaux et volumes pour la production', 5),
(939, 157, 'Orchestrer des stacks avec Compose et un cluster Swarm', 6),
(940, 157, 'Repérer les risques et appliquer des mesures de sécurité de base', 7),
(941, 157, 'Préparer la certification RS6425', 8),
(942, 158, 'Cartographier une attaque et les comportements adverses usuels', 1),
(943, 158, 'Analyser une architecture pour en déduire les vulnérabilités critiques', 2),
(944, 158, 'Concevoir et faire évoluer une politique de sécurité alignée sur les risques', 3),
(945, 158, 'Exploiter les flux Threat Intelligence et les capacités d\'un SOC', 4),
(946, 158, 'Choisir et combiner des briques d\'architecture défensive adaptées', 5),
(947, 158, 'Relier exigences réglementaires et cadres nationaux aux mesures opérationnelles', 6),
(948, 159, 'Décrypter les principes et le vocabulaire des tests logiciels', 1),
(949, 159, 'Positionner les activités de test selon les cycles et méthodes utilisés en entreprise', 2),
(950, 159, 'Animer ou contribuer aux revues et analyses statiques', 3),
(951, 159, 'Structurer conditions, cas et données de tests (boîte noire, blanche, heuristiques)', 4),
(952, 159, 'Piloter plan, risques, incidents et reporting de campagne', 5),
(953, 159, 'Identifier quand et comment mobiliser un outil de test', 6),
(954, 159, 'Viser la réussite de l’examen ISTQB Fondation', 7),
(955, 160, 'Faire vivre le test dans une équipe Agile (manifeste, feedback continu)', 1),
(956, 160, 'Adapter stratégies, risques et estimation entre mode classique et mode itératif', 2),
(957, 160, 'Contribuer aux ateliers (user stories, critères d’acceptation, rétrospectives)', 3),
(958, 160, 'Sélectionner techniques et outils de test pertinents pour le sprint', 4),
(959, 160, 'Préparer sereinement l’épreuve ISTQB Testeur Agile', 5),
(960, 161, 'Traduire besoins et exigences en scénarios d’acceptation traçables', 1),
(961, 161, 'Structurer critères et données pour sécuriser la recette', 2),
(962, 161, 'Combiner exploration, bêta et rituels collaboratifs type ATDD/BDD', 3),
(963, 161, 'Exploiter BPMN et DMN pour nourrir la conception de tests', 4),
(964, 161, 'Intégrer performance, UX ou sécurité dans la phase d’acceptation', 5),
(965, 161, 'Réussir l’examen ISTQB Tests d’acceptation', 6),
(966, 162, 'Esquisser une stratégie cyber ancrée dans l’analyse de risque', 1),
(967, 162, 'Coordonner durcissement réseau et serveurs selon vos contraintes', 2),
(968, 162, 'Déployer un SMSI ISO 27001/27002 et suivre les plans d’action', 3),
(969, 162, 'Mettre à profit ISO 27005 et EBIOS Risk Manager dans vos arbitrages', 4),
(970, 162, 'Structurer réponse à incident et communication interne', 5),
(971, 162, 'Concevoir et déployer des dispositifs de contrôle, cadres d’assurance et démarches d’audit', 6),
(972, 162, 'Former et sensibiliser les équipes avec une vision mesurable', 7),
(973, 162, 'Capitaliser les acquis dans un dossier et une soutenance de validation', 8),
(974, 163, 'Structurer et produire des pages et sites en HTML5 sémantique', 1),
(975, 163, 'Styliser et agencer des interfaces avec CSS3 (dont Flexbox et techniques avancées)', 2),
(976, 163, 'Concevoir des formulaires et tableaux accessibles et cohérents', 3),
(977, 163, 'Adapter les mises en page au multi-écran (Responsive Web Design, media queries)', 4),
(978, 163, 'Manipulation du DOM et gestion d’événements en JavaScript', 5),
(979, 163, 'Consommer des API REST (XHR, Fetch, JSON) et des WebSockets', 6),
(980, 163, 'Finaliser la préparation à la certification ENI HTML5/CSS3 si vous vous engagez sur l’examen', 7),
(981, 164, 'Configurer Python et PyCharm avec environnements virtuels', 1),
(982, 164, 'Maîtriser la syntaxe de base et les collections Python', 2),
(983, 164, 'Structurer une application en fonctions, modules et packages', 3),
(984, 164, 'Modéliser des domaines métier en POO (classes, héritage, polymorphisme)', 4),
(985, 164, 'Appliquer une gestion d’exceptions propre et des tests unittest', 5),
(986, 164, 'Automatiser avec la bibliothèque standard (OS, regexp, fichiers, dates)', 6),
(987, 164, 'Créer des IHM avec Tkinter', 7),
(988, 164, 'Préparer et passer la certification RS6701 selon le calendrier du certificateur', 8),
(989, 165, 'Définir la culture digitale et en situer les effets macroéconomiques', 1),
(990, 165, 'Repérer les usages et comportements liés aux grands services numériques', 2),
(991, 165, 'Lire les évolutions des métiers et des organisations sous l’angle digital', 3),
(992, 165, 'Utiliser un vocabulaire commun Web, médias sociaux et outils collaboratifs', 4),
(993, 165, 'Cartographier des outils digitaux et leur valeur ajoutée dans un contexte donné', 5),
(994, 165, 'Mobiliser des bases de capacité managériale et d’aisance à l’oral pour partager la vision digitale', 6),
(995, 166, 'Expliquer le rôle du CLR, des assemblies et du déploiement .NET', 1),
(996, 166, 'Produire du code C# structuré (syntaxe, types, exceptions, bonnes pratiques)', 2),
(997, 166, 'Modéliser et implémenter des classes, relations, interfaces et événements en C#', 3),
(998, 166, 'Exploiter les API de base (.NET) : chaînes, collections, LINQ to Objects', 4),
(999, 166, 'Esquisser des applications WPF, web MVC et services à partir d’exemples guidés', 5),
(1000, 166, 'Travailler de façon rigoureuse et consciencieuse sur des TPs encadrés sous Visual Studio', 6),
(1001, 167, 'Formuler les enjeux modularité, réutilisation et évolutivité en conception objet', 1),
(1002, 167, 'Structurer un problème avec classes, instances, messages et héritage', 2),
(1003, 167, 'Produire des diagrammes UML pertinents (classes, séquences) avec un outil', 3),
(1004, 167, 'Appliquer réification, encapsulation et découpage de domaines', 4),
(1005, 167, 'Esquisser une traduction modèle → implémentation et situer .NET vs écosystème Java EE / Jakarta EE', 5),
(1006, 167, 'Qualifier une approche frameworks / composants et reconnaître des situations adaptées aux design patterns', 6),
(1007, 168, 'Positionner le RSSI dans la gouvernance SI et auprès de la direction', 1),
(1008, 168, 'Esquisser ou faire évoluer un SMSI conforme aux attentes ISO/IEC 27001', 2),
(1009, 168, 'Conduire une analyse de risques structurée (EBIOS RM, ISO/IEC 27005)', 3),
(1010, 168, 'Relier exigences réglementaires et mesures de durcissement (dont logique ANSSI)', 4),
(1011, 168, 'Formaliser une stratégie et une feuille de route cybersécurité alignées sur le métier', 5),
(1012, 169, 'Nommer et situer les briques du cloud et de la virtualisation dans un paysage SI', 1),
(1013, 169, 'Comparer offres, modèles de service et de déploiement et technologies associées', 2),
(1014, 169, 'Expliquer la valeur du cloud pour les métiers comme pour les fonctions IT', 3),
(1015, 169, 'Formuler besoins sécurité, risques résiduels et leviers d’atténuation', 4),
(1016, 169, 'Relier cloud et gouvernance du SI pour préparer ou piloter une transition', 5),
(1017, 169, 'Travailler avec rigueur et exigence sur les contenus de préparation à la CTA', 6),
(1018, 170, 'Expliquer les principes de communication selon OSI et TCP/IP sur un LAN', 1),
(1019, 170, 'Mettre en service un petit LAN avec switch Cisco (IOS, CLI, Ethernet)', 2),
(1020, 170, 'Adresser en IPv4, mettre en œuvre le routage statique et des ACL de base', 3),
(1021, 170, 'Déployer VLAN, trunk, routage inter-VLAN et DHCP sur équipement Cisco', 4),
(1022, 170, 'Appliquer les premiers réflexes de durcissement et de supervision des équipements', 5),
(1023, 170, 'Configurer des routes statiques IPv6 et intégrer les bases dans une préparation 200-301', 6),
(1024, 170, 'Travailler avec rigueur et méthode sur les scénarios de lab', 7),
(1025, 171, 'Relier évolution du cloud et virtualisation aux enjeux d’architecture d’entreprise', 1),
(1026, 171, 'Exploiter les modèles IaaS, PaaS, SaaS et XaaS dans une analyse « as a service »', 2),
(1027, 171, 'Analyser l’impact du cloud sur la gestion du service IT et les cycles de vie', 3),
(1028, 171, 'Esquisser l’évaluation d’une architecture cloud et les axes d’une migration', 4),
(1029, 171, 'Structurer spécifications, business case et roadmap pour une solution cloud', 5),
(1030, 171, 'Préparer et passer l’examen PCSA avec rigueur et méthode', 6),
(1031, 172, 'Mettre en place un environnement de tests d’intrusion mobiles adapté au contexte Android', 1),
(1032, 172, 'Réaliser une analyse statique d’applications Android', 2),
(1033, 172, 'Analyser les flux et comportements réseau des applications mobiles', 3),
(1034, 172, 'Conduire une analyse dynamique ciblée sur les scénarios d’audit', 4),
(1035, 172, 'Repérer et qualifier des vulnérabilités courantes sur applications Android', 5),
(1036, 173, 'Expliquer le vocabulaire, les avantages et les principes clés DevSecOps', 1),
(1037, 173, 'Comparer sécurité « native » DevOps et autres approches de sécurité', 2),
(1038, 173, 'Esquisser des stratégies de sécurité alignées business et relire les décisions avec des apports data', 3),
(1039, 173, 'Structurer le jeu d’équipes rouges / bleues dans une organisation', 4),
(1040, 173, 'Brancher contrôles et tests de sécurité sur une chaîne CI/CD', 5),
(1041, 173, 'Articuler rôles DevSecOps, culture et organisation DevOps', 6),
(1042, 173, 'Appliquer rigueur et méthode dans les ateliers et la préparation à la certification DSOE', 7),
(1043, 174, 'Lire et écrire du C++ idiomatique en distinguant les apports par rapport au C', 1),
(1044, 174, 'Structurer une conception par classes, hiérarchies et interfaces avec polymorphisme', 2),
(1045, 174, 'Exploiter un environnement de développement C++ courant sur des livrables TP', 3),
(1046, 174, 'Mettre en œuvre les constructions C++11 abordées (auto, constructeurs, parcours, etc.)', 4),
(1047, 174, 'Utiliser exceptions, surcharge d’opérateurs et templates dans des cas représentatifs', 5),
(1048, 174, 'Navigager dans les I/O par streams et comprendre les bases de la STL', 6),
(1049, 174, 'Travailler avec rigueur et exigence sur l’étude de cas tout au long du parcours', 7),
(1050, 175, 'Cadrer des investigations criminalistiques selon des standards industriels et des politiques à jour', 1),
(1051, 175, 'Conduire acquisitions et analyses sur disques, environnements Windows, Linux et macOS', 2),
(1052, 175, 'Structurer chaîne de preuve, protocoles de laboratoire et restitution aux parties prenantes', 3),
(1053, 175, 'Exploiter les volets eDiscovery, ESI et criminalistique mobile dans une démarche globale', 4),
(1054, 175, 'Documenter et gérer un incident avec des livrables adaptés à la certification C-DFE', 5),
(1055, 176, 'Structurer gouvernance sécurité, risques et alignement avec les objectifs métier', 1),
(1056, 176, 'Protéger et classer les actifs sur l’ensemble du cycle de vie', 2),
(1057, 176, 'Concevoir et évaluer des architectures, réseaux et contrôles au prisme CIA', 3),
(1058, 176, 'Mettre en œuvre IAM, évaluation, tests et opérations de sécurité de façon cohérente', 4),
(1059, 176, 'Intégrer la sécurité dans le développement logiciel et préparer l’examen CISSP avec méthode', 5),
(1060, 177, 'Maîtrise de la syntaxe Python', 1),
(1061, 177, 'Automatisation de tâches', 2),
(1062, 177, 'Analyse de données de base', 3),
(1063, 178, 'Maîtrise du HTML5 et CSS3', 1),
(1064, 178, 'Flexbox et CSS Grid', 2),
(1065, 178, 'Design adaptatif (Mobile-First)', 3),
(1066, 179, 'Développement backend PHP', 1),
(1067, 179, 'Gestion des bases de données MySQL', 2),
(1068, 179, 'Création de sites dynamiques', 3),
(1069, 180, 'Fondamentaux de la sécurité', 1),
(1070, 180, 'Protection des données', 2),
(1071, 180, 'Hygiène informatique', 3),
(1072, 181, 'Gouvernance de la sécurité', 1),
(1073, 181, 'Gestion des risques (EBIOS)', 2),
(1074, 181, 'Conformité RGPD', 3),
(1075, 182, 'Configuration de switchs et routeurs', 1),
(1076, 182, 'Protocoles de routage (OSPF, BGP)', 2),
(1077, 182, 'Sécurisation des réseaux Cisco', 3),
(1078, 183, 'Expliquer les concepts fondamentaux de l’intelligence artificielle générative', 1),
(1079, 183, 'Identifier les usages métiers de Microsoft 365 Copilot', 2),
(1080, 183, 'Utiliser Copilot Chat pour automatiser des tâches professionnelles', 3),
(1081, 183, 'Rédiger et améliorer du contenu à l’aide de Copilot', 4),
(1082, 183, 'Analyser et visualiser des données avec Copilot dans Excel', 5),
(1083, 183, 'Optimiser la collaboration et les réunions avec Copilot dans Outlook et Teams', 6),
(1084, 183, 'Envisager l’intégration de Copilot dans les processus métiers', 7),
(1085, 184, 'Comprendre les fondamentaux de l’IA et ses usages dans un contexte IT', 1),
(1086, 184, 'Identifier et prioriser des cas d’usage de l’IA générative au travail', 2),
(1087, 184, 'Produire et ajuster des scripts et de la documentation technique assistés par IA', 3),
(1088, 184, 'Interagir avec un LLM pour le diagnostic et la résolution de problèmes', 4),
(1089, 184, 'Automatiser des tâches administratives ou documentaires de façon raisonnée', 5),
(1090, 184, 'Expérimenter des prompts adaptés aux besoins techniques', 6),
(1091, 184, 'Intégrer les enjeux légaux, éthiques et organisationnels de l’IA', 7),
(1092, 184, 'Contrôler et valider les sorties produites par l’IA', 8),
(1093, 185, 'Exploiter le fonctionnement et l’architecture des principaux outils d’IA générative', 1),
(1094, 185, 'Analyser des cas d’usage sectoriels pertinents pour l’entreprise', 2),
(1095, 185, 'Concevoir des prompts avancés pour la création et l’analyse de contenus', 3),
(1096, 185, 'Mettre en œuvre LLM et transformers pour automatiser des flux de travail', 4),
(1097, 185, 'Produire des synthèses multi-sources avec l’IA', 5),
(1098, 185, 'Concevoir et raccorder un chatbot à des API de modèles génératifs', 6),
(1099, 185, 'Comparer et utiliser des solutions open source en complément des offres propriétaires', 7),
(1100, 185, 'Mettre en place un prototype de chatbot fonctionnel avec des composants ouverts ou hors ligne', 8),
(1101, 186, 'Expliquer le fonctionnement des modèles génératifs et de l’écosystème OpenAI', 1),
(1102, 186, 'Intégrer l’API OpenAI et ChatGPT dans un flux de développement réaliste', 2),
(1103, 186, 'S’appuyer sur l’IA pour produire, refactoriser et fiabiliser du code', 3),
(1104, 186, 'Identifier et traiter des problématiques de sécurité avec l’aide de l’IA', 4),
(1105, 186, 'Dimensionner les risques, limites et enjeux éthiques des usages en entreprise', 5),
(1106, 187, 'Maîtriser le cycle requête/réponse de l’API ChatGPT et ses limites', 1),
(1107, 187, 'Configurer un environnement sécurisé pour les clés et jetons', 2),
(1108, 187, 'Piloter les paramètres et le contexte pour des réponses adaptées', 3),
(1109, 187, 'Concevoir des flux multi-tours fiables et économes en appels', 4),
(1110, 187, 'Intégrer l’API dans des applications web et mobiles selon les bonnes pratiques', 5),
(1111, 187, 'Préparer un déploiement et suivre performances et disponibilité', 6),
(1112, 187, 'Appliquer une démarche éthique et conforme aux politiques de confidentialité', 7),
(1113, 187, 'Documenter et présenter une intégration réaliste', 8),
(1114, 188, 'Intégrer l’IA générative dans les workflows de communication', 1),
(1115, 188, 'Concevoir des prompts structurés pour des livrables exploitables', 2),
(1116, 188, 'Esquisser et ajuster une stratégie webmarketing assistée par l’IA', 3),
(1117, 188, 'Produire et fiabiliser des contenus éditoriaux avec l’IA', 4),
(1118, 188, 'Appliquer des bonnes pratiques SEO assistées par l’IA', 5),
(1119, 188, 'Préparer des supports relations presse et RP avec l’IA', 6),
(1120, 188, 'Planifier une présence sociale et une veille e-réputation avec l’IA', 7),
(1121, 188, 'Créer des annonces et visuels marketing avec des outils IA', 8),
(1122, 189, 'Cadrer un cas d’usage résoluble par machine learning et choisir les bons outils', 1),
(1123, 189, 'Préparer, nettoyer et transformer des jeux de données', 2),
(1124, 189, 'Mettre en œuvre des modèles supervisés et non supervisés', 3),
(1125, 189, 'Mesurer les performances et itérer (réglages, régularisation)', 4),
(1126, 189, 'Identifier les limites techniques et pistes d’amélioration', 5),
(1127, 189, 'Produire des livrables interprétables pour le métier', 6),
(1128, 189, 'Appliquer le ML à l’image, au texte et à la recommandation', 7),
(1129, 190, 'Relier les usages d’IA à des besoins métiers concrets', 1),
(1130, 190, 'Décoder le vocabulaire IA / ML / deep learning et les annonces du marché', 2),
(1131, 190, 'Repérer les acteurs clés et les orientations de la recherche', 3),
(1132, 190, 'Anticiper impacts et conditions d’une intégration IA responsable', 4),
(1133, 191, 'Préparer des corpus textuels pour l’apprentissage profond', 1),
(1134, 191, 'Implémenter et ajuster des architectures NLP', 2),
(1135, 191, 'Diagnostiquer sur-apprentissage, sous-apprentissage et biais', 3),
(1136, 191, 'Appliquer la régularisation et des stratégies d’optimisation', 4),
(1137, 191, 'Déployer des chaînes traduction, résumé, génération et classification', 5),
(1138, 191, 'Piloter des expériences par métriques et courbes d’apprentissage', 6),
(1139, 192, 'Comprendre le fonctionnement interne d\'Android', 1),
(1140, 192, 'Mettre en œuvre le système de fabrication d\'Android', 2),
(1141, 192, 'Adapter Android à un matériel spécifique', 3),
(1142, 192, 'Rajouter des périphériques dans un Android existant', 4),
(1143, 192, 'Configurer et compiler un noyau Android', 5),
(1144, 192, 'Utiliser ADB pour le débogage à distance', 6),
(1145, 192, 'Personnaliser le rootfs et intégrer des bibliothèques natives', 7),
(1146, 192, 'Packager et intégrer des applications Android (.apk)', 8),
(1147, 193, 'Réaliser une collecte d’information sur une cible web', 1),
(1148, 193, 'Identifier et exploiter des vulnérabilités Cross-Site Scripting (XSS)', 2),
(1149, 193, 'Maîtriser les techniques d\'injection et de contournement d\'autorisation', 3),
(1150, 193, 'Auditer la sécurité des tokens d\'authentification JWT', 4),
(1151, 193, 'Détecter et prévenir les failles CSRF et les téléchargements non sécurisés', 5),
(1152, 194, 'Maîtriser le développement d\'exploits Windows en mode utilisateur sur architecture x86', 1),
(1153, 194, 'Contourner les mécanismes de sécurité modernes tels que DEP et ASLR', 2),
(1154, 194, 'Développer des chaînes ROP personnalisées', 3),
(1155, 194, 'Écrire du shellcode sur mesure', 4),
(1156, 194, 'Utiliser WinDbg et IDA Pro pour le débogage et le reverse engineering', 5),
(1157, 194, 'Exploiter les débordements de tampon et les SEH Overflows', 6),
(1158, 194, 'Mettre en œuvre des techniques egghunter', 7),
(1159, 194, 'Identifier des vulnérabilités via le reverse engineering', 8),
(1160, 194, 'Préparer et réussir l\'examen de certification OSED', 9),
(1161, 195, 'Mettre en œuvre et gérer efficacement un programme de sécurité du cloud', 1),
(1162, 195, 'Interpréter les normes ISO/IEC 27017 et ISO/IEC 27018 dans le contexte d\'une entreprise', 2),
(1163, 195, 'Comprendre la corrélation avec d\'autres cadres réglementaires', 3),
(1164, 195, 'Planifier, surveiller et maintenir la sécurité du cloud', 4),
(1165, 195, 'Gérer les risques liés au cloud computing', 5),
(1166, 195, 'Assurer la gestion des incidents de sécurité du cloud et l\'amélioration continue', 6),
(1167, 195, 'Conseiller l\'organisme en s\'appuyant sur les bonnes pratiques', 7),
(1168, 196, 'Comprendre l\'apport du Big Data pour les directions métiers', 1),
(1169, 196, 'Traiter et analyser des données structurées et non structurées', 2),
(1170, 196, 'Appliquer des méthodes de datamining (classification, estimation, prévision)', 3),
(1171, 196, 'Identifier les cas d\'usage clés (e-réputation, segmentation, ROI)', 4),
(1172, 196, 'Acquérir les méthodes de cadrage et de mise en place de la stratégie Big Data', 5),
(1173, 196, 'Piloter la stratégie et mettre en place une organisation adaptée', 6),
(1174, 197, 'Mettre en œuvre les principes de la Programmation Orientée Objet', 1),
(1175, 197, 'Maîtriser la syntaxe du langage Java', 2),
(1176, 197, 'Définir, instancier et concevoir des classes et des hiérarchies', 3),
(1177, 197, 'Manipuler le polymorphisme, l\'héritage et la généricité', 4),
(1178, 197, 'Gérer les exceptions et programmer des entrées/sorties', 5),
(1179, 197, 'Créer des interfaces graphiques (IHM)', 6),
(1180, 197, 'Maîtriser les principales librairies standards Java', 7),
(1181, 197, 'Maîtriser un environnement de développement intégré (IDE) pour Java', 8),
(1182, 198, 'Capacité managériale', 1),
(1183, 198, 'Capacité à déléguer', 2),
(1184, 198, 'Diversifier ses styles de leadership', 3),
(1185, 198, 'Adapter son style de management à chaque collaborateur et situation', 4),
(1186, 198, 'Accompagner le développement de la motivation et des compétences', 5),
(1187, 198, 'Mener des entretiens de re-motivation et traiter les situations difficiles', 6),
(1188, 199, 'Définir et caractériser les enjeux sociaux et environnementaux de l\'entreprise', 1),
(1189, 199, 'Maîtriser les outils et méthodes pour la mise en œuvre opérationnelle de la RSE', 2),
(1190, 199, 'Proposer de nouvelles approches d\'analyse pour les problèmes complexes et multi-acteurs', 3),
(1191, 199, 'Comprendre les enjeux du développement durable (social, économique, environnemental, éthique)', 4),
(1192, 199, 'Développer une capacité d\'analyse et de synthèse ainsi qu\'une aisance à communiquer', 5),
(1193, 199, 'S\'adapter, gérer les conflits, négocier et exercer sa capacité managériale', 6),
(1194, 200, 'Acquérir une méthodologie complète de conduite de projet', 1),
(1195, 200, 'Rédiger le cadrage (cahier des charges, note de cadrage)', 2),
(1196, 200, 'Planifier un projet (délais, marges, tâches critiques)', 3),
(1197, 200, 'Sécuriser financièrement et maîtriser les risques d\'un projet', 4),
(1198, 200, 'Construire, animer et fédérer une équipe projet', 5),
(1199, 200, 'Définir des indicateurs de performance et un tableau de bord', 6),
(1200, 200, 'Aisance dans la gestion des projets et bonne planification', 7),
(1201, 200, 'Exercer une capacité managériale et un management transversal', 8),
(1202, 201, 'Adapter son mode de management dans un environnement complexe', 1),
(1203, 201, 'Développer les compétences d’agilité pour soi et son équipe', 2),
(1204, 201, 'Adopter les postures du manager Agile (mentor, pédagogue)', 3),
(1205, 201, 'Utiliser les méthodes et outils pour penser et agir avec agilité', 4),
(1206, 201, 'Mobiliser les 4 leviers du travail collaboratif (confiance, cohésion, convivialité, créativité)', 5),
(1207, 201, 'Accompagner les équipes dans le changement', 6),
(1208, 201, 'Capacité managériale et sens de la créativité', 7),
(1209, 202, 'Affiner ses compétences en leadership', 1),
(1210, 202, 'Renforcer la collaboration et l\'engagement au sein de son équipe', 2),
(1211, 202, 'Favoriser l\'apprentissage et la motivation de ses collaborateurs', 3),
(1212, 202, 'Exercer une capacité managériale adaptée', 4),
(1213, 202, 'Développer sa capacité de planification', 5),
(1214, 203, 'Comprendre les concepts de base de Docker', 1),
(1215, 203, 'Utiliser les outils Docker Compose pour définir et gérer des applications multi-conteneurs', 2),
(1216, 203, 'Déployer et gérer des applications à l\'aide de Docker Swarm', 3),
(1217, 203, 'Utiliser les outils d\'intégration continue avec Docker pour automatiser les déploiements', 4),
(1218, 203, 'Créer des images via Dockerfile et gérer l\'Infrastructure As Code', 5),
(1219, 204, 'Installer une infrastructure Windows Server et intégrer les services de virtualisation', 1),
(1220, 204, 'Implémenter la haute disponibilité (HA)', 2),
(1221, 204, 'Installer et comprendre l\'intérêt et les limites de la conteneurisation', 3),
(1222, 204, 'Installer et configurer les services de bureau à distance', 4),
(1223, 204, 'Implémenter les services de mises à jour (WSUS, WDS)', 5),
(1224, 205, 'Naviguer dans l\'interface Excel et gérer les classeurs', 1),
(1225, 205, 'Organiser feuilles et lier des données entre tableaux', 2),
(1226, 205, 'Créer des tableaux avec formules et mise en forme professionnelle', 3),
(1227, 205, 'Appliquer une mise en forme conditionnelle et préparer des impressions', 4),
(1228, 205, 'Se préparer efficacement à l\'épreuve TOSA', 5),
(1229, 205, 'Mesurer et valoriser son niveau de compétences bureautiques', 6),
(1230, 206, 'Structurer une présentation avec une méthode claire (objectifs, plan, délais)', 1),
(1231, 206, 'Personnaliser thèmes, masques et ligne graphique', 2),
(1232, 206, 'Organiser les diapositives en mode Trieuse', 3),
(1233, 206, 'Intégrer visuels, tableaux, graphiques et objets mis en page', 4),
(1234, 206, 'Animer et présenter un diaporama en mode présentateur', 5),
(1235, 206, 'Se préparer et réussir la certification TOSA PowerPoint', 6),
(1236, 207, 'Personnaliser l\'interface et les outils Word (ruban, raccourcis, correction)', 1),
(1237, 207, 'Créer et appliquer styles, thèmes et modèles de documents', 2),
(1238, 207, 'Structurer un document avec plan, titres numérotés et table des matières', 3),
(1239, 207, 'Intégrer images, tableaux, graphiques et SmartArt', 4),
(1240, 207, 'Mettre en page avec tableaux dessinés et colonnes', 5),
(1241, 207, 'Collaborer sur un document partagé et réussir la certification TOSA', 6);

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_consents_log`
--

CREATE TABLE `gdpr_consents_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `consent_type` varchar(80) NOT NULL,
  `granted` tinyint(1) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `gdpr_consents_log`
--

INSERT INTO `gdpr_consents_log` (`id`, `site_id`, `user_email`, `consent_type`, `granted`, `ip_address`, `created_at`) VALUES
(1, 5, 'yanislaldjipro@gmail.com', 'trainer_application', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 17:49:00'),
(2, 5, 'sinay.l777@gmail.com', 'client_registration', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 21:52:25'),
(8, 5, 'yanislaldjipro@gmail.com', 'trainer_application', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:50:38'),
(9, 5, 'yanislaldjipro@gmail.com', 'account_erasure', 0, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:53:26'),
(10, 5, 'sinay.l777@gmail.com', 'account_erasure', 0, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-09 22:57:49'),
(11, 5, 'yanislaldjipro@gmail.com', 'trainer_application', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:44:18'),
(12, 5, 'sinay.l777@gmail.com', 'client_registration', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:46:44'),
(13, 6, 'sinay.l777@gmail.com', 'coach_registration', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:48:41'),
(14, 6, 'yanislaldjipro@gmail.com', 'client_registration', 1, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 01:52:49'),
(15, 6, 'sinay.l777@gmail.com', 'account_erasure', 0, '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-10 02:06:27'),
(16, 6, 'yanislaldjipro@gmail.com', 'coach_registration', 1, '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 16:55:36'),
(17, 6, 'oui@gmail.com', 'client_registration', 1, '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 16:57:08');

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_deletion_requests`
--

CREATE TABLE `gdpr_deletion_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `status` enum('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` datetime NOT NULL DEFAULT current_timestamp(),
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketing_email_logs`
--

CREATE TABLE `marketing_email_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `template_used` varchar(120) DEFAULT NULL,
  `status` enum('queued','sent','failed') NOT NULL DEFAULT 'queued',
  `error_message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `media_library`
--

CREATE TABLE `media_library` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `path` varchar(500) NOT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `size_bytes` int(10) UNSIGNED DEFAULT NULL,
  `uploaded_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `media_library`
--

INSERT INTO `media_library` (`id`, `site_id`, `filename`, `path`, `mime_type`, `size_bytes`, `uploaded_by`, `created_at`) VALUES
(1, 5, '2eb4d5ad-f489-4ea7-80e9-444bdadded4d.png', '/api/uploads/blog/2eb4d5ad-f489-4ea7-80e9-444bdadded4d.png', 'image/png', 77558, 1, '2026-07-09 23:00:12'),
(2, 6, '850892e4-bb72-4531-ae70-1a9999a1c19c.png', '/api/uploads/blog/850892e4-bb72-4531-ae70-1a9999a1c19c.png', 'image/png', 57312, 1, '2026-07-10 01:59:52'),
(3, 4, 'c0e68f4b-c013-40b1-80ca-ba04902c81a0.png', '/api/uploads/blog/c0e68f4b-c013-40b1-80ca-ba04902c81a0.png', 'image/png', 132530, 1, '2026-07-10 02:15:17'),
(4, 3, 'f53831f5-69a2-4979-8854-ebcbd00487ba.png', '/api/uploads/medical/f53831f5-69a2-4979-8854-ebcbd00487ba.png', 'image/png', 50624, 1, '2026-07-10 15:23:36'),
(5, 3, '431ab378-2378-4d04-b4e4-eb256e9594af.png', '/api/uploads/medical/431ab378-2378-4d04-b4e4-eb256e9594af.png', 'image/png', 50624, 1, '2026-07-10 15:43:54'),
(6, 2, 'dc011904-c356-45dc-a356-14fd386a1e4a.png', '/api/uploads/blog/dc011904-c356-45dc-a356-14fd386a1e4a.png', 'image/png', 6778, 1, '2026-07-23 12:51:32'),
(7, 1, '34c7235f-6ee4-454d-abc5-295d8fce5e7a.png', '/api/uploads/alt/34c7235f-6ee4-454d-abc5-295d8fce5e7a.png', 'image/png', 51384, 1, '2026-07-24 03:35:26'),
(8, 1, '2279a370-f178-458d-815a-c4b051343af6.png', '/api/uploads/alt/2279a370-f178-458d-815a-c4b051343af6.png', 'image/png', 1702833, 1, '2026-07-24 03:35:39'),
(9, 1, '39e59adf-7fb5-415d-902b-d5efe628d02a.png', '/api/uploads/alt/39e59adf-7fb5-415d-902b-d5efe628d02a.png', 'image/png', 1702833, 1, '2026-07-24 03:35:47'),
(10, 1, 'ec8e7a4b-4733-401a-9fdc-b97ccf46ecea.png', '/api/uploads/blog/ec8e7a4b-4733-401a-9fdc-b97ccf46ecea.png', 'image/png', 1702833, 1, '2026-07-24 03:38:34'),
(11, 5, '35f2a563-457c-4d3b-9f0e-6ec08427f1c9.jpg', '/api/uploads/blog/35f2a563-457c-4d3b-9f0e-6ec08427f1c9.jpg', 'image/jpeg', 36137, 1, '2026-07-27 14:24:43'),
(12, 6, 'f03fd86a-d712-4e21-ab5b-23f2b0de4eaa.jpg', '/api/uploads/blog/f03fd86a-d712-4e21-ab5b-23f2b0de4eaa.jpg', 'image/jpeg', 36137, 1, '2026-07-27 16:23:49');

-- --------------------------------------------------------

--
-- Structure de la table `metiers`
--

CREATE TABLE `metiers` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `code_rome` varchar(20) DEFAULT NULL,
  `slug` varchar(150) NOT NULL,
  `libelle` varchar(200) NOT NULL,
  `titre` varchar(200) DEFAULT NULL,
  `description_courte` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `presentation` text DEFAULT NULL,
  `journee_type` text DEFAULT NULL,
  `perspectives` text DEFAULT NULL,
  `niveau_etudes` varchar(100) DEFAULT NULL,
  `salaire_fourchette` varchar(100) DEFAULT NULL,
  `salaire_debutant` varchar(100) DEFAULT NULL,
  `salaire_confirme` varchar(100) DEFAULT NULL,
  `salaire_liberal` varchar(100) DEFAULT NULL,
  `salaire_details` text DEFAULT NULL,
  `famille_metier` varchar(150) DEFAULT NULL,
  `secteur_id` int(10) UNSIGNED DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `metiers`
--

INSERT INTO `metiers` (`id`, `site_id`, `code_rome`, `slug`, `libelle`, `titre`, `description_courte`, `description`, `image_url`, `presentation`, `journee_type`, `perspectives`, `niveau_etudes`, `salaire_fourchette`, `salaire_debutant`, `salaire_confirme`, `salaire_liberal`, `salaire_details`, `famille_metier`, `secteur_id`, `actif`, `created_at`, `updated_at`) VALUES
(1, 3, NULL, 'erezr', 'erezr', 'fsfzeffe', 'zefzeff', 'ezfzefze', '/api/uploads/medical/431ab378-2378-4d04-b4e4-eb256e9594af.png', 'reerezrg', 'zefzefz', 'ezfzfez', '5', '5210', '64', '545', '98', 'efzef', NULL, 1, 1, '2026-07-10 15:44:18', '2026-07-10 15:44:18');

-- --------------------------------------------------------

--
-- Structure de la table `metier_competences`
--

CREATE TABLE `metier_competences` (
  `metier_id` int(10) UNSIGNED NOT NULL,
  `competence_id` int(10) UNSIGNED NOT NULL,
  `importance` enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_campaigns`
--

CREATE TABLE `newsletter_campaigns` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `list_id` int(10) UNSIGNED DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `preview_text` varchar(255) DEFAULT NULL,
  `content_html` longtext DEFAULT NULL,
  `content_text` longtext DEFAULT NULL,
  `status` enum('draft','scheduled','sending','sent','cancelled') NOT NULL DEFAULT 'draft',
  `scheduled_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_events`
--

CREATE TABLE `newsletter_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `campaign_id` bigint(20) UNSIGNED NOT NULL,
  `subscriber_id` int(10) UNSIGNED DEFAULT NULL,
  `event_type` enum('queued','sent','open','click','bounce','unsubscribe','error') NOT NULL,
  `metadata_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata_json`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_lists`
--

CREATE TABLE `newsletter_lists` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_subscribers`
--

CREATE TABLE `newsletter_subscribers` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `status` enum('pending','active','unsubscribed','bounced','complained') NOT NULL DEFAULT 'pending',
  `confirmed_at` datetime DEFAULT NULL,
  `rgpd_consent_at` datetime NOT NULL,
  `rgpd_consent_ip` varchar(45) DEFAULT NULL,
  `source` enum('form','import','api','candidat','checkout') NOT NULL DEFAULT 'form',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_subscriptions`
--

CREATE TABLE `newsletter_subscriptions` (
  `subscriber_id` int(10) UNSIGNED NOT NULL,
  `list_id` int(10) UNSIGNED NOT NULL,
  `subscribed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `unsubscribed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `offres_emploi`
--

CREATE TABLE `offres_emploi` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `department` enum('collaborateur','formateur') DEFAULT NULL COMMENT 'Alt RH carrières ; NULL = offre classique',
  `entreprise_id` int(10) UNSIGNED NOT NULL,
  `recruteur_id` int(10) UNSIGNED DEFAULT NULL,
  `metier_id` int(10) UNSIGNED DEFAULT NULL,
  `reference` varchar(50) DEFAULT NULL,
  `slug` varchar(250) NOT NULL,
  `titre` varchar(300) NOT NULL,
  `description` longtext NOT NULL,
  `profil_recherche` text DEFAULT NULL,
  `avantages` text DEFAULT NULL,
  `competences_text` text DEFAULT NULL,
  `type_contrat` enum('cdi','cdd','interim','alternance','freelance','stage') NOT NULL,
  `experience_min` enum('debutant','1-2','3-5','5-10','10+') DEFAULT NULL,
  `salaire_min` int(10) UNSIGNED DEFAULT NULL,
  `salaire_max` int(10) UNSIGNED DEFAULT NULL,
  `salaire_afficher` tinyint(1) NOT NULL DEFAULT 1,
  `teletravail` enum('non','partiel','total') NOT NULL DEFAULT 'non',
  `temps_travail` enum('temps_plein','temps_partiel','variable') NOT NULL DEFAULT 'temps_plein',
  `ville` varchar(100) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `departement` varchar(5) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `is_urgent` tinyint(1) NOT NULL DEFAULT 0,
  `statut` enum('brouillon','publiee','pourvue','expiree','archivee') NOT NULL DEFAULT 'brouillon',
  `date_publication` datetime DEFAULT NULL,
  `date_expiration` datetime DEFAULT NULL,
  `vues` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT 'Ordre carrières Alt Formation',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `offres_emploi`
--

INSERT INTO `offres_emploi` (`id`, `site_id`, `department`, `entreprise_id`, `recruteur_id`, `metier_id`, `reference`, `slug`, `titre`, `description`, `profil_recherche`, `avantages`, `competences_text`, `type_contrat`, `experience_min`, `salaire_min`, `salaire_max`, `salaire_afficher`, `teletravail`, `temps_travail`, `ville`, `code_postal`, `departement`, `region`, `is_featured`, `is_urgent`, `statut`, `date_publication`, `date_expiration`, `vues`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 3, NULL, 1, NULL, NULL, 'dsfzz', 'yanis-43732', 'yanis', 'zefzfz', 'efzfzef', 'zfezfez', 'ezfzfze', 'cdi', 'debutant', 2800, NULL, 1, 'non', 'temps_plein', 'paris', '77410', '77', 'idf', 0, 1, 'archivee', '2026-07-10 02:35:47', '2026-07-17 23:59:59', 0, 0, '2026-07-10 02:35:32', '2026-07-20 19:42:34'),
(2, 3, NULL, 2, 2, 1, 'fefef', 'dzdefzef-75679', 'dzdefzef', 'efzfefdz', 'jeune,fort', 'chèque vacance, ticket resto', 'exigence, intelligence, élégance', 'cdi', '3-5', 2500, NULL, 1, 'non', 'temps_plein', 'némours', '77777', '74', NULL, 0, 1, 'publiee', '2026-07-20 21:28:36', '2026-07-29 23:59:59', 0, 0, '2026-07-20 21:27:59', '2026-07-20 21:28:36'),
(3, 2, NULL, 3, 3, NULL, NULL, 'scdscsc-61860', 'scdscsc', 'scscdscd', 'sdcdscsc', NULL, 'oui, non', 'cdi', '3-5', 45000, NULL, 1, 'partiel', 'temps_partiel', 'dcsdcsc', NULL, '7441', NULL, 0, 0, 'publiee', '2026-07-23 01:11:20', '2026-07-24 23:59:59', 0, 0, '2026-07-23 01:11:00', '2026-07-23 01:11:20');

-- --------------------------------------------------------

--
-- Structure de la table `offres_favorites`
--

CREATE TABLE `offres_favorites` (
  `candidat_id` int(10) UNSIGNED NOT NULL,
  `offre_id` int(10) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `offre_competences`
--

CREATE TABLE `offre_competences` (
  `offre_id` int(10) UNSIGNED NOT NULL,
  `competence_id` int(10) UNSIGNED NOT NULL,
  `importance` enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `portal_password_resets`
--

CREATE TABLE `portal_password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `account_type` enum('recruteur','candidat') NOT NULL,
  `account_id` int(10) UNSIGNED NOT NULL COMMENT 'recruteurs.id ou users.id',
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `portal_password_resets`
--

INSERT INTO `portal_password_resets` (`id`, `account_type`, `account_id`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 'recruteur', 1, '1b3303ba788699588d7eb8aeeb4f66d922ae4239361c0d3cad524f190c30fad5', '2026-07-10 03:38:17', '2026-07-10 02:38:28', '2026-07-10 02:38:17'),
(2, 'candidat', 1, '44685be5b259325fb55a6e81d438111e91b11b257b7bba66a97863ad4755b087', '2026-07-20 20:40:59', NULL, '2026-07-20 19:40:59'),
(3, 'recruteur', 3, 'a5b61842f170f4545b8a19927662ba6aa8c64a2ff89dfcb7a0843be9f4ce64bf', '2026-07-23 02:09:25', NULL, '2026-07-23 01:09:25');

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_scoring_config`
--

CREATE TABLE `recrutement_scoring_config` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `poids_competences` tinyint(3) UNSIGNED NOT NULL DEFAULT 40,
  `poids_experience` tinyint(3) UNSIGNED NOT NULL DEFAULT 25,
  `poids_localisation` tinyint(3) UNSIGNED NOT NULL DEFAULT 15,
  `poids_diplome` tinyint(3) UNSIGNED NOT NULL DEFAULT 12,
  `poids_langues` tinyint(3) UNSIGNED NOT NULL DEFAULT 8,
  `bonus_champs_site` tinyint(3) UNSIGNED NOT NULL DEFAULT 10,
  `updated_by_admin_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Déchargement des données de la table `recrutement_scoring_config`
--

INSERT INTO `recrutement_scoring_config` (`id`, `site_id`, `poids_competences`, `poids_experience`, `poids_localisation`, `poids_diplome`, `poids_langues`, `bonus_champs_site`, `updated_by_admin_id`, `created_at`, `updated_at`) VALUES
(1, NULL, 40, 25, 15, 12, 8, 10, NULL, '2026-07-09 16:51:38', '2026-07-09 16:51:38');

-- --------------------------------------------------------

--
-- Structure de la table `recrutement_scoring_history`
--

CREATE TABLE `recrutement_scoring_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `config_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`config_json`)),
  `auteur_admin_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `recruteurs`
--

CREATE TABLE `recruteurs` (
  `id` int(10) UNSIGNED NOT NULL,
  `entreprise_id` int(10) UNSIGNED DEFAULT NULL,
  `nom_entreprise` varchar(250) NOT NULL,
  `prenom` varchar(100) DEFAULT NULL,
  `nom` varchar(100) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `fonction` varchar(150) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `status` enum('pending','actif','suspendu') NOT NULL DEFAULT 'pending',
  `validated_at` datetime DEFAULT NULL,
  `validated_by` int(11) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `recruteurs`
--

INSERT INTO `recruteurs` (`id`, `entreprise_id`, `nom_entreprise`, `prenom`, `nom`, `telephone`, `fonction`, `email`, `password_hash`, `status`, `validated_at`, `validated_by`, `last_login_at`, `created_at`, `updated_at`) VALUES
(2, 2, 'zenfjkzfnejfzf', 'efzefzf', 'efzfzef', '07 82 12 44 52', 'ezfzfze', 'sinay.l777@gmail.com', '$2y$12$COE0r.NBmytONvt6SExOIelcKNHFpuzMNTrIIvU7WtvCfPmwhpNve', 'actif', '2026-07-20 19:44:23', 1, '2026-07-20 21:45:38', '2026-07-20 19:44:11', '2026-07-20 21:45:38'),
(3, 3, 'efzefzfef', 'Yanis', 'Laldji', '0782124452', 'fezfnzjf', 'yanislaldjipro@gmail.com', '$2y$12$TJIjUHYnwDL18AFFFtpDkueSob7G8DRWhs5wpyJiy4WFgcDQ.Onwi', 'actif', '2026-07-23 01:08:44', 1, '2026-07-24 02:29:21', '2026-07-23 01:07:47', '2026-07-24 02:29:21');

-- --------------------------------------------------------

--
-- Structure de la table `recruteur_activation_tokens`
--

CREATE TABLE `recruteur_activation_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `recruteur_id` int(10) UNSIGNED NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `recruteur_activation_tokens`
--

INSERT INTO `recruteur_activation_tokens` (`id`, `recruteur_id`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(2, 2, 'ed47780979e29b505dab8fec1d63877b44b8361e43d1d5f46f2fa84d074505dd', '2026-07-23 19:44:23', NULL, '2026-07-20 19:44:23'),
(3, 3, 'df99364b80fb7d0e94e5f4ff76b67d694381552fdd97aded581505c6195ee770', '2026-07-26 01:08:44', NULL, '2026-07-23 01:08:44');

-- --------------------------------------------------------

--
-- Structure de la table `recruteur_sites`
--

CREATE TABLE `recruteur_sites` (
  `recruteur_id` int(10) UNSIGNED NOT NULL,
  `site` enum('coaching','recrutement','medical','carriere','trainers','formation') NOT NULL,
  `granted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `granted_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `recruteur_sites`
--

INSERT INTO `recruteur_sites` (`recruteur_id`, `site`, `granted_at`, `granted_by`) VALUES
(2, 'medical', '2026-07-20 19:44:23', 1),
(3, 'recrutement', '2026-07-23 01:07:47', 1);

-- --------------------------------------------------------

--
-- Structure de la table `recruteur_tokens`
--

CREATE TABLE `recruteur_tokens` (
  `id` int(10) UNSIGNED NOT NULL,
  `recruteur_id` int(10) UNSIGNED NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `recruteur_tokens`
--

INSERT INTO `recruteur_tokens` (`id`, `recruteur_id`, `token_hash`, `ip_address`, `user_agent`, `expires_at`, `created_at`) VALUES
(11, 2, '031ec801493f36309b8d7e8c8c9e9b44ad14cd1758761b8ecca89e7f40c91613', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-27 21:30:44', '2026-07-20 21:30:44'),
(12, 2, '3ba1f53dad387cb928df47bd0b264c1e8b28808c362e573a6770c0fb696cf90e', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-27 21:32:13', '2026-07-20 21:32:13'),
(13, 2, 'e22a6204aea7d300080ce83de22d6501cf397e55ca69f962973496a790d86d4e', '2a01:cb01:1046:97f3:2da2:f1db:301c:b2ec', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-27 21:45:38', '2026-07-20 21:45:38');

-- --------------------------------------------------------

--
-- Structure de la table `secteurs_activite`
--

CREATE TABLE `secteurs_activite` (
  `id` int(10) UNSIGNED NOT NULL,
  `slug` varchar(100) NOT NULL,
  `label` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `secteurs_activite`
--

INSERT INTO `secteurs_activite` (`id`, `slug`, `label`) VALUES
(1, 'dfdzef', 'dfdzef'),
(2, 'ezefzf', 'ezefzf'),
(3, 'ererf', 'ererf'),
(4, 'dsnkfnezfehfzf', 'dsnkfnezfehfzf'),
(5, 'ededed', 'ededed');

-- --------------------------------------------------------

--
-- Structure de la table `seo_metadata`
--

CREATE TABLE `seo_metadata` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `path` varchar(255) NOT NULL,
  `meta_title` varchar(70) DEFAULT NULL,
  `meta_description` varchar(160) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_pricing`
--

CREATE TABLE `site_pricing` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `amount_eur` decimal(10,2) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `site_pricing`
--

INSERT INTO `site_pricing` (`id`, `site_id`, `amount_eur`, `created_at`, `updated_at`) VALUES
(1, 6, '1500.00', '2026-07-10 01:02:27', NULL),
(2, 6, '4500.00', '2026-07-10 01:02:27', NULL),
(6, 4, '1600.00', '2026-07-30 01:56:59', NULL),
(7, 4, '1950.00', '2026-07-30 01:56:59', NULL),
(8, 4, '1850.00', '2026-07-30 01:56:59', NULL),
(9, 1, '1600.00', '2026-07-30 05:06:35', NULL),
(10, 1, '1950.00', '2026-07-30 05:06:35', NULL),
(11, 1, '1850.00', '2026-07-30 05:06:35', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `system_logs`
--

CREATE TABLE `system_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL COMMENT 'ID du site core_sites (null si global/inconnu)',
  `level` enum('info','warning','error','critical') NOT NULL,
  `source` enum('frontend','api','database') NOT NULL,
  `message` text NOT NULL,
  `context` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `system_logs`
--

INSERT INTO `system_logs` (`id`, `site_id`, `level`, `source`, `message`, `context`, `ip_address`, `created_at`) VALUES
(1, 5, 'info', 'frontend', 'Page visitee : /blog', '{\"type\":\"navigation\",\"site_id\":\"5\",\"visitor_id\":\"bcdee283-79dd-4669-936f-d6cbaf8ce1e0\",\"occurred_at\":\"2026-07-27T13:52:27.719Z\",\"url\":\"https:\\/\\/trainers.nexytal.com\\/blog\",\"path\":\"\\/blog\",\"referrer\":null,\"userAgent\":\"Mozilla\\/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/150.0.0.0 Safari\\/537.36\",\"user_id\":null,\"user_email\":null,\"user_role\":\"guest\",\"trainer_id\":null,\"client_id\":null}', '2a01:cb01:2076:e101:9888:5f1f:f23a:8227', '2026-07-27 15:52:28'),
(2, 4, 'info', 'frontend', 'Test system_logs IONOS Codex no BOM', '{\"source\":\"codex_remote_test\",\"check\":\"system_logs_insert\"}', '2a01:cb01:2015:ade:cc6d:e917:773:d12b', '2026-07-30 02:16:12'),
(3, 4, 'info', 'frontend', 'Test system_logs IONOS 2026-07-30T00:20:18.887Z', '{\"source\":\"npm_test_ionos_logs\",\"node\":\"v22.22.0\"}', '2a01:cb01:2015:ade:cc6d:e917:773:d12b', '2026-07-30 02:20:19'),
(4, 4, 'info', 'frontend', 'frontend_ready', '{\"path\":\"/contact\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.7922.34 Safari/537.36\",\"href\":\"http://127.0.0.1:3000/contact\"}', '2a01:cb01:2015:ade:cc6d:e917:773:d12b', '2026-07-30 02:20:52'),
(5, 4, 'info', 'frontend', 'frontend_ready', '{\"path\":\"/\",\"userAgent\":\"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36\",\"href\":\"https://carriere.nexytal.com/\"}', '2a01:cb01:2015:ade:cc6d:e917:773:d12b', '2026-07-30 02:26:01');

-- --------------------------------------------------------

--
-- Structure de la table `trainers`
--

CREATE TABLE `trainers` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT 5,
  `slug` varchar(120) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `title` varchar(200) NOT NULL,
  `bio` text DEFAULT NULL,
  `tagline` text DEFAULT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `avatar_initials` char(3) DEFAULT NULL,
  `city_id` int(11) UNSIGNED DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `linkedin_url` varchar(512) DEFAULT NULL,
  `experience_years` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `tjm_eur` decimal(10,2) DEFAULT NULL,
  `primary_expertise_id` int(11) UNSIGNED DEFAULT NULL,
  `legal_status` varchar(80) DEFAULT NULL,
  `qualiopi_eligible` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('draft','pending_review','active','inactive') NOT NULL DEFAULT 'pending_review',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `rating_avg` decimal(3,2) NOT NULL DEFAULT 0.00,
  `reviews_count` int(11) NOT NULL DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `validated_at` datetime DEFAULT NULL,
  `validated_by` int(11) DEFAULT NULL COMMENT 'Admin validateur (Nexytal Gestion)',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainers`
--

INSERT INTO `trainers` (`id`, `site_id`, `slug`, `first_name`, `last_name`, `title`, `bio`, `tagline`, `avatar_url`, `avatar_initials`, `city_id`, `email`, `phone`, `linkedin_url`, `experience_years`, `tjm_eur`, `primary_expertise_id`, `legal_status`, `qualiopi_eligible`, `status`, `is_featured`, `sort_order`, `rating_avg`, `reviews_count`, `published_at`, `validated_at`, `validated_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(14, 5, 'anis-aldji', 'Compte', 'supprime', 'eferf', NULL, NULL, NULL, NULL, 1, 'deleted-trainer-14@removed.nexytal.local', NULL, NULL, 4, '600.00', 9, 'SASU', 0, 'inactive', 0, 0, '0.00', 0, '2026-07-09 22:50:57', '2026-07-09 22:50:57', 1, '2026-07-09 22:50:38', '2026-07-09 22:53:26', '2026-07-09 22:53:26'),
(15, 5, 'anis-aldji-2', 'Yanis', 'Laldji', 'ezfzf', 'zefezfez', 'zefzfe', NULL, 'YL', 1, 'yanislaldjipro@gmail.com', '0782124452', NULL, 0, '600.00', 9, 'EURL', 0, 'active', 0, 0, '0.00', 0, '2026-07-10 01:44:36', '2026-07-10 01:44:36', 1, '2026-07-10 01:44:18', '2026-07-10 01:44:36', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_appointment_slots`
--

CREATE TABLE `trainer_appointment_slots` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slot_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time DEFAULT NULL,
  `trainer_id` int(11) UNSIGNED DEFAULT NULL,
  `capacity` tinyint(3) UNSIGNED NOT NULL DEFAULT 1,
  `booked_count` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_appointment_slots`
--

INSERT INTO `trainer_appointment_slots` (`id`, `site_id`, `slot_date`, `start_time`, `end_time`, `trainer_id`, `capacity`, `booked_count`, `is_active`, `created_at`) VALUES
(1, 5, '2026-07-24', '09:00:00', '10:00:00', 15, 10, 1, 1, '2026-07-10 01:45:17');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_certifications`
--

CREATE TABLE `trainer_certifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(110) NOT NULL,
  `name` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_certifications`
--

INSERT INTO `trainer_certifications` (`id`, `slug`, `name`) VALUES
(1, 'njkefjzfjnz', 'njkefjzfjnz'),
(2, 'eded', 'eded');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_certification_links`
--

CREATE TABLE `trainer_certification_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `certification_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_certification_links`
--

INSERT INTO `trainer_certification_links` (`trainer_id`, `certification_id`) VALUES
(13, 1),
(14, 2),
(15, 2);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_cities`
--

CREATE TABLE `trainer_cities` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(80) NOT NULL,
  `region` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_cities`
--

INSERT INTO `trainer_cities` (`id`, `name`, `slug`, `region`) VALUES
(1, 'Villevaudé', 'illevaude', NULL),
(2, 'efzf', 'efzf', 'zefzf');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_city_links`
--

CREATE TABLE `trainer_city_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `city_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_client_links`
--

CREATE TABLE `trainer_client_links` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `client_id` int(11) UNSIGNED NOT NULL,
  `status` enum('pending','active','ended') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_client_links`
--

INSERT INTO `trainer_client_links` (`id`, `site_id`, `trainer_id`, `client_id`, `status`, `created_at`) VALUES
(1, 5, 15, 2, 'active', '2026-07-10 01:46:52');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_client_profiles`
--

CREATE TABLE `trainer_client_profiles` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `company` varchar(150) DEFAULT NULL,
  `job_title` varchar(150) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_client_profiles`
--

INSERT INTO `trainer_client_profiles` (`id`, `site_id`, `first_name`, `last_name`, `email`, `phone`, `company`, `job_title`, `status`, `created_at`) VALUES
(1, 5, 'Compte', 'supprime', 'deleted-client-1@removed.nexytal.local', NULL, NULL, NULL, 'inactive', '2026-07-09 21:52:24'),
(2, 5, 'Yanis', 'Laldji', 'sinay.l777@gmail.com', '0782124452', 'ef', 'efzfe', 'active', '2026-07-10 01:46:44');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_courses`
--

CREATE TABLE `trainer_courses` (
  `id` int(11) UNSIGNED NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(300) NOT NULL,
  `description` text DEFAULT NULL,
  `duration_label` varchar(50) DEFAULT NULL,
  `level` varchar(50) DEFAULT NULL,
  `participants_min` tinyint(3) UNSIGNED DEFAULT NULL,
  `participants_max` tinyint(3) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_expertise_links`
--

CREATE TABLE `trainer_expertise_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `expertise_id` int(11) UNSIGNED NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_expertise_links`
--

INSERT INTO `trainer_expertise_links` (`trainer_id`, `expertise_id`, `is_primary`) VALUES
(14, 9, 1),
(15, 9, 1);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_languages`
--

CREATE TABLE `trainer_languages` (
  `id` int(11) UNSIGNED NOT NULL,
  `code` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  `flag_emoji` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_languages`
--

INSERT INTO `trainer_languages` (`id`, `code`, `name`, `flag_emoji`) VALUES
(1, 'ranca', 'Français', NULL),
(2, 'te', 'test', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_language_links`
--

CREATE TABLE `trainer_language_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `language_id` int(11) UNSIGNED NOT NULL,
  `level` enum('Notions','Intermédiaire','Courant','Bilingue','Natif') NOT NULL DEFAULT 'Courant'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_language_links`
--

INSERT INTO `trainer_language_links` (`trainer_id`, `language_id`, `level`) VALUES
(13, 1, 'Natif'),
(14, 1, 'Courant'),
(15, 1, 'Courant');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_modalities`
--

CREATE TABLE `trainer_modalities` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `modality` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_modalities`
--

INSERT INTO `trainer_modalities` (`trainer_id`, `modality`) VALUES
(13, 'distanciel'),
(13, 'présentiel'),
(14, 'distanciel'),
(14, 'présentiel'),
(15, 'distanciel'),
(15, 'présentiel');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_portal_accounts`
--

CREATE TABLE `trainer_portal_accounts` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `role` enum('trainer','client') NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `trainer_id` int(11) UNSIGNED DEFAULT NULL,
  `client_id` int(11) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_portal_accounts`
--

INSERT INTO `trainer_portal_accounts` (`id`, `site_id`, `role`, `email`, `password_hash`, `trainer_id`, `client_id`, `is_active`, `last_login_at`, `created_at`) VALUES
(4, 5, 'trainer', 'yanislaldjipro@gmail.com', '$argon2id$v=19$m=65536,t=4,p=1$YU56YWdMb2tZTC9qanI5TQ$vsD6hZjFkCJoxDkZxzuGI58LJ1PelF5SjcthmvAFfq8', 15, NULL, 1, '2026-07-27 15:11:52', '2026-07-10 01:44:18'),
(5, 5, 'client', 'sinay.l777@gmail.com', '$argon2id$v=19$m=65536,t=4,p=1$TENqQ3I1eVprQnFob3Bkag$IquIEbrLa2t7mzA8tBIn/ZfG8B5OCOJyEFHBAodLgeo', NULL, 2, 1, '2026-07-10 01:46:44', '2026-07-10 01:46:44');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_portal_password_resets`
--

CREATE TABLE `trainer_portal_password_resets` (
  `id` int(11) UNSIGNED NOT NULL,
  `account_id` int(11) UNSIGNED NOT NULL,
  `role` enum('trainer','client') NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_portal_password_resets`
--

INSERT INTO `trainer_portal_password_resets` (`id`, `account_id`, `role`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 1, 'trainer', '02b1c83837c0f831d89d5c3f0ee98d509e28697013609b8209e2756c6765a65e', '2026-07-12 17:49:58', NULL, '2026-07-09 17:49:58'),
(2, 1, 'trainer', '9482ce3a8e54f1b1bc3c14cfc3f4ff370571ca4c55bf931a725728bc1f459f4f', '2026-07-09 23:16:50', NULL, '2026-07-09 22:16:50'),
(3, 1, 'trainer', '05cfd41a4e0dd0094bb4ed6320a9e3cbda512c7aaf2c059abfa9beb351c26c7f', '2026-07-09 23:27:04', '2026-07-09 22:27:40', '2026-07-09 22:27:04'),
(5, 4, 'trainer', '43645a9927bd9005586faa014a6f45f854cf6c501563c671a288f936bd0df788', '2026-07-13 01:44:36', NULL, '2026-07-10 01:44:36'),
(6, 4, 'trainer', 'd031c04623fda5c92f35fbd4d938665f2f18087a54906e6ed21dc214f7c7bdb0', '2026-07-27 15:29:05', '2026-07-27 14:29:22', '2026-07-27 14:29:05');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_portal_tokens`
--

CREATE TABLE `trainer_portal_tokens` (
  `id` int(11) UNSIGNED NOT NULL,
  `account_id` int(11) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_portal_tokens`
--

INSERT INTO `trainer_portal_tokens` (`id`, `account_id`, `token_hash`, `ip_address`, `expires_at`, `created_at`) VALUES
(4, 1, 'bfdac1f698292dc1aa86d8e9ca23b117d53d06cf91e7a8aeb194e64b1f3472e9', '2a01:cb06:8065:1f1b:1590:3b4f:1c62:f79c', '2026-07-16 22:27:51', '2026-07-09 22:27:51');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_reviews`
--

CREATE TABLE `trainer_reviews` (
  `id` int(11) UNSIGNED NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `author_name` varchar(150) NOT NULL,
  `company` varchar(150) DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED NOT NULL,
  `comment` text NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_session_bookings`
--

CREATE TABLE `trainer_session_bookings` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `slot_id` int(11) UNSIGNED NOT NULL,
  `client_id` int(11) UNSIGNED NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `status` enum('pending','confirmed','cancelled','completed') NOT NULL DEFAULT 'confirmed',
  `notes` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_session_bookings`
--

INSERT INTO `trainer_session_bookings` (`id`, `site_id`, `slot_id`, `client_id`, `trainer_id`, `status`, `notes`, `created_at`) VALUES
(1, 5, 1, 2, 15, 'confirmed', NULL, '2026-07-10 01:46:52');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_skills`
--

CREATE TABLE `trainer_skills` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(110) NOT NULL,
  `name` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_skills`
--

INSERT INTO `trainer_skills` (`id`, `slug`, `name`) VALUES
(1, 'oui', 'oui'),
(2, 'bhbhebzf', 'bhbhebzf');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_skill_links`
--

CREATE TABLE `trainer_skill_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `skill_id` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_skill_links`
--

INSERT INTO `trainer_skill_links` (`trainer_id`, `skill_id`) VALUES
(13, 2),
(15, 2);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role` enum('candidat','consultant') NOT NULL DEFAULT 'candidat',
  `email_verifie` tinyint(1) NOT NULL DEFAULT 0,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `derniere_connexion` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `email`, `password_hash`, `role`, `email_verifie`, `actif`, `derniere_connexion`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'yanislaldjipro@gmail.com', '$2y$12$40uLUQo2iSqA/7miJggSjOL6W5FLJYUDyaruCOXhMQova5QBSLCi.', 'candidat', 0, 1, '2026-07-30 02:41:04', '2026-07-10 02:39:47', '2026-07-30 02:41:04', NULL),
(2, 'sinay.l777@gmail.com', '$2y$12$naYZfESLn4i.IJrP2DtC3.XO5IScMZ8W6HSrp2AHcDrsTGAOOiohi', 'candidat', 0, 1, '2026-07-23 13:21:44', '2026-07-23 13:08:14', '2026-07-23 13:21:44', NULL),
(3, 'oui@gmail.com', '$2y$12$ub1Lpqj2Cn3OfJlwjYHudO/qIsH49H6XrdH/XrxoUPMyOirwItKtm', 'candidat', 0, 1, '2026-07-24 02:25:44', '2026-07-23 13:22:46', '2026-07-24 02:25:44', NULL),
(4, 'test@gmail.com', '$2y$12$bfh3SPtihgFGtXP0Kf8WkOzR8VCVc9rcuuffanX6Hcb4GjZ33NGgq', 'candidat', 0, 1, '2026-07-24 02:29:06', '2026-07-24 02:26:26', '2026-07-24 02:29:06', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `villes`
--

CREATE TABLE `villes` (
  `id` int(10) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `nom` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_coaches_catalog`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_coaches_catalog` (
`id` int(11) unsigned
,`site_id` int(11)
,`slug` varchar(120)
,`name` varchar(161)
,`first_name` varchar(80)
,`last_name` varchar(80)
,`title` varchar(200)
,`bio` text
,`full_bio` longtext
,`avatar_initials` char(3)
,`avatar_url` varchar(512)
,`experience_years` tinyint(3) unsigned
,`is_featured` tinyint(1)
,`sort_order` int(11)
,`published_at` datetime
,`validated_at` datetime
,`created_at` datetime
,`location` varchar(100)
,`city_slug` varchar(80)
,`specialties` mediumtext
,`certifications` mediumtext
,`languages` mediumtext
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_coaches_pending_validation`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_coaches_pending_validation` (
`id` int(11) unsigned
,`site_id` int(11)
,`site_code` enum('formation','recrutement','medical','carriere','trainers','coaching')
,`site_name` varchar(255)
,`slug` varchar(120)
,`first_name` varchar(80)
,`last_name` varchar(80)
,`name` varchar(161)
,`title` varchar(200)
,`email` varchar(255)
,`phone` varchar(30)
,`status` enum('draft','pending_review','active','inactive')
,`created_at` datetime
,`updated_at` datetime
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_expertises_catalog`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_expertises_catalog` (
`id` int(11) unsigned
,`site_id` int(11)
,`slug` varchar(110)
,`label` varchar(150)
,`name` varchar(150)
,`subtitle` varchar(200)
,`description` text
,`icon` varchar(50)
,`sort_order` int(11)
,`is_active` tinyint(1)
,`skills_json` text
,`certifications_json` text
,`faq_json` text
,`created_at` datetime
,`updated_at` datetime
,`trainers_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_gestion_candidatures`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_gestion_candidatures` (
`type` varchar(7)
,`candidature_id` int(10) unsigned
,`site_id` int(11)
,`site_code` varchar(11)
,`offre_id` int(10) unsigned
,`offre_titre` varchar(300)
,`offre_statut` varchar(9)
,`recruteur_id` int(10) unsigned
,`entreprise_nom` varchar(250)
,`recruteur_email` varchar(255)
,`prenom` varchar(100)
,`nom` varchar(100)
,`candidat_email` varchar(255)
,`telephone` varchar(20)
,`message` mediumtext
,`cv_filename` varchar(255)
,`experience_candidat` enum('debutant','1-2','3-5','5-10','10+')
,`competences_reponses` longtext
,`disponibilite` date
,`statut` varchar(9)
,`verifie_nexytal` tinyint(4)
,`score_nexytal` tinyint(3) unsigned
,`note_nexytal` mediumtext
,`date_candidature` datetime /* mariadb-5.3 */
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_recruteur_offres`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_recruteur_offres` (
`id` int(10) unsigned
,`site_id` int(11)
,`site_code` enum('formation','recrutement','medical','carriere','trainers','coaching')
,`site_name` varchar(255)
,`site_domain` varchar(255)
,`recruteur_id` int(10) unsigned
,`entreprise_id` int(10) unsigned
,`entreprise_nom` varchar(200)
,`slug` varchar(250)
,`titre` varchar(300)
,`statut` enum('brouillon','publiee','pourvue','expiree','archivee')
,`is_urgent` tinyint(1)
,`is_featured` tinyint(1)
,`date_publication` datetime
,`date_expiration` datetime
,`vues` int(10) unsigned
,`created_at` datetime
,`updated_at` datetime
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_recruteur_sites_actifs`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_recruteur_sites_actifs` (
`recruteur_id` int(10) unsigned
,`email` varchar(255)
,`nom_entreprise` varchar(250)
,`site_code` enum('coaching','recrutement','medical','carriere','trainers','formation')
,`site_id` int(11)
,`site_name` varchar(255)
,`site_domain` varchar(255)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_trainers_catalog`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_trainers_catalog` (
`id` int(11) unsigned
,`site_id` int(11)
,`slug` varchar(120)
,`name` varchar(161)
,`first_name` varchar(80)
,`last_name` varchar(80)
,`title` varchar(200)
,`bio` mediumtext
,`tagline` text
,`avatar_initials` char(3)
,`avatar_url` varchar(512)
,`experience` tinyint(3) unsigned
,`availability` varchar(9)
,`rating` decimal(3,2)
,`reviews` int(11)
,`tjm` decimal(10,2)
,`city_name` varchar(100)
,`city_region` varchar(100)
,`region` varchar(100)
,`created_at` datetime
,`expertise` mediumtext
,`skills` mediumtext
,`certifications` mediumtext
,`modalities` mediumtext
,`cities` mediumtext
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_trainers_pending_validation`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_trainers_pending_validation` (
`id` int(11) unsigned
,`site_id` int(11)
,`site_code` enum('formation','recrutement','medical','carriere','trainers','coaching')
,`site_name` varchar(255)
,`slug` varchar(120)
,`first_name` varchar(80)
,`last_name` varchar(80)
,`name` varchar(161)
,`title` varchar(200)
,`email` varchar(255)
,`phone` varchar(30)
,`status` enum('draft','pending_review','active','inactive')
,`created_at` datetime
,`updated_at` datetime
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_coaches_catalog`
--
DROP TABLE IF EXISTS `v_coaches_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_coaches_catalog`  AS SELECT `c`.`id` AS `id`, `c`.`site_id` AS `site_id`, `c`.`slug` AS `slug`, concat(`c`.`first_name`,' ',`c`.`last_name`) AS `name`, `c`.`first_name` AS `first_name`, `c`.`last_name` AS `last_name`, `c`.`title` AS `title`, `c`.`bio_short` AS `bio`, `c`.`bio_full` AS `full_bio`, `c`.`avatar_initials` AS `avatar_initials`, `c`.`avatar_url` AS `avatar_url`, `c`.`experience_years` AS `experience_years`, `c`.`is_featured` AS `is_featured`, `c`.`sort_order` AS `sort_order`, `c`.`published_at` AS `published_at`, `c`.`validated_at` AS `validated_at`, `c`.`created_at` AS `created_at`, `cc`.`name` AS `location`, `cc`.`slug` AS `city_slug`, group_concat(distinct `cs`.`name` order by `cs`.`name` ASC separator ', ') AS `specialties`, group_concat(distinct `cert`.`name` order by `cert`.`name` ASC separator ', ') AS `certifications`, group_concat(distinct coalesce(`cl`.`flag_emoji`,`cl`.`code`) order by `cl`.`name` ASC separator ', ') AS `languages` FROM (((((((`coaches` `c` left join `coaching_cities` `cc` on(`cc`.`id` = `c`.`city_id`)) left join `coach_specialty_links` `csl` on(`csl`.`coach_id` = `c`.`id`)) left join `coaching_specialties` `cs` on(`cs`.`id` = `csl`.`specialty_id` and `cs`.`is_active` = 1)) left join `coach_certification_links` `ccl` on(`ccl`.`coach_id` = `c`.`id`)) left join `coaching_certifications` `cert` on(`cert`.`id` = `ccl`.`certification_id`)) left join `coach_language_links` `cll` on(`cll`.`coach_id` = `c`.`id`)) left join `coaching_languages` `cl` on(`cl`.`id` = `cll`.`language_id`)) WHERE `c`.`status` = 'active' AND `c`.`validated_at` is not null AND `c`.`deleted_at` is null GROUP BY `c`.`id``id` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_coaches_pending_validation`
--
DROP TABLE IF EXISTS `v_coaches_pending_validation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_coaches_pending_validation`  AS SELECT `c`.`id` AS `id`, `c`.`site_id` AS `site_id`, `cs`.`site_code` AS `site_code`, `cs`.`name` AS `site_name`, `c`.`slug` AS `slug`, `c`.`first_name` AS `first_name`, `c`.`last_name` AS `last_name`, concat(`c`.`first_name`,' ',`c`.`last_name`) AS `name`, `c`.`title` AS `title`, `c`.`email` AS `email`, `c`.`phone` AS `phone`, `c`.`status` AS `status`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at` FROM (`coaches` `c` join `core_sites` `cs` on(`cs`.`id` = `c`.`site_id`)) WHERE `c`.`status` = 'pending_review' AND `c`.`validated_at` is null AND `c`.`deleted_at` is null ORDER BY `c`.`created_at` ASC`created_at` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_expertises_catalog`
--
DROP TABLE IF EXISTS `v_expertises_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_expertises_catalog`  AS SELECT `e`.`id` AS `id`, `e`.`site_id` AS `site_id`, `e`.`slug` AS `slug`, `e`.`label` AS `label`, `e`.`name` AS `name`, `e`.`subtitle` AS `subtitle`, `e`.`description` AS `description`, `e`.`icon` AS `icon`, `e`.`sort_order` AS `sort_order`, `e`.`is_active` AS `is_active`, `e`.`skills_json` AS `skills_json`, `e`.`certifications_json` AS `certifications_json`, `e`.`faq_json` AS `faq_json`, `e`.`created_at` AS `created_at`, `e`.`updated_at` AS `updated_at`, count(distinct case when `t`.`id` is not null and `t`.`status` = 'active' and `t`.`validated_at` is not null and `t`.`deleted_at` is null then `t`.`id` end) AS `trainers_count` FROM ((`expertises` `e` left join `trainer_expertise_links` `tel` on(`tel`.`expertise_id` = `e`.`id`)) left join `trainers` `t` on(`t`.`id` = `tel`.`trainer_id`)) GROUP BY `e`.`id``id` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_gestion_candidatures`
--
DROP TABLE IF EXISTS `v_gestion_candidatures`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_gestion_candidatures`  AS SELECT 'externe' AS `type`, `ce`.`id` AS `candidature_id`, `ce`.`site_id` AS `site_id`, `cs`.`site_code` AS `site_code`, `ce`.`offre_id` AS `offre_id`, `o`.`titre` AS `offre_titre`, `o`.`statut` AS `offre_statut`, `o`.`recruteur_id` AS `recruteur_id`, coalesce(`e`.`nom`,`r`.`nom_entreprise`) AS `entreprise_nom`, `r`.`email` AS `recruteur_email`, `ce`.`prenom` AS `prenom`, `ce`.`nom` AS `nom`, `ce`.`email` AS `candidat_email`, `ce`.`telephone` AS `telephone`, `ce`.`lettre_motivation` AS `message`, `ce`.`cv_filename` AS `cv_filename`, `ce`.`experience_candidat` AS `experience_candidat`, `ce`.`competences_reponses` AS `competences_reponses`, `ce`.`disponibilite` AS `disponibilite`, `ce`.`statut` AS `statut`, `ce`.`verifie_nexytal` AS `verifie_nexytal`, `ce`.`score_nexytal` AS `score_nexytal`, `ce`.`note_nexytal` AS `note_nexytal`, `ce`.`created_at` AS `date_candidature` FROM ((((`candidatures_externes` `ce` join `core_sites` `cs` on(`cs`.`id` = `ce`.`site_id`)) join `offres_emploi` `o` on(`o`.`id` = `ce`.`offre_id`)) left join `recruteurs` `r` on(`r`.`id` = `o`.`recruteur_id`)) left join `entreprises` `e` on(`e`.`id` = `o`.`entreprise_id`)) union all select 'interne' AS `interne`,`c`.`id` AS `id`,`o`.`site_id` AS `site_id`,`cs`.`site_code` AS `site_code`,`c`.`offre_id` AS `offre_id`,`o`.`titre` AS `titre`,`o`.`statut` AS `statut`,`o`.`recruteur_id` AS `recruteur_id`,coalesce(`e`.`nom`,`r`.`nom_entreprise`) AS `COALESCE(e.nom, r.nom_entreprise)`,`r`.`email` AS `email`,`ca`.`prenom` AS `prenom`,`ca`.`nom` AS `nom`,coalesce(`u`.`email`,'') AS `COALESCE(u.email,'')`,`ca`.`telephone` AS `telephone`,`c`.`message_motivation` AS `message_motivation`,NULL AS `NULL`,NULL AS `NULL`,NULL AS `NULL`,`ca`.`disponibilite` AS `disponibilite`,`c`.`statut` AS `statut`,`c`.`verifie_nexytal` AS `verifie_nexytal`,`c`.`score_nexytal` AS `score_nexytal`,`c`.`note_nexytal` AS `note_nexytal`,`c`.`date_candidature` AS `date_candidature` from ((((((`candidatures` `c` join `candidats` `ca` on(`ca`.`id` = `c`.`candidat_id`)) left join `users` `u` on(`u`.`id` = `ca`.`user_id`)) join `offres_emploi` `o` on(`o`.`id` = `c`.`offre_id`)) join `core_sites` `cs` on(`cs`.`id` = `o`.`site_id`)) left join `recruteurs` `r` on(`r`.`id` = `o`.`recruteur_id`)) left join `entreprises` `e` on(`e`.`id` = `o`.`entreprise_id`)) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_recruteur_offres`
--
DROP TABLE IF EXISTS `v_recruteur_offres`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_recruteur_offres`  AS SELECT `o`.`id` AS `id`, `o`.`site_id` AS `site_id`, `s`.`site_code` AS `site_code`, `s`.`name` AS `site_name`, `s`.`domain` AS `site_domain`, `o`.`recruteur_id` AS `recruteur_id`, `o`.`entreprise_id` AS `entreprise_id`, `e`.`nom` AS `entreprise_nom`, `o`.`slug` AS `slug`, `o`.`titre` AS `titre`, `o`.`statut` AS `statut`, `o`.`is_urgent` AS `is_urgent`, `o`.`is_featured` AS `is_featured`, `o`.`date_publication` AS `date_publication`, `o`.`date_expiration` AS `date_expiration`, `o`.`vues` AS `vues`, `o`.`created_at` AS `created_at`, `o`.`updated_at` AS `updated_at` FROM ((`offres_emploi` `o` join `core_sites` `s` on(`s`.`id` = `o`.`site_id`)) join `entreprises` `e` on(`e`.`id` = `o`.`entreprise_id`)) WHERE `o`.`recruteur_id` is not nullnot null ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_recruteur_sites_actifs`
--
DROP TABLE IF EXISTS `v_recruteur_sites_actifs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_recruteur_sites_actifs`  AS SELECT `r`.`id` AS `recruteur_id`, `r`.`email` AS `email`, `r`.`nom_entreprise` AS `nom_entreprise`, `rs`.`site` AS `site_code`, `cs`.`id` AS `site_id`, `cs`.`name` AS `site_name`, `cs`.`domain` AS `site_domain` FROM ((`recruteurs` `r` join `recruteur_sites` `rs` on(`rs`.`recruteur_id` = `r`.`id`)) join `core_sites` `cs` on(`cs`.`site_code` = `rs`.`site`)) WHERE `r`.`status` = 'actif''actif' ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_trainers_catalog`
--
DROP TABLE IF EXISTS `v_trainers_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_trainers_catalog`  AS SELECT `t`.`id` AS `id`, `t`.`site_id` AS `site_id`, `t`.`slug` AS `slug`, concat(`t`.`first_name`,' ',`t`.`last_name`) AS `name`, `t`.`first_name` AS `first_name`, `t`.`last_name` AS `last_name`, `t`.`title` AS `title`, coalesce(`t`.`bio`,`t`.`tagline`) AS `bio`, `t`.`tagline` AS `tagline`, `t`.`avatar_initials` AS `avatar_initials`, `t`.`avatar_url` AS `avatar_url`, `t`.`experience_years` AS `experience`, 'available' AS `availability`, `t`.`rating_avg` AS `rating`, `t`.`reviews_count` AS `reviews`, coalesce(`t`.`tjm_eur`,0) AS `tjm`, `tc`.`name` AS `city_name`, `tc`.`region` AS `city_region`, `tc`.`region` AS `region`, `t`.`created_at` AS `created_at`, group_concat(distinct coalesce(`e`.`label`,`e`.`name`) order by `e`.`label` ASC separator ', ') AS `expertise`, group_concat(distinct `s`.`name` order by `s`.`name` ASC separator ', ') AS `skills`, group_concat(distinct `cert`.`name` order by `cert`.`name` ASC separator ', ') AS `certifications`, group_concat(distinct `tm`.`modality` order by `tm`.`modality` ASC separator ', ') AS `modalities`, group_concat(distinct `tc2`.`name` order by `tc2`.`name` ASC separator ', ') AS `cities` FROM ((((((((((`trainers` `t` left join `trainer_cities` `tc` on(`tc`.`id` = `t`.`city_id`)) left join `trainer_expertise_links` `tel` on(`tel`.`trainer_id` = `t`.`id`)) left join `expertises` `e` on(`e`.`id` = `tel`.`expertise_id` and `e`.`is_active` = 1)) left join `trainer_skill_links` `tsl` on(`tsl`.`trainer_id` = `t`.`id`)) left join `trainer_skills` `s` on(`s`.`id` = `tsl`.`skill_id`)) left join `trainer_certification_links` `tcl` on(`tcl`.`trainer_id` = `t`.`id`)) left join `trainer_certifications` `cert` on(`cert`.`id` = `tcl`.`certification_id`)) left join `trainer_modalities` `tm` on(`tm`.`trainer_id` = `t`.`id`)) left join `trainer_city_links` `tcl2` on(`tcl2`.`trainer_id` = `t`.`id`)) left join `trainer_cities` `tc2` on(`tc2`.`id` = `tcl2`.`city_id`)) WHERE `t`.`status` = 'active' AND `t`.`validated_at` is not null AND `t`.`deleted_at` is null GROUP BY `t`.`id``id` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_trainers_pending_validation`
--
DROP TABLE IF EXISTS `v_trainers_pending_validation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY INVOKER VIEW `v_trainers_pending_validation`  AS SELECT `t`.`id` AS `id`, `t`.`site_id` AS `site_id`, `cs`.`site_code` AS `site_code`, `cs`.`name` AS `site_name`, `t`.`slug` AS `slug`, `t`.`first_name` AS `first_name`, `t`.`last_name` AS `last_name`, concat(`t`.`first_name`,' ',`t`.`last_name`) AS `name`, `t`.`title` AS `title`, `t`.`email` AS `email`, `t`.`phone` AS `phone`, `t`.`status` AS `status`, `t`.`created_at` AS `created_at`, `t`.`updated_at` AS `updated_at` FROM (`trainers` `t` join `core_sites` `cs` on(`cs`.`id` = `t`.`site_id`)) WHERE `t`.`status` = 'pending_review' AND `t`.`validated_at` is null AND `t`.`deleted_at` is null ORDER BY `t`.`created_at` ASC`created_at` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `alertes_emploi`
--
ALTER TABLE `alertes_emploi`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_blog_author_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_blog_cat_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_blog_comments_post_status` (`post_id`,`status`,`created_at`);

--
-- Index pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_blog_post_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_blog_versions_post_created` (`post_id`,`created_at`);

--
-- Index pour la table `blog_post_tags`
--
ALTER TABLE `blog_post_tags`
  ADD PRIMARY KEY (`post_id`,`tag_id`);

--
-- Index pour la table `blog_related_posts`
--
ALTER TABLE `blog_related_posts`
  ADD PRIMARY KEY (`post_id`,`related_post_id`);

--
-- Index pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_blog_tag_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `candidats`
--
ALTER TABLE `candidats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_candidats_user` (`user_id`),
  ADD KEY `idx_candidats_deleted_created` (`deleted_at`,`created_at`);

--
-- Index pour la table `candidatures`
--
ALTER TABLE `candidatures`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_candidature_offre_candidat` (`offre_id`,`candidat_id`),
  ADD KEY `idx_candidatures_offre_status` (`offre_id`,`statut`);

--
-- Index pour la table `candidatures_externes`
--
ALTER TABLE `candidatures_externes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cand_ext_site_status_created` (`site_id`,`statut`,`created_at`),
  ADD KEY `idx_cand_ext_offre_status` (`offre_id`,`statut`);

--
-- Index pour la table `candidature_historique`
--
ALTER TABLE `candidature_historique`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `candidat_competences`
--
ALTER TABLE `candidat_competences`
  ADD PRIMARY KEY (`candidat_id`,`competence_id`);

--
-- Index pour la table `candidat_metiers_souhaites`
--
ALTER TABLE `candidat_metiers_souhaites`
  ADD PRIMARY KEY (`candidat_id`,`metier_id`);

--
-- Index pour la table `candidat_tokens`
--
ALTER TABLE `candidat_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_candidat_token_hash` (`token_hash`);

--
-- Index pour la table `career_applications`
--
ALTER TABLE `career_applications`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `career_job_offers`
--
ALTER TABLE `career_job_offers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_career_offer_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `coaches`
--
ALTER TABLE `coaches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coach_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `coaching_appointment_slots`
--
ALTER TABLE `coaching_appointment_slots`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `coaching_certifications`
--
ALTER TABLE `coaching_certifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coaching_cert_slug` (`slug`);

--
-- Index pour la table `coaching_cities`
--
ALTER TABLE `coaching_cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coaching_city_slug` (`slug`);

--
-- Index pour la table `coaching_client_profiles`
--
ALTER TABLE `coaching_client_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_client_site_email` (`site_id`,`email`);

--
-- Index pour la table `coaching_coach_client_links`
--
ALTER TABLE `coaching_coach_client_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coach_client_link` (`coach_id`,`client_id`);

--
-- Index pour la table `coaching_contact_requests`
--
ALTER TABLE `coaching_contact_requests`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `coaching_contact_slots`
--
ALTER TABLE `coaching_contact_slots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contact_slot_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `coaching_languages`
--
ALTER TABLE `coaching_languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coaching_lang_code` (`code`);

--
-- Index pour la table `coaching_portal_accounts`
--
ALTER TABLE `coaching_portal_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_portal_site_email_role` (`site_id`,`email`,`role`);

--
-- Index pour la table `coaching_portal_password_resets`
--
ALTER TABLE `coaching_portal_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_coaching_portal_reset_token` (`token_hash`),
  ADD KEY `idx_coaching_portal_reset_account` (`account_id`),
  ADD KEY `idx_coaching_portal_reset_expires` (`expires_at`);

--
-- Index pour la table `coaching_portal_tokens`
--
ALTER TABLE `coaching_portal_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_coaching_portal_tokens_account_expiry` (`account_id`,`expires_at`);

--
-- Index pour la table `coaching_session_bookings`
--
ALTER TABLE `coaching_session_bookings`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `coaching_specialties`
--
ALTER TABLE `coaching_specialties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coaching_specialty_slug` (`slug`);

--
-- Index pour la table `coach_certification_links`
--
ALTER TABLE `coach_certification_links`
  ADD PRIMARY KEY (`coach_id`,`certification_id`);

--
-- Index pour la table `coach_language_links`
--
ALTER TABLE `coach_language_links`
  ADD PRIMARY KEY (`coach_id`,`language_id`);

--
-- Index pour la table `coach_specialty_links`
--
ALTER TABLE `coach_specialty_links`
  ADD PRIMARY KEY (`coach_id`,`specialty_id`);

--
-- Index pour la table `competences`
--
ALTER TABLE `competences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_competence_slug` (`slug`);

--
-- Index pour la table `core_admin_password_resets`
--
ALTER TABLE `core_admin_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_admin_reset_token_hash` (`token_hash`),
  ADD KEY `idx_admin_reset_admin_expiry` (`admin_id`,`expires_at`,`used_at`);

--
-- Index pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_sessions_admin_expiry` (`admin_id`,`expires_at`);

--
-- Index pour la table `core_admin_site_access`
--
ALTER TABLE `core_admin_site_access`
  ADD PRIMARY KEY (`admin_id`,`site_id`);

--
-- Index pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_admin_email` (`email`);

--
-- Index pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_site_created` (`site_id`,`created_at`),
  ADD KEY `idx_audit_action_ip_created` (`action`,`ip_address`,`created_at`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`);

--
-- Index pour la table `core_sites`
--
ALTER TABLE `core_sites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_core_sites_slug` (`slug`),
  ADD UNIQUE KEY `uk_core_sites_code` (`site_code`),
  ADD UNIQUE KEY `uk_core_sites_domain` (`domain`);

--
-- Index pour la table `demandes_urgentes`
--
ALTER TABLE `demandes_urgentes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `entreprises`
--
ALTER TABLE `entreprises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_entreprise_slug` (`slug`),
  ADD UNIQUE KEY `uk_entreprise_siret` (`siret`);

--
-- Index pour la table `expertises`
--
ALTER TABLE `expertises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_expertise_slug` (`slug`),
  ADD KEY `idx_expertise_site_active` (`site_id`,`is_active`,`sort_order`);

--
-- Index pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_formation_cat_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `formation_courses`
--
ALTER TABLE `formation_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_formation_course_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `formation_course_stats`
--
ALTER TABLE `formation_course_stats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_formation_stat_course` (`course_id`);

--
-- Index pour la table `formation_info_blocks`
--
ALTER TABLE `formation_info_blocks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_formation_info_block_course` (`course_id`);

--
-- Index pour la table `formation_info_points`
--
ALTER TABLE `formation_info_points`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_formation_info_point_block` (`block_id`);

--
-- Index pour la table `formation_jobs`
--
ALTER TABLE `formation_jobs`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `formation_objectives`
--
ALTER TABLE `formation_objectives`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_formation_objective_course` (`course_id`);

--
-- Index pour la table `formation_skills`
--
ALTER TABLE `formation_skills`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `gdpr_consents_log`
--
ALTER TABLE `gdpr_consents_log`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdpr_delete_site_status` (`site_id`,`status`,`requested_at`),
  ADD KEY `idx_gdpr_delete_email` (`user_email`);

--
-- Index pour la table `marketing_email_logs`
--
ALTER TABLE `marketing_email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_marketing_email_site_status` (`site_id`,`status`,`created_at`),
  ADD KEY `idx_marketing_email_recipient` (`recipient_email`);

--
-- Index pour la table `media_library`
--
ALTER TABLE `media_library`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `metiers`
--
ALTER TABLE `metiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_metier_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `metier_competences`
--
ALTER TABLE `metier_competences`
  ADD PRIMARY KEY (`metier_id`,`competence_id`);

--
-- Index pour la table `newsletter_campaigns`
--
ALTER TABLE `newsletter_campaigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_newsletter_campaign_site_status` (`site_id`,`status`,`created_at`);

--
-- Index pour la table `newsletter_events`
--
ALTER TABLE `newsletter_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_newsletter_events_campaign` (`campaign_id`,`event_type`,`created_at`);

--
-- Index pour la table `newsletter_lists`
--
ALTER TABLE `newsletter_lists`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_newsletter_list_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_newsletter_sub_site_email` (`site_id`,`email`);

--
-- Index pour la table `newsletter_subscriptions`
--
ALTER TABLE `newsletter_subscriptions`
  ADD PRIMARY KEY (`subscriber_id`,`list_id`);

--
-- Index pour la table `offres_emploi`
--
ALTER TABLE `offres_emploi`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_offre_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_offres_site_status_dates` (`site_id`,`statut`,`date_publication`,`date_expiration`),
  ADD KEY `idx_offres_recruteur` (`recruteur_id`,`site_id`),
  ADD KEY `idx_offres_entreprise` (`entreprise_id`);

--
-- Index pour la table `offres_favorites`
--
ALTER TABLE `offres_favorites`
  ADD PRIMARY KEY (`candidat_id`,`offre_id`);

--
-- Index pour la table `offre_competences`
--
ALTER TABLE `offre_competences`
  ADD PRIMARY KEY (`offre_id`,`competence_id`);

--
-- Index pour la table `portal_password_resets`
--
ALTER TABLE `portal_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_portal_reset_token` (`token_hash`),
  ADD KEY `idx_portal_reset_account` (`account_type`,`account_id`),
  ADD KEY `idx_portal_reset_expires` (`expires_at`);

--
-- Index pour la table `recrutement_scoring_config`
--
ALTER TABLE `recrutement_scoring_config`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_scoring_config_site` (`site_id`);

--
-- Index pour la table `recrutement_scoring_history`
--
ALTER TABLE `recrutement_scoring_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_scoring_history_site_created` (`site_id`,`created_at`);

--
-- Index pour la table `recruteurs`
--
ALTER TABLE `recruteurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_recruteur_email` (`email`),
  ADD KEY `idx_recruteurs_status_created` (`status`,`created_at`),
  ADD KEY `idx_recruteurs_entreprise` (`entreprise_id`);

--
-- Index pour la table `recruteur_activation_tokens`
--
ALTER TABLE `recruteur_activation_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `recruteur_sites`
--
ALTER TABLE `recruteur_sites`
  ADD PRIMARY KEY (`recruteur_id`,`site`);

--
-- Index pour la table `recruteur_tokens`
--
ALTER TABLE `recruteur_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `secteurs_activite`
--
ALTER TABLE `secteurs_activite`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_secteur_slug` (`slug`);

--
-- Index pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_seo_site_path` (`site_id`,`path`);

--
-- Index pour la table `site_pricing`
--
ALTER TABLE `site_pricing`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_site_pricing_site` (`site_id`);

--
-- Index pour la table `system_logs`
--
ALTER TABLE `system_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_level_created` (`level`,`created_at`),
  ADD KEY `idx_site_id` (`site_id`);

--
-- Index pour la table `trainers`
--
ALTER TABLE `trainers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_trainers_primary_expertise` (`primary_expertise_id`);

--
-- Index pour la table `trainer_appointment_slots`
--
ALTER TABLE `trainer_appointment_slots`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `trainer_certifications`
--
ALTER TABLE `trainer_certifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_cert_slug` (`slug`);

--
-- Index pour la table `trainer_certification_links`
--
ALTER TABLE `trainer_certification_links`
  ADD PRIMARY KEY (`trainer_id`,`certification_id`);

--
-- Index pour la table `trainer_cities`
--
ALTER TABLE `trainer_cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_city_slug` (`slug`);

--
-- Index pour la table `trainer_city_links`
--
ALTER TABLE `trainer_city_links`
  ADD PRIMARY KEY (`trainer_id`,`city_id`);

--
-- Index pour la table `trainer_client_links`
--
ALTER TABLE `trainer_client_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_client_link` (`trainer_id`,`client_id`);

--
-- Index pour la table `trainer_client_profiles`
--
ALTER TABLE `trainer_client_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_client_site_email` (`site_id`,`email`);

--
-- Index pour la table `trainer_courses`
--
ALTER TABLE `trainer_courses`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `trainer_expertise_links`
--
ALTER TABLE `trainer_expertise_links`
  ADD PRIMARY KEY (`trainer_id`,`expertise_id`),
  ADD KEY `idx_tel_expertise` (`expertise_id`);

--
-- Index pour la table `trainer_languages`
--
ALTER TABLE `trainer_languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_lang_code` (`code`);

--
-- Index pour la table `trainer_language_links`
--
ALTER TABLE `trainer_language_links`
  ADD PRIMARY KEY (`trainer_id`,`language_id`);

--
-- Index pour la table `trainer_modalities`
--
ALTER TABLE `trainer_modalities`
  ADD PRIMARY KEY (`trainer_id`,`modality`);

--
-- Index pour la table `trainer_portal_accounts`
--
ALTER TABLE `trainer_portal_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_portal_site_email_role` (`site_id`,`email`,`role`);

--
-- Index pour la table `trainer_portal_password_resets`
--
ALTER TABLE `trainer_portal_password_resets`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `trainer_portal_tokens`
--
ALTER TABLE `trainer_portal_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_trainer_portal_tokens_account_expiry` (`account_id`,`expires_at`);

--
-- Index pour la table `trainer_reviews`
--
ALTER TABLE `trainer_reviews`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `trainer_session_bookings`
--
ALTER TABLE `trainer_session_bookings`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `trainer_skills`
--
ALTER TABLE `trainer_skills`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_skill_slug` (`slug`);

--
-- Index pour la table `trainer_skill_links`
--
ALTER TABLE `trainer_skill_links`
  ADD PRIMARY KEY (`trainer_id`,`skill_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_user_email` (`email`);

--
-- Index pour la table `villes`
--
ALTER TABLE `villes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_villes_slug` (`slug`,`site_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `alertes_emploi`
--
ALTER TABLE `alertes_emploi`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `candidats`
--
ALTER TABLE `candidats`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `candidatures`
--
ALTER TABLE `candidatures`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `candidatures_externes`
--
ALTER TABLE `candidatures_externes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `candidature_historique`
--
ALTER TABLE `candidature_historique`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `candidat_tokens`
--
ALTER TABLE `candidat_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT pour la table `career_applications`
--
ALTER TABLE `career_applications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `career_job_offers`
--
ALTER TABLE `career_job_offers`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaches`
--
ALTER TABLE `coaches`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT pour la table `coaching_appointment_slots`
--
ALTER TABLE `coaching_appointment_slots`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `coaching_certifications`
--
ALTER TABLE `coaching_certifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT pour la table `coaching_cities`
--
ALTER TABLE `coaching_cities`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `coaching_client_profiles`
--
ALTER TABLE `coaching_client_profiles`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `coaching_coach_client_links`
--
ALTER TABLE `coaching_coach_client_links`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `coaching_contact_requests`
--
ALTER TABLE `coaching_contact_requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_contact_slots`
--
ALTER TABLE `coaching_contact_slots`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_languages`
--
ALTER TABLE `coaching_languages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT pour la table `coaching_portal_accounts`
--
ALTER TABLE `coaching_portal_accounts`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `coaching_portal_password_resets`
--
ALTER TABLE `coaching_portal_password_resets`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `coaching_portal_tokens`
--
ALTER TABLE `coaching_portal_tokens`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `coaching_session_bookings`
--
ALTER TABLE `coaching_session_bookings`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `coaching_specialties`
--
ALTER TABLE `coaching_specialties`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `competences`
--
ALTER TABLE `competences`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `core_admin_password_resets`
--
ALTER TABLE `core_admin_password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT pour la table `core_sites`
--
ALTER TABLE `core_sites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `demandes_urgentes`
--
ALTER TABLE `demandes_urgentes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `entreprises`
--
ALTER TABLE `entreprises`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `expertises`
--
ALTER TABLE `expertises`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT pour la table `formation_courses`
--
ALTER TABLE `formation_courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=208;

--
-- AUTO_INCREMENT pour la table `formation_course_stats`
--
ALTER TABLE `formation_course_stats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=703;

--
-- AUTO_INCREMENT pour la table `formation_info_blocks`
--
ALTER TABLE `formation_info_blocks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=487;

--
-- AUTO_INCREMENT pour la table `formation_info_points`
--
ALTER TABLE `formation_info_points`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2453;

--
-- AUTO_INCREMENT pour la table `formation_jobs`
--
ALTER TABLE `formation_jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=910;

--
-- AUTO_INCREMENT pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1184;

--
-- AUTO_INCREMENT pour la table `formation_objectives`
--
ALTER TABLE `formation_objectives`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=490;

--
-- AUTO_INCREMENT pour la table `formation_skills`
--
ALTER TABLE `formation_skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1242;

--
-- AUTO_INCREMENT pour la table `gdpr_consents_log`
--
ALTER TABLE `gdpr_consents_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketing_email_logs`
--
ALTER TABLE `marketing_email_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `media_library`
--
ALTER TABLE `media_library`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `metiers`
--
ALTER TABLE `metiers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `newsletter_campaigns`
--
ALTER TABLE `newsletter_campaigns`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `newsletter_events`
--
ALTER TABLE `newsletter_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `newsletter_lists`
--
ALTER TABLE `newsletter_lists`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `offres_emploi`
--
ALTER TABLE `offres_emploi`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `portal_password_resets`
--
ALTER TABLE `portal_password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `recrutement_scoring_config`
--
ALTER TABLE `recrutement_scoring_config`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recrutement_scoring_history`
--
ALTER TABLE `recrutement_scoring_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `recruteurs`
--
ALTER TABLE `recruteurs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `recruteur_activation_tokens`
--
ALTER TABLE `recruteur_activation_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `recruteur_tokens`
--
ALTER TABLE `recruteur_tokens`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `secteurs_activite`
--
ALTER TABLE `secteurs_activite`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_pricing`
--
ALTER TABLE `site_pricing`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT pour la table `system_logs`
--
ALTER TABLE `system_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `trainers`
--
ALTER TABLE `trainers`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `trainer_appointment_slots`
--
ALTER TABLE `trainer_appointment_slots`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `trainer_certifications`
--
ALTER TABLE `trainer_certifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `trainer_cities`
--
ALTER TABLE `trainer_cities`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `trainer_client_links`
--
ALTER TABLE `trainer_client_links`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `trainer_client_profiles`
--
ALTER TABLE `trainer_client_profiles`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `trainer_courses`
--
ALTER TABLE `trainer_courses`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `trainer_languages`
--
ALTER TABLE `trainer_languages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `trainer_portal_accounts`
--
ALTER TABLE `trainer_portal_accounts`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `trainer_portal_password_resets`
--
ALTER TABLE `trainer_portal_password_resets`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `trainer_portal_tokens`
--
ALTER TABLE `trainer_portal_tokens`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT pour la table `trainer_reviews`
--
ALTER TABLE `trainer_reviews`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `trainer_session_bookings`
--
ALTER TABLE `trainer_session_bookings`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `trainer_skills`
--
ALTER TABLE `trainer_skills`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `villes`
--
ALTER TABLE `villes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `formation_course_stats`
--
ALTER TABLE `formation_course_stats`
  ADD CONSTRAINT `fk_formation_stat_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_info_blocks`
--
ALTER TABLE `formation_info_blocks`
  ADD CONSTRAINT `fk_formation_info_block_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_info_points`
--
ALTER TABLE `formation_info_points`
  ADD CONSTRAINT `fk_formation_info_point_block` FOREIGN KEY (`block_id`) REFERENCES `formation_info_blocks` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_objectives`
--
ALTER TABLE `formation_objectives`
  ADD CONSTRAINT `fk_formation_objective_course` FOREIGN KEY (`course_id`) REFERENCES `formation_courses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainers`
--
ALTER TABLE `trainers`
  ADD CONSTRAINT `fk_trainer_expertise` FOREIGN KEY (`primary_expertise_id`) REFERENCES `expertises` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `trainer_expertise_links`
--
ALTER TABLE `trainer_expertise_links`
  ADD CONSTRAINT `fk_tel_expertise` FOREIGN KEY (`expertise_id`) REFERENCES `expertises` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tel_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
