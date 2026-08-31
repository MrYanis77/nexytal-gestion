-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Hôte : db5020658636.hosting-data.io
-- Généré le : mar. 16 juin 2026 à 09:28
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
  `id` int(11) UNSIGNED NOT NULL,
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `metier_id` int(11) UNSIGNED DEFAULT NULL,
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
(1, 4, 'test ', 'test', 'yanislaldjipro@gmail.com', 'test-test', NULL, NULL, 1, '2026-06-11 12:50:39', NULL),
(2, 6, 'yanis', 'laldji', 'yanislaldjipro@gmail.com', 'yanis-laldji', 'dzddzd', '/api/uploads/blog/56de95f9-676b-412a-986f-3cc09a9fe187.webp', 1, '2026-06-16 11:09:25', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_categories`
--

CREATE TABLE `blog_categories` (
  `id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
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
(1, 1, 'blog formation', '', 'csscsc', '', 1, 0, '2026-06-11 12:24:43', NULL),
(2, 3, 'cat médical', 'cat-medical', 'sdsdz', NULL, 0, 0, '2026-06-11 14:33:03', NULL),
(3, 2, 'cat recrutement ', 'cat-recrutement', 'zdzdzd', NULL, 1, 0, '2026-06-11 14:38:39', NULL),
(4, 4, 'edzd', 'edzd', 'dzdz', NULL, 0, 0, '2026-06-11 15:00:45', NULL),
(5, 6, 'zdzdd', 'zdzdd', 'dzdzd', NULL, 0, 0, '2026-06-11 15:01:07', NULL),
(6, 5, 'zdzd', 'zdzd', 'dzd', NULL, 1, 0, '2026-06-11 15:35:16', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_comments`
--

CREATE TABLE `blog_comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `author_name` varchar(150) NOT NULL,
  `author_email` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `status` enum('pending','approved','spam') NOT NULL DEFAULT 'pending',
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
  `cover_image_url` varchar(255) DEFAULT NULL,
  `read_time_mins` int(11) DEFAULT NULL,
  `status` enum('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `views_count` int(11) NOT NULL DEFAULT 0,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_posts`
--

INSERT INTO `blog_posts` (`id`, `site_id`, `category_id`, `author_id`, `title`, `slug`, `excerpt`, `content`, `cover_image_url`, `read_time_mins`, `status`, `is_featured`, `views_count`, `meta_title`, `meta_description`, `published_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(25, 5, 6, NULL, 'test blog', 'test-blog', 'test blog 1', 'test blog 1', '/api/uploads/blog/67bc693b-4cf9-4a36-a09c-292720361a93.png', NULL, 'published', 0, 0, NULL, NULL, '2026-06-15 16:12:22', '2026-06-15 16:12:22', NULL, NULL),
(26, 6, 5, NULL, 'test blog ', 'test-blog', 'hebdhebdhebhbf', 'hbedhebhbehbdehbd', '/api/uploads/blog/38f59d70-6314-4a5b-89d3-b679ee929492.png', NULL, 'published', 0, 0, NULL, NULL, '2026-06-16 00:11:16', '2026-06-16 00:11:16', NULL, NULL),
(27, 4, 4, NULL, 'test blog carrière', 'test-blog-carriere', 'ncjebehbfhceh', 'fenfjkemdnfvmsnmjlndsmnvjmkkvns', '/api/uploads/blog/b7cdb972-3926-4217-a18e-13161201b3f6.png', NULL, 'published', 0, 0, NULL, NULL, '2026-06-16 00:00:00', '2026-06-16 00:36:19', '2026-06-16 00:46:28', NULL),
(28, 4, 4, NULL, 'test blog oui', 'test-blog-oui', 'edhehde', 'djzndjzdnkzdzk', '/api/uploads/blog/b26e047e-b423-449e-9101-a0e9c5d296e9.png', NULL, 'published', 0, 0, NULL, NULL, '2026-06-16 00:48:33', '2026-06-16 00:48:33', NULL, NULL),
(29, 4, 4, NULL, 'test blog yanis', 'test-blog-yanis', 'jhgkbjgkgj', 'jgjhfgjf', '/api/uploads/blog/289b9dce-5ef3-48ec-96e9-ed80e9880fe0.jpg', NULL, 'published', 0, 0, NULL, NULL, '2026-06-16 09:25:02', '2026-06-16 09:25:02', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `blog_posts_versions`
--

CREATE TABLE `blog_posts_versions` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `status` enum('draft','review','published','archived') NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `blog_posts_versions`
--

INSERT INTO `blog_posts_versions` (`id`, `post_id`, `title`, `content`, `status`, `created_by`, `created_at`) VALUES
(3, 27, 'test blog carrière', 'fenfjkemdnfvmsnmjlndsmnvjmkkvns', 'published', 1, '2026-06-16 00:46:28');

-- --------------------------------------------------------

--
-- Structure de la table `blog_post_tags`
--

CREATE TABLE `blog_post_tags` (
  `post_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(1, 1, 'tag formation', '', '2026-06-11 12:24:24'),
(2, 4, 'super', 'super', '2026-06-16 11:08:55');

-- --------------------------------------------------------

--
-- Structure de la table `candidats`
--

CREATE TABLE `candidats` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `date_naissance` date DEFAULT NULL,
  `situation_professionnelle` enum('salarie','demandeur_emploi','independant','cadre_reconversion','parent_reprise','autre') DEFAULT NULL,
  `resume_court` varchar(500) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `mobilite_km` smallint(6) DEFAULT NULL,
  `teletravail_souhaite` enum('non','partiel','total','indifferent') DEFAULT 'indifferent',
  `disponibilite` date DEFAULT NULL,
  `recherche_active` tinyint(1) NOT NULL DEFAULT 1,
  `salaire_souhaite_min` int(11) UNSIGNED DEFAULT NULL,
  `type_contrat_souhaite` set('cdi','cdd','interim','alternance','freelance','stage') DEFAULT NULL,
  `rgpd_consent_at` datetime NOT NULL,
  `profil_public` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidats`
--

INSERT INTO `candidats` (`id`, `user_id`, `prenom`, `nom`, `telephone`, `date_naissance`, `situation_professionnelle`, `resume_court`, `ville`, `code_postal`, `region`, `mobilite_km`, `teletravail_souhaite`, `disponibilite`, `recherche_active`, `salaire_souhaite_min`, `type_contrat_souhaite`, `rgpd_consent_at`, `profil_public`, `created_at`, `updated_at`, `deleted_at`) VALUES
(15, 1, 'dzdzd', 'zdzd', '0782124452', '2026-06-11', 'salarie', 'dzdz', 'Villevaudé', '77410', 'dzd', 22, 'non', '2026-06-11', 1, 1, '', '2026-06-11 15:44:39', 1, '2026-06-11 15:44:39', '2026-06-11 15:44:39', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `candidatures`
--

CREATE TABLE `candidatures` (
  `id` int(11) UNSIGNED NOT NULL,
  `offre_id` int(11) UNSIGNED NOT NULL,
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `message_motivation` text DEFAULT NULL,
  `notes_recruteur` text DEFAULT NULL,
  `statut` enum('recue','vue','shortlist','entretien','offre','refusee','retiree') NOT NULL DEFAULT 'recue',
  `source` enum('site','bilan','alerte','recommandation') NOT NULL DEFAULT 'site',
  `date_candidature` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidatures`
--

INSERT INTO `candidatures` (`id`, `offre_id`, `candidat_id`, `message_motivation`, `notes_recruteur`, `statut`, `source`, `date_candidature`, `updated_at`) VALUES
(1, 1, 15, 'dzdzdzdz', 'ddzdz', 'recue', 'site', '2026-06-11 15:44:56', '2026-06-11 15:44:56'),
(2, 2, 15, 'ddzdz', 'dzd', 'recue', 'site', '2026-06-11 15:45:23', '2026-06-11 15:45:23');

-- --------------------------------------------------------

--
-- Structure de la table `candidatures_externes`
--

CREATE TABLE `candidatures_externes` (
  `id` int(11) UNSIGNED NOT NULL,
  `offre_id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `lettre_motivation` text DEFAULT NULL,
  `linkedin_url` varchar(500) DEFAULT NULL,
  `statut` enum('recue','vue','shortlist','entretien','offre','refusee') NOT NULL DEFAULT 'recue',
  `rgpd_consent_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `candidatures_externes`
--

INSERT INTO `candidatures_externes` (`id`, `offre_id`, `site_id`, `prenom`, `nom`, `email`, `telephone`, `lettre_motivation`, `linkedin_url`, `statut`, `rgpd_consent_at`, `created_at`) VALUES
(1, 2, 2, 'zdzd', 'dzd', 'yanislaldjipro@gmail.com', '0782124452', 'dzd', 'zdzd', 'recue', '2026-06-11 15:42:39', '2026-06-11 15:42:39'),
(2, 1, 3, 'ddzd', 'dzd', 'dzdz', '0782124452', 'dzdz', 'zzd', 'recue', '2026-06-11 15:42:49', '2026-06-11 15:42:49');

-- --------------------------------------------------------

--
-- Structure de la table `candidature_historique`
--

CREATE TABLE `candidature_historique` (
  `id` int(11) UNSIGNED NOT NULL,
  `candidature_id` int(11) UNSIGNED NOT NULL,
  `ancien_statut` varchar(50) DEFAULT NULL,
  `nouveau_statut` varchar(50) NOT NULL,
  `commentaire` text DEFAULT NULL,
  `auteur_user_id` int(11) UNSIGNED DEFAULT NULL,
  `auteur_admin_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_competences`
--

CREATE TABLE `candidat_competences` (
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `niveau` enum('debutant','intermediaire','confirme','expert') NOT NULL DEFAULT 'intermediaire',
  `annees` tinyint(3) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_experiences`
--

CREATE TABLE `candidat_experiences` (
  `id` int(11) UNSIGNED NOT NULL,
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `metier_id` int(11) UNSIGNED DEFAULT NULL,
  `entreprise` varchar(200) NOT NULL,
  `poste` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date DEFAULT NULL,
  `en_cours` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_formations`
--

CREATE TABLE `candidat_formations` (
  `id` int(11) UNSIGNED NOT NULL,
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `diplome` varchar(200) NOT NULL,
  `etablissement` varchar(200) DEFAULT NULL,
  `annee_obtention` smallint(6) DEFAULT NULL,
  `niveau` enum('cap','bac','bac+2','bac+3','bac+5','doctorat','certification') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `candidat_metiers_souhaites`
--

CREATE TABLE `candidat_metiers_souhaites` (
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `metier_id` int(11) UNSIGNED NOT NULL,
  `priorite` tinyint(4) NOT NULL DEFAULT 1,
  `source` enum('bilan','manuel','suggestion') NOT NULL DEFAULT 'manuel'
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
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaches`
--

INSERT INTO `coaches` (`id`, `site_id`, `slug`, `first_name`, `last_name`, `title`, `bio_short`, `bio_full`, `avatar_url`, `avatar_initials`, `city_id`, `email`, `phone`, `linkedin_url`, `experience_years`, `status`, `is_featured`, `sort_order`, `published_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 6, 'yanis-laldji', 'yanis', 'laldji', 'test ', 'bonjour', 'feuhbdsbsbd', '/api/uploads/media/5c8f3b63-39c4-4312-9cb1-100f363d68bf.png', 'yl', 1, 'yanislaldjipro@gmail.com', '0782124452', NULL, 5, 'active', 0, 0, NULL, '2026-06-15 16:46:42', NULL, NULL);

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
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_appointment_slots`
--

INSERT INTO `coaching_appointment_slots` (`id`, `site_id`, `slot_date`, `start_time`, `end_time`, `coach_id`, `capacity`, `booked_count`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 6, '2026-06-16', '09:00:00', '09:30:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL),
(2, 6, '2026-06-16', '10:30:00', '11:00:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL),
(3, 6, '2026-06-16', '14:00:00', '14:30:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL),
(4, 6, '2026-06-17', '09:00:00', '09:30:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL),
(5, 6, '2026-06-17', '11:00:00', '11:30:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL),
(6, 6, '2026-06-17', '14:30:00', '15:00:00', NULL, 1, 0, 1, '2026-06-15 14:26:28', NULL);

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
(1, 'icf-mcc', 'ICF MCC', 1),
(2, 'icf-pcc', 'ICF PCC', 2),
(3, 'icf-acc', 'ICF ACC', 3),
(4, 'emcc', 'EMCC', 4);

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
(1, 'paris', 'Paris', 'Île-de-France', 1),
(2, 'lyon', 'Lyon', 'Auvergne-Rhône-Alpes', 1);

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
  `rgpd_consent_ip` varchar(45) DEFAULT NULL,
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
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_contact_slots`
--

INSERT INTO `coaching_contact_slots` (`id`, `site_id`, `slug`, `label`, `description`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 6, 'matin', 'Matin (9h-12h)', 'Créneau matinal pour le diagnostic', 1, 1, '2026-06-15 14:26:28', NULL),
(2, 6, 'midi', 'Midi (12h-14h)', 'Pause déjeuner', 2, 1, '2026-06-15 14:26:28', NULL),
(3, 6, 'apres-midi', 'Après-midi (14h-18h)', 'Créneau après-midi', 3, 1, '2026-06-15 14:26:28', NULL),
(4, 6, 'soir', 'Fin de journée (18h-19h)', 'Fin de journée', 4, 1, '2026-06-15 14:26:28', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `coaching_diagnostic_requests`
--

CREATE TABLE `coaching_diagnostic_requests` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `appointment_slot_id` int(11) UNSIGNED DEFAULT NULL,
  `slot_label` varchar(200) DEFAULT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `telephone` varchar(25) DEFAULT NULL,
  `profil` varchar(50) NOT NULL,
  `statut` enum('nouveau','confirme','annule','termine') NOT NULL DEFAULT 'nouveau',
  `rgpd_consent_at` datetime NOT NULL,
  `rgpd_consent_ip` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
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
(1, 'fr', 'Français', '🇫🇷'),
(2, 'en', 'Anglais', '🇬🇧'),
(3, 'de', 'Allemand', '🇩🇪'),
(4, 'es', 'Espagnol', '🇪🇸'),
(5, 'it', 'Italien', '🇮🇹');

-- --------------------------------------------------------

--
-- Structure de la table `coaching_specialties`
--

CREATE TABLE `coaching_specialties` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `name` varchar(120) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `coaching_specialties`
--

INSERT INTO `coaching_specialties` (`id`, `slug`, `name`, `sort_order`, `is_active`, `created_at`) VALUES
(1, 'dirigeants', 'Dirigeants', 1, 1, '2026-06-15 14:26:28'),
(2, 'managers', 'Managers', 2, 1, '2026-06-15 14:26:28'),
(3, 'equipes', 'Équipes', 3, 1, '2026-06-15 14:26:28'),
(4, 'reconversion', 'Reconversion', 4, 1, '2026-06-15 14:26:28'),
(5, 'transformation', 'Transformation', 5, 1, '2026-06-15 14:26:28'),
(6, 'salaries', 'Salariés', 6, 1, '2026-06-15 14:26:28'),
(7, 'stress', 'Stress', 7, 1, '2026-06-15 14:26:28'),
(8, 'test', 'test', 0, 1, '2026-06-15 23:50:38');

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
(1, 3);

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
(1, 1);

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
(1, 2);

-- --------------------------------------------------------

--
-- Structure de la table `competences`
--

CREATE TABLE `competences` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(100) NOT NULL,
  `label` varchar(150) NOT NULL,
  `categorie` enum('technique','soft_skill','langue','outil','certification') NOT NULL DEFAULT 'technique'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `competences`
--

INSERT INTO `competences` (`id`, `slug`, `label`, `categorie`) VALUES
(1, 'dzdzd', 'dzdzd', 'technique'),
(2, 'dzdzddqdezdsqd', 'dzdzddqdezdsqd', 'technique'),
(3, 'dzzdz', 'dzzdz', 'technique');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_password_resets`
--

CREATE TABLE `core_admin_password_resets` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_sessions`
--

CREATE TABLE `core_admin_sessions` (
  `id` varchar(128) NOT NULL,
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
('069e470544f2ded560441974780807d6b78b137c28612fe4d46572dae5800c27', 1, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', 'node', '2026-06-12 15:31:50', '2026-06-11 15:31:50'),
('0f9e2f05eeabed31935d8a6cbda292c995ae3ec6e95a2d10cfe128337a44b573', 1, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-16 15:58:45', '2026-06-15 15:58:45'),
('1a85cde90e7a4b6ba01b59200a45a108a4f6ffcfc52a723c0a642ecef7cf597f', 1, '2a01:cb09:b06d:1296:40a6:5c61:11fa:1e3f', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-16 01:08:14', '2026-06-15 01:08:14'),
('4d508a5900d060ecdca8203c1390ec0b583a533e148b451eda541fae39b5f791', 1, '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-16 11:19:37', '2026-06-15 11:19:37'),
('98189b6daa3d7bc9e53ec1e85148117992184dffc7cc7245f8c7456c8eafdd7d', 1, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', 'node', '2026-06-12 15:05:22', '2026-06-11 15:05:22'),
('be129a8bb394e1b2a96e79b3ed9a54d7cf478f026a0d4a351c8c0d13a5c25755', 1, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 15:32:36', '2026-06-11 15:32:36'),
('beb987d8dd07bd8a4d98d7d62dfce20ace1e7ac4c05bbf29650855796b091c9c', 1, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', 'node', '2026-06-12 15:05:42', '2026-06-11 15:05:42'),
('c197935990f0616ce9cd94809ab313867a3e3e8bf12f030e164ff86ec39eba0a', 1, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 12:24:10', '2026-06-11 12:24:10');

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_site_access`
--

CREATE TABLE `core_admin_site_access` (
  `admin_id` int(11) NOT NULL,
  `site_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_admin_site_access`
--

INSERT INTO `core_admin_site_access` (`admin_id`, `site_id`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6);

-- --------------------------------------------------------

--
-- Structure de la table `core_admin_users`
--

CREATE TABLE `core_admin_users` (
  `id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `role` enum('superadmin','admin','editor','moderator','recruiter','seo') NOT NULL DEFAULT 'editor',
  `avatar_url` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_admin_users`
--

INSERT INTO `core_admin_users` (`id`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `avatar_url`, `is_active`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'admin@nexytal.com', '$2y$12$K9JcPW/dJXz/059N7EQZHes9zCc.PppjSdrgPgz2pA82zf7orlkpO', 'Super', 'Admin', 'superadmin', NULL, 1, '2026-06-15 15:58:45', '2026-06-11 10:17:35', '2026-06-15 15:58:45');

-- --------------------------------------------------------

--
-- Structure de la table `core_audit_logs`
--

CREATE TABLE `core_audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `site_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `entity_id` int(11) DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_audit_logs`
--

INSERT INTO `core_audit_logs` (`id`, `admin_id`, `site_id`, `action`, `entity_type`, `entity_id`, `old_data`, `new_data`, `ip_address`, `created_at`) VALUES
(1, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:20:27'),
(2, 1, NULL, 'login_failed', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:24:06'),
(3, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:24:10'),
(4, 1, 1, 'create', 'blog_tag', 1, NULL, '{\"name\":\"tag formation\",\"slug\":\"\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:24:24'),
(5, 1, 1, 'create', 'blog_category', 1, NULL, '{\"name\":\"blog formation\",\"slug\":\"\",\"description\":\"csscsc\",\"color\":\"\",\"is_active\":true}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:24:43'),
(6, 1, NULL, 'update', 'admin_user', 1, '{\"id\":1,\"email\":\"admin@nexytal.com\",\"first_name\":\"Super\",\"last_name\":\"Admin\",\"role\":\"superadmin\",\"avatar_url\":null,\"is_active\":1,\"last_login\":\"2026-06-11 12:24:10\",\"created_at\":\"2026-06-11 10:17:35\",\"updated_at\":\"2026-06-11 12:24:10\"}', '{\"email\":\"admin@nexytal.com\",\"first_name\":\"Super\",\"last_name\":\"Admin\",\"role\":\"superadmin\",\"is_active\":1,\"site_ids\":[1,2,3,4,5,6]}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:46:23'),
(7, 1, NULL, 'logout', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:46:25'),
(8, 1, NULL, 'login_failed', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:46:32'),
(9, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:46:36'),
(10, 1, NULL, 'update', 'admin_user', 1, '{\"id\":1,\"email\":\"admin@nexytal.com\",\"first_name\":\"Super\",\"last_name\":\"Admin\",\"role\":\"superadmin\",\"avatar_url\":null,\"is_active\":1,\"last_login\":\"2026-06-11 12:46:36\",\"created_at\":\"2026-06-11 10:17:35\",\"updated_at\":\"2026-06-11 12:46:36\"}', '{\"email\":\"admin@nexytal.com\",\"first_name\":\"Super\",\"last_name\":\"Admin\",\"role\":\"superadmin\",\"is_active\":1,\"site_ids\":[1,2,3,4,5,6]}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:46:48'),
(11, 1, 4, 'create', 'blog_author', 1, NULL, '{\"first_name\":\"test \",\"last_name\":\"test\",\"email\":\"yanislaldjipro@gmail.com\",\"bio\":null,\"avatar_url\":null,\"is_active\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 12:50:39'),
(12, 1, 1, 'create', 'formation_category', 1, NULL, '{\"label\":\"TEST\",\"description\":null,\"catalogue_type\":\"all\",\"is_active\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:30:11'),
(13, 1, 1, 'create', 'blog_post', 1, NULL, '{\"title\":\"test\",\"excerpt\":\"ddd\",\"content\":\"sdsdsds\",\"category_id\":1,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2004-06-18 00:00:00\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:31:32'),
(14, 1, 1, 'create', 'formation', 1, NULL, '{\"hero_title\":\"test formatio\",\"hero_subtitle\":null,\"type\":\"longue\",\"category_id\":1,\"hero_image_url\":null,\"card_image_url\":null,\"presentation_image\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"sdsd\",\"presentation_content\":\"sdsd\",\"programme_duration_label\":null,\"methodology\":\"dsd\",\"certification_label\":\"dsds\",\"evaluation_title\":\"sds\",\"evaluation_description\":\"sdsd\",\"debouches_title\":\"sdsd\",\"debouches_subtitle\":\"sdsd\",\"debouches_sectors\":\"sdsd\",\"info_modalities_title\":\"sdsd\",\"info_prerequisites_title\":\"sdsd\",\"cta_title\":\"sdsd\",\"cta_subtitle\":\"sdsdsdsd\",\"cta_button_label\":\"sdsd\",\"cta_button_url\":null,\"cta_secondary_label\":\"sdsdsd\",\"cta_secondary_url\":null,\"status\":\"published\",\"published_at\":\"2026-06-26 00:00:00\",\"official_certification\":{\"repertoire\":\"RNCP\",\"code\":\"625622\",\"official_title\":\"sdsdsd\",\"level\":5,\"france_competences_url\":\"https:\\/\\/www.francecompetences.fr\",\"show_on_certification_page\":1}}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:32:21'),
(15, 1, 1, 'update', 'formation', 1, '{\"id\":1,\"site_id\":1,\"slug\":\"test-formatio\",\"type\":\"longue\",\"category_id\":1,\"status\":\"published\",\"published_at\":\"2026-06-11 14:32:21\",\"hero_title\":\"test formatio\",\"hero_subtitle\":null,\"hero_video_url\":null,\"hero_image_url\":null,\"card_image_url\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"sdsd\",\"presentation_content\":\"sdsd\",\"presentation_image\":null,\"programme_duration_label\":null,\"modalites_catalogue\":null,\"methodology\":\"dsd\",\"certification_label\":\"dsds\",\"evaluation_title\":\"sds\",\"evaluation_description\":\"sdsd\",\"debouches_title\":\"sdsd\",\"debouches_subtitle\":\"sdsd\",\"debouches_sectors\":\"sdsd\",\"info_modalities_title\":\"sdsd\",\"info_prerequisites_title\":\"sdsd\",\"cta_title\":\"sdsd\",\"cta_subtitle\":\"sdsdsdsd\",\"cta_button_label\":\"sdsd\",\"cta_button_url\":\"\\/contact\",\"cta_secondary_label\":\"sdsdsd\",\"cta_secondary_url\":null,\"internal_reference\":null,\"sort_order\":0,\"created_by\":1,\"updated_by\":1,\"created_at\":\"2026-06-11 14:32:21\",\"updated_at\":\"2026-06-11 14:32:21\"}', '{\"hero_title\":\"test formatio\",\"hero_subtitle\":null,\"type\":\"longue\",\"category_id\":1,\"hero_image_url\":null,\"card_image_url\":null,\"presentation_image\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"sdsd\",\"presentation_content\":\"sdsd\",\"programme_duration_label\":\"6\",\"methodology\":\"dsd\",\"certification_label\":\"dsds\",\"evaluation_title\":\"sds\",\"evaluation_description\":\"sdsd\",\"debouches_title\":\"sdsd\",\"debouches_subtitle\":\"sdsd\",\"debouches_sectors\":\"sdsd\",\"info_modalities_title\":\"sdsd\",\"info_prerequisites_title\":\"sdsd\",\"cta_title\":\"sdsd\",\"cta_subtitle\":\"sdsdsdsd\",\"cta_button_label\":\"sdsd\",\"cta_button_url\":\"\\/contact\",\"cta_secondary_label\":\"sdsdsd\",\"cta_secondary_url\":null,\"status\":\"published\",\"published_at\":\"2026-06-11 00:00:00\",\"official_certification\":{\"repertoire\":\"RNCP\",\"code\":\"5655\",\"official_title\":\"test formatio\",\"level\":null,\"france_competences_url\":\"https:\\/\\/www.francecompetences.fr\",\"show_on_certification_page\":1}}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:32:45'),
(16, 1, 3, 'create', 'blog_category', 2, NULL, '{\"name\":\"cat médical\",\"description\":\"sdsdz\",\"is_active\":false}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:33:03'),
(17, 1, 3, 'create', 'blog_post', 2, NULL, '{\"title\":\"article médical\",\"excerpt\":\"dzdz\",\"content\":\"dzd\",\"category_id\":2,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"6565-06-18 00:00:00\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:33:47'),
(18, 1, 2, 'create', 'blog_category', 3, NULL, '{\"name\":\"cat recrutement \",\"description\":\"zdzdzd\",\"is_active\":true}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:38:39'),
(19, 1, 1, 'create', 'formation', 2, NULL, '{\"hero_title\":\"zdzd\",\"hero_subtitle\":\"dzdzdz\",\"type\":\"longue\",\"category_id\":1,\"hero_image_url\":null,\"card_image_url\":null,\"presentation_image\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"dzd\",\"presentation_content\":\"dzd\",\"programme_duration_label\":\"6\",\"methodology\":\"zdzd\",\"certification_label\":\"zdz\",\"evaluation_title\":\"dzdz\",\"evaluation_description\":\"dzdz\",\"debouches_title\":\"zddzd\",\"debouches_subtitle\":\"zdzd\",\"debouches_sectors\":\"dzzd\",\"status\":\"published\",\"published_at\":\"2026-06-24 00:00:00\",\"list_items\":[{\"list_type\":\"info_modalite\",\"content\":\"zdzd\",\"sort_order\":0},{\"list_type\":\"info_prerequis\",\"content\":\"zdzd\",\"sort_order\":0}],\"official_certification\":{\"repertoire\":\"RNCP\",\"code\":\"zdzd\",\"official_title\":\"dzdz\",\"level\":5,\"france_competences_url\":\"https:\\/\\/www.francecompetences.fr\",\"show_on_certification_page\":1}}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:49:50'),
(20, 1, 1, 'create', 'competence', 1, NULL, '{\"label\":\"dzdzd\",\"categorie\":\"technique\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:55:45'),
(21, 1, 1, 'create', 'secteur_activite', 1, NULL, '{\"label\":\"dzdzd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:55:49'),
(22, 1, 1, 'create', 'entreprise', 1, NULL, '{\"nom\":\"dzdzdzd\",\"siret\":null,\"description\":\"dzdzd\",\"taille\":\"1-10\",\"secteur_id\":1,\"adresse\":\"ddzdz\",\"code_postal\":\"zdzd\",\"ville\":\"zdzd\",\"validee\":0}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:57:15'),
(23, 1, 3, 'create', 'offre_emploi', 1, NULL, '{\"titre\":\"zdddz\",\"reference\":null,\"entreprise_id\":1,\"metier_id\":null,\"recruteur_id\":null,\"type_contrat\":\"cdi\",\"description\":\"dzd\",\"profil_recherche\":\"dzdzdz\",\"avantages\":\"zdzdz\",\"experience_min\":\"1-2\",\"salaire_min\":3151,\"salaire_max\":415149,\"salaire_afficher\":0,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"dzd\",\"code_postal\":\"zdzd\",\"departement\":\"zdzd\",\"region\":\"zdzd\",\"is_urgent\":0,\"is_featured\":0,\"statut\":\"publiee\",\"date_publication\":\"2026-06-18 00:00:00\",\"date_expiration\":\"2026-06-22 23:59:59\",\"meta_title\":null,\"meta_description\":null,\"competences_text\":\"dzdzddqdezdsqd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:57:55'),
(24, 1, 1, 'create', 'secteur_activite', 2, NULL, '{\"label\":\"sdzdzdz\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 14:58:44'),
(25, 1, 4, 'create', 'blog_category', 4, NULL, '{\"name\":\"edzd\",\"description\":\"dzdz\",\"is_active\":false}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:00:45'),
(26, 1, 4, 'create', 'blog_post', 3, NULL, '{\"title\":\"zdzdzd\",\"excerpt\":\"zdzd\",\"content\":\"zdzdzd\",\"category_id\":4,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-23 00:00:00\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:01'),
(27, 1, 6, 'create', 'blog_category', 5, NULL, '{\"name\":\"zdzdd\",\"description\":\"dzdzd\",\"is_active\":false}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:07'),
(28, 1, 6, 'create', 'blog_post', 4, NULL, '{\"title\":\"dzdzd\",\"excerpt\":\"dzdzd\",\"content\":\"dzdzd\",\"category_id\":5,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-24 00:00:00\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:21'),
(29, 1, 5, 'create', 'trainer_language', 1, NULL, '{\"name\":\"zdzd\",\"code\":\"zd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:31'),
(30, 1, 5, 'create', 'trainer_certifications', 1, NULL, '{\"name\":\"dzdzdzd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:35'),
(31, 1, 5, 'create', 'trainer_city', 1, NULL, '{\"name\":\"ddzdz\",\"region\":\"zdzd\",\"description\":\"zdzd\",\"is_active\":0}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:39'),
(32, 1, 5, 'create', 'trainer_skills', 1, NULL, '{\"name\":\"dzdzdzd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:43'),
(33, 1, 1, 'create', 'expertise', 1, NULL, '{\"label\":\"zdzdzd\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:01:47'),
(34, 1, 5, 'create', 'trainer', 1, NULL, '{\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"avatar_url\":\"zdzdzd\",\"experience_years\":4,\"tjm_eur\":565265,\"availability\":\"soon\",\"legal_status\":\"sasu\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzdzd\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:02:10'),
(35, 1, 5, 'update', 'trainer', 1, '{\"id\":1,\"slug\":\"dzd-zdzd\",\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"bio\":\"dzdzd\",\"avatar_initials\":null,\"avatar_url\":\"zdzdzd\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"565265.00\",\"availability\":\"soon\",\"legal_status\":\"sasu\",\"primary_expertise_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-11 15:02:10\",\"created_at\":\"2026-06-11 15:02:10\",\"updated_at\":\"2026-06-11 15:02:10\",\"deleted_at\":null}', '{\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"avatar_url\":\"zdzdzd\",\"experience_years\":4,\"tjm_eur\":565265,\"availability\":\"soon\",\"legal_status\":\"sasu\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzdzd\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:02:18'),
(36, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:05:22'),
(37, 1, 1, 'create', 'metier', 1, NULL, '{\"libelle\":\"Test metier libelle\",\"site_id\":2}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:05:22'),
(38, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:05:42'),
(39, 1, 1, 'create', 'metier', 2, NULL, '{\"libelle\":\"métier test\",\"description\":\"dzdzd\",\"secteur_id\":1,\"site_id\":3,\"code_rome\":null,\"famille_metier\":\"dzdz\",\"niveau_etudes\":\"dzd\",\"perspectives\":\"zdzd\",\"actif\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:27:44'),
(40, 1, 1, 'create', 'metier', 3, NULL, '{\"libelle\":\"dzdzdz\",\"description\":\"dzd\",\"secteur_id\":2,\"site_id\":2,\"code_rome\":\"zdzdz\",\"famille_metier\":\"dzdd\",\"niveau_etudes\":\"dzdz\",\"perspectives\":\"zdz\",\"actif\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:28:27'),
(41, 1, 5, 'update', 'trainer', 1, '{\"id\":1,\"slug\":\"dzd-zdzd\",\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"bio\":\"dzdzd\",\"avatar_initials\":null,\"avatar_url\":\"zdzdzd\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"565265.00\",\"availability\":\"soon\",\"legal_status\":\"sasu\",\"primary_expertise_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-11 15:02:10\",\"created_at\":\"2026-06-11 15:02:10\",\"updated_at\":\"2026-06-11 15:02:18\",\"deleted_at\":null}', '{\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"avatar_url\":\"zdzdzd\",\"experience_years\":4,\"tjm_eur\":565265,\"availability\":\"soon\",\"legal_status\":\"sasu\",\"linkedin_url\":null,\"status\":\"inactive\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzdzd\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:28:44'),
(42, 1, 5, 'create', 'trainer', 3, NULL, '{\"first_name\":\"dzd\",\"last_name\":\"zdzddzd\",\"title\":\"zdzdzdzd\",\"tagline\":\"dzdzd\",\"email\":\"zdzd@gmail.com\",\"phone\":\"0421424\",\"avatar_url\":\"dzdzdz\",\"experience_years\":5,\"tjm_eur\":4100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzzddz\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:29:29'),
(43, 1, 5, 'update', 'trainer', 3, '{\"id\":3,\"slug\":\"dzd-zdzddzd\",\"first_name\":\"dzd\",\"last_name\":\"zdzddzd\",\"title\":\"zdzdzdzd\",\"tagline\":\"dzdzd\",\"bio\":\"dzzddz\",\"avatar_initials\":null,\"avatar_url\":\"dzdzdz\",\"city_id\":null,\"experience_years\":5,\"tjm_eur\":\"4100.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":1,\"email\":\"zdzd@gmail.com\",\"phone\":\"0421424\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-11 15:29:29\",\"created_at\":\"2026-06-11 15:29:29\",\"updated_at\":\"2026-06-11 15:29:29\",\"deleted_at\":null}', '{\"first_name\":\"dzdzdzdzd\",\"last_name\":\"zdzddzd\",\"title\":\"zdzdzdzd\",\"tagline\":\"dzdzd\",\"email\":\"zdzd@gmail.com\",\"phone\":\"0421424\",\"avatar_url\":\"dzdzdz\",\"experience_years\":5,\"tjm_eur\":4100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzzddz\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:30:12'),
(44, 1, 1, 'create', 'newsletter_campaign', 1, NULL, '{\"subject\":\"dsdsd\",\"list_id\":1,\"preview_text\":\"dsdz\",\"content_html\":\"dzdzdzd\",\"status\":\"draft\",\"scheduled_at\":\"2026-06-18\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:31:27'),
(45, 1, NULL, 'logout', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:31:45'),
(46, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:31:50'),
(47, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:32:36'),
(48, 1, 1, 'create', 'formation_category', 2, NULL, '{\"label\":\"e learning\",\"description\":null,\"catalogue_type\":\"all\",\"is_active\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:32:50'),
(49, 1, 1, 'create', 'formation_category', 3, NULL, '{\"label\":\"certifiante\",\"description\":null,\"catalogue_type\":\"all\",\"is_active\":0}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:33:02'),
(50, 1, 1, 'create', 'formation_category', 4, NULL, '{\"label\":\"Diplômantes\",\"description\":null,\"catalogue_type\":\"all\",\"is_active\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:33:19'),
(51, 1, 1, 'update', 'formation_category', 3, '{\"id\":3,\"site_id\":1,\"slug\":\"certifiante\",\"label\":\"certifiante\",\"description\":null,\"catalogue_type\":\"all\",\"sort_order\":0,\"is_active\":0,\"created_at\":\"2026-06-11 15:33:02\",\"updated_at\":\"2026-06-11 15:33:02\"}', '{\"label\":\"certifiante\",\"description\":null,\"catalogue_type\":\"all\",\"is_active\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:33:23'),
(52, 1, 5, 'create', 'blog_category', 6, NULL, '{\"name\":\"zdzd\",\"description\":\"dzd\",\"is_active\":true}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:35:16'),
(53, 1, 2, 'create', 'offre_emploi', 2, NULL, '{\"titre\":\"zdzzdz\",\"reference\":null,\"entreprise_id\":1,\"metier_id\":3,\"recruteur_id\":null,\"type_contrat\":\"cdi\",\"description\":\"dzdzd\",\"profil_recherche\":\"dzdz\",\"avantages\":\"zdzdz\",\"experience_min\":\"debutant\",\"salaire_min\":656554,\"salaire_max\":5156143,\"salaire_afficher\":1,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"dzdz\",\"code_postal\":\"zdz\",\"departement\":\"dzd\",\"region\":\"zdzd\",\"is_urgent\":1,\"is_featured\":1,\"statut\":\"publiee\",\"date_publication\":\"2026-06-10 00:00:00\",\"date_expiration\":\"2026-06-25 23:59:59\",\"meta_title\":null,\"meta_description\":null,\"competences_text\":\"dzzdz\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:39:49'),
(54, 1, 2, 'create', 'candidature_externe', 1, NULL, '{\"offre_id\":2,\"prenom\":\"zdzd\",\"nom\":\"dzd\",\"email\":\"yanislaldjipro@gmail.com\",\"telephone\":\"0782124452\",\"linkedin_url\":\"zdzd\",\"lettre_motivation\":\"dzd\",\"statut\":\"recue\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:42:39'),
(55, 1, 3, 'create', 'candidature_externe', 2, NULL, '{\"offre_id\":1,\"prenom\":\"ddzd\",\"nom\":\"dzd\",\"email\":\"dzdz\",\"telephone\":\"0782124452\",\"linkedin_url\":\"zzd\",\"lettre_motivation\":\"dzdz\",\"statut\":\"recue\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:42:49'),
(56, 1, 1, 'create', 'user', 1, NULL, '{\"email\":\"zddzd@gmail.com\",\"role\":\"candidat\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:44:39'),
(57, 1, 1, 'create', 'candidat', 15, NULL, '{\"prenom\":\"dzdzd\",\"nom\":\"zdzd\",\"email\":\"zddzd@gmail.com\",\"user_id\":1,\"telephone\":\"0782124452\",\"date_naissance\":\"2026-06-11\",\"situation_professionnelle\":\"salarie\",\"resume_court\":\"dzdz\",\"ville\":\"Villevaudé\",\"code_postal\":\"77410\",\"region\":\"dzd\",\"mobilite_km\":22,\"teletravail_souhaite\":\"non\",\"disponibilite\":\"2026-06-11\",\"recherche_active\":1,\"salaire_souhaite_min\":1,\"type_contrat_souhaite\":\"ddz\",\"profil_public\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:44:39'),
(58, 1, 3, 'create', 'candidature', 1, NULL, '{\"offre_id\":1,\"candidat_id\":15,\"statut\":\"recue\",\"notes_recruteur\":\"ddzdz\",\"message_motivation\":\"dzdzdzdz\",\"source\":\"site\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:44:56'),
(59, 1, 2, 'create', 'candidature', 2, NULL, '{\"offre_id\":2,\"candidat_id\":15,\"statut\":\"recue\",\"notes_recruteur\":\"dzd\",\"message_motivation\":\"ddzdz\",\"source\":\"site\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:45:23'),
(60, 1, 5, 'create', 'trainer_review', 1, NULL, '{\"trainer_id\":3,\"author_name\":\"dzdzd\",\"company\":\"zdzd\",\"rating\":4,\"comment\":\"zzddzd\",\"is_published\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:45:35'),
(61, 1, 5, 'create', 'blog_post', 5, NULL, '{\"title\":\"dzdzd\",\"excerpt\":\"zdzd\",\"content\":\"zdzd\",\"category_id\":6,\"cover_image_url\":null,\"is_featured\":1,\"status\":\"published\",\"published_at\":\"2026-06-30 00:00:00\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:45:50'),
(62, 1, 1, 'create', 'newsletter_subscriber', 1, NULL, '{\"email\":\"dzdzd@gmail.com\",\"first_name\":\"dzd\",\"last_name\":\"dzdz\",\"status\":\"active\"}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:46:31'),
(63, 1, 1, 'create', 'newsletter_subscription', 0, NULL, '{\"subscriber_id\":1,\"list_id\":1}', '2a01:cb08:e79:c400:5f:f65f:5813:94e7', '2026-06-11 15:46:35'),
(64, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb09:b06d:1296:40a6:5c61:11fa:1e3f', '2026-06-15 01:08:14'),
(65, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:c1f3:77d0:64fa:3539', '2026-06-15 09:45:14'),
(66, 1, 5, 'create', 'trainer_city', 2, NULL, '{\"name\":\"test\",\"region\":\"zdd\",\"description\":\"ddzd\",\"is_active\":0}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 10:36:30'),
(67, 1, 5, 'create', 'blog_post', 6, NULL, '{\"title\":\"yanis test\",\"excerpt\":\"dzdddezd\",\"content\":\"dzadqsdsqd\",\"category_id\":6,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 10:47:13'),
(68, 1, 5, 'create', 'trainer', 4, NULL, '{\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"title\":\"expert dev\",\"tagline\":\"je suis fort\",\"email\":\"test@gmail.com\",\"phone\":\"0482124452\",\"avatar_url\":\"https:\\/\\/images.pexels.com\\/photos\\/6740170\\/pexels-photo-6740170.jpeg?_gl=1*m7ksci*_ga*MjAwMzQ4NTAzNi4xNzc1NzM3MDM5*_ga_8JE65Q40S6*czE3ODE1MTQzNDgkbzMwJGcxJHQxNzgxNTE0Mzc5JGoyOSRsMCRoMA..\",\"experience_years\":7,\"tjm_eur\":5000,\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"linkedin_url\":\"www.linkedin.com\\/in\\/yanis-laldji-4616412a6\",\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":1,\"bio\":\"bonjour\",\"primary_expertise_id\":1}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 11:07:09'),
(69, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 11:19:37'),
(70, 1, 1, 'create', 'expertise', 2, NULL, '{\"label\":\"test\"}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 11:22:18'),
(71, 1, 5, 'update', 'trainer', 4, '{\"id\":4,\"slug\":\"yanis-laldji\",\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"title\":\"expert dev\",\"tagline\":\"je suis fort\",\"bio\":\"bonjour\",\"avatar_initials\":null,\"avatar_url\":\"https:\\/\\/images.pexels.com\\/photos\\/6740170\\/pexels-photo-6740170.jpeg?_gl=1*m7ksci*_ga*MjAwMzQ4NTAzNi4xNzc1NzM3MDM5*_ga_8JE65Q40S6*czE3ODE1MTQzNDgkbzMwJGcxJHQxNzgxNTE0Mzc5JGoyOSRsMCRoMA..\",\"city_id\":null,\"experience_years\":7,\"tjm_eur\":\"5000.00\",\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"primary_expertise_id\":1,\"email\":\"test@gmail.com\",\"phone\":\"0482124452\",\"linkedin_url\":\"www.linkedin.com\\/in\\/yanis-laldji-4616412a6\",\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":1,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 11:07:09\",\"created_at\":\"2026-06-15 11:07:09\",\"updated_at\":\"2026-06-15 11:07:09\",\"deleted_at\":null}', '{\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"title\":\"expert dev\",\"tagline\":\"je suis fort\",\"email\":\"test@gmail.com\",\"phone\":\"0482124452\",\"avatar_url\":null,\"experience_years\":7,\"tjm_eur\":5000,\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"linkedin_url\":\"www.linkedin.com\\/in\\/yanis-laldji-4616412a6\",\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":1,\"bio\":\"bonjour\",\"primary_expertise_id\":1,\"expertise_ids\":[1,2],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"test module\",\"duration_label\":null,\"description\":\"test formation\",\"sort_order\":0,\"is_active\":1}]}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 11:26:13'),
(72, 1, 5, 'create', 'trainer', 5, NULL, '{\"first_name\":\"formateur\",\"last_name\":\"test\",\"title\":\"ygygsgyz\",\"tagline\":\"ddzd\",\"email\":\"test4578@gmail.com\",\"phone\":\"0742124452\",\"avatar_url\":null,\"experience_years\":5,\"tjm_eur\":3997,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"zddzd\",\"primary_expertise_id\":2,\"expertise_ids\":[2,1],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"test\",\"duration_label\":null,\"description\":\"sdzd\",\"sort_order\":0,\"is_active\":1}]}', '2a01:cb08:e79:c400:4d06:c55d:d0a8:2a56', '2026-06-15 11:42:13'),
(73, 1, 5, 'create', 'trainer', 6, NULL, '{\"first_name\":\"alexandre\",\"last_name\":\"test\",\"title\":\"test\",\"tagline\":\"eezsefd\",\"email\":\"alex@gmail.com\",\"phone\":\"0465\",\"avatar_url\":null,\"experience_years\":3,\"tjm_eur\":5000,\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"dzdzdz\",\"primary_expertise_id\":2,\"expertise_ids\":[1,2],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"test\",\"duration_label\":null,\"description\":\"dzdzd\",\"sort_order\":0,\"is_active\":1}]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 12:32:38'),
(74, 1, 5, 'create', 'blog_post', 7, NULL, '{\"title\":\"hththhgh\",\"excerpt\":\"fegere\",\"content\":\"sdef\",\"category_id\":6,\"cover_image_url\":null,\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 12:37:12'),
(75, 1, 5, 'create', 'blog_post', 8, NULL, '{\"title\":\"test img\",\"excerpt\":\"dzdzd\",\"content\":\"zdzddzdzd\",\"category_id\":6,\"cover_image_url\":\"\\/uploads\\/blog\\/e5b8cab5-3015-49a4-9bd4-e7a9a6baf72e.jpg\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2004-06-18 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:24:28'),
(76, 1, 4, 'create', 'blog_post', 9, NULL, '{\"title\":\"test images carrière\",\"excerpt\":\"zdzdz\",\"content\":\"dzdzdzd\",\"category_id\":4,\"cover_image_url\":\"\\/uploads\\/blog\\/4ead7693-cd5e-4b16-9c1d-79153cd26cb7.jpg\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:32:26'),
(77, 1, 1, 'update', 'formation', 2, '{\"id\":2,\"site_id\":1,\"slug\":\"zdzd\",\"type\":\"longue\",\"category_id\":1,\"status\":\"published\",\"published_at\":\"2026-06-11 14:49:50\",\"hero_title\":\"zdzd\",\"hero_subtitle\":\"dzdzdz\",\"hero_video_url\":null,\"hero_image_url\":null,\"card_image_url\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"dzd\",\"presentation_content\":\"dzd\",\"presentation_image\":null,\"programme_duration_label\":\"6\",\"modalites_catalogue\":null,\"methodology\":\"zdzd\",\"certification_label\":\"zdz\",\"evaluation_title\":\"dzdz\",\"evaluation_description\":\"dzdz\",\"debouches_title\":\"zddzd\",\"debouches_subtitle\":\"zdzd\",\"debouches_sectors\":\"dzzd\",\"info_modalities_title\":\"Modalités pratiques\",\"info_prerequisites_title\":\"Prérequis\",\"cta_title\":null,\"cta_subtitle\":null,\"cta_button_label\":null,\"cta_button_url\":\"\\/contact\",\"cta_secondary_label\":null,\"cta_secondary_url\":null,\"internal_reference\":null,\"sort_order\":0,\"created_by\":1,\"updated_by\":1,\"created_at\":\"2026-06-11 14:49:50\",\"updated_at\":\"2026-06-11 14:49:50\"}', '{\"hero_title\":\"zdzd\",\"hero_subtitle\":\"dzdzdz\",\"type\":\"longue\",\"category_id\":1,\"hero_image_url\":\"\\/api\\/uploads\\/alt\\/6e9afe6f-804f-4bb6-8eb6-059019c26a60.jpg\",\"card_image_url\":null,\"presentation_image\":null,\"hero_video_url\":null,\"seo_title\":null,\"seo_description\":null,\"presentation_title\":\"dzd\",\"presentation_content\":\"dzd\",\"programme_duration_label\":\"6\",\"methodology\":\"zdzd\",\"certification_label\":\"zdz\",\"evaluation_title\":\"dzdz\",\"evaluation_description\":\"dzdz\",\"debouches_title\":\"zddzd\",\"debouches_subtitle\":\"zdzd\",\"debouches_sectors\":\"dzzd\",\"info_modalities_title\":\"Modalités pratiques\",\"info_prerequisites_title\":\"Prérequis\",\"status\":\"published\",\"published_at\":\"2026-06-11 00:00:00\",\"modules\":[],\"stats\":[],\"job_outcomes\":[],\"list_items\":[]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:39:56'),
(78, 1, 5, 'delete', 'trainer', 6, '{\"id\":6,\"slug\":\"alexandre-test\",\"first_name\":\"alexandre\",\"last_name\":\"test\",\"title\":\"test\",\"tagline\":\"eezsefd\",\"bio\":\"dzdzdz\",\"avatar_initials\":null,\"avatar_url\":null,\"city_id\":null,\"experience_years\":3,\"tjm_eur\":\"5000.00\",\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"primary_expertise_id\":2,\"email\":\"alex@gmail.com\",\"phone\":\"0465\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 12:32:38\",\"created_at\":\"2026-06-15 12:32:38\",\"updated_at\":\"2026-06-15 12:32:38\",\"deleted_at\":null}', NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:42:47'),
(79, 1, 5, 'delete', 'trainer', 5, '{\"id\":5,\"slug\":\"formateur-test\",\"first_name\":\"formateur\",\"last_name\":\"test\",\"title\":\"ygygsgyz\",\"tagline\":\"ddzd\",\"bio\":\"zddzd\",\"avatar_initials\":null,\"avatar_url\":null,\"city_id\":null,\"experience_years\":5,\"tjm_eur\":\"3997.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":2,\"email\":\"test4578@gmail.com\",\"phone\":\"0742124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 11:42:12\",\"created_at\":\"2026-06-15 11:42:12\",\"updated_at\":\"2026-06-15 11:42:12\",\"deleted_at\":null}', NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:42:49'),
(80, 1, 5, 'delete', 'trainer', 4, '{\"id\":4,\"slug\":\"yanis-laldji\",\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"title\":\"expert dev\",\"tagline\":\"je suis fort\",\"bio\":\"bonjour\",\"avatar_initials\":null,\"avatar_url\":null,\"city_id\":null,\"experience_years\":7,\"tjm_eur\":\"5000.00\",\"availability\":\"available\",\"legal_status\":\"auto_entrepreneur\",\"primary_expertise_id\":1,\"email\":\"test@gmail.com\",\"phone\":\"0482124452\",\"linkedin_url\":\"www.linkedin.com\\/in\\/yanis-laldji-4616412a6\",\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":1,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 11:07:09\",\"created_at\":\"2026-06-15 11:07:09\",\"updated_at\":\"2026-06-15 11:26:13\",\"deleted_at\":null}', NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:42:50'),
(81, 1, 5, 'delete', 'trainer', 3, '{\"id\":3,\"slug\":\"dzd-zdzddzd\",\"first_name\":\"dzdzdzdzd\",\"last_name\":\"zdzddzd\",\"title\":\"zdzdzdzd\",\"tagline\":\"dzdzd\",\"bio\":\"dzzddz\",\"avatar_initials\":null,\"avatar_url\":\"dzdzdz\",\"city_id\":null,\"experience_years\":5,\"tjm_eur\":\"4100.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":1,\"email\":\"zdzd@gmail.com\",\"phone\":\"0421424\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-11 15:29:29\",\"created_at\":\"2026-06-11 15:29:29\",\"updated_at\":\"2026-06-11 15:30:12\",\"deleted_at\":null}', NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:42:52'),
(82, 1, 5, 'delete', 'trainer', 1, '{\"id\":1,\"slug\":\"dzd-zdzd\",\"first_name\":\"dzd\",\"last_name\":\"zdzd\",\"title\":\"dzddz\",\"tagline\":\"ddzd\",\"bio\":\"dzdzd\",\"avatar_initials\":null,\"avatar_url\":\"zdzdzd\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"565265.00\",\"availability\":\"soon\",\"legal_status\":\"sasu\",\"primary_expertise_id\":1,\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"linkedin_url\":null,\"status\":\"inactive\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-11 15:02:10\",\"created_at\":\"2026-06-11 15:02:10\",\"updated_at\":\"2026-06-11 15:28:44\",\"deleted_at\":null}', NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:42:54'),
(83, 1, 5, 'create', 'trainer', 9, NULL, '{\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/404ce0d0-2922-4fa7-8edc-962dee324dc5.png\",\"experience_years\":4,\"tjm_eur\":100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"formation super\",\"primary_expertise_id\":2,\"expertise_ids\":[2,1],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"php\",\"duration_label\":null,\"description\":\"php test\",\"sort_order\":0,\"is_active\":1}]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 14:45:49'),
(84, 1, 5, 'update', 'blog_post', 8, '{\"id\":8,\"site_id\":5,\"category_id\":6,\"author_id\":null,\"title\":\"test img\",\"slug\":\"test-img\",\"excerpt\":\"dzdzd\",\"content\":\"zdzddzdzd\",\"cover_image_url\":\"\\/uploads\\/blog\\/e5b8cab5-3015-49a4-9bd4-e7a9a6baf72e.jpg\",\"read_time_mins\":null,\"status\":\"published\",\"is_featured\":0,\"views_count\":0,\"meta_title\":null,\"meta_description\":null,\"published_at\":\"2026-06-15 14:24:28\",\"created_at\":\"2026-06-15 14:24:28\",\"updated_at\":null,\"deleted_at\":null}', '{\"title\":\"test img\",\"excerpt\":\"dzdzd\",\"content\":\"zdzddzdzd\",\"category_id\":6,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/c809a9b2-168e-41bb-b5d5-3bd4a83172ce.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:02:01'),
(85, 1, 5, 'create', 'blog_post', 24, NULL, '{\"title\":\"test images trainer\",\"excerpt\":\"dzdzdqd\",\"content\":\"frgergfs\",\"category_id\":6,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/bee61c94-6c73-4a6f-b8ab-7e10e9e9ea14.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:05:26'),
(86, 1, 5, 'update', 'blog_post', 24, '{\"id\":24,\"site_id\":5,\"category_id\":6,\"author_id\":null,\"title\":\"test images trainer\",\"slug\":\"test-images-trainer\",\"excerpt\":\"dzdzdqd\",\"content\":\"frgergfs\",\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/bee61c94-6c73-4a6f-b8ab-7e10e9e9ea14.png\",\"read_time_mins\":null,\"status\":\"published\",\"is_featured\":0,\"views_count\":0,\"meta_title\":null,\"meta_description\":null,\"published_at\":\"2026-06-15 15:05:26\",\"created_at\":\"2026-06-15 15:05:26\",\"updated_at\":null,\"deleted_at\":null}', '{\"title\":\"test images trainer\",\"excerpt\":\"dzdzdqd\",\"content\":\"frgergfs\",\"category_id\":6,\"cover_image_url\":\"\\/api\\/uploads\\/global\\/d98e3227-2cb1-427b-bf36-c575b9801bfa.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:14:56'),
(87, 1, 5, 'update', 'trainer', 9, '{\"id\":9,\"slug\":\"yandzdzdzdis-laldjizdzd\",\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"bio\":\"formation super\",\"avatar_initials\":null,\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/404ce0d0-2922-4fa7-8edc-962dee324dc5.png\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"100.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":2,\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 14:45:49\",\"created_at\":\"2026-06-15 14:45:49\",\"updated_at\":\"2026-06-15 14:45:49\",\"deleted_at\":null}', '{\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/4b8942d5-f385-4e88-96a5-7ba9cfe54e41.png\",\"experience_years\":4,\"tjm_eur\":100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"formation super\",\"primary_expertise_id\":2,\"expertise_ids\":[1,2],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"php\",\"duration_label\":null,\"description\":\"php test\",\"sort_order\":0,\"is_active\":1}]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:19:27'),
(88, 1, 5, 'update', 'trainer', 9, '{\"id\":9,\"slug\":\"yandzdzdzdis-laldjizdzd\",\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"bio\":\"formation super\",\"avatar_initials\":null,\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/4b8942d5-f385-4e88-96a5-7ba9cfe54e41.png\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"100.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":2,\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 14:45:49\",\"created_at\":\"2026-06-15 14:45:49\",\"updated_at\":\"2026-06-15 15:19:27\",\"deleted_at\":null}', '{\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/4b8942d5-f385-4e88-96a5-7ba9cfe54e41.png\",\"experience_years\":4,\"tjm_eur\":100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"formation super\",\"primary_expertise_id\":2,\"expertise_ids\":[1,2],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"php\",\"duration_label\":null,\"description\":\"php test\",\"sort_order\":0,\"is_active\":1},{\"title\":\"test\",\"duration_label\":null,\"description\":\"sdsds\",\"sort_order\":1,\"is_active\":1}]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:46:17'),
(89, 1, NULL, 'logout', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:53:36'),
(90, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:53:45'),
(91, 1, NULL, 'logout', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:58:38'),
(92, 1, NULL, 'login_success', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 15:58:45'),
(93, 1, 5, 'create', 'trainer_review', 2, NULL, '{\"trainer_id\":9,\"author_name\":\"alexandre\",\"company\":\"alt rh\",\"rating\":4,\"comment\":\"super formateur\",\"is_published\":0}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 16:03:48'),
(94, 1, 5, 'update', 'trainer', 9, '{\"id\":9,\"slug\":\"yandzdzdzdis-laldjizdzd\",\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"bio\":\"formation super\",\"avatar_initials\":null,\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/4b8942d5-f385-4e88-96a5-7ba9cfe54e41.png\",\"city_id\":null,\"experience_years\":4,\"tjm_eur\":\"100.00\",\"availability\":\"available\",\"legal_status\":\"eurl\",\"primary_expertise_id\":2,\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"rating_avg\":\"0.0\",\"reviews_count\":0,\"published_at\":\"2026-06-15 14:45:49\",\"created_at\":\"2026-06-15 14:45:49\",\"updated_at\":\"2026-06-15 15:46:17\",\"deleted_at\":null}', '{\"first_name\":\"Yandzdzdzdis\",\"last_name\":\"laldjizdzd\",\"title\":\"expert devdzd\",\"tagline\":\"je suis fort\",\"email\":\"super@gmail.com\",\"phone\":\"0722124452\",\"avatar_url\":\"\\/api\\/uploads\\/trainers\\/76af6f6f-6699-454b-82fd-1c94a65bfd1b.png\",\"experience_years\":4,\"tjm_eur\":100,\"availability\":\"available\",\"legal_status\":\"eurl\",\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"qualiopi_eligible\":0,\"bio\":\"formation super\",\"primary_expertise_id\":2,\"expertise_ids\":[1,2],\"skill_ids\":[1],\"certification_ids\":[1],\"courses\":[{\"title\":\"php\",\"duration_label\":null,\"description\":\"php test\",\"sort_order\":0,\"is_active\":1},{\"title\":\"test\",\"duration_label\":null,\"description\":\"sdsds\",\"sort_order\":1,\"is_active\":1}]}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 16:04:30'),
(95, 1, 5, 'create', 'blog_post', 25, NULL, '{\"title\":\"test blog\",\"excerpt\":\"test blog 1\",\"content\":\"test blog 1\",\"category_id\":6,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/67bc693b-4cf9-4a36-a09c-292720361a93.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-15 00:00:00\"}', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', '2026-06-15 16:12:22'),
(96, 1, 6, 'create', 'coaches', 1, NULL, '{\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"title\":\"test \",\"email\":\"yanislaldjipro@gmail.com\",\"phone\":\"0782124452\",\"avatar_url\":\"\\/api\\/uploads\\/media\\/5c8f3b63-39c4-4312-9cb1-100f363d68bf.png\",\"experience_years\":5,\"linkedin_url\":null,\"status\":\"active\",\"is_featured\":0,\"sort_order\":0,\"bio_short\":\"bonjour\",\"bio_full\":\"feuhbdsbsbd\",\"city_id\":1,\"specialties\":[2],\"certifications\":[3],\"languages\":[1]}', '2a01:cb08:e79:c400:8059:8b7f:decc:cb1', '2026-06-15 16:46:42'),
(97, 1, 6, 'create', 'coaching_specialties', 8, NULL, '{\"name\":\"test\",\"sort_order\":\"\",\"is_active\":1}', '2a01:cb09:b07a:290a:b4cd:7666:78d4:ffa7', '2026-06-15 23:50:38'),
(98, 1, 6, 'create', 'blog_post', 26, NULL, '{\"title\":\"test blog \",\"excerpt\":\"hebdhebdhebhbf\",\"content\":\"hbedhebhbehbdehbd\",\"category_id\":5,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/38f59d70-6314-4a5b-89d3-b679ee929492.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-16 00:00:00\"}', '2a01:cb09:b07a:290a:b4cd:7666:78d4:ffa7', '2026-06-16 00:11:16'),
(99, 1, 4, 'create', 'blog_post', 27, NULL, '{\"title\":\"test blog carrière\",\"excerpt\":\"ncjebehbfhceh\",\"content\":\"fenfjkemdnfvmsnmjlndsmnvjmkkvns\",\"category_id\":4,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/b7cdb972-3926-4217-a18e-13161201b3f6.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-24 00:00:00\"}', '2a01:cb09:b07a:290a:b4cd:7666:78d4:ffa7', '2026-06-16 00:36:19'),
(100, 1, 4, 'update', 'blog_post', 27, '{\"id\":27,\"site_id\":4,\"category_id\":4,\"author_id\":null,\"title\":\"test blog carrière\",\"slug\":\"test-blog-carriere\",\"excerpt\":\"ncjebehbfhceh\",\"content\":\"fenfjkemdnfvmsnmjlndsmnvjmkkvns\",\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/b7cdb972-3926-4217-a18e-13161201b3f6.png\",\"read_time_mins\":null,\"status\":\"published\",\"is_featured\":0,\"views_count\":0,\"meta_title\":null,\"meta_description\":null,\"published_at\":\"2026-06-16 00:36:19\",\"created_at\":\"2026-06-16 00:36:19\",\"updated_at\":null,\"deleted_at\":null}', '{\"title\":\"test blog carrière\",\"excerpt\":\"ncjebehbfhceh\",\"content\":\"fenfjkemdnfvmsnmjlndsmnvjmkkvns\",\"category_id\":4,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/b7cdb972-3926-4217-a18e-13161201b3f6.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-16 00:00:00\"}', '2a01:cb09:b07a:290a:b4cd:7666:78d4:ffa7', '2026-06-16 00:46:28'),
(101, 1, 4, 'create', 'blog_post', 28, NULL, '{\"title\":\"test blog oui\",\"excerpt\":\"edhehde\",\"content\":\"djzndjzdnkzdzk\",\"category_id\":4,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/b26e047e-b423-449e-9101-a0e9c5d296e9.png\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-16 00:00:00\"}', '2a01:cb09:b07a:290a:b4cd:7666:78d4:ffa7', '2026-06-16 00:48:33'),
(102, 1, 4, 'create', 'blog_post', 29, NULL, '{\"title\":\"test blog yanis\",\"excerpt\":\"jhgkbjgkgj\",\"content\":\"jgjhfgjf\",\"category_id\":4,\"cover_image_url\":\"\\/api\\/uploads\\/blog\\/289b9dce-5ef3-48ec-96e9-ed80e9880fe0.jpg\",\"is_featured\":0,\"status\":\"published\",\"published_at\":\"2026-06-16 00:00:00\"}', '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 09:25:02'),
(103, 1, 3, 'create', 'entreprise', 2, NULL, '{\"nom\":\"ihu claye souilly\",\"siret\":null,\"description\":\"dzdzdqdz\",\"taille\":\"201-500\",\"secteur_id\":null,\"adresse\":\"14 Rue de la Grande Mare\",\"code_postal\":\"77410\",\"ville\":\"Villevaudé\",\"validee\":1,\"site_id\":3}', '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 10:31:47'),
(104, 1, 3, 'update', 'offre_emploi', 1, '{\"id\":1,\"site_id\":3,\"entreprise_id\":1,\"recruteur_id\":null,\"metier_id\":null,\"reference\":null,\"slug\":\"zdddz\",\"titre\":\"zdddz\",\"description\":\"dzd\",\"profil_recherche\":\"dzdzdz\",\"avantages\":\"zdzdz\",\"type_contrat\":\"cdi\",\"experience_min\":\"1-2\",\"salaire_min\":3151,\"salaire_max\":415149,\"salaire_afficher\":0,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"dzd\",\"code_postal\":\"zdzd\",\"departement\":\"zdzd\",\"region\":\"zdzd\",\"is_featured\":0,\"is_urgent\":0,\"statut\":\"publiee\",\"date_publication\":\"2026-06-11 14:57:55\",\"date_expiration\":\"2026-06-22 23:59:59\",\"vues\":0,\"meta_title\":null,\"meta_description\":null,\"created_at\":\"2026-06-11 14:57:55\",\"updated_at\":\"2026-06-11 14:57:55\"}', '{\"titre\":\"zdddz\",\"reference\":null,\"entreprise_id\":2,\"metier_id\":2,\"recruteur_id\":null,\"type_contrat\":\"cdi\",\"description\":\"dzd\",\"profil_recherche\":\"dzdzdz\",\"avantages\":\"zdzdz\",\"experience_min\":\"1-2\",\"salaire_min\":3151,\"salaire_max\":415149,\"salaire_afficher\":0,\"teletravail\":\"non\",\"temps_travail\":\"temps_plein\",\"ville\":\"dzd\",\"code_postal\":\"zdzd\",\"departement\":\"zdzd\",\"region\":\"zdzd\",\"is_urgent\":1,\"is_featured\":0,\"statut\":\"publiee\",\"date_publication\":\"2026-06-11 00:00:00\",\"date_expiration\":\"2026-06-22 23:59:59\",\"meta_title\":null,\"meta_description\":null,\"competences_text\":\"dzdzddqdezdsqd\"}', '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 10:32:04'),
(105, NULL, NULL, 'login_failed', 'auth', NULL, NULL, NULL, '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 10:40:38'),
(106, 1, 4, 'create', 'blog_tag', 2, NULL, '{\"name\":\"super\",\"slug\":\"super\"}', '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 11:08:55'),
(107, 1, 6, 'create', 'blog_author', 2, NULL, '{\"first_name\":\"yanis\",\"last_name\":\"laldji\",\"email\":\"yanislaldjipro@gmail.com\",\"slug\":\"yanis-laldji\",\"bio\":\"dzddzd\",\"avatar_url\":\"\\/api\\/uploads\\/blog\\/56de95f9-676b-412a-986f-3cc09a9fe187.webp\",\"is_active\":1}', '2a01:cb08:e79:c400:252b:9544:11b2:8968', '2026-06-16 11:09:25');

-- --------------------------------------------------------

--
-- Structure de la table `core_sites`
--

CREATE TABLE `core_sites` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `domain` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `core_sites`
--

INSERT INTO `core_sites` (`id`, `name`, `slug`, `domain`, `is_active`) VALUES
(1, 'Alt Formation', 'alt-formation', 'alt-formation.fr', 1),
(2, 'Nexytal Recrutement', 'nexytal-recrutement', 'recrutement.nexytal.com', 1),
(3, 'Nexytal Médical', 'nexytal-medical', 'medical.nexytal.com', 1),
(4, 'Nexytal Carrière', 'nexytal-carriere', 'carriere.nexytal.com', 1),
(5, 'Nexytal Trainer', 'nexytal-trainer', 'trainer.nexytal.com', 1),
(6, 'Nexytal Coaching', 'nexytal-coaching', 'coaching.nexytal.com', 1);

-- --------------------------------------------------------

--
-- Structure de la table `entreprises`
--

CREATE TABLE `entreprises` (
  `id` int(11) UNSIGNED NOT NULL,
  `nom` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `siret` varchar(14) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `site_web` varchar(500) DEFAULT NULL,
  `taille` enum('1-10','11-50','51-200','201-500','500+') DEFAULT NULL,
  `secteur_id` int(11) UNSIGNED DEFAULT NULL,
  `adresse` varchar(300) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `validee` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `entreprises`
--

INSERT INTO `entreprises` (`id`, `nom`, `slug`, `siret`, `description`, `logo_url`, `site_web`, `taille`, `secteur_id`, `adresse`, `code_postal`, `ville`, `validee`, `created_at`, `updated_at`) VALUES
(1, 'dzdzdzd', 'dzdzdzd', NULL, 'dzdzd', NULL, NULL, '1-10', 1, 'ddzdz', 'zdzd', 'zdzd', 0, '2026-06-11 14:57:15', '2026-06-11 14:57:15'),
(2, 'ihu claye souilly', 'ihu-claye-souilly', NULL, 'dzdzdqdz', NULL, NULL, '201-500', NULL, '14 Rue de la Grande Mare', '77410', 'Villevaudé', 1, '2026-06-16 10:31:47', '2026-06-16 10:31:47');

-- --------------------------------------------------------

--
-- Structure de la table `expertises`
--

CREATE TABLE `expertises` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `label` varchar(120) NOT NULL,
  `subtitle` varchar(200) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `expertises`
--

INSERT INTO `expertises` (`id`, `slug`, `label`, `subtitle`, `description`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'zdzdzd', 'zdzdzd', NULL, NULL, 0, 1, '2026-06-11 15:01:47', '2026-06-11 15:01:47'),
(2, 'test', 'test', NULL, NULL, 0, 1, '2026-06-15 11:22:18', '2026-06-15 11:22:18');

-- --------------------------------------------------------

--
-- Structure de la table `formations`
--

CREATE TABLE `formations` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT 1,
  `slug` varchar(220) NOT NULL,
  `type` enum('longue','courte','certifiante') NOT NULL,
  `category_id` int(11) UNSIGNED DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `published_at` datetime DEFAULT NULL,
  `hero_title` varchar(255) NOT NULL,
  `hero_subtitle` text DEFAULT NULL,
  `hero_video_url` varchar(512) DEFAULT NULL,
  `hero_image_url` varchar(512) DEFAULT NULL,
  `card_image_url` varchar(512) DEFAULT NULL,
  `seo_title` varchar(255) DEFAULT NULL,
  `seo_description` text DEFAULT NULL,
  `presentation_title` varchar(150) DEFAULT 'Le métier',
  `presentation_content` longtext DEFAULT NULL,
  `presentation_image` varchar(512) DEFAULT NULL,
  `programme_duration_label` varchar(255) DEFAULT NULL,
  `modalites_catalogue` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`modalites_catalogue`)),
  `methodology` text DEFAULT NULL,
  `certification_label` varchar(255) DEFAULT NULL,
  `evaluation_title` varchar(255) DEFAULT NULL,
  `evaluation_description` text DEFAULT NULL,
  `debouches_title` varchar(255) DEFAULT NULL,
  `debouches_subtitle` text DEFAULT NULL,
  `debouches_sectors` text DEFAULT NULL,
  `info_modalities_title` varchar(150) DEFAULT 'Modalités pratiques',
  `info_prerequisites_title` varchar(150) DEFAULT 'Prérequis',
  `cta_title` varchar(255) DEFAULT NULL,
  `cta_subtitle` text DEFAULT NULL,
  `cta_button_label` varchar(120) DEFAULT NULL,
  `cta_button_url` varchar(255) DEFAULT '/contact',
  `cta_secondary_label` varchar(120) DEFAULT NULL,
  `cta_secondary_url` varchar(255) DEFAULT NULL,
  `internal_reference` varchar(80) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_by` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formations`
--

INSERT INTO `formations` (`id`, `site_id`, `slug`, `type`, `category_id`, `status`, `published_at`, `hero_title`, `hero_subtitle`, `hero_video_url`, `hero_image_url`, `card_image_url`, `seo_title`, `seo_description`, `presentation_title`, `presentation_content`, `presentation_image`, `programme_duration_label`, `modalites_catalogue`, `methodology`, `certification_label`, `evaluation_title`, `evaluation_description`, `debouches_title`, `debouches_subtitle`, `debouches_sectors`, `info_modalities_title`, `info_prerequisites_title`, `cta_title`, `cta_subtitle`, `cta_button_label`, `cta_button_url`, `cta_secondary_label`, `cta_secondary_url`, `internal_reference`, `sort_order`, `created_by`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'test-formatio', 'longue', 1, 'published', '2026-06-11 00:00:00', 'test formatio', NULL, NULL, NULL, NULL, NULL, NULL, 'sdsd', 'sdsd', NULL, '6', NULL, 'dsd', 'dsds', 'sds', 'sdsd', 'sdsd', 'sdsd', 'sdsd', 'sdsd', 'sdsd', 'sdsd', 'sdsdsdsd', 'sdsd', '/contact', 'sdsdsd', NULL, NULL, 0, 1, 1, '2026-06-11 14:32:21', '2026-06-11 14:32:45'),
(2, 1, 'zdzd', 'longue', 1, 'published', '2026-06-11 00:00:00', 'zdzd', 'dzdzdz', NULL, '/api/uploads/alt/6e9afe6f-804f-4bb6-8eb6-059019c26a60.jpg', NULL, NULL, NULL, 'dzd', 'dzd', NULL, '6', NULL, 'zdzd', 'zdz', 'dzdz', 'dzdz', 'zddzd', 'zdzd', 'dzzd', 'Modalités pratiques', 'Prérequis', NULL, NULL, NULL, '/contact', NULL, NULL, NULL, 0, 1, 1, '2026-06-11 14:49:50', '2026-06-15 14:39:56');

-- --------------------------------------------------------

--
-- Structure de la table `formation_categories`
--

CREATE TABLE `formation_categories` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL DEFAULT 1,
  `slug` varchar(80) NOT NULL,
  `label` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `catalogue_type` enum('longue','courte','certifiante','all') NOT NULL DEFAULT 'all',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_categories`
--

INSERT INTO `formation_categories` (`id`, `site_id`, `slug`, `label`, `description`, `catalogue_type`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'test', 'TEST', NULL, 'all', 0, 1, '2026-06-11 14:30:11', '2026-06-11 14:30:11'),
(2, 1, 'e-learning', 'e learning', NULL, 'all', 0, 1, '2026-06-11 15:32:50', '2026-06-11 15:32:50'),
(3, 1, 'certifiante', 'certifiante', NULL, 'all', 0, 1, '2026-06-11 15:33:02', '2026-06-11 15:33:23'),
(4, 1, 'diplomantes', 'Diplômantes', NULL, 'all', 0, 1, '2026-06-11 15:33:19', '2026-06-11 15:33:19');

-- --------------------------------------------------------

--
-- Structure de la table `formation_job_outcomes`
--

CREATE TABLE `formation_job_outcomes` (
  `id` int(11) UNSIGNED NOT NULL,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `job_title` varchar(255) NOT NULL,
  `salary_label` varchar(120) DEFAULT 'Selon expérience',
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_list_items`
--

CREATE TABLE `formation_list_items` (
  `id` int(11) UNSIGNED NOT NULL,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `list_type` enum('competence','objectif','metier_vise','evaluation_step','info_modalite','info_prerequis') NOT NULL,
  `content` text NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_modules`
--

CREATE TABLE `formation_modules` (
  `id` int(11) UNSIGNED NOT NULL,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `duration_label` varchar(80) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `formation_official_certifications`
--

CREATE TABLE `formation_official_certifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `repertoire` enum('RNCP','RS') NOT NULL DEFAULT 'RNCP',
  `code` varchar(20) NOT NULL,
  `official_title` varchar(255) NOT NULL,
  `level` tinyint(3) UNSIGNED DEFAULT NULL,
  `france_competences_url` varchar(512) NOT NULL,
  `show_on_certification_page` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `formation_official_certifications`
--

INSERT INTO `formation_official_certifications` (`id`, `formation_id`, `repertoire`, `code`, `official_title`, `level`, `france_competences_url`, `show_on_certification_page`) VALUES
(1, 1, 'RNCP', '5655', 'test formatio', NULL, 'https://www.francecompetences.fr', 1);

-- --------------------------------------------------------

--
-- Structure de la table `formation_stats`
--

CREATE TABLE `formation_stats` (
  `id` int(11) UNSIGNED NOT NULL,
  `formation_id` int(11) UNSIGNED NOT NULL,
  `label` varchar(80) NOT NULL,
  `value` varchar(255) NOT NULL,
  `icon` varchar(40) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_consents_log`
--

CREATE TABLE `gdpr_consents_log` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` text DEFAULT NULL,
  `consent_type` varchar(50) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `granted` tinyint(1) NOT NULL DEFAULT 1,
  `granted_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `gdpr_consents_log`
--

INSERT INTO `gdpr_consents_log` (`id`, `site_id`, `user_email`, `ip_address`, `user_agent`, `consent_type`, `reference_id`, `granted`, `granted_at`) VALUES
(1, 5, 'yanislaldjipro@gmail.com', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'newsletter', 2, 1, '2026-06-15 12:29:12');

-- --------------------------------------------------------

--
-- Structure de la table `gdpr_deletion_requests`
--

CREATE TABLE `gdpr_deletion_requests` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `status` enum('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
  `requested_at` datetime NOT NULL DEFAULT current_timestamp(),
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `marketing_email_logs`
--

CREATE TABLE `marketing_email_logs` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `recipient_email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `template_used` varchar(100) DEFAULT NULL,
  `status` enum('sent','failed','bounced') NOT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `media_library`
--

CREATE TABLE `media_library` (
  `id` int(11) UNSIGNED NOT NULL,
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
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Médiathèque centralisée (images, vidéos, PDF…)';

--
-- Déchargement des données de la table `media_library`
--

INSERT INTO `media_library` (`id`, `site_id`, `file_name`, `original_name`, `file_path`, `mime_type`, `file_type`, `file_size`, `alt_text`, `uploaded_by`, `created_at`, `updated_at`) VALUES
(10, NULL, 'fb56a942-13f2-415d-b7ef-d4fd4f0bdd4f.png', 'credit-agrocole.png', '/api/uploads/global/fb56a942-13f2-415d-b7ef-d4fd4f0bdd4f.png', 'image/png', 'image', 63798, NULL, 1, '2026-06-15 16:00:07', NULL),
(11, 5, '76af6f6f-6699-454b-82fd-1c94a65bfd1b.png', 'orange.png', '/api/uploads/trainers/76af6f6f-6699-454b-82fd-1c94a65bfd1b.png', 'image/png', 'image', 3129, NULL, 1, '2026-06-15 16:04:27', NULL),
(12, 5, '67bc693b-4cf9-4a36-a09c-292720361a93.png', 'france-compétence.png', '/api/uploads/blog/67bc693b-4cf9-4a36-a09c-292720361a93.png', 'image/png', 'image', 38747, NULL, 1, '2026-06-15 16:12:16', NULL),
(13, 6, '5c8f3b63-39c4-4312-9cb1-100f363d68bf.png', 'orange.png', '/api/uploads/media/5c8f3b63-39c4-4312-9cb1-100f363d68bf.png', 'image/png', 'image', 3129, NULL, 1, '2026-06-15 16:46:20', NULL),
(14, 6, '38f59d70-6314-4a5b-89d3-b679ee929492.png', 'agefiph.png', '/api/uploads/blog/38f59d70-6314-4a5b-89d3-b679ee929492.png', 'image/png', 'image', 24451, NULL, 1, '2026-06-16 00:11:07', NULL),
(15, 4, 'b7cdb972-3926-4217-a18e-13161201b3f6.png', 'bnp-paribas.png', '/api/uploads/blog/b7cdb972-3926-4217-a18e-13161201b3f6.png', 'image/png', 'image', 6803, NULL, 1, '2026-06-16 00:36:12', NULL),
(16, 4, 'b26e047e-b423-449e-9101-a0e9c5d296e9.png', 'france-compétence.png', '/api/uploads/blog/b26e047e-b423-449e-9101-a0e9c5d296e9.png', 'image/png', 'image', 38747, NULL, 1, '2026-06-16 00:48:25', NULL),
(17, 4, '289b9dce-5ef3-48ec-96e9-ed80e9880fe0.jpg', 'admin_system.jpg', '/api/uploads/blog/289b9dce-5ef3-48ec-96e9-ed80e9880fe0.jpg', 'image/jpeg', 'image', 73810, NULL, 1, '2026-06-16 09:24:55', NULL),
(18, 6, '56de95f9-676b-412a-986f-3cc09a9fe187.webp', 'cpf-400w.webp', '/api/uploads/blog/56de95f9-676b-412a-986f-3cc09a9fe187.webp', 'image/webp', 'image', 7330, NULL, 1, '2026-06-16 11:09:21', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `metiers`
--

CREATE TABLE `metiers` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) DEFAULT NULL,
  `code_rome` varchar(20) DEFAULT NULL,
  `slug` varchar(150) NOT NULL,
  `libelle` varchar(200) NOT NULL,
  `titre` varchar(200) DEFAULT NULL,
  `slogan` varchar(255) DEFAULT NULL,
  `description_courte` varchar(500) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `presentation` longtext DEFAULT NULL,
  `journee_type` text DEFAULT NULL,
  `famille_metier` varchar(150) DEFAULT NULL,
  `secteur_id` int(11) UNSIGNED DEFAULT NULL,
  `niveau_etudes` varchar(100) DEFAULT NULL,
  `perspectives` text DEFAULT NULL,
  `actif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `image_url` varchar(500) DEFAULT NULL,
  `secteur_offres` varchar(150) DEFAULT NULL COMMENT 'Slug offres: medecin, infirmier…',
  `salaire_fourchette` varchar(100) DEFAULT NULL,
  `salaire_debutant` varchar(150) DEFAULT NULL,
  `salaire_confirme` varchar(150) DEFAULT NULL,
  `salaire_liberal` varchar(150) DEFAULT NULL,
  `salaire_details` text DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `metiers`
--

INSERT INTO `metiers` (`id`, `site_id`, `code_rome`, `slug`, `libelle`, `titre`, `slogan`, `description_courte`, `description`, `presentation`, `journee_type`, `famille_metier`, `secteur_id`, `niveau_etudes`, `perspectives`, `actif`, `created_at`, `updated_at`, `image_url`, `secteur_offres`, `salaire_fourchette`, `salaire_debutant`, `salaire_confirme`, `salaire_liberal`, `salaire_details`, `sort_order`) VALUES
(1, 2, NULL, 'test-metier-libelle', 'Test metier libelle', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-06-11 15:05:22', '2026-06-11 15:05:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(2, 3, NULL, 'metier-test', 'métier test', NULL, NULL, NULL, 'dzdzd', NULL, NULL, 'dzdz', 1, 'dzd', 'zdzd', 1, '2026-06-11 15:27:44', '2026-06-11 15:27:44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0),
(3, 2, 'zdzdz', 'dzdzdz', 'dzdzdz', NULL, NULL, NULL, 'dzd', NULL, NULL, 'dzdd', 2, 'dzdz', 'zdz', 1, '2026-06-11 15:28:27', '2026-06-11 15:28:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0);

-- --------------------------------------------------------

--
-- Structure de la table `metier_competences`
--

CREATE TABLE `metier_competences` (
  `metier_id` int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `importance` enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_campaigns`
--

CREATE TABLE `newsletter_campaigns` (
  `id` int(11) UNSIGNED NOT NULL,
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
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `newsletter_campaigns`
--

INSERT INTO `newsletter_campaigns` (`id`, `site_id`, `list_id`, `created_by`, `subject`, `preview_text`, `content_html`, `content_text`, `status`, `scheduled_at`, `sent_at`, `recipients_count`, `opens_count`, `clicks_count`, `bounces_count`, `unsubscribes_count`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'dsdsd', 'dsdz', 'dzdzdzd', NULL, 'draft', '2026-06-18 00:00:00', NULL, 0, 0, 0, 0, 0, '2026-06-11 15:31:27', '2026-06-11 15:31:27');

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_events`
--

CREATE TABLE `newsletter_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `campaign_id` int(11) UNSIGNED NOT NULL,
  `subscriber_id` int(11) UNSIGNED NOT NULL,
  `event_type` enum('sent','opened','clicked','bounced','complained','unsubscribed') NOT NULL,
  `url_clicked` varchar(500) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_lists`
--

CREATE TABLE `newsletter_lists` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `newsletter_lists`
--

INSERT INTO `newsletter_lists` (`id`, `site_id`, `name`, `slug`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Newsletter générale', 'generale', 'Actualités Alt Formation', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35'),
(2, 2, 'Alertes emploi', 'alertes', 'Nouvelles offres recrutement', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35'),
(3, 3, 'Alertes médical', 'alertes', 'Offres secteur médical', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35'),
(4, 4, 'Newsletter carrière', 'generale', 'Conseils carrière', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35'),
(5, 5, 'Newsletter trainers', 'generale', 'Actualités formateurs', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35'),
(6, 6, 'Newsletter coaching', 'generale', 'Actualités coaching', 1, '2026-06-11 10:17:35', '2026-06-11 10:17:35');

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_subscribers`
--

CREATE TABLE `newsletter_subscribers` (
  `id` int(11) UNSIGNED NOT NULL,
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
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `newsletter_subscribers`
--

INSERT INTO `newsletter_subscribers` (`id`, `site_id`, `email`, `first_name`, `last_name`, `status`, `confirm_token`, `confirm_token_expires_at`, `confirmed_at`, `unsubscribed_at`, `unsubscribe_reason`, `rgpd_consent_at`, `rgpd_consent_ip`, `user_id`, `source`, `created_at`, `updated_at`) VALUES
(1, 1, 'dzdzd@gmail.com', 'dzd', 'dzdz', 'active', NULL, NULL, NULL, NULL, NULL, '2026-06-11 15:46:31', NULL, NULL, 'import', '2026-06-11 15:46:31', '2026-06-11 15:46:31'),
(2, 5, 'yanislaldjipro@gmail.com', NULL, NULL, 'active', NULL, NULL, NULL, NULL, NULL, '2026-06-15 12:29:12', '2a01:cb08:e79:c400:4533:c41d:6f69:9c64', NULL, 'form', '2026-06-15 12:29:12', '2026-06-15 12:29:12');

-- --------------------------------------------------------

--
-- Structure de la table `newsletter_subscriptions`
--

CREATE TABLE `newsletter_subscriptions` (
  `subscriber_id` int(11) UNSIGNED NOT NULL,
  `list_id` int(11) UNSIGNED NOT NULL,
  `subscribed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `unsubscribed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `newsletter_subscriptions`
--

INSERT INTO `newsletter_subscriptions` (`subscriber_id`, `list_id`, `subscribed_at`, `unsubscribed_at`) VALUES
(1, 1, '2026-06-11 15:46:35', NULL),
(2, 5, '2026-06-15 12:29:12', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `offres_emploi`
--

CREATE TABLE `offres_emploi` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `entreprise_id` int(11) UNSIGNED NOT NULL,
  `recruteur_id` int(11) UNSIGNED DEFAULT NULL,
  `metier_id` int(11) UNSIGNED DEFAULT NULL,
  `reference` varchar(50) DEFAULT NULL,
  `slug` varchar(250) NOT NULL,
  `titre` varchar(300) NOT NULL,
  `description` longtext NOT NULL,
  `profil_recherche` text DEFAULT NULL,
  `avantages` text DEFAULT NULL,
  `type_contrat` enum('cdi','cdd','interim','alternance','freelance','stage') NOT NULL,
  `experience_min` enum('debutant','1-2','3-5','5-10','10+') DEFAULT NULL,
  `salaire_min` int(11) UNSIGNED DEFAULT NULL,
  `salaire_max` int(11) UNSIGNED DEFAULT NULL,
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
  `vues` int(11) UNSIGNED NOT NULL DEFAULT 0,
  `meta_title` varchar(70) DEFAULT NULL,
  `meta_description` varchar(160) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `offres_emploi`
--

INSERT INTO `offres_emploi` (`id`, `site_id`, `entreprise_id`, `recruteur_id`, `metier_id`, `reference`, `slug`, `titre`, `description`, `profil_recherche`, `avantages`, `type_contrat`, `experience_min`, `salaire_min`, `salaire_max`, `salaire_afficher`, `teletravail`, `temps_travail`, `ville`, `code_postal`, `departement`, `region`, `is_featured`, `is_urgent`, `statut`, `date_publication`, `date_expiration`, `vues`, `meta_title`, `meta_description`, `created_at`, `updated_at`) VALUES
(1, 3, 2, NULL, 2, NULL, 'zdddz', 'zdddz', 'dzd', 'dzdzdz', 'zdzdz', 'cdi', '1-2', 3151, 415149, 0, 'non', 'temps_plein', 'dzd', 'zdzd', 'zdzd', 'zdzd', 0, 1, 'publiee', '2026-06-11 00:00:00', '2026-06-22 23:59:59', 0, NULL, NULL, '2026-06-11 14:57:55', '2026-06-16 10:32:04'),
(2, 2, 1, NULL, 3, NULL, 'zdzzdz', 'zdzzdz', 'dzdzd', 'dzdz', 'zdzdz', 'cdi', 'debutant', 656554, 5156143, 1, 'non', 'temps_plein', 'dzdz', 'zdz', 'dzd', 'zdzd', 1, 1, 'publiee', '2026-06-11 15:39:49', '2026-06-25 23:59:59', 0, NULL, NULL, '2026-06-11 15:39:49', '2026-06-11 15:39:49');

-- --------------------------------------------------------

--
-- Structure de la table `offres_favorites`
--

CREATE TABLE `offres_favorites` (
  `candidat_id` int(11) UNSIGNED NOT NULL,
  `offre_id` int(11) UNSIGNED NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `offre_competences`
--

CREATE TABLE `offre_competences` (
  `offre_id` int(11) UNSIGNED NOT NULL,
  `competence_id` int(11) UNSIGNED NOT NULL,
  `importance` enum('essentielle','souhaitable') NOT NULL DEFAULT 'essentielle'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `offre_competences`
--

INSERT INTO `offre_competences` (`offre_id`, `competence_id`, `importance`) VALUES
(1, 2, 'essentielle'),
(2, 3, 'essentielle');

-- --------------------------------------------------------

--
-- Structure de la table `recruteurs`
--

CREATE TABLE `recruteurs` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `entreprise_id` int(11) UNSIGNED NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `fonction` varchar(150) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `principal` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `secteurs_activite`
--

CREATE TABLE `secteurs_activite` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(100) NOT NULL,
  `label` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `secteurs_activite`
--

INSERT INTO `secteurs_activite` (`id`, `slug`, `label`) VALUES
(1, 'dzdzd', 'dzdzd'),
(2, 'sdzdzdz', 'sdzdzdz');

-- --------------------------------------------------------

--
-- Structure de la table `seo_metadata`
--

CREATE TABLE `seo_metadata` (
  `id` int(11) UNSIGNED NOT NULL,
  `site_id` int(11) NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` int(11) UNSIGNED NOT NULL,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `canonical_url` varchar(500) DEFAULT NULL,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` text DEFAULT NULL,
  `og_image` varchar(500) DEFAULT NULL,
  `schema_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`schema_json`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainers`
--

CREATE TABLE `trainers` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(120) DEFAULT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `title` varchar(200) NOT NULL,
  `tagline` varchar(300) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `avatar_initials` varchar(4) DEFAULT NULL,
  `avatar_url` varchar(512) DEFAULT NULL,
  `city_id` int(11) UNSIGNED DEFAULT NULL,
  `experience_years` int(11) NOT NULL DEFAULT 0,
  `tjm_eur` decimal(10,2) DEFAULT NULL,
  `availability` enum('available','soon','unavailable') DEFAULT 'available',
  `legal_status` enum('auto_entrepreneur','sasu','eurl','portage_salarial','other') DEFAULT NULL,
  `primary_expertise_id` int(11) UNSIGNED DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `linkedin_url` varchar(512) DEFAULT NULL,
  `status` enum('draft','pending_review','active','inactive','rejected') DEFAULT 'pending_review',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `qualiopi_eligible` tinyint(1) NOT NULL DEFAULT 0,
  `rating_avg` decimal(2,1) NOT NULL DEFAULT 0.0,
  `reviews_count` int(11) NOT NULL DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainers`
--

INSERT INTO `trainers` (`id`, `slug`, `first_name`, `last_name`, `title`, `tagline`, `bio`, `avatar_initials`, `avatar_url`, `city_id`, `experience_years`, `tjm_eur`, `availability`, `legal_status`, `primary_expertise_id`, `email`, `phone`, `linkedin_url`, `status`, `is_featured`, `qualiopi_eligible`, `rating_avg`, `reviews_count`, `published_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'dzd-zdzd', 'dzd', 'zdzd', 'dzddz', 'ddzd', 'dzdzd', NULL, 'zdzdzd', NULL, 4, '565265.00', 'soon', 'sasu', 1, 'yanislaldjipro@gmail.com', '0782124452', NULL, 'inactive', 0, 0, '0.0', 0, '2026-06-11 15:02:10', '2026-06-11 15:02:10', '2026-06-15 14:42:54', '2026-06-15 14:42:54'),
(3, 'dzd-zdzddzd', 'dzdzdzdzd', 'zdzddzd', 'zdzdzdzd', 'dzdzd', 'dzzddz', NULL, 'dzdzdz', NULL, 5, '4100.00', 'available', 'eurl', 1, 'zdzd@gmail.com', '0421424', NULL, 'inactive', 0, 0, '0.0', 0, '2026-06-11 15:29:29', '2026-06-11 15:29:29', '2026-06-15 14:42:52', '2026-06-15 14:42:52'),
(4, 'yanis-laldji', 'yanis', 'laldji', 'expert dev', 'je suis fort', 'bonjour', NULL, NULL, NULL, 7, '5000.00', 'available', 'auto_entrepreneur', 1, 'test@gmail.com', '0482124452', 'www.linkedin.com/in/yanis-laldji-4616412a6', 'inactive', 0, 1, '0.0', 0, '2026-06-15 11:07:09', '2026-06-15 11:07:09', '2026-06-15 14:42:50', '2026-06-15 14:42:50'),
(5, 'formateur-test', 'formateur', 'test', 'ygygsgyz', 'ddzd', 'zddzd', NULL, NULL, NULL, 5, '3997.00', 'available', 'eurl', 2, 'test4578@gmail.com', '0742124452', NULL, 'inactive', 0, 0, '0.0', 0, '2026-06-15 11:42:12', '2026-06-15 11:42:12', '2026-06-15 14:42:49', '2026-06-15 14:42:49'),
(6, 'alexandre-test', 'alexandre', 'test', 'test', 'eezsefd', 'dzdzdz', NULL, NULL, NULL, 3, '5000.00', 'available', 'auto_entrepreneur', 2, 'alex@gmail.com', '0465', NULL, 'inactive', 0, 0, '0.0', 0, '2026-06-15 12:32:38', '2026-06-15 12:32:38', '2026-06-15 14:42:47', '2026-06-15 14:42:47'),
(9, 'yandzdzdzdis-laldjizdzd', 'Yandzdzdzdis', 'laldjizdzd', 'expert devdzd', 'je suis fort', 'formation super', NULL, '/api/uploads/trainers/76af6f6f-6699-454b-82fd-1c94a65bfd1b.png', NULL, 4, '100.00', 'available', 'eurl', 2, 'super@gmail.com', '0722124452', NULL, 'active', 0, 0, '0.0', 0, '2026-06-15 14:45:49', '2026-06-15 14:45:49', '2026-06-15 16:04:30', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_applications`
--

CREATE TABLE `trainer_applications` (
  `id` int(11) UNSIGNED NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `linkedin_url` varchar(512) DEFAULT NULL,
  `primary_expertise_id` int(11) UNSIGNED DEFAULT NULL,
  `experience_range` varchar(20) DEFAULT NULL,
  `experience_years` int(11) DEFAULT NULL,
  `tjm_requested` decimal(10,2) DEFAULT NULL,
  `certifications_text` text DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` enum('new','in_review','interview','approved','rejected') NOT NULL DEFAULT 'new',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `trainer_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_certifications`
--

CREATE TABLE `trainer_certifications` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `slug` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_certifications`
--

INSERT INTO `trainer_certifications` (`id`, `name`, `slug`) VALUES
(1, 'dzdzdzd', 'dzdzdzd');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_certification_links`
--

CREATE TABLE `trainer_certification_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `certification_id` int(11) UNSIGNED NOT NULL,
  `obtained_at` date DEFAULT NULL,
  `expires_at` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_certification_links`
--

INSERT INTO `trainer_certification_links` (`trainer_id`, `certification_id`, `obtained_at`, `expires_at`) VALUES
(4, 1, NULL, NULL),
(5, 1, NULL, NULL),
(6, 1, NULL, NULL),
(9, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_cities`
--

CREATE TABLE `trainer_cities` (
  `id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(80) NOT NULL,
  `name` varchar(100) NOT NULL,
  `region` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_cities`
--

INSERT INTO `trainer_cities` (`id`, `slug`, `name`, `region`, `description`, `is_active`) VALUES
(1, 'ddzdz', 'ddzdz', 'zdzd', 'zdzd', 0),
(2, 'test', 'test', 'zdd', 'ddzd', 0);

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
-- Structure de la table `trainer_courses`
--

CREATE TABLE `trainer_courses` (
  `id` int(11) UNSIGNED NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(200) NOT NULL,
  `duration_label` varchar(50) DEFAULT NULL,
  `duration_days` decimal(4,1) DEFAULT NULL,
  `level` enum('debutant','intermediaire','avance','expert') DEFAULT NULL,
  `participants_min` int(11) DEFAULT NULL,
  `participants_max` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_courses`
--

INSERT INTO `trainer_courses` (`id`, `trainer_id`, `title`, `duration_label`, `duration_days`, `level`, `participants_min`, `participants_max`, `description`, `is_active`, `sort_order`, `created_at`) VALUES
(1, 4, 'test module', NULL, NULL, NULL, NULL, NULL, 'test formation', 1, 0, '2026-06-15 11:26:13'),
(2, 5, 'test', NULL, NULL, NULL, NULL, NULL, 'sdzd', 1, 0, '2026-06-15 11:42:13'),
(3, 6, 'test', NULL, NULL, NULL, NULL, NULL, 'dzdzd', 1, 0, '2026-06-15 12:32:38'),
(8, 9, 'php', NULL, NULL, NULL, NULL, NULL, 'php test', 1, 0, '2026-06-15 16:04:30'),
(9, 9, 'test', NULL, NULL, NULL, NULL, NULL, 'sdsds', 1, 1, '2026-06-15 16:04:30');

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
(4, 1, 1),
(4, 2, 0),
(5, 1, 0),
(5, 2, 1),
(6, 1, 0),
(6, 2, 1),
(9, 1, 0),
(9, 2, 1);

-- --------------------------------------------------------

--
-- Structure de la table `trainer_languages`
--

CREATE TABLE `trainer_languages` (
  `id` int(11) UNSIGNED NOT NULL,
  `code` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_languages`
--

INSERT INTO `trainer_languages` (`id`, `code`, `name`) VALUES
(1, 'zd', 'zdzd');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_language_links`
--

CREATE TABLE `trainer_language_links` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `language_id` int(11) UNSIGNED NOT NULL,
  `level` varchar(20) DEFAULT 'native'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_modalities`
--

CREATE TABLE `trainer_modalities` (
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `modality` enum('presentiel','distanciel','hybride') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `trainer_reviews`
--

CREATE TABLE `trainer_reviews` (
  `id` int(11) UNSIGNED NOT NULL,
  `trainer_id` int(11) UNSIGNED NOT NULL,
  `author_name` varchar(100) NOT NULL,
  `company` varchar(150) DEFAULT NULL,
  `rating` smallint(6) NOT NULL CHECK (`rating` between 1 and 5),
  `comment` text NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_reviews`
--

INSERT INTO `trainer_reviews` (`id`, `trainer_id`, `author_name`, `company`, `rating`, `comment`, `is_published`, `created_at`) VALUES
(1, 3, 'dzdzd', 'zdzd', 4, 'zzddzd', 1, '2026-06-11 15:45:35'),
(2, 9, 'alexandre', 'alt rh', 4, 'super formateur', 0, '2026-06-15 16:03:48');

-- --------------------------------------------------------

--
-- Structure de la table `trainer_skills`
--

CREATE TABLE `trainer_skills` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `trainer_skills`
--

INSERT INTO `trainer_skills` (`id`, `name`, `slug`) VALUES
(1, 'dzdzdzd', 'dzdzdzd');

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
(4, 1),
(5, 1),
(6, 1),
(9, 1);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role` enum('candidat','recruteur','consultant') NOT NULL,
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
(1, 'zddzd@gmail.com', NULL, 'candidat', 1, 1, NULL, '2026-06-11 15:44:39', '2026-06-11 15:44:39', NULL);

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
,`created_at` datetime
,`location` varchar(100)
,`city_slug` varchar(80)
,`specialties` mediumtext
,`certifications` mediumtext
,`languages` mediumtext
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_trainers_catalog`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `v_trainers_catalog` (
`id` int(11) unsigned
,`slug` varchar(120)
,`name` varchar(161)
,`title` varchar(200)
,`bio` text
,`avatar_initials` varchar(4)
,`avatar_url` varchar(512)
,`tjm` decimal(10,2)
,`experience` int(11)
,`availability` enum('available','soon','unavailable')
,`rating` decimal(2,1)
,`reviews` int(11)
,`created_at` datetime
,`region` mediumtext
,`cities` mediumtext
,`city_slug` varchar(80)
,`expertise` mediumtext
,`skills` mediumtext
,`certifications` mediumtext
,`modalities` mediumtext
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_coaches_catalog`
--
DROP TABLE IF EXISTS `v_coaches_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY DEFINER VIEW `v_coaches_catalog`  AS SELECT `c`.`id` AS `id`, `c`.`site_id` AS `site_id`, `c`.`slug` AS `slug`, concat(`c`.`first_name`,' ',`c`.`last_name`) AS `name`, `c`.`first_name` AS `first_name`, `c`.`last_name` AS `last_name`, `c`.`title` AS `title`, `c`.`bio_short` AS `bio`, `c`.`bio_full` AS `full_bio`, `c`.`avatar_initials` AS `avatar_initials`, `c`.`avatar_url` AS `avatar_url`, `c`.`experience_years` AS `experience_years`, `c`.`is_featured` AS `is_featured`, `c`.`sort_order` AS `sort_order`, `c`.`published_at` AS `published_at`, `c`.`created_at` AS `created_at`, `cc`.`name` AS `location`, `cc`.`slug` AS `city_slug`, group_concat(distinct `cs`.`name` order by `cs`.`name` ASC separator ', ') AS `specialties`, group_concat(distinct `cert`.`name` order by `cert`.`name` ASC separator ', ') AS `certifications`, group_concat(distinct coalesce(`cl`.`flag_emoji`,`cl`.`code`) order by `cl`.`name` ASC separator ', ') AS `languages` FROM (((((((`coaches` `c` left join `coaching_cities` `cc` on(`cc`.`id` = `c`.`city_id`)) left join `coach_specialty_links` `csl` on(`csl`.`coach_id` = `c`.`id`)) left join `coaching_specialties` `cs` on(`cs`.`id` = `csl`.`specialty_id` and `cs`.`is_active` = 1)) left join `coach_certification_links` `ccl` on(`ccl`.`coach_id` = `c`.`id`)) left join `coaching_certifications` `cert` on(`cert`.`id` = `ccl`.`certification_id`)) left join `coach_language_links` `cll` on(`cll`.`coach_id` = `c`.`id`)) left join `coaching_languages` `cl` on(`cl`.`id` = `cll`.`language_id`)) WHERE `c`.`status` = 'active' AND `c`.`deleted_at` is null GROUP BY `c`.`id`, `c`.`site_id`, `c`.`slug`, `c`.`first_name`, `c`.`last_name`, `c`.`title`, `c`.`bio_short`, `c`.`bio_full`, `c`.`avatar_initials`, `c`.`avatar_url`, `c`.`experience_years`, `c`.`is_featured`, `c`.`sort_order`, `c`.`published_at`, `c`.`created_at`, `cc`.`name`, `cc`.`slug``slug` ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_trainers_catalog`
--
DROP TABLE IF EXISTS `v_trainers_catalog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`o15772578`@`%` SQL SECURITY DEFINER VIEW `v_trainers_catalog`  AS SELECT `t`.`id` AS `id`, `t`.`slug` AS `slug`, concat(`t`.`first_name`,' ',`t`.`last_name`) AS `name`, `t`.`title` AS `title`, `t`.`bio` AS `bio`, `t`.`avatar_initials` AS `avatar_initials`, `t`.`avatar_url` AS `avatar_url`, `t`.`tjm_eur` AS `tjm`, `t`.`experience_years` AS `experience`, `t`.`availability` AS `availability`, `t`.`rating_avg` AS `rating`, `t`.`reviews_count` AS `reviews`, `t`.`created_at` AS `created_at`, coalesce(group_concat(distinct `c_link`.`region` order by `c_link`.`region` ASC separator ', '),`c_main`.`region`) AS `region`, coalesce(group_concat(distinct `c_link`.`name` order by `c_link`.`name` ASC separator ', '),`c_main`.`name`) AS `cities`, coalesce((select `c2`.`slug` from (`trainer_city_links` `tcl2` join `trainer_cities` `c2` on(`c2`.`id` = `tcl2`.`city_id`)) where `tcl2`.`trainer_id` = `t`.`id` limit 1),`c_main`.`slug`) AS `city_slug`, group_concat(distinct `e`.`label` order by `e`.`label` ASC separator ', ') AS `expertise`, group_concat(distinct `sk`.`name` order by `sk`.`name` ASC separator ', ') AS `skills`, group_concat(distinct `cert`.`name` order by `cert`.`name` ASC separator ', ') AS `certifications`, group_concat(distinct `tm`.`modality` separator ', ') AS `modalities` FROM ((((((((((`trainers` `t` left join `trainer_cities` `c_main` on(`c_main`.`id` = `t`.`city_id`)) left join `trainer_city_links` `tcl` on(`tcl`.`trainer_id` = `t`.`id`)) left join `trainer_cities` `c_link` on(`c_link`.`id` = `tcl`.`city_id`)) left join `trainer_expertise_links` `tel` on(`tel`.`trainer_id` = `t`.`id`)) left join `expertises` `e` on(`e`.`id` = `tel`.`expertise_id`)) left join `trainer_skill_links` `tsl` on(`tsl`.`trainer_id` = `t`.`id`)) left join `trainer_skills` `sk` on(`sk`.`id` = `tsl`.`skill_id`)) left join `trainer_certification_links` `tc` on(`tc`.`trainer_id` = `t`.`id`)) left join `trainer_certifications` `cert` on(`cert`.`id` = `tc`.`certification_id`)) left join `trainer_modalities` `tm` on(`tm`.`trainer_id` = `t`.`id`)) WHERE `t`.`status` = 'active' AND `t`.`deleted_at` is null GROUP BY `t`.`id`, `t`.`slug`, `t`.`first_name`, `t`.`last_name`, `t`.`title`, `t`.`bio`, `t`.`avatar_initials`, `t`.`avatar_url`, `t`.`tjm_eur`, `t`.`experience_years`, `t`.`availability`, `t`.`rating_avg`, `t`.`reviews_count`, `t`.`created_at`, `c_main`.`name`, `c_main`.`slug`, `c_main`.`region``region` ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `alertes_emploi`
--
ALTER TABLE `alertes_emploi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_alerte_active` (`candidat_id`,`active`),
  ADD KEY `fk_alerte_metier` (`metier_id`);

--
-- Index pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_author_site_slug` (`site_id`,`slug`),
  ADD UNIQUE KEY `uq_blog_author_site_email` (`site_id`,`email`);

--
-- Index pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_cat_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_blog_cat_active` (`site_id`,`is_active`,`sort_order`);

--
-- Index pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_blog_comment_post` (`post_id`,`status`),
  ADD KEY `fk_blog_comment_parent` (`parent_id`);

--
-- Index pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_post_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_blog_post_status` (`site_id`,`status`,`published_at`),
  ADD KEY `idx_blog_post_featured` (`site_id`,`is_featured`),
  ADD KEY `idx_blog_post_deleted` (`deleted_at`),
  ADD KEY `fk_blog_post_cat` (`category_id`),
  ADD KEY `fk_blog_post_author` (`author_id`);

--
-- Index pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_blog_ver_post` (`post_id`,`created_at`),
  ADD KEY `fk_blog_ver_author` (`created_by`);

--
-- Index pour la table `blog_post_tags`
--
ALTER TABLE `blog_post_tags`
  ADD PRIMARY KEY (`post_id`,`tag_id`),
  ADD KEY `fk_blog_post_tags_tag` (`tag_id`);

--
-- Index pour la table `blog_related_posts`
--
ALTER TABLE `blog_related_posts`
  ADD PRIMARY KEY (`post_id`,`related_post_id`),
  ADD KEY `fk_blog_rel_related` (`related_post_id`);

--
-- Index pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_blog_tag_site_slug` (`site_id`,`slug`);

--
-- Index pour la table `candidats`
--
ALTER TABLE `candidats`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_candidat_user` (`user_id`),
  ADD KEY `idx_candidat_ville` (`ville`),
  ADD KEY `idx_candidat_recherche` (`recherche_active`,`profil_public`);

--
-- Index pour la table `candidatures`
--
ALTER TABLE `candidatures`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_candidature` (`offre_id`,`candidat_id`),
  ADD KEY `idx_candidature_statut` (`statut`,`date_candidature`),
  ADD KEY `fk_cand_candidat` (`candidat_id`);

--
-- Index pour la table `candidatures_externes`
--
ALTER TABLE `candidatures_externes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cand_ext_offre` (`offre_id`,`statut`),
  ADD KEY `fk_candext_site` (`site_id`);

--
-- Index pour la table `candidature_historique`
--
ALTER TABLE `candidature_historique`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_hist_candidature` (`candidature_id`,`created_at`),
  ADD KEY `fk_hist_user` (`auteur_user_id`),
  ADD KEY `fk_hist_admin` (`auteur_admin_id`);

--
-- Index pour la table `candidat_competences`
--
ALTER TABLE `candidat_competences`
  ADD PRIMARY KEY (`candidat_id`,`competence_id`),
  ADD KEY `fk_cc_competence` (`competence_id`);

--
-- Index pour la table `candidat_experiences`
--
ALTER TABLE `candidat_experiences`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_exp_candidat` (`candidat_id`),
  ADD KEY `fk_exp_metier` (`metier_id`);

--
-- Index pour la table `candidat_formations`
--
ALTER TABLE `candidat_formations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_candidat` (`candidat_id`);

--
-- Index pour la table `candidat_metiers_souhaites`
--
ALTER TABLE `candidat_metiers_souhaites`
  ADD PRIMARY KEY (`candidat_id`,`metier_id`),
  ADD KEY `fk_cms_metier` (`metier_id`);

--
-- Index pour la table `coaches`
--
ALTER TABLE `coaches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coach_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_coaches_catalog` (`site_id`,`status`,`is_featured`,`sort_order`),
  ADD KEY `fk_coach_city` (`city_id`);

--
-- Index pour la table `coaching_appointment_slots`
--
ALTER TABLE `coaching_appointment_slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_appt_slot_date` (`site_id`,`slot_date`,`is_active`),
  ADD KEY `fk_appt_coach` (`coach_id`);

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
-- Index pour la table `coaching_contact_requests`
--
ALTER TABLE `coaching_contact_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_contact_req_statut` (`site_id`,`statut`,`created_at`),
  ADD KEY `fk_contact_req_slot` (`slot_id`);

--
-- Index pour la table `coaching_contact_slots`
--
ALTER TABLE `coaching_contact_slots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_contact_slot_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_contact_slot_active` (`site_id`,`is_active`,`sort_order`);

--
-- Index pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_diag_req_statut` (`site_id`,`statut`,`created_at`),
  ADD KEY `fk_diag_req_slot` (`appointment_slot_id`);

--
-- Index pour la table `coaching_languages`
--
ALTER TABLE `coaching_languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_coaching_lang_code` (`code`);

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
  ADD PRIMARY KEY (`coach_id`,`certification_id`),
  ADD KEY `fk_ccl_cert` (`certification_id`);

--
-- Index pour la table `coach_language_links`
--
ALTER TABLE `coach_language_links`
  ADD PRIMARY KEY (`coach_id`,`language_id`),
  ADD KEY `fk_cll_lang` (`language_id`);

--
-- Index pour la table `coach_specialty_links`
--
ALTER TABLE `coach_specialty_links`
  ADD PRIMARY KEY (`coach_id`,`specialty_id`),
  ADD KEY `fk_csl_specialty` (`specialty_id`);

--
-- Index pour la table `competences`
--
ALTER TABLE `competences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_competence_slug` (`slug`);

--
-- Index pour la table `core_admin_password_resets`
--
ALTER TABLE `core_admin_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pwreset_token` (`token_hash`),
  ADD KEY `fk_pwreset_admin` (`admin_id`);

--
-- Index pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_session_admin_exp` (`admin_id`,`expires_at`);

--
-- Index pour la table `core_admin_site_access`
--
ALTER TABLE `core_admin_site_access`
  ADD PRIMARY KEY (`admin_id`,`site_id`),
  ADD KEY `fk_asa_site` (`site_id`);

--
-- Index pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_admin_email` (`email`);

--
-- Index pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_site_date` (`site_id`,`created_at`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `fk_audit_admin` (`admin_id`);

--
-- Index pour la table `core_sites`
--
ALTER TABLE `core_sites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_site_slug` (`slug`),
  ADD UNIQUE KEY `uq_site_domain` (`domain`);

--
-- Index pour la table `entreprises`
--
ALTER TABLE `entreprises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_entreprise_slug` (`slug`),
  ADD UNIQUE KEY `uq_entreprise_siret` (`siret`),
  ADD KEY `idx_entreprise_ville` (`ville`),
  ADD KEY `fk_entreprise_secteur` (`secteur_id`);

--
-- Index pour la table `expertises`
--
ALTER TABLE `expertises`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_expertise_slug` (`slug`);

--
-- Index pour la table `formations`
--
ALTER TABLE `formations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_formation_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_formation_catalogue` (`site_id`,`type`,`status`,`published_at`),
  ADD KEY `fk_formation_category` (`category_id`),
  ADD KEY `fk_formation_created_by` (`created_by`),
  ADD KEY `fk_formation_updated_by` (`updated_by`);

--
-- Index pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_form_cat_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_form_cat_active` (`site_id`,`is_active`,`sort_order`);

--
-- Index pour la table `formation_job_outcomes`
--
ALTER TABLE `formation_job_outcomes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_jobs` (`formation_id`,`sort_order`);

--
-- Index pour la table `formation_list_items`
--
ALTER TABLE `formation_list_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_list` (`formation_id`,`list_type`,`sort_order`);

--
-- Index pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_modules` (`formation_id`,`sort_order`);

--
-- Index pour la table `formation_official_certifications`
--
ALTER TABLE `formation_official_certifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_formation_cert` (`formation_id`,`repertoire`),
  ADD KEY `idx_official_cert_code` (`repertoire`,`code`);

--
-- Index pour la table `formation_stats`
--
ALTER TABLE `formation_stats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_form_stats` (`formation_id`,`sort_order`);

--
-- Index pour la table `gdpr_consents_log`
--
ALTER TABLE `gdpr_consents_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdpr_site_type` (`site_id`,`consent_type`,`granted_at`);

--
-- Index pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_gdpr_del_status` (`site_id`,`status`),
  ADD KEY `fk_gdpr_del_admin` (`processed_by`);

--
-- Index pour la table `marketing_email_logs`
--
ALTER TABLE `marketing_email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email_log_site` (`site_id`,`created_at`);

--
-- Index pour la table `media_library`
--
ALTER TABLE `media_library`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_media_site` (`site_id`),
  ADD KEY `idx_media_mime` (`mime_type`),
  ADD KEY `idx_media_type` (`file_type`),
  ADD KEY `idx_media_uploaded` (`uploaded_by`);

--
-- Index pour la table `metiers`
--
ALTER TABLE `metiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_metier_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_metier_actif` (`site_id`,`actif`),
  ADD KEY `fk_metier_secteur` (`secteur_id`);
ALTER TABLE `metiers` ADD FULLTEXT KEY `ft_metier` (`libelle`,`description`);

--
-- Index pour la table `metier_competences`
--
ALTER TABLE `metier_competences`
  ADD PRIMARY KEY (`metier_id`,`competence_id`),
  ADD KEY `fk_mc_competence` (`competence_id`);

--
-- Index pour la table `newsletter_campaigns`
--
ALTER TABLE `newsletter_campaigns`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_campaign_status` (`site_id`,`status`),
  ADD KEY `fk_nl_camp_list` (`list_id`),
  ADD KEY `fk_nl_camp_created_by` (`created_by`);

--
-- Index pour la table `newsletter_events`
--
ALTER TABLE `newsletter_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_nl_event_campaign` (`campaign_id`,`event_type`),
  ADD KEY `fk_nl_evt_subscriber` (`subscriber_id`);

--
-- Index pour la table `newsletter_lists`
--
ALTER TABLE `newsletter_lists`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_nl_list_slug` (`site_id`,`slug`);

--
-- Index pour la table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_subscriber_site_email` (`site_id`,`email`),
  ADD KEY `idx_subscriber_status` (`site_id`,`status`),
  ADD KEY `fk_nl_sub_user` (`user_id`);

--
-- Index pour la table `newsletter_subscriptions`
--
ALTER TABLE `newsletter_subscriptions`
  ADD PRIMARY KEY (`subscriber_id`,`list_id`),
  ADD KEY `fk_nl_sub_list` (`list_id`);

--
-- Index pour la table `offres_emploi`
--
ALTER TABLE `offres_emploi`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_offre_site_slug` (`site_id`,`slug`),
  ADD KEY `idx_offre_site_statut` (`site_id`,`statut`,`date_publication`),
  ADD KEY `idx_offre_ville` (`ville`),
  ADD KEY `fk_offre_entreprise` (`entreprise_id`),
  ADD KEY `fk_offre_recruteur` (`recruteur_id`),
  ADD KEY `fk_offre_metier` (`metier_id`);
ALTER TABLE `offres_emploi` ADD FULLTEXT KEY `ft_offre` (`titre`,`description`,`profil_recherche`);

--
-- Index pour la table `offres_favorites`
--
ALTER TABLE `offres_favorites`
  ADD PRIMARY KEY (`candidat_id`,`offre_id`),
  ADD KEY `fk_fav_offre` (`offre_id`);

--
-- Index pour la table `offre_competences`
--
ALTER TABLE `offre_competences`
  ADD PRIMARY KEY (`offre_id`,`competence_id`),
  ADD KEY `fk_oc_competence` (`competence_id`);

--
-- Index pour la table `recruteurs`
--
ALTER TABLE `recruteurs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recruteur_user` (`user_id`),
  ADD KEY `idx_recruteur_entreprise` (`entreprise_id`);

--
-- Index pour la table `secteurs_activite`
--
ALTER TABLE `secteurs_activite`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_secteur_slug` (`slug`);

--
-- Index pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_seo_entity` (`site_id`,`entity_type`,`entity_id`);

--
-- Index pour la table `trainers`
--
ALTER TABLE `trainers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_email` (`email`),
  ADD UNIQUE KEY `uq_trainer_slug` (`slug`),
  ADD KEY `idx_trainers_catalog` (`status`,`availability`,`rating_avg`),
  ADD KEY `fk_trainer_city` (`city_id`),
  ADD KEY `fk_trainer_expertise` (`primary_expertise_id`);

--
-- Index pour la table `trainer_applications`
--
ALTER TABLE `trainer_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tapp_status` (`status`,`created_at`),
  ADD KEY `fk_tapp_expertise` (`primary_expertise_id`),
  ADD KEY `fk_tapp_reviewer` (`reviewed_by`),
  ADD KEY `fk_tapp_trainer` (`trainer_id`);

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
  ADD PRIMARY KEY (`trainer_id`,`certification_id`),
  ADD KEY `fk_tcl_cert` (`certification_id`);

--
-- Index pour la table `trainer_cities`
--
ALTER TABLE `trainer_cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_trainer_city_slug` (`slug`),
  ADD KEY `idx_trainer_city_region` (`region`,`is_active`);

--
-- Index pour la table `trainer_city_links`
--
ALTER TABLE `trainer_city_links`
  ADD PRIMARY KEY (`trainer_id`,`city_id`),
  ADD KEY `fk_tcityl_city` (`city_id`);

--
-- Index pour la table `trainer_courses`
--
ALTER TABLE `trainer_courses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tcourse_trainer` (`trainer_id`,`is_active`);

--
-- Index pour la table `trainer_expertise_links`
--
ALTER TABLE `trainer_expertise_links`
  ADD PRIMARY KEY (`trainer_id`,`expertise_id`),
  ADD KEY `fk_tel_expertise` (`expertise_id`);

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
  ADD PRIMARY KEY (`trainer_id`,`language_id`),
  ADD KEY `fk_tll_lang` (`language_id`);

--
-- Index pour la table `trainer_modalities`
--
ALTER TABLE `trainer_modalities`
  ADD PRIMARY KEY (`trainer_id`,`modality`);

--
-- Index pour la table `trainer_reviews`
--
ALTER TABLE `trainer_reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_treview_trainer` (`trainer_id`,`is_published`);

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
  ADD PRIMARY KEY (`trainer_id`,`skill_id`),
  ADD KEY `fk_tsl_skill` (`skill_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_email` (`email`),
  ADD KEY `idx_users_role` (`role`,`actif`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `alertes_emploi`
--
ALTER TABLE `alertes_emploi`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `candidats`
--
ALTER TABLE `candidats`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `candidatures`
--
ALTER TABLE `candidatures`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `candidatures_externes`
--
ALTER TABLE `candidatures_externes`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `candidature_historique`
--
ALTER TABLE `candidature_historique`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `candidat_experiences`
--
ALTER TABLE `candidat_experiences`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `candidat_formations`
--
ALTER TABLE `candidat_formations`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaches`
--
ALTER TABLE `coaches`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `coaching_appointment_slots`
--
ALTER TABLE `coaching_appointment_slots`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `coaching_certifications`
--
ALTER TABLE `coaching_certifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `coaching_cities`
--
ALTER TABLE `coaching_cities`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `coaching_contact_requests`
--
ALTER TABLE `coaching_contact_requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_contact_slots`
--
ALTER TABLE `coaching_contact_slots`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `coaching_languages`
--
ALTER TABLE `coaching_languages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `coaching_specialties`
--
ALTER TABLE `coaching_specialties`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `competences`
--
ALTER TABLE `competences`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `core_admin_password_resets`
--
ALTER TABLE `core_admin_password_resets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `core_admin_users`
--
ALTER TABLE `core_admin_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT pour la table `core_sites`
--
ALTER TABLE `core_sites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `entreprises`
--
ALTER TABLE `entreprises`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `expertises`
--
ALTER TABLE `expertises`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `formations`
--
ALTER TABLE `formations`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `formation_job_outcomes`
--
ALTER TABLE `formation_job_outcomes`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_list_items`
--
ALTER TABLE `formation_list_items`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `formation_official_certifications`
--
ALTER TABLE `formation_official_certifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `formation_stats`
--
ALTER TABLE `formation_stats`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `gdpr_consents_log`
--
ALTER TABLE `gdpr_consents_log`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `marketing_email_logs`
--
ALTER TABLE `marketing_email_logs`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `media_library`
--
ALTER TABLE `media_library`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT pour la table `metiers`
--
ALTER TABLE `metiers`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `newsletter_campaigns`
--
ALTER TABLE `newsletter_campaigns`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `newsletter_events`
--
ALTER TABLE `newsletter_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `newsletter_lists`
--
ALTER TABLE `newsletter_lists`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `offres_emploi`
--
ALTER TABLE `offres_emploi`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `recruteurs`
--
ALTER TABLE `recruteurs`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `secteurs_activite`
--
ALTER TABLE `secteurs_activite`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `trainers`
--
ALTER TABLE `trainers`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `trainer_applications`
--
ALTER TABLE `trainer_applications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `trainer_certifications`
--
ALTER TABLE `trainer_certifications`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `trainer_cities`
--
ALTER TABLE `trainer_cities`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `trainer_courses`
--
ALTER TABLE `trainer_courses`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `trainer_languages`
--
ALTER TABLE `trainer_languages`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `trainer_reviews`
--
ALTER TABLE `trainer_reviews`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `trainer_skills`
--
ALTER TABLE `trainer_skills`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `alertes_emploi`
--
ALTER TABLE `alertes_emploi`
  ADD CONSTRAINT `fk_alerte_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_alerte_metier` FOREIGN KEY (`metier_id`) REFERENCES `metiers` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `blog_authors`
--
ALTER TABLE `blog_authors`
  ADD CONSTRAINT `fk_blog_author_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD CONSTRAINT `fk_blog_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_comments`
--
ALTER TABLE `blog_comments`
  ADD CONSTRAINT `fk_blog_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `blog_comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_blog_comment_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_posts`
--
ALTER TABLE `blog_posts`
  ADD CONSTRAINT `fk_blog_post_author` FOREIGN KEY (`author_id`) REFERENCES `blog_authors` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_post_cat` FOREIGN KEY (`category_id`) REFERENCES `blog_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_post_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_posts_versions`
--
ALTER TABLE `blog_posts_versions`
  ADD CONSTRAINT `fk_blog_ver_author` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`),
  ADD CONSTRAINT `fk_blog_ver_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_post_tags`
--
ALTER TABLE `blog_post_tags`
  ADD CONSTRAINT `fk_blog_post_tags_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_blog_post_tags_tag` FOREIGN KEY (`tag_id`) REFERENCES `blog_tags` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_related_posts`
--
ALTER TABLE `blog_related_posts`
  ADD CONSTRAINT `fk_blog_rel_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_blog_rel_related` FOREIGN KEY (`related_post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `blog_tags`
--
ALTER TABLE `blog_tags`
  ADD CONSTRAINT `fk_blog_tag_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidats`
--
ALTER TABLE `candidats`
  ADD CONSTRAINT `fk_candidat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidatures`
--
ALTER TABLE `candidatures`
  ADD CONSTRAINT `fk_cand_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cand_offre` FOREIGN KEY (`offre_id`) REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidatures_externes`
--
ALTER TABLE `candidatures_externes`
  ADD CONSTRAINT `fk_candext_offre` FOREIGN KEY (`offre_id`) REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_candext_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidature_historique`
--
ALTER TABLE `candidature_historique`
  ADD CONSTRAINT `fk_hist_admin` FOREIGN KEY (`auteur_admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_hist_candidature` FOREIGN KEY (`candidature_id`) REFERENCES `candidatures` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_hist_user` FOREIGN KEY (`auteur_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `candidat_competences`
--
ALTER TABLE `candidat_competences`
  ADD CONSTRAINT `fk_cc_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidat_experiences`
--
ALTER TABLE `candidat_experiences`
  ADD CONSTRAINT `fk_exp_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_exp_metier` FOREIGN KEY (`metier_id`) REFERENCES `metiers` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `candidat_formations`
--
ALTER TABLE `candidat_formations`
  ADD CONSTRAINT `fk_form_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `candidat_metiers_souhaites`
--
ALTER TABLE `candidat_metiers_souhaites`
  ADD CONSTRAINT `fk_cms_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cms_metier` FOREIGN KEY (`metier_id`) REFERENCES `metiers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaches`
--
ALTER TABLE `coaches`
  ADD CONSTRAINT `fk_coach_city` FOREIGN KEY (`city_id`) REFERENCES `coaching_cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_coach_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_appointment_slots`
--
ALTER TABLE `coaching_appointment_slots`
  ADD CONSTRAINT `fk_appt_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_appt_slot_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_contact_requests`
--
ALTER TABLE `coaching_contact_requests`
  ADD CONSTRAINT `fk_contact_req_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_contact_req_slot` FOREIGN KEY (`slot_id`) REFERENCES `coaching_contact_slots` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `coaching_contact_slots`
--
ALTER TABLE `coaching_contact_slots`
  ADD CONSTRAINT `fk_contact_slot_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coaching_diagnostic_requests`
--
ALTER TABLE `coaching_diagnostic_requests`
  ADD CONSTRAINT `fk_diag_req_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_diag_req_slot` FOREIGN KEY (`appointment_slot_id`) REFERENCES `coaching_appointment_slots` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `coach_certification_links`
--
ALTER TABLE `coach_certification_links`
  ADD CONSTRAINT `fk_ccl_cert` FOREIGN KEY (`certification_id`) REFERENCES `coaching_certifications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ccl_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coach_language_links`
--
ALTER TABLE `coach_language_links`
  ADD CONSTRAINT `fk_cll_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cll_lang` FOREIGN KEY (`language_id`) REFERENCES `coaching_languages` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `coach_specialty_links`
--
ALTER TABLE `coach_specialty_links`
  ADD CONSTRAINT `fk_csl_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_csl_specialty` FOREIGN KEY (`specialty_id`) REFERENCES `coaching_specialties` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_password_resets`
--
ALTER TABLE `core_admin_password_resets`
  ADD CONSTRAINT `fk_pwreset_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_sessions`
--
ALTER TABLE `core_admin_sessions`
  ADD CONSTRAINT `fk_session_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_admin_site_access`
--
ALTER TABLE `core_admin_site_access`
  ADD CONSTRAINT `fk_asa_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_asa_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `core_audit_logs`
--
ALTER TABLE `core_audit_logs`
  ADD CONSTRAINT `fk_audit_admin` FOREIGN KEY (`admin_id`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_audit_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `entreprises`
--
ALTER TABLE `entreprises`
  ADD CONSTRAINT `fk_entreprise_secteur` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs_activite` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `formations`
--
ALTER TABLE `formations`
  ADD CONSTRAINT `fk_formation_category` FOREIGN KEY (`category_id`) REFERENCES `formation_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_formation_created_by` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_formation_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_formation_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `formation_categories`
--
ALTER TABLE `formation_categories`
  ADD CONSTRAINT `fk_form_cat_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_job_outcomes`
--
ALTER TABLE `formation_job_outcomes`
  ADD CONSTRAINT `fk_formation_job_outcomes` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_list_items`
--
ALTER TABLE `formation_list_items`
  ADD CONSTRAINT `fk_formation_list_items` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_modules`
--
ALTER TABLE `formation_modules`
  ADD CONSTRAINT `fk_formation_modules` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_official_certifications`
--
ALTER TABLE `formation_official_certifications`
  ADD CONSTRAINT `fk_formation_official_cert` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `formation_stats`
--
ALTER TABLE `formation_stats`
  ADD CONSTRAINT `fk_formation_stats` FOREIGN KEY (`formation_id`) REFERENCES `formations` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `gdpr_consents_log`
--
ALTER TABLE `gdpr_consents_log`
  ADD CONSTRAINT `fk_gdpr_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `gdpr_deletion_requests`
--
ALTER TABLE `gdpr_deletion_requests`
  ADD CONSTRAINT `fk_gdpr_del_admin` FOREIGN KEY (`processed_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_gdpr_del_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `marketing_email_logs`
--
ALTER TABLE `marketing_email_logs`
  ADD CONSTRAINT `fk_email_log_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `media_library`
--
ALTER TABLE `media_library`
  ADD CONSTRAINT `fk_media_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_media_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `metiers`
--
ALTER TABLE `metiers`
  ADD CONSTRAINT `fk_metier_secteur` FOREIGN KEY (`secteur_id`) REFERENCES `secteurs_activite` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_metier_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `metier_competences`
--
ALTER TABLE `metier_competences`
  ADD CONSTRAINT `fk_mc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mc_metier` FOREIGN KEY (`metier_id`) REFERENCES `metiers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `newsletter_campaigns`
--
ALTER TABLE `newsletter_campaigns`
  ADD CONSTRAINT `fk_nl_camp_created_by` FOREIGN KEY (`created_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_nl_camp_list` FOREIGN KEY (`list_id`) REFERENCES `newsletter_lists` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_nl_camp_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `newsletter_events`
--
ALTER TABLE `newsletter_events`
  ADD CONSTRAINT `fk_nl_evt_campaign` FOREIGN KEY (`campaign_id`) REFERENCES `newsletter_campaigns` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_nl_evt_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscribers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `newsletter_lists`
--
ALTER TABLE `newsletter_lists`
  ADD CONSTRAINT `fk_nl_list_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `newsletter_subscribers`
--
ALTER TABLE `newsletter_subscribers`
  ADD CONSTRAINT `fk_nl_sub_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_nl_sub_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `newsletter_subscriptions`
--
ALTER TABLE `newsletter_subscriptions`
  ADD CONSTRAINT `fk_nl_sub_list` FOREIGN KEY (`list_id`) REFERENCES `newsletter_lists` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_nl_sub_subscriber` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscribers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `offres_emploi`
--
ALTER TABLE `offres_emploi`
  ADD CONSTRAINT `fk_offre_entreprise` FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_offre_metier` FOREIGN KEY (`metier_id`) REFERENCES `metiers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_offre_recruteur` FOREIGN KEY (`recruteur_id`) REFERENCES `recruteurs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_offre_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `offres_favorites`
--
ALTER TABLE `offres_favorites`
  ADD CONSTRAINT `fk_fav_candidat` FOREIGN KEY (`candidat_id`) REFERENCES `candidats` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_fav_offre` FOREIGN KEY (`offre_id`) REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `offre_competences`
--
ALTER TABLE `offre_competences`
  ADD CONSTRAINT `fk_oc_competence` FOREIGN KEY (`competence_id`) REFERENCES `competences` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_oc_offre` FOREIGN KEY (`offre_id`) REFERENCES `offres_emploi` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `recruteurs`
--
ALTER TABLE `recruteurs`
  ADD CONSTRAINT `fk_recruteur_entreprise` FOREIGN KEY (`entreprise_id`) REFERENCES `entreprises` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_recruteur_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `seo_metadata`
--
ALTER TABLE `seo_metadata`
  ADD CONSTRAINT `fk_seo_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainers`
--
ALTER TABLE `trainers`
  ADD CONSTRAINT `fk_trainer_city` FOREIGN KEY (`city_id`) REFERENCES `trainer_cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_trainer_expertise` FOREIGN KEY (`primary_expertise_id`) REFERENCES `expertises` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `trainer_applications`
--
ALTER TABLE `trainer_applications`
  ADD CONSTRAINT `fk_tapp_expertise` FOREIGN KEY (`primary_expertise_id`) REFERENCES `expertises` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tapp_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `core_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tapp_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `trainer_certification_links`
--
ALTER TABLE `trainer_certification_links`
  ADD CONSTRAINT `fk_tcl_cert` FOREIGN KEY (`certification_id`) REFERENCES `trainer_certifications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tcl_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_city_links`
--
ALTER TABLE `trainer_city_links`
  ADD CONSTRAINT `fk_tcityl_city` FOREIGN KEY (`city_id`) REFERENCES `trainer_cities` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tcityl_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_courses`
--
ALTER TABLE `trainer_courses`
  ADD CONSTRAINT `fk_tcourse_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_expertise_links`
--
ALTER TABLE `trainer_expertise_links`
  ADD CONSTRAINT `fk_tel_expertise` FOREIGN KEY (`expertise_id`) REFERENCES `expertises` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tel_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_language_links`
--
ALTER TABLE `trainer_language_links`
  ADD CONSTRAINT `fk_tll_lang` FOREIGN KEY (`language_id`) REFERENCES `trainer_languages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tll_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_modalities`
--
ALTER TABLE `trainer_modalities`
  ADD CONSTRAINT `fk_tmod_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_reviews`
--
ALTER TABLE `trainer_reviews`
  ADD CONSTRAINT `fk_treview_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `trainer_skill_links`
--
ALTER TABLE `trainer_skill_links`
  ADD CONSTRAINT `fk_tsl_skill` FOREIGN KEY (`skill_id`) REFERENCES `trainer_skills` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tsl_trainer` FOREIGN KEY (`trainer_id`) REFERENCES `trainers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
