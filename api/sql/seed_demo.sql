-- =============================================================================
-- NEXYTAL — Données de démonstration (v2.1)
-- À exécuter APRÈS schema_v2.sql dans phpMyAdmin ou via import_seed.php
--
-- Contenu : 1 enregistrement minimum par table métier + données réalistes
-- Login admin inchangé : admin@nexytal.com / password
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- BLOG (site 1 — Alt Formation)
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `blog_categories` (`site_id`, `name`, `slug`, `description`, `color`, `is_active`, `sort_order`) VALUES
(1, 'Actualités', 'actualites', 'Nouveautés formations', '#7C3AED', 1, 1),
(2, 'Ressources IT', 'ressources-it', 'Conseils recrutement tech', '#2563EB', 1, 1),
(3, 'Santé', 'sante', 'Actualités médicales', '#059669', 1, 1),
(4, 'Carrière', 'carriere', 'Conseils carrière', '#10B981', 1, 1),
(5, 'Pédagogie', 'pedagogie', 'Formateurs', '#0891B2', 1, 1),
(6, 'Leadership', 'leadership', 'Coaching', '#F59E0B', 1, 1);

INSERT IGNORE INTO `blog_tags` (`site_id`, `name`, `slug`) VALUES
(1, 'RNCP', 'rncp'),
(2, 'DevOps', 'devops'),
(3, 'Infirmier', 'infirmier');

INSERT IGNORE INTO `blog_authors` (`site_id`, `first_name`, `last_name`, `email`, `slug`, `bio`, `is_active`) VALUES
(1, 'Marie', 'Dupont', 'marie.dupont@alt-formation.fr', 'marie-dupont', 'Responsable pédagogique Alt Formation', 1),
(2, 'Thomas', 'Martin', 'thomas.martin@nexytal.com', 'thomas-martin', 'Expert recrutement IT', 1);

INSERT IGNORE INTO `blog_posts`
  (`site_id`, `category_id`, `author_id`, `title`, `slug`, `excerpt`, `content`, `cover_image_url`, `read_time_mins`, `status`, `is_featured`, `published_at`)
SELECT 1, c.id, a.id,
  'Lancement catalogue 2026', 'lancement-catalogue-2026',
  'Découvrez nos nouvelles formations certifiantes.',
  '<p>Alt Formation enrichit son catalogue avec des parcours RNCP et courtes durées.</p>',
  'https://cdn.alt-formation.fr/blog/catalogue-2026.jpg', 5, 'published', 1, NOW()
FROM `blog_categories` c, `blog_authors` a
WHERE c.site_id = 1 AND c.slug = 'actualites' AND a.site_id = 1 AND a.slug = 'marie-dupont'
LIMIT 1;

INSERT IGNORE INTO `blog_posts`
  (`site_id`, `category_id`, `author_id`, `title`, `slug`, `excerpt`, `content`, `status`, `published_at`)
SELECT 2, c.id, a.id,
  'Tendances recrutement cloud 2026', 'tendances-cloud-2026',
  'Les compétences les plus demandées.',
  '<p>AWS, Kubernetes et sécurité cloud dominent les offres.</p>',
  'published', NOW()
FROM `blog_categories` c, `blog_authors` a
WHERE c.site_id = 2 AND c.slug = 'ressources-it' AND a.site_id = 2 AND a.slug = 'thomas-martin'
LIMIT 1;

INSERT IGNORE INTO `blog_post_tags` (`post_id`, `tag_id`)
SELECT p.id, t.id FROM `blog_posts` p, `blog_tags` t
WHERE p.slug = 'lancement-catalogue-2026' AND t.slug = 'rncp' LIMIT 1;

INSERT IGNORE INTO `blog_related_posts` (`post_id`, `related_post_id`)
SELECT p1.id, p2.id FROM `blog_posts` p1, `blog_posts` p2
WHERE p1.slug = 'lancement-catalogue-2026' AND p2.slug = 'tendances-cloud-2026' LIMIT 1;

INSERT IGNORE INTO `blog_posts_versions` (`post_id`, `title`, `content`, `status`, `created_by`)
SELECT p.id, p.title, p.content, 'published', 1
FROM `blog_posts` p WHERE p.slug = 'lancement-catalogue-2026' LIMIT 1;

