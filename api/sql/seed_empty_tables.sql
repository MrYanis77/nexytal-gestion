-- =============================================================================
-- NEXYTAL — Remplissage des tables encore vides (Ionos dbs15772578)
-- Compatible avec une BDD partiellement peuplée (tests API ou seed partiel).
-- Idempotent : peut être relancé sans doublons.
--
-- Usage phpMyAdmin :
--   1. Sélectionner la base dbs15772578
--   2. Importer ce fichier
--   3. Vérifier avec verify_all_tables.sql
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

USE `dbs15772578`;

-- -----------------------------------------------------------------------------
-- 1. blog_posts_versions — une version initiale par article existant
-- -----------------------------------------------------------------------------
INSERT INTO `blog_posts_versions` (`post_id`, `title`, `content`, `status`, `created_by`, `created_at`)
SELECT
  p.`id`,
  CONCAT(p.`title`, ' (v1)'),
  p.`content`,
  p.`status`,
  p.`author_id`,
  p.`created_at`
FROM `blog_posts` p
WHERE NOT EXISTS (
  SELECT 1 FROM `blog_posts_versions` v WHERE v.`post_id` = p.`id`
);

-- -----------------------------------------------------------------------------
-- 2. formation_skills — 3 compétences par formation sans skills
-- -----------------------------------------------------------------------------
INSERT INTO `formation_skills` (`course_id`, `name`, `sort_order`)
SELECT c.`id`, 'Maîtriser les fondamentaux du métier visé', 1
FROM `formation_courses` c
WHERE NOT EXISTS (SELECT 1 FROM `formation_skills` s WHERE s.`course_id` = c.`id`);

INSERT INTO `formation_skills` (`course_id`, `name`, `sort_order`)
SELECT c.`id`, 'Appliquer les bonnes pratiques professionnelles', 2
FROM `formation_courses` c
WHERE (SELECT COUNT(*) FROM `formation_skills` s WHERE s.`course_id` = c.`id`) = 1;

INSERT INTO `formation_skills` (`course_id`, `name`, `sort_order`)
SELECT c.`id`, 'Mener un projet réel en autonomie', 3
FROM `formation_courses` c
WHERE (SELECT COUNT(*) FROM `formation_skills` s WHERE s.`course_id` = c.`id`) = 2;

-- -----------------------------------------------------------------------------
-- 3. formation_jobs — 2 débouchés par formation sans jobs
-- -----------------------------------------------------------------------------
INSERT INTO `formation_jobs` (`course_id`, `title`, `salary_min`, `salary_max`, `sort_order`)
SELECT c.`id`, CONCAT('Emploi junior — ', LEFT(c.`title`, 120)), 32000.00, 42000.00, 1
FROM `formation_courses` c
WHERE NOT EXISTS (SELECT 1 FROM `formation_jobs` j WHERE j.`course_id` = c.`id`);

INSERT INTO `formation_jobs` (`course_id`, `title`, `salary_min`, `salary_max`, `sort_order`)
SELECT c.`id`, CONCAT('Emploi confirmé — ', LEFT(c.`title`, 120)), 42000.00, 62000.00, 2
FROM `formation_courses` c
WHERE (SELECT COUNT(*) FROM `formation_jobs` j WHERE j.`course_id` = c.`id`) = 1;

-- -----------------------------------------------------------------------------
-- 4. coaching_coach_certifications — lier coachs ↔ certifications existantes
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `coaching_coach_certifications` (`coach_id`, `certification_id`, `year_obtained`)
SELECT cc.`id`, cert.`id`, 2023
FROM `coaching_coaches` cc
INNER JOIN (
  SELECT MIN(`id`) AS `id` FROM `coaching_certifications`
) cert ON 1 = 1
WHERE NOT EXISTS (
  SELECT 1 FROM `coaching_coach_certifications` ccc WHERE ccc.`coach_id` = cc.`id`
);

INSERT IGNORE INTO `coaching_coach_certifications` (`coach_id`, `certification_id`, `year_obtained`)
SELECT cc.`id`, cert.`id`, 2021
FROM `coaching_coaches` cc
INNER JOIN (
  SELECT `id` FROM `coaching_certifications` ORDER BY `id` ASC LIMIT 1 OFFSET 1
) cert ON 1 = 1
WHERE (SELECT COUNT(*) FROM `coaching_coach_certifications` ccc WHERE ccc.`coach_id` = cc.`id`) = 1;

-- -----------------------------------------------------------------------------
-- 5. coaching_reviews — un avis publié par coach actif sans avis
-- -----------------------------------------------------------------------------
INSERT INTO `coaching_reviews`
  (`coach_id`, `author_name`, `author_title`, `author_company`, `rating`, `comment`, `is_verified`, `is_published`)