INSERT IGNORE INTO `blog_comments` (`post_id`, `author_name`, `author_email`, `content`, `status`)
SELECT p.id, 'Jean Lecteur', 'jean.lecteur@example.com', 'Article très utile, merci !', 'approved'
FROM `blog_posts` p WHERE p.slug = 'lancement-catalogue-2026' LIMIT 1;

-- -----------------------------------------------------------------------------
-- FORMATION
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `formation_categories` (`site_id`, `slug`, `label`, `description`, `catalogue_type`, `sort_order`, `is_active`) VALUES
(1, 'informatique', 'Informatique & Digital', 'Formations tech et numérique', 'all', 1, 1),
(1, 'management', 'Management', 'Formations managériales', 'longue', 2, 1);

INSERT IGNORE INTO `formations`
  (`site_id`, `slug`, `type`, `category_id`, `status`, `published_at`, `hero_title`, `hero_subtitle`,
   `hero_image_url`, `seo_title`, `presentation_content`, `programme_duration_label`, `certification_label`,
   `cta_title`, `created_by`, `updated_by`)
SELECT 1, 'developpeur-fullstack', 'certifiante', c.id, 'published', NOW(),
  'Développeur Full Stack', 'Devenez développeur en 6 mois',
  'https://cdn.alt-formation.fr/formations/fullstack-hero.jpg',
  'Formation Développeur Full Stack RNCP',
  'Parcours intensif couvrant front-end, back-end et DevOps.',
  '6 mois (1050h)', 'Certification RNCP niveau 6',
  'Prêt à vous lancer ?', 1, 1
FROM `formation_categories` c WHERE c.slug = 'informatique' LIMIT 1;

INSERT IGNORE INTO `formation_stats` (`formation_id`, `label`, `value`, `icon`, `sort_order`)
SELECT f.id, 'Taux d''insertion', '87%', 'chart', 1 FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

INSERT IGNORE INTO `formation_modules` (`formation_id`, `title`, `duration_label`, `description`, `sort_order`)
SELECT f.id, 'HTML, CSS & JavaScript', '3 semaines', 'Fondamentaux du web', 1
FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

INSERT IGNORE INTO `formation_list_items` (`formation_id`, `list_type`, `content`, `sort_order`)
SELECT f.id, 'competence', 'Maîtriser React et Node.js', 1
FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

INSERT IGNORE INTO `formation_job_outcomes` (`formation_id`, `job_title`, `salary_label`, `sort_order`)
SELECT f.id, 'Développeur Full Stack', '35 000 - 45 000 €', 1
FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

INSERT IGNORE INTO `formation_official_certifications`
  (`formation_id`, `repertoire`, `code`, `official_title`, `level`, `france_competences_url`)
SELECT f.id, 'RNCP', '37680', 'Concepteur développeur d''applications', 6,
  'https://www.francecompetences.fr/recherche/rncp/37680/'
FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

-- -----------------------------------------------------------------------------
-- RECRUTEMENT & MÉDICAL
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `secteurs_activite` (`slug`, `label`) VALUES
('informatique', 'Informatique & Digital'),
('sante', 'Santé & Médical'),
('industrie', 'Industrie');

INSERT IGNORE INTO `competences` (`slug`, `label`, `categorie`) VALUES
('react', 'React', 'technique'),
('kubernetes', 'Kubernetes', 'technique'),
('soins-infirmiers', 'Soins infirmiers', 'technique');

INSERT IGNORE INTO `metiers` (`site_id`, `code_rome`, `slug`, `libelle`, `description`, `secteur_id`, `actif`) VALUES
(2, 'M1805', 'developpeur-applications', 'Développeur d''applications', 'Conception et développement logiciel',
 (SELECT id FROM secteurs_activite WHERE slug = 'informatique' LIMIT 1), 1),
(3, NULL, 'infirmier', 'Infirmier(ère)', 'Soins et accompagnement patients',
 (SELECT id FROM secteurs_activite WHERE slug = 'sante' LIMIT 1), 1),