SELECT
  cc.`id`,
  CONCAT('Client satisfait ', cc.`id`),
  'Manager',
  'Entreprise partenaire',
  5,
  CONCAT(
    'Excellent accompagnement avec ',
    cc.`first_name`, ' ', cc.`last_name`,
    '. Je recommande vivement ce coach.'
  ),
  1,
  1
FROM `coaching_coaches` cc
WHERE cc.`status` = 'active'
  AND NOT EXISTS (SELECT 1 FROM `coaching_reviews` r WHERE r.`coach_id` = cc.`id`);

-- -----------------------------------------------------------------------------
-- 6. coaching_diagnostic_requests — demandes de diagnostic réalistes
-- -----------------------------------------------------------------------------
INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `phone`, `company`, `job_title`,
   `coaching_type`, `message`, `budget_range`, `status`)
SELECT
  (SELECT MIN(`id`) FROM `coaching_coaches`),
  'Henri', 'Vasseur', 'henri.vasseur@seed.nexytal.com', '06 90 90 90 90',
  'FinTech Solutions', 'Directeur Général',
  'Coaching de dirigeants',
  'Je prends la direction générale en septembre et souhaite un accompagnement de 6 mois.',
  '10k-20k', 'contacted'
WHERE EXISTS (SELECT 1 FROM `coaching_coaches`)
  AND NOT EXISTS (
    SELECT 1 FROM `coaching_diagnostic_requests` d WHERE d.`email` = 'henri.vasseur@seed.nexytal.com'
  );

INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `phone`, `company`, `job_title`,
   `coaching_type`, `message`, `budget_range`, `status`)
SELECT
  (SELECT MAX(`id`) FROM `coaching_coaches`),
  'Karima', 'Boudali', 'karima.boudali@seed.nexytal.com', '07 01 01 01 01',
  'Grande Distribution', 'Responsable d''équipe',
  'Coaching de managers',
  'Mon équipe de 8 personnes traverse des tensions. J''ai besoin d''outils concrets.',
  '5k-10k', 'new'
WHERE EXISTS (SELECT 1 FROM `coaching_coaches`)
  AND NOT EXISTS (
    SELECT 1 FROM `coaching_diagnostic_requests` d WHERE d.`email` = 'karima.boudali@seed.nexytal.com'
  );

INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `coaching_type`, `message`, `budget_range`, `status`)
SELECT
  NULL,
  'Pierre', 'Garnier', 'pierre.garnier@seed.nexytal.com',
  'Prise de parole en public',
  'Je dois animer des conférences et j''ai une peur intense de prendre la parole.',
  '<5k', 'new'
WHERE NOT EXISTS (
  SELECT 1 FROM `coaching_diagnostic_requests` d WHERE d.`email` = 'pierre.garnier@seed.nexytal.com'
);

INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `coaching_type`, `message`, `budget_range`, `status`)
SELECT
  NULL,
  'Thomas', 'Collin', 'thomas.collin@seed.nexytal.com',
  'Coaching bien-être',
  'Je ressens des signes de burn-out et souhaite un accompagnement préventif.',
  '<5k', 'new'
WHERE NOT EXISTS (
  SELECT 1 FROM `coaching_diagnostic_requests` d WHERE d.`email` = 'thomas.collin@seed.nexytal.com'
);

INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `coaching_type`, `message`, `budget_range`, `status`)
SELECT
  (SELECT MIN(`id`) FROM `coaching_coaches`),
  'Laure', 'Mignot', 'laure.mignot@seed.nexytal.com',
  'Reconversion professionnelle',
  'Je veux changer de métier après 12 ans dans l''assurance.',
  '5k-10k', 'converted'
WHERE EXISTS (SELECT 1 FROM `coaching_coaches`)
  AND NOT EXISTS (
    SELECT 1 FROM `coaching_diagnostic_requests` d WHERE d.`email` = 'laure.mignot@seed.nexytal.com'
  );

-- -----------------------------------------------------------------------------
-- 7. recrutement_application_history — historique pipeline par candidature
-- -----------------------------------------------------------------------------
INSERT INTO `recrutement_application_history`
  (`application_id`, `old_status`, `new_status`, `changed_by_id`, `note`)
SELECT
  a.`id`,
  NULL,
  a.`status`,
  (SELECT MIN(`id`) FROM `core_admin_users` WHERE `is_active` = 1),
  CONCAT('Candidature enregistrée — statut initial : ', a.`status`)
FROM `recrutement_applications` a
WHERE NOT EXISTS (
  SELECT 1 FROM `recrutement_application_history` h WHERE h.`application_id` = a.`id`
);

INSERT INTO `recrutement_application_history`
  (`application_id`, `old_status`, `new_status`, `changed_by_id`, `note`)
SELECT
  a.`id`,
  'new',
  a.`status`,
  (SELECT MIN(`id`) FROM `core_admin_users` WHERE `is_active` = 1),
  'Passage en revue par le recruteur'
FROM `recrutement_applications` a
WHERE a.`status` IN ('reviewing', 'interview', 'offer', 'hired', 'rejected')
  AND (SELECT COUNT(*) FROM `recrutement_application_history` h WHERE h.`application_id` = a.`id`) = 1;

INSERT INTO `recrutement_application_history`
  (`application_id`, `old_status`, `new_status`, `changed_by_id`, `note`)
SELECT
  a.`id`,
  'reviewing',
  a.`status`,
  (SELECT MIN(`id`) FROM `core_admin_users` WHERE `is_active` = 1),
  'Mise à jour avancée du pipeline'
FROM `recrutement_applications` a
WHERE a.`status` IN ('interview', 'offer', 'hired')
  AND (SELECT COUNT(*) FROM `recrutement_application_history` h WHERE h.`application_id` = a.`id`) = 2;

-- -----------------------------------------------------------------------------
-- 8. gdpr_consents — consentements liés aux données existantes
-- -----------------------------------------------------------------------------
INSERT INTO `gdpr_consents`
  (`user_type`, `user_email`, `user_id`, `consent_type`, `is_given`, `given_at`, `ip_address`)
SELECT
  'applicant',
  a.`email`,
  a.`id`,
  'data_processing',
  COALESCE(a.`gdpr_consent`, 1),
  a.`gdpr_consent_date`,
  '88.101.23.45'
FROM `recrutement_applications` a
WHERE NOT EXISTS (
  SELECT 1 FROM `gdpr_consents` g
  WHERE g.`user_email` = a.`email` AND g.`consent_type` = 'data_processing' AND g.`user_type` = 'applicant'
);

INSERT INTO `gdpr_consents`
  (`user_type`, `user_email`, `user_id`, `consent_type`, `is_given`, `given_at`, `ip_address`)
SELECT
  'subscriber',
  n.`email`,
  NULL,
  'marketing',
  n.`is_active`,
  COALESCE(n.`created_at`, NOW()),
  '92.123.45.67'
FROM `marketing_newsletter_subs` n
WHERE NOT EXISTS (
  SELECT 1 FROM `gdpr_consents` g
  WHERE g.`user_email` = n.`email` AND g.`consent_type` = 'marketing' AND g.`user_type` = 'subscriber'
);

INSERT INTO `gdpr_consents`
  (`user_type`, `user_email`, `user_id`, `consent_type`, `is_given`, `given_at`, `ip_address`)
SELECT
  'diagnostic_request',
  d.`email`,
  NULL,
  'data_processing',
  1,
  d.`created_at`,
  '94.156.78.90'
FROM `coaching_diagnostic_requests` d
WHERE NOT EXISTS (
  SELECT 1 FROM `gdpr_consents` g
  WHERE g.`user_email` = d.`email` AND g.`consent_type` = 'data_processing' AND g.`user_type` = 'diagnostic_request'
);

INSERT INTO `gdpr_consents`
  (`user_type`, `user_email`, `user_id`, `consent_type`, `is_given`, `given_at`, `ip_address`)
SELECT
  'review_author',
  CONCAT('avis.', r.`coach_id`, '.', r.`id`, '@seed.nexytal.com'),
  NULL,
  'data_processing',
  1,
  r.`created_at`,
  '88.167.89.01'
FROM `coaching_reviews` r
WHERE NOT EXISTS (
  SELECT 1 FROM `gdpr_consents` g
  WHERE g.`user_email` = CONCAT('avis.', r.`coach_id`, '.', r.`id`, '@seed.nexytal.com')
);

-- Consentement marketing refusé (exemple)
INSERT IGNORE INTO `gdpr_consents`
  (`user_type`, `user_email`, `consent_type`, `is_given`, `given_at`, `ip_address`)
SELECT 'subscriber', 'exemple.refus@seed.nexytal.com', 'marketing', 0, NOW(), '82.145.67.89'
WHERE NOT EXISTS (
  SELECT 1 FROM `gdpr_consents` g WHERE g.`user_email` = 'exemple.refus@seed.nexytal.com'
);

SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- Résumé des 8 tables ciblées
-- -----------------------------------------------------------------------------
SELECT 'blog_posts_versions' AS tbl, COUNT(*) AS cnt FROM `blog_posts_versions`
UNION ALL SELECT 'formation_skills', COUNT(*) FROM `formation_skills`
UNION ALL SELECT 'formation_jobs', COUNT(*) FROM `formation_jobs`
UNION ALL SELECT 'coaching_coach_certifications', COUNT(*) FROM `coaching_coach_certifications`
UNION ALL SELECT 'coaching_reviews', COUNT(*) FROM `coaching_reviews`
UNION ALL SELECT 'coaching_diagnostic_requests', COUNT(*) FROM `coaching_diagnostic_requests`
UNION ALL SELECT 'recrutement_application_history', COUNT(*) FROM `recrutement_application_history`
UNION ALL SELECT 'gdpr_consents', COUNT(*) FROM `gdpr_consents`
ORDER BY tbl;