(NULL, 'M1805', 'developpeur-web-commun', 'Développeur web', 'Métier commun IT', NULL, 1);

INSERT IGNORE INTO `metier_competences` (`metier_id`, `competence_id`, `importance`)
SELECT m.id, c.id, 'essentielle'
FROM `metiers` m, `competences` c
WHERE m.slug = 'developpeur-applications' AND c.slug = 'react' LIMIT 1;

INSERT IGNORE INTO `entreprises` (`nom`, `slug`, `siret`, `description`, `logo_url`, `site_web`, `taille`, `secteur_id`, `ville`, `code_postal`, `validee`) VALUES
('TechNova SAS', 'technova', '12345678901234', 'ESN spécialisée cloud', 'https://cdn.nexytal.com/logos/technova.png', 'https://technova.fr', '51-200',
 (SELECT id FROM secteurs_activite WHERE slug = 'informatique' LIMIT 1), 'Lyon', '69003', 1),
('Clinique du Parc', 'clinique-du-parc', '98765432109876', 'Établissement de santé privé', NULL, 'https://clinique-parc.fr', '201-500',
 (SELECT id FROM secteurs_activite WHERE slug = 'sante' LIMIT 1), 'Paris', '75015', 1);

INSERT IGNORE INTO `users` (`email`, `password_hash`, `role`, `email_verifie`, `actif`) VALUES
('recruteur@technova.fr', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'recruteur', 1, 1),
('candidat.demo@nexytal.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'candidat', 1, 1);

INSERT IGNORE INTO `recruteurs` (`user_id`, `entreprise_id`, `prenom`, `nom`, `fonction`, `telephone`, `principal`)
SELECT u.id, e.id, 'Sophie', 'Bernard', 'DRH', '0612345678', 1
FROM `users` u, `entreprises` e
WHERE u.email = 'recruteur@technova.fr' AND e.slug = 'technova' LIMIT 1;

INSERT IGNORE INTO `candidats`
  (`user_id`, `prenom`, `nom`, `telephone`, `ville`, `code_postal`, `recherche_active`, `rgpd_consent_at`, `profil_public`)
SELECT u.id, 'Lucas', 'Moreau', '0698765432', 'Lyon', '69007', 1, NOW(), 1
FROM `users` u WHERE u.email = 'candidat.demo@nexytal.com' LIMIT 1;

INSERT IGNORE INTO `candidat_metiers_souhaites` (`candidat_id`, `metier_id`, `priorite`, `source`)
SELECT cand.id, m.id, 1, 'manuel'
FROM `candidats` cand, `metiers` m, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id AND m.slug = 'developpeur-applications' LIMIT 1;

INSERT IGNORE INTO `candidat_competences` (`candidat_id`, `competence_id`, `niveau`, `annees`)
SELECT cand.id, c.id, 'confirme', 3
FROM `candidats` cand, `competences` c, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id AND c.slug = 'react' LIMIT 1;

INSERT IGNORE INTO `candidat_experiences` (`candidat_id`, `metier_id`, `entreprise`, `poste`, `date_debut`, `date_fin`, `en_cours`)
SELECT cand.id, m.id, 'Startup ABC', 'Développeur React', '2022-01-01', NULL, 1
FROM `candidats` cand, `metiers` m, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id AND m.slug = 'developpeur-applications' LIMIT 1;

INSERT IGNORE INTO `candidat_formations` (`candidat_id`, `diplome`, `etablissement`, `annee_obtention`, `niveau`)
SELECT cand.id, 'Licence Informatique', 'Université Lyon 2', 2021, 'bac+3'
FROM `candidats` cand, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id LIMIT 1;

INSERT IGNORE INTO `offres_emploi`
  (`site_id`, `entreprise_id`, `recruteur_id`, `metier_id`, `reference`, `slug`, `titre`, `description`,
   `profil_recherche`, `type_contrat`, `experience_min`, `salaire_min`, `salaire_max`, `ville`, `code_postal`,
   `statut`, `date_publication`, `is_featured`)
SELECT 2, e.id, r.id, m.id, 'REF-IT-001', 'developpeur-react-lyon',
  'Développeur React — Lyon', 'Mission sur produit SaaS B2B.',
  '3 ans d''expérience React/TypeScript.', 'cdi', '3-5', 38000, 48000, 'Lyon', '69003',
  'publiee', NOW(), 1
FROM `entreprises` e, `recruteurs` r, `metiers` m, `users` u
WHERE e.slug = 'technova' AND u.email = 'recruteur@technova.fr' AND r.user_id = u.id AND m.slug = 'developpeur-applications'
LIMIT 1;

INSERT IGNORE INTO `offres_emploi`
  (`site_id`, `entreprise_id`, `metier_id`, `slug`, `titre`, `description`, `type_contrat`, `ville`, `statut`, `date_publication`)
SELECT 3, e.id, m.id, 'infirmier-paris', 'Infirmier(ère) — Paris',
  'Poste en service de chirurgie ambulatoire.', 'cdi', 'Paris', 'publiee', NOW()
FROM `entreprises` e, `metiers` m
WHERE e.slug = 'clinique-du-parc' AND m.slug = 'infirmier' LIMIT 1;

INSERT IGNORE INTO `offre_competences` (`offre_id`, `competence_id`, `importance`)
SELECT o.id, c.id, 'essentielle'
FROM `offres_emploi` o, `competences` c
WHERE o.slug = 'developpeur-react-lyon' AND c.slug = 'react' LIMIT 1;

INSERT IGNORE INTO `candidatures` (`offre_id`, `candidat_id`, `message_motivation`, `statut`, `source`)
SELECT o.id, cand.id, 'Très motivé par votre offre React.', 'recue', 'site'
FROM `offres_emploi` o, `candidats` cand, `users` u
WHERE o.slug = 'developpeur-react-lyon' AND u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id LIMIT 1;

INSERT IGNORE INTO `candidatures_externes`
  (`offre_id`, `site_id`, `prenom`, `nom`, `email`, `lettre_motivation`, `statut`, `rgpd_consent_at`)
SELECT o.id, 2, 'Emma', 'Petit', 'emma.petit@example.com', 'Candidature spontanée via le site.', 'recue', NOW()
FROM `offres_emploi` o WHERE o.slug = 'developpeur-react-lyon' LIMIT 1;

INSERT IGNORE INTO `candidature_historique` (`candidature_id`, `ancien_statut`, `nouveau_statut`, `commentaire`, `auteur_admin_id`)
SELECT c.id, NULL, 'recue', 'Candidature reçue', 1
FROM `candidatures` c
INNER JOIN `offres_emploi` o ON c.offre_id = o.id
WHERE o.slug = 'developpeur-react-lyon' LIMIT 1;

INSERT IGNORE INTO `offres_favorites` (`candidat_id`, `offre_id`)
SELECT cand.id, o.id
FROM `candidats` cand, `offres_emploi` o, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id AND o.slug = 'developpeur-react-lyon' LIMIT 1;

INSERT IGNORE INTO `alertes_emploi` (`candidat_id`, `metier_id`, `ville`, `rayon_km`, `type_contrat`, `frequence`, `active`)
SELECT cand.id, m.id, 'Lyon', 30, 'cdi', 'hebdomadaire', 1
FROM `candidats` cand, `metiers` m, `users` u
WHERE u.email = 'candidat.demo@nexytal.com' AND cand.user_id = u.id AND m.slug = 'developpeur-applications' LIMIT 1;

-- -----------------------------------------------------------------------------
-- TRAINERS
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `expertises` (`slug`, `label`, `subtitle`, `description`, `sort_order`) VALUES
('agile-scrum', 'Agile & Scrum', 'Management de projet agile', 'Formation et coaching agile', 1),
('cybersecurite', 'Cybersécurité', 'Sécurité des SI', 'Sensibilisation et techniques', 2);

INSERT IGNORE INTO `trainer_skills` (`name`, `slug`) VALUES ('Facilitation', 'facilitation'), ('Pédagogie adultes', 'pedagogie-adultes');
INSERT IGNORE INTO `trainer_certifications` (`name`, `slug`) VALUES ('Certifié Scrum Master', 'csm'), ('Qualiopi', 'qualiopi');
INSERT IGNORE INTO `trainer_cities` (`slug`, `name`, `region`, `is_active`) VALUES
('lyon', 'Lyon', 'Auvergne-Rhône-Alpes', 1),
('paris', 'Paris', 'Île-de-France', 1);
INSERT IGNORE INTO `trainer_languages` (`code`, `name`) VALUES ('fr', 'Français'), ('en', 'Anglais');

INSERT IGNORE INTO `trainers`
  (`slug`, `first_name`, `last_name`, `title`, `bio`, `avatar_url`, `city_id`, `experience_years`,
   `tjm_eur`, `availability`, `primary_expertise_id`, `email`, `phone`, `status`, `is_featured`, `qualiopi_eligible`, `published_at`)
SELECT 'pierre-durand', 'Pierre', 'Durand', 'Formateur Agile & Scrum',
  '15 ans d''expérience en transformation agile.',
  'https://cdn.nexytal-trainer.com/avatars/pierre-durand.jpg',
  tc.id, 15, 650.00, 'available', e.id, 'pierre.durand@nexytal-trainer.com', '0611223344',
  'active', 1, 1, NOW()
FROM `trainer_cities` tc, `expertises` e
WHERE tc.slug = 'lyon' AND e.slug = 'agile-scrum' LIMIT 1;

INSERT IGNORE INTO `trainer_expertise_links` (`trainer_id`, `expertise_id`, `is_primary`)
SELECT t.id, e.id, 1 FROM `trainers` t, `expertises` e
WHERE t.slug = 'pierre-durand' AND e.slug = 'agile-scrum' LIMIT 1;

INSERT IGNORE INTO `trainer_skill_links` (`trainer_id`, `skill_id`)
SELECT t.id, s.id FROM `trainers` t, `trainer_skills` s
WHERE t.slug = 'pierre-durand' AND s.slug = 'facilitation' LIMIT 1;

INSERT IGNORE INTO `trainer_certification_links` (`trainer_id`, `certification_id`, `obtained_at`)
SELECT t.id, c.id, '2020-06-01' FROM `trainers` t, `trainer_certifications` c
WHERE t.slug = 'pierre-durand' AND c.slug = 'csm' LIMIT 1;

INSERT IGNORE INTO `trainer_modalities` (`trainer_id`, `modality`)
SELECT t.id, 'presentiel' FROM `trainers` t WHERE t.slug = 'pierre-durand' LIMIT 1;

INSERT IGNORE INTO `trainer_modalities` (`trainer_id`, `modality`)
SELECT t.id, 'distanciel' FROM `trainers` t WHERE t.slug = 'pierre-durand' LIMIT 1;

INSERT IGNORE INTO `trainer_language_links` (`trainer_id`, `language_id`, `level`)
SELECT t.id, l.id, 'native' FROM `trainers` t, `trainer_languages` l
WHERE t.slug = 'pierre-durand' AND l.code = 'fr' LIMIT 1;

INSERT IGNORE INTO `trainer_city_links` (`trainer_id`, `city_id`)
SELECT t.id, tc.id FROM `trainers` t, `trainer_cities` tc
WHERE t.slug = 'pierre-durand' AND tc.slug = 'paris' LIMIT 1;

INSERT IGNORE INTO `trainer_courses` (`trainer_id`, `title`, `duration_label`, `duration_days`, `level`, `description`, `sort_order`)
SELECT t.id, 'Initiation Scrum', '2 jours', 2.0, 'debutant', 'Les fondamentaux du framework Scrum', 1
FROM `trainers` t WHERE t.slug = 'pierre-durand' LIMIT 1;

INSERT IGNORE INTO `trainer_reviews` (`trainer_id`, `author_name`, `company`, `rating`, `comment`, `is_published`)
SELECT t.id, 'Claire Rousseau', 'TechNova', 5, 'Excellent formateur, très pédagogue.', 1
FROM `trainers` t WHERE t.slug = 'pierre-durand' LIMIT 1;

INSERT IGNORE INTO `trainer_applications`
  (`first_name`, `last_name`, `email`, `phone`, `primary_expertise_id`, `experience_years`, `message`, `status`)
SELECT 'Nadia', 'Benali', 'nadia.benali@example.com', '0688776655', e.id, 8,
  'Je souhaite rejoindre le réseau Nexytal Trainer.', 'new'
FROM `expertises` e WHERE e.slug = 'cybersecurite' LIMIT 1;

-- -----------------------------------------------------------------------------
-- NEWSLETTER
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `newsletter_subscribers`
  (`site_id`, `email`, `first_name`, `last_name`, `status`, `confirmed_at`, `rgpd_consent_at`, `source`)
VALUES
(1, 'demo.subscriber@nexytal.com', 'Demo', 'Subscriber', 'active', NOW(), NOW(), 'form'),
(2, 'alertes.it@nexytal.com', 'Alertes', 'IT', 'active', NOW(), NOW(), 'form');

INSERT IGNORE INTO `newsletter_subscriptions` (`subscriber_id`, `list_id`)
SELECT s.id, l.id FROM `newsletter_subscribers` s, `newsletter_lists` l
WHERE s.email = 'demo.subscriber@nexytal.com' AND l.site_id = 1 AND l.slug = 'generale' LIMIT 1;

INSERT IGNORE INTO `newsletter_campaigns`
  (`site_id`, `list_id`, `created_by`, `subject`, `preview_text`, `content_html`, `status`, `recipients_count`)
SELECT 1, l.id, 1, 'Nouveautés formations Alt', 'Découvrez le catalogue 2026',
  '<h1>Catalogue 2026</h1><p>Nouvelles formations disponibles.</p>', 'draft', 0
FROM `newsletter_lists` l WHERE l.site_id = 1 AND l.slug = 'generale' LIMIT 1;

INSERT IGNORE INTO `newsletter_events` (`campaign_id`, `subscriber_id`, `event_type`, `ip_address`)
SELECT camp.id, sub.id, 'sent', '127.0.0.1'
FROM `newsletter_campaigns` camp, `newsletter_subscribers` sub
WHERE camp.subject = 'Nouveautés formations Alt' AND sub.email = 'demo.subscriber@nexytal.com' LIMIT 1;

-- -----------------------------------------------------------------------------
-- RGPD, SEO, EMAIL LOGS
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `gdpr_consents_log` (`site_id`, `user_email`, `ip_address`, `consent_type`, `granted`, `granted_at`) VALUES
(1, 'demo.subscriber@nexytal.com', '127.0.0.1', 'newsletter', 1, NOW()),
(2, 'candidat.demo@nexytal.com', '127.0.0.1', 'candidature', 1, NOW());

INSERT IGNORE INTO `gdpr_deletion_requests` (`site_id`, `user_email`, `status`, `requested_at`) VALUES
(4, 'ancien.user@example.com', 'pending', NOW());

INSERT IGNORE INTO `seo_metadata`
  (`site_id`, `entity_type`, `entity_id`, `meta_title`, `meta_description`, `canonical_url`, `og_title`)
SELECT 1, 'formation', f.id, 'Formation Développeur Full Stack', 'Devenez développeur certifié RNCP',
  'https://alt-formation.fr/formations/developpeur-fullstack', 'Développeur Full Stack'
FROM `formations` f WHERE f.slug = 'developpeur-fullstack' LIMIT 1;

INSERT IGNORE INTO `marketing_email_logs`
  (`site_id`, `recipient_email`, `subject`, `template_used`, `status`)
VALUES (1, 'demo.subscriber@nexytal.com', 'Bienvenue newsletter Alt Formation', 'welcome', 'sent');

-- -----------------------------------------------------------------------------
-- CORE (sessions, audit, password reset)
-- -----------------------------------------------------------------------------
INSERT IGNORE INTO `core_audit_logs` (`admin_id`, `site_id`, `action`, `entity_type`, `entity_id`, `ip_address`)
VALUES (1, 1, 'seed', 'demo_data', NULL, '127.0.0.1');

INSERT IGNORE INTO `core_admin_password_resets` (`admin_id`, `token_hash`, `expires_at`)
VALUES (1, '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', DATE_ADD(NOW(), INTERVAL 1 HOUR));

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Fin seed demo — Vérifier : SELECT COUNT(*) FROM formations; (attendu >= 1)
-- =============================================================================
