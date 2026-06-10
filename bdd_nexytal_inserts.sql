-- =============================================================================
-- NEXYTAL PLATFORM — Jeu de données complet (INSERT)
-- Compatible : bdd_nexytal_v3.sql
-- Contient des données réalistes pour les 49 tables
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
-- Ionos prod : dbs15772578 | local : bdd_nexytal
USE `dbs15772578`;

-- =============================================================================
-- 1. CORE MODULE
-- =============================================================================

-- core_sites (6 sites)
INSERT IGNORE INTO `core_sites` (`id`, `name`, `slug`, `domain`, `is_active`) VALUES
  (1, 'Alt Formation',       'alt-formation',       'alt-formation.fr',           1),
  (2, 'Nexytal Recrutement', 'nexytal-recrutement', 'recrutement.nexytal.com',    1),
  (3, 'Nexytal Médical',     'nexytal-medical',     'medical.nexytal.com',        1),
  (4, 'Nexytal Carrière',    'nexytal-carriere',    'carriere.nexytal.com',       1),
  (5, 'Nexytal Trainer',     'nexytal-trainer',     'trainer.nexytal.com',        1),
  (6, 'Nexytal Coaching',    'nexytal-coaching',    'coaching.nexytal.com',       1);

-- core_admin_users
-- ⚠️ Mots de passe en clair (pour référence) :
--   id=1 superadmin → "Nexytal@2025!"
--   id=2 admin      → "AdminAlt@2025"
--   id=3 editor     → "Editor@2025"
--   id=4 recruiter  → "Recrut@2025"
--   id=5 moderator  → "Modo@2025"
-- Hash bcrypt généré avec cost=10
INSERT IGNORE INTO `core_admin_users`
  (`id`, `email`, `password_hash`, `first_name`, `last_name`, `role`, `is_active`) VALUES
  (1, 'superadmin@nexytal.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   'Sophie', 'Martin', 'superadmin', 1),
  (2, 'admin.alt@nexytal.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   'Thomas', 'Dupont', 'admin', 1),
  (3, 'editor.carriere@nexytal.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   'Lucie', 'Bernard', 'editor', 1),
  (4, 'recruiter@nexytal.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   'Marc', 'Leroy', 'recruiter', 1),
  (5, 'moderator@nexytal.com',
   '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
   'Emma', 'Petit', 'moderator', 1);

-- core_admin_site_access
INSERT IGNORE INTO `core_admin_site_access` (`admin_id`, `site_id`) VALUES
  -- superadmin → tous les sites
  (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
  -- admin Alt Formation → site 1
  (2,1),
  -- editor Carrière → sites 4 et 5
  (3,4),(3,5),
  -- recruiter → sites 2 et 3
  (4,2),(4,3),
  -- moderator → sites 4,5,6
  (5,4),(5,5),(5,6);

-- core_admin_sessions
INSERT IGNORE INTO `core_admin_sessions`
  (`id`, `admin_id`, `token`, `ip_address`, `user_agent`, `expires_at`) VALUES
  (1, 1, 'tok_superadmin_abc123def456ghi789jkl012mno345pqr',
   '192.168.1.1', 'Mozilla/5.0 Chrome/124 Safari/537',
   DATE_ADD(NOW(), INTERVAL 8 HOUR)),
  (2, 2, 'tok_admin_xyz987wvu654tsr321qpo098nml765kji',
   '192.168.1.10', 'Mozilla/5.0 Firefox/125',
   DATE_ADD(NOW(), INTERVAL 4 HOUR));

-- core_password_reset_tokens
INSERT IGNORE INTO `core_password_reset_tokens`
  (`id`, `admin_id`, `token`, `expires_at`, `used_at`) VALUES
  (1, 3, 'reset_lucie_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6',
   DATE_ADD(NOW(), INTERVAL 1 HOUR), NULL),
  (2, 5, 'reset_emma_z9y8x7w6v5u4t3s2r1q0p9o8n7m6l5k4',
   DATE_SUB(NOW(), INTERVAL 2 HOUR), NOW());

-- core_admin_activity_logs
INSERT INTO `core_admin_activity_logs`
  (`admin_id`, `action`, `resource`, `resource_id`, `ip_address`) VALUES
  (1, 'login',          'auth',                NULL, '192.168.1.1'),
  (1, 'create',         'formation_courses',   1,    '192.168.1.1'),
  (2, 'login',          'auth',                NULL, '192.168.1.10'),
  (2, 'publish',        'formation_courses',   1,    '192.168.1.10'),
  (4, 'create',         'recrutement_offers',  1,    '10.0.0.5'),
  (3, 'update',         'blog_posts',          1,    '10.0.0.12'),
  (1, 'delete',         'coaching_reviews',    3,    '192.168.1.1'),
  (5, 'moderate',       'blog_comments',       2,    '172.16.0.3');

-- core_settings
INSERT IGNORE INTO `core_settings` (`site_id`, `setting_key`, `setting_value`, `setting_type`) VALUES
  (NULL, 'app_name',            'Nexytal Platform',        'string'),
  (NULL, 'maintenance_mode',    '0',                       'boolean'),
  (NULL, 'default_language',    'fr',                      'string'),
  (NULL, 'max_upload_size_mb',  '10',                      'int'),
  (NULL, 'smtp_host',           'mail.ionos.fr',           'string'),
  (NULL, 'smtp_port',           '587',                     'int'),
  (NULL, 'smtp_from',           'noreply@nexytal.com',     'string'),
  (1,    'site_color',          '#1A3E6B',                 'string'),
  (1,    'cpf_info_url',        'https://www.moncompteformation.gouv.fr', 'string'),
  (2,    'site_color',          '#0A2540',                 'string'),
  (2,    'offers_per_page',     '12',                      'int'),
  (3,    'site_color',          '#10b981',                 'string'),
  (4,    'site_color',          '#6366f1',                 'string'),
  (5,    'site_color',          '#f59e0b',                 'string'),
  (6,    'site_color',          '#C9A24B',                 'string'),
  (6,    'booking_duration_default', '60',                 'int'),
  (NULL, 'gdpr_retention_days', '730',                     'int'),
  (NULL, 'analytics_enabled',   '1',                       'boolean');

-- core_audit_logs
INSERT INTO `core_audit_logs`
  (`admin_id`, `site_id`, `action`, `entity_type`, `entity_id`,
   `old_data`, `new_data`, `ip_address`) VALUES
  (1, 1, 'create', 'formation_courses', 1,
   NULL,
   '{"title":"Développeur Web Full Stack","status":"draft"}',
   '192.168.1.1'),
  (2, 1, 'update', 'formation_courses', 1,
   '{"status":"draft"}',
   '{"status":"published"}',
   '192.168.1.10'),
  (4, 2, 'create', 'recrutement_offers', 1,
   NULL,
   '{"title":"Développeur React Senior","status":"published"}',
   '10.0.0.5'),
  (1, 6, 'delete', 'coaching_reviews', 3,
   '{"rating":1,"comment":"Faux avis","is_published":1}',
   NULL,
   '192.168.1.1'),
  (3, 4, 'update', 'blog_posts', 1,
   '{"status":"draft"}',
   '{"status":"published"}',
   '10.0.0.12');

-- =============================================================================
-- 2. BLOG MODULE
-- =============================================================================

-- blog_categories
INSERT IGNORE INTO `blog_categories`
  (`id`, `site_id`, `name`, `slug`, `description`, `color`, `sort_order`) VALUES
  -- Carrière (site 4)
  (1,  4, 'Recrutement',        'recrutement',        'Conseils pour trouver un emploi',        '#6366f1', 1),
  (2,  4, 'Carrière',           'carriere',            'Évolution professionnelle',               '#0ea5e9', 2),
  (3,  4, 'CV & Lettres',       'cv-lettres',          'Rédiger un CV efficace',                  '#10b981', 3),
  (4,  4, 'Entretien',          'entretien',           'Préparer ses entretiens',                 '#f59e0b', 4),
  (5,  4, 'Reconversion',       'reconversion',        'Changer de voie professionnelle',         '#ec4899', 5),
  -- Trainer (site 5)
  (6,  5, 'Formation',          'formation',           'Actualités formation professionnelle',    '#10b981', 1),
  (7,  5, 'Certifications',     'certifications',      'Guides certifications IT',                '#3b82f6', 2),
  (8,  5, 'Conseils',           'conseils',            'Astuces et méthodes pédagogiques',       '#f59e0b', 3),
  -- Médical (site 3)
  (9,  3, 'Actualités Santé',   'actu-sante',          'Dernières nouvelles du secteur',          '#ef4444', 1),
  (10, 3, 'Recrutement Médical','recrutement-medical', 'Trouver un poste dans la santé',          '#10b981', 2),
  -- Coaching (site 6)
  (11, 6, 'Leadership',         'leadership',          'Développer son leadership',               '#0A2540', 1),
  (12, 6, 'Bien-être au travail','bien-etre-travail',  'Qualité de vie professionnelle',          '#C9A24B', 2),
  (13, 6, 'Management',         'management',          'Outils et méthodes managériales',         '#6B9080', 3);

-- blog_tags
INSERT IGNORE INTO `blog_tags` (`id`, `site_id`, `name`, `slug`) VALUES
  (1,  4, 'Emploi',             'emploi'),
  (2,  4, 'CV',                 'cv'),
  (3,  4, 'Entretien',          'entretien'),
  (4,  4, 'Reconversion',       'reconversion'),
  (5,  4, 'Télétravail',        'teletravail'),
  (6,  4, 'Salaire',            'salaire'),
  (7,  5, 'CPF',                'cpf'),
  (8,  5, 'Alternance',         'alternance'),
  (9,  5, 'RNCP',               'rncp'),
  (10, 5, 'IA',                 'ia'),
  (11, 3, 'Infirmier',          'infirmier'),
  (12, 3, 'Médecin',            'medecin'),
  (13, 3,'Hôpital',            'hopital'),
  (14, 6, 'Leadership',         'leadership'),
  (15, 6, 'Burn-out',           'burn-out'),
  (16, 6, 'Intelligence émotionnelle', 'intelligence-emotionnelle');

-- blog_authors
INSERT IGNORE INTO `blog_authors`
  (`id`, `site_id`, `first_name`, `last_name`, `email`, `slug`, `bio`) VALUES
  (1, 4, 'Claire',   'Fontaine',
   'claire.fontaine@nexytal.com', 'claire-fontaine',
   'Consultante RH avec 10 ans d'expérience en recrutement et évolution de carrière.'),
  (2, 4, 'Antoine',  'Vidal',
   'antoine.vidal@nexytal.com', 'antoine-vidal',
   'Expert en coaching carrière et bilan de compétences, certifié ICF.'),
  (3, 5, 'Nathalie', 'Rousseau',
   'nathalie.rousseau@nexytal.com', 'nathalie-rousseau',
   'Formatrice certifiée en développement web et data science depuis 8 ans.'),
  (4, 5, 'Julien',   'Moreau',
   'julien.moreau@nexytal.com', 'julien-moreau',
   'Ingénieur pédagogique spécialisé dans les formations IT et certifications.'),
  (5, 3, 'Dr Marie', 'Leblanc',
   'marie.leblanc@nexytal.com', 'dr-marie-leblanc',
   'Médecin généraliste et consultante en recrutement médical.'),
  (6, 6, 'Pierre',   'Girard',
   'pierre.girard@nexytal.com', 'pierre-girard',
   'Coach exécutif certifié ICF PCC, spécialiste leadership et transformation.');

-- blog_posts
INSERT INTO `blog_posts`
  (`id`, `site_id`, `category_id`, `author_id`, `title`, `slug`, `excerpt`,
   `content`, `cover_image_url`, `read_time_mins`, `status`, `is_featured`, `published_at`,
   `meta_title`, `meta_description`, `views_count`) VALUES
  (1, 4, 1, 1,
   '10 conseils pour réussir son entretien d'embauche en 2025',
   '10-conseils-entretien-embauche-2025',
   'Décrocher un entretien c'est bien, le réussir c'est mieux. Voici 10 conseils concrets.',
   '<h2>Préparez-vous en amont</h2><p>La préparation est la clé d''un entretien réussi...</p>',
   '/uploads/blog/entretien-2025.jpg', 7, 'published', 1, '2025-03-15 09:00:00',
   '10 conseils entretien 2025 | Nexytal Carrière',
   'Réussissez votre entretien d''embauche avec nos 10 conseils experts pour 2025.', 1842),
  (2, 4, 3, 1,
   'Comment rédiger un CV qui attire les recruteurs en 2025',
   'rediger-cv-attire-recruteurs-2025',
   'Votre CV est votre carte de visite. Découvrez comment le rendre irrésistible.',
   '<h2>Le format</h2><p>Un bon CV tient sur une page et met en valeur vos réalisations...</p>',
   '/uploads/blog/cv-2025.jpg', 6, 'published', 0, '2025-04-02 10:00:00',
   'Rédiger un CV 2025 | Nexytal Carrière',
   'Nos conseils pour créer un CV percutant qui retient l''attention des recruteurs.', 934),
  (3, 4, 5, 2,
   'Reconversion professionnelle : par où commencer ?',
   'reconversion-professionnelle-par-ou-commencer',
   'Changer de métier est une démarche courageuse. Voici la méthode étape par étape.',
   '<h2>Faire le point</h2><p>Avant de vous lancer, réalisez un bilan de compétences...</p>',
   '/uploads/blog/reconversion.jpg', 9, 'published', 1, '2025-04-20 08:30:00',
   'Reconversion professionnelle 2025 | Guide complet',
   'Comment réussir sa reconversion professionnelle : méthode, aides et ressources.', 2156),
  (4, 5, 6, 3,
   'CPF en 2025 : quelles formations financer ?',
   'cpf-2025-formations-financer',
   'Le Compte Personnel de Formation évolue. Ce que vous devez savoir pour en profiter.',
   '<h2>Qu''est-ce que le CPF ?</h2><p>Le CPF est un compte alimenté en euros chaque année...</p>',
   '/uploads/blog/cpf-2025.jpg', 8, 'published', 1, '2025-03-01 09:00:00',
   'CPF 2025 : formations éligibles | Nexytal Trainer',
   'Tout savoir sur le CPF en 2025 : droits, formations éligibles et démarches.', 3421),
  (5, 5, 7, 4,
   'Guide complet : passer la certification AWS Cloud Practitioner',
   'guide-certification-aws-cloud-practitioner',
   'La certification AWS Cloud Practitioner ouvre de nombreuses portes dans l''IT.',
   '<h2>Pourquoi AWS Cloud Practitioner ?</h2><p>C''est la certification d''entrée dans l''écosystème AWS...</p>',
   '/uploads/blog/aws-certif.jpg', 12, 'published', 0, '2025-04-10 10:00:00',
   'Certification AWS Cloud Practitioner 2025 | Guide',
   'Préparez et réussissez la certification AWS Cloud Practitioner avec notre guide complet.', 1289),
  (6, 3, 10, 5,
   'Trouver un poste d''infirmier en 2025 : les meilleures stratégies',
   'trouver-poste-infirmier-2025',
   'Le marché de l''emploi infirmier est tendu. Comment tirer son épingle du jeu ?',
   '<h2>Un marché en tension</h2><p>La demande d''infirmiers diplômés d''État ne cesse de croître...</p>',
   '/uploads/blog/infirmier-emploi.jpg', 6, 'published', 0, '2025-05-05 09:00:00',
   'Emploi infirmier 2025 | Nexytal Médical',
   'Stratégies pour trouver un poste d''infirmier en 2025 dans un marché en tension.', 876),
  (7, 6, 11, 6,
   'Les 5 piliers d''un leadership inspirant',
   '5-piliers-leadership-inspirant',
   'Le leadership ne s''improvise pas. Découvrez les 5 piliers qui font les grands leaders.',
   '<h2>1. La vision</h2><p>Un leader inspire en donnant une direction claire et motivante...</p>',
   '/uploads/blog/leadership.jpg', 10, 'published', 1, '2025-03-22 08:00:00',
   '5 piliers leadership inspirant | Nexytal Coaching',
   'Développez votre leadership avec les 5 piliers fondamentaux des managers qui inspirent.', 2034),
  (8, 4, 2, 2,
   'Négocier son salaire : les techniques qui fonctionnent',
   'negocier-salaire-techniques',
   'Beaucoup hésitent à négocier leur salaire. Pourtant c''est une compétence qui s''apprend.',
   '<h2>Pourquoi négocier ?</h2><p>Seulement 37% des candidats négocient leur salaire...</p>',
   '/uploads/blog/negociation-salaire.jpg', 8, 'published', 0, '2025-05-12 10:00:00',
   'Négocier son salaire 2025 | Nexytal Carrière',
   'Techniques et scripts pour négocier efficacement votre salaire lors d''un entretien.', 1567),
  (9, 5, 8, 3,
   'Méthode Agile en formation : comment l''appliquer ?',
   'methode-agile-formation',
   'La méthode Agile révolutionne aussi le monde de la formation. Découvrez comment.',
   '<h2>Agile et pédagogie</h2><p>L''approche itérative s''applique parfaitement aux parcours de formation...</p>',
   '/uploads/blog/agile-formation.jpg', 11, 'draft', 0, NULL,
   NULL, NULL, 0),
  (10, 6, 12, 6,
   'Prévenir le burn-out : les signaux d''alarme à ne pas ignorer',
   'prevenir-burn-out-signaux-alarme',
   'Le burn-out touche de plus en plus de salariés. Apprenez à reconnaître les signes avant-coureurs.',
   '<h2>Qu''est-ce que le burn-out ?</h2><p>Le burn-out est un épuisement professionnel total...</p>',
   '/uploads/blog/burn-out.jpg', 9, 'published', 0, '2025-05-18 09:00:00',
   'Prévenir le burn-out | Nexytal Coaching',
   'Reconnaître et prévenir le burn-out : signaux d''alarme et stratégies de protection.', 1923);

-- blog_posts_versions
INSERT INTO `blog_posts_versions`
  (`post_id`, `title`, `content`, `status`, `created_by`) VALUES
  (1, '10 conseils entretien (v1)',
   '<h2>Avant l''entretien</h2><p>Version initiale...</p>', 'draft', 2),
  (1, '10 conseils entretien (v2)',
   '<h2>Préparez-vous en amont</h2><p>Version révisée...</p>', 'review', 1),
  (3, 'Reconversion pro (v1)',
   '<h2>Faire le point</h2><p>Première version...</p>', 'draft', 3),
  (7, '5 piliers leadership (v1)',
   '<h2>Vision</h2><p>Brouillon initial...</p>', 'draft', 6);

-- blog_post_tags
INSERT IGNORE INTO `blog_post_tags` (`post_id`, `tag_id`) VALUES
  (1, 3),(1, 1),
  (2, 2),(2, 1),
  (3, 4),(3, 1),
  (4, 7),(4, 8),
  (5, 9),(5, 10),
  (6, 11),
  (7, 14),
  (8, 6),(8, 3),
  (10, 15),(10, 16);

-- blog_related_posts
INSERT IGNORE INTO `blog_related_posts` (`post_id`, `related_post_id`) VALUES
  (1, 2),(1, 8),
  (2, 1),(2, 3),
  (3, 1),(3, 8),
  (4, 5),
  (7, 10);

-- blog_comments
INSERT INTO `blog_comments`
  (`post_id`, `parent_id`, `author_name`, `author_email`, `content`, `status`) VALUES
  (1, NULL, 'Jean Dupont',    'jean.dupont@gmail.com',
   'Excellent article, merci pour ces conseils pratiques !', 'approved'),
  (1, NULL, 'Marie Curie',    'marie.curie@outlook.fr',
   'Très utile, surtout la partie sur la préparation en amont.', 'approved'),
  (1, 1,    'Claire Fontaine','claire.fontaine@nexytal.com',
   'Merci Jean, n''hésitez pas à partager l''article !', 'approved'),
  (3, NULL, 'Lucas Bertin',   'lucas.bertin@yahoo.fr',
   'Je vis exactement cette situation, merci pour les pistes.', 'approved'),
  (7, NULL, 'Isabelle Roy',   'isabelle.roy@gmail.com',
   'Très inspirant, j''ai partagé à toute mon équipe.', 'approved'),
  (7, NULL, 'Spam Bot',       'bot@spam123.ru',
   'Buy cheap stuff here http://spam.example.com', 'spam'),
  (4, NULL, 'Franck Morin',   'franck.morin@laposte.net',
   'J''ai utilisé mon CPF pour une formation Data, ça change la vie !', 'approved'),
  (10, NULL,'Sandrine Petit', 'sandrine.petit@gmail.com',
   'J''aurais aimé lire ça il y a 2 ans...', 'pending');

-- =============================================================================
-- 3. RECRUTEMENT MODULE
-- =============================================================================

-- recrutement_sectors
INSERT IGNORE INTO `recrutement_sectors` (`id`, `site_id`, `name`, `slug`) VALUES
  (1, 2, 'IT & Digital',        'it-digital'),
  (2, 2, 'Cybersécurité',       'cybersecurite'),
  (3, 2, 'Cloud & DevOps',      'cloud-devops'),
  (4, 2, 'Data & IA',           'data-ia'),
  (5, 2, 'Management IT',       'management-it'),
  (6, 3, 'Médecine',            'medecine'),
  (7, 3, 'Soins infirmiers',    'soins-infirmiers'),
  (8, 3, 'Rééducation',         'reeducation'),
  (9, 3, 'Pharmacie',           'pharmacie'),
  (10,3, 'Médico-social',       'medico-social');

-- recrutement_jobs
INSERT IGNORE INTO `recrutement_jobs` (`id`, `sector_id`, `name`, `slug`) VALUES
  (1,  1, 'Développeur Frontend',         'developpeur-frontend'),
  (2,  1, 'Développeur Backend',          'developpeur-backend'),
  (3,  1, 'Développeur Full Stack',       'developpeur-full-stack'),
  (4,  2, 'Analyste SOC',                 'analyste-soc'),
  (5,  2, 'Pentesteur',                   'pentesteur'),
  (6,  3, 'Ingénieur DevOps',             'ingenieur-devops'),
  (7,  3, 'Architecte Cloud',             'architecte-cloud'),
  (8,  4, 'Data Scientist',               'data-scientist'),
  (9,  4, 'Data Engineer',                'data-engineer'),
  (10, 5, 'DSI',                          'dsi'),
  (11, 6, 'Médecin généraliste',          'medecin-generaliste'),
  (12, 6, 'Médecin urgentiste',           'medecin-urgentiste'),
  (13, 7, 'Infirmier(e) DE',              'infirmier-de'),
  (14, 7, 'Infirmier(e) spécialisé(e)',   'infirmier-specialise'),
  (15, 8, 'Kinésithérapeute',             'kinesitherapeute'),
  (16, 9, 'Pharmacien(ne) adjoint(e)',    'pharmacien-adjoint'),
  (17,10, 'Aide-soignant(e)',             'aide-soignant');

-- recrutement_contract_types
INSERT IGNORE INTO `recrutement_contract_types` (`id`, `code`, `name`) VALUES
  (1, 'CDI',       'CDI'),
  (2, 'CDD',       'CDD'),
  (3, 'FREELANCE', 'Freelance'),
  (4, 'INTERIM',   'Intérim'),
  (5, 'ALTERNANCE','Alternance'),
  (6, 'STAGE',     'Stage');

-- recrutement_professions (pages SEO Médical)
INSERT IGNORE INTO `recrutement_professions`
  (`id`, `site_id`, `name`, `slug`, `sector`, `description`, `color`, `is_active`) VALUES
  (1, 3, 'Médecin généraliste',    'medecin-generaliste',
   'Médecine générale',
   '<h2>Le métier</h2><p>Le médecin généraliste est le premier recours du patient...</p>',
   '#3b82f6', 1),
  (2, 3, 'Infirmier(e)',           'infirmier',
   'Soins infirmiers',
   '<h2>Le métier</h2><p>L''infirmier(e) assure les soins sur prescription médicale...</p>',
   '#10b981', 1),
  (3, 3, 'Aide-soignant(e)',       'aide-soignant',
   'Soins de proximité',
   '<h2>Le métier</h2><p>L''aide-soignant accompagne les patients dans les actes de la vie quotidienne...</p>',
   '#f59e0b', 1),
  (4, 3, 'Kinésithérapeute',       'kinesitherapeute',
   'Rééducation',
   '<h2>Le métier</h2><p>Le kinésithérapeute prend en charge la rééducation motrice et fonctionnelle...</p>',
   '#8b5cf6', 1),
  (5, 3, 'Pharmacien(ne)',         'pharmacien',
   'Pharmacie',
   '<h2>Le métier</h2><p>Le pharmacien est le garant du bon usage du médicament...</p>',
   '#ec4899', 1),
  (6, 3, 'Médecin urgentiste',     'medecin-urgentiste',
   'Médecine d''urgence',
   '<h2>Le métier</h2><p>Le médecin urgentiste intervient dans des situations critiques...</p>',
   '#ef4444', 1);

-- recrutement_offers
INSERT INTO `recrutement_offers`
  (`id`, `site_id`, `job_id`, `contract_type_id`, `profession_id`,
   `title`, `slug`, `company_name`, `location`, `postal_code`,
   `salary_range`, `experience_level`, `is_urgent`,
   `short_desc`, `full_desc`,
   `status`, `published_at`, `expires_at`, `created_by`) VALUES
  (1, 2, 3, 1, NULL,
   'Développeur Full Stack React/Node.js – Senior',
   'developpeur-full-stack-react-nodejs-senior',
   'TechCorp Paris', 'Paris 8e', '75008',
   '55 000 – 70 000 € brut/an', 'Senior (5+ ans)',
   0,
   'Rejoignez une scale-up fintech en forte croissance pour développer des features à fort impact.',
   '<h2>À propos</h2><p>TechCorp est une fintech qui révolutionne les paiements B2B...</p>',
   'published', '2025-04-01 08:00:00', '2025-07-01', 4),
  (2, 2, 6, 3, NULL,
   'Ingénieur DevOps AWS – Freelance',
   'ingenieur-devops-aws-freelance',
   'DataStream', 'Lyon (remote OK)', '69001',
   '550 – 700 €/jour', 'Confirmé (3-5 ans)',
   1,
   'Mission longue durée dans une ESN spécialisée data. Stack AWS, Terraform, Kubernetes.',
   '<h2>La mission</h2><p>Dans le cadre d''un projet de migration cloud...</p>',
   'published', '2025-04-15 09:00:00', '2025-06-30', 4),
  (3, 2, 8, 1, NULL,
   'Data Scientist – Machine Learning',
   'data-scientist-machine-learning',
   'InsureAI', 'Bordeaux (hybride)', '33000',
   '48 000 – 62 000 € brut/an', 'Junior/Confirmé (1-3 ans)',
   0,
   'Startup assurtech cherche son premier Data Scientist pour développer des modèles prédictifs.',
   '<h2>Vos missions</h2><p>Développement de modèles ML pour la tarification...</p>',
   'published', '2025-05-01 10:00:00', '2025-08-01', 4),
  (4, 2, 4, 1, NULL,
   'Analyste SOC N2 – CDI',
   'analyste-soc-n2-cdi',
   'CyberShield France', 'Lille', '59000',
   '42 000 – 52 000 € brut/an', 'Confirmé (2-4 ans)',
   0,
   'CyberShield recrute un analyste SOC N2 pour renforcer son équipe de surveillance.',
   '<h2>Le poste</h2><p>Au sein du SOC, vous assurez la surveillance des SI clients...</p>',
   'published', '2025-05-10 08:30:00', '2025-08-10', 4),
  (5, 3, 13, 2, 2,
   'Infirmier(e) DE – Service cardiologie',
   'infirmier-de-service-cardiologie',
   'CHU de Nantes', 'Nantes', '44000',
   '2 400 – 2 800 € brut/mois', 'Débutant accepté',
   1,
   'Le CHU de Nantes recrute un(e) infirmier(e) pour son service de cardiologie.',
   '<h2>Le poste</h2><p>Rattaché(e) au cadre de santé, vous assurerez les soins...</p>',
   'published', '2025-05-01 09:00:00', '2025-07-31', 4),
  (6, 3, 11, 1, 1,
   'Médecin généraliste – Cabinet de groupe',
   'medecin-generaliste-cabinet-groupe',
   'Cabinet Médical Santé+', 'Marseille', '13001',
   'Rémunération à l''acte – CCAM', 'Toute expérience',
   0,
   'Cabinet de groupe cherche médecin généraliste pour rejoindre une équipe pluridisciplinaire.',
   '<h2>L''opportunité</h2><p>Cabinet récent, locaux modernes, patientèle fidèle...</p>',
   'published', '2025-04-20 10:00:00', '2025-09-30', 4),
  (7, 2, 7, 3, NULL,
   'Architecte Cloud Azure – Mission 6 mois',
   'architecte-cloud-azure-6-mois',
   'Société Générale', 'Paris La Défense', '92800',
   '700 – 900 €/jour', 'Expert (7+ ans)',
   0,
   'Grande banque cherche architecte cloud pour migration d''applications legacy vers Azure.',
   '<h2>Contexte</h2><p>Dans le cadre du programme de transformation digitale...</p>',
   'published', '2025-05-20 08:00:00', '2025-07-20', 4),
  (8, 2, 1, 5, NULL,
   'Développeur Frontend React – Alternance',
   'developpeur-frontend-react-alternance',
   'StartupLab', 'Paris 11e', '75011',
   '1 100 – 1 400 €/mois (selon âge)', '0 an requis',
   0,
   'StartupLab cherche un alternant développeur frontend pour rejoindre l''équipe produit.',
   '<h2>Le poste</h2><p>En alternance avec votre école, vous travaillerez sur notre application SaaS...</p>',
   'published', '2025-05-25 09:00:00', '2025-09-01', 4);

-- recrutement_offer_missions
INSERT INTO `recrutement_offer_missions` (`offer_id`, `content`, `sort_order`) VALUES
  (1, 'Développer des nouvelles features front (React 18, TypeScript) et back (Node.js, NestJS)', 1),
  (1, 'Participer aux choix d''architecture et code review', 2),
  (1, 'Travailler en méthode Agile/Scrum avec des sprints de 2 semaines', 3),
  (1, 'Contribuer à l''amélioration des performances et de la qualité du code', 4),
  (2, 'Concevoir et maintenir les pipelines CI/CD (GitHub Actions, ArgoCD)', 1),
  (2, 'Gérer l''infrastructure AWS (EKS, RDS, S3, CloudFront) via Terraform', 2),
  (2, 'Assurer la sécurité et la haute disponibilité des environnements', 3),
  (3, 'Développer des modèles de tarification prédictive en Python/scikit-learn', 1),
  (3, 'Analyser les données sinistres et construire des indicateurs clés', 2),
  (3, 'Collaborer avec les équipes métier pour traduire les besoins en modèles', 3),
  (4, 'Analyser les alertes SIEM et traiter les incidents de sécurité N2', 1),
  (4, 'Mener des investigations forensiques sur les endpoints et les réseaux', 2),
  (4, 'Rédiger des rapports d''incident et des procédures de réponse', 3),
  (5, 'Assurer les soins infirmiers prescrit (injections, perfusions, pansements)', 1),
  (5, 'Surveiller l''état clinique des patients et détecter les anomalies', 2),
  (5, 'Collaborer avec l''équipe médicale et les aides-soignants', 3),
  (5, 'Participer aux transmissions orales et informatisées', 4);

-- recrutement_offer_profiles
INSERT INTO `recrutement_offer_profiles` (`offer_id`, `content`, `sort_order`) VALUES
  (1, 'Bac+5 en informatique (école d''ingénieur ou université)', 1),
  (1, '5 ans d''expérience minimum en développement full stack', 2),
  (1, 'Maîtrise de React, TypeScript, Node.js et des bases SQL/NoSQL', 3),
  (1, 'Expérience avec Docker, Kubernetes et les environnements cloud (AWS ou GCP)', 4),
  (2, 'Expert AWS (certifications AWS Solutions Architect ou DevOps Engineer recommandées)', 1),
  (2, 'Maîtrise de Terraform, Ansible, Kubernetes et Helm', 2),
  (2, 'Expérience en scripting Python et Bash', 3),
  (3, 'Bac+5 en Data Science, Statistiques ou équivalent', 1),
  (3, 'Maîtrise de Python (scikit-learn, pandas, XGBoost)', 2),
  (3, 'Connaissance des outils MLOps (MLflow, DVC) un plus', 3),
  (4, 'Bac+3 à Bac+5 en cybersécurité ou informatique', 1),
  (4, 'Connaissance des outils SIEM (Splunk, Microsoft Sentinel)', 2),
  (4, 'Certification CompTIA Security+ ou CEH appréciée', 3),
  (5, 'Diplôme d''État d''Infirmier(e) obligatoire', 1),
  (5, 'Inscription au Conseil de l''Ordre des Infirmiers', 2),
  (5, 'Expérience en cardiologie appréciée mais non obligatoire', 3);

-- recrutement_offer_advantages
INSERT INTO `recrutement_offer_advantages` (`offer_id`, `content`, `sort_order`) VALUES
  (1, 'Télétravail 3 jours/semaine', 1),
  (1, 'Tickets restaurant Swile 10€/jour (60% pris en charge)', 2),
  (1, 'Mutuelle Alan 100% prise en charge', 3),
  (1, 'Budget formation annuel 2 000€', 4),
  (1, 'Stock-options pour les profils seniors', 5),
  (2, 'Full remote possible', 1),
  (2, 'Mission renouvelable 12 mois', 2),
  (2, 'Équipement fourni (MacBook Pro M3)', 3),
  (3, 'Environnement startup dynamique et bienveillant', 1),
  (3, 'Flexibilité horaires', 2),
  (3, 'Accès aux conférences et meetups IA', 3),
  (4, 'Formation continue en cybersécurité financée', 1),
  (4, 'Certification prise en charge par l''entreprise', 2),
  (4, 'Primes sur objectifs', 3),
  (5, 'Primes SEGUR', 1),
  (5, 'Horaires fixes ou roulants selon préférence', 2),
  (5, 'Crèche hospitalière disponible', 3),
  (5, 'Self et stationnement gratuits', 4);

-- recrutement_tags
INSERT IGNORE INTO `recrutement_tags` (`site_id`, `name`, `slug`) VALUES
  (2, 'React',        'react'),
  (2, 'TypeScript',   'typescript'),
  (2, 'Node.js',      'nodejs'),
  (2, 'Python',       'python'),
  (2, 'Docker',       'docker'),
  (2, 'Kubernetes',   'kubernetes'),
  (2, 'AWS',          'aws'),
  (2, 'Azure',        'azure'),
  (2, 'Terraform',    'terraform'),
  (2, 'CI/CD',        'cicd'),
  (2, 'Machine Learning', 'machine-learning'),
  (2, 'SIEM',         'siem'),
  (2, 'Splunk',       'splunk'),
  (2, 'NestJS',       'nestjs'),
  (2, 'PostgreSQL',   'postgresql');

-- recrutement_offer_tags
INSERT IGNORE INTO `recrutement_offer_tags` (`offer_id`, `tag_id`) VALUES
  (1, 1),(1, 2),(1, 3),(1, 5),(1, 6),
  (2, 5),(2, 6),(2, 7),(2, 9),(2, 10),
  (3, 4),(3, 11),
  (4, 12),(4, 13),
  (7, 8),(7, 9),(7, 10),
  (8, 1),(8, 2);

-- recrutement_applications
INSERT INTO `recrutement_applications`
  (`offer_id`, `first_name`, `last_name`, `email`, `phone`,
   `cv_url`, `cover_letter`, `linkedin_url`, `status`) VALUES
  (1, 'Alexandre', 'Morand',  'alexandre.morand@gmail.com',   '06 12 34 56 78',
   '/uploads/cv/cv-alexandre-morand.pdf',
   'Passionné de React et d''architecture distribuée, je souhaite rejoindre une fintech ambitieuse...',
   'https://linkedin.com/in/alexandre-morand', 'interview'),
  (1, 'Camille',   'Nguyen',  'camille.nguyen@outlook.fr',    '07 23 45 67 89',
   '/uploads/cv/cv-camille-nguyen.pdf',
   'Développeuse senior avec 6 ans d''expérience en React et Node.js...',
   'https://linkedin.com/in/camille-nguyen', 'offer'),
  (1, 'Romain',    'Faure',   'romain.faure@yahoo.fr',        NULL,
   '/uploads/cv/cv-romain-faure.pdf',
   NULL, NULL, 'rejected'),
  (2, 'Hugo',      'Bastien', 'hugo.bastien@gmail.com',       '06 98 76 54 32',
   '/uploads/cv/cv-hugo-bastien.pdf',
   'DevOps freelance depuis 4 ans, certifié AWS SAA et CKA...',
   'https://linkedin.com/in/hugo-bastien', 'reviewing'),
  (3, 'Noémie',    'Carré',   'noemie.carre@gmail.com',       '07 45 67 89 01',
   '/uploads/cv/cv-noemie-carre.pdf',
   'Data scientist junior avec un Master en statistiques appliquées...',
   'https://linkedin.com/in/noemie-carre', 'new'),
  (5, 'Aurore',    'Tessier', 'aurore.tessier@gmail.com',     '06 34 56 78 90',
   '/uploads/cv/cv-aurore-tessier.pdf',
   'Infirmière DE depuis 3 ans, expérience en médecine interne...',
   NULL, 'new'),
  (5, 'Baptiste',  'Renard',  'baptiste.renard@hotmail.com',  '07 56 78 90 12',
   '/uploads/cv/cv-baptiste-renard.pdf',
   NULL, NULL, 'reviewing');

-- recrutement_application_history
INSERT INTO `recrutement_application_history`
  (`application_id`, `old_status`, `new_status`, `changed_by_id`, `note`) VALUES
  (1, 'new',        'reviewing',  4, 'CV intéressant, profil senior cohérent.'),
  (1, 'reviewing',  'interview',  4, 'Entretien planifié le 15/05 à 14h00.'),
  (2, 'new',        'reviewing',  4, 'Excellent profil, expérience parfaitement alignée.'),
  (2, 'reviewing',  'interview',  4, 'Entretien technique réussi.'),
  (2, 'interview',  'offer',      1, 'Offre transmise le 20/05. Salaire proposé : 67k.'),
  (3, 'new',        'rejected',   4, 'Profil trop junior pour le poste senior.'),
  (4, 'new',        'reviewing',  4, 'Certifications AWS vérifiées, TJM à négocier.');

-- =============================================================================
-- 4. FORMATION MODULE
-- =============================================================================

-- formation_categories
INSERT IGNORE INTO `formation_categories`
  (`id`, `site_id`, `name`, `slug`, `description`, `sort_order`, `is_active`) VALUES
  (1, 1, 'Développement Web',     'dev-web',      'Formations frontend, backend et full stack',       1, 1),
  (2, 1, 'Data & IA',             'data-ia',      'Data science, machine learning et intelligence artificielle', 2, 1),
  (3, 1, 'Cybersécurité',         'cybersecurite','Sécurité informatique et protection des données', 3, 1),
  (4, 1, 'Cloud & DevOps',        'cloud-devops', 'Infrastructure cloud et pratiques DevOps',        4, 1),
  (5, 1, 'Gestion de Projet',     'gestion-projet','Management de projet Agile et PMP',              5, 1),
  (6, 1, 'Réseaux & Systèmes',    'reseaux-sys',  'Administration système et réseaux',               6, 1);

-- formation_courses
INSERT INTO `formation_courses`
  (`id`, `site_id`, `category_id`, `title`, `slug`, `subtitle`,
   `duration`, `price`, `is_cpf_eligible`, `is_alternance`,
   `rncp_repertoire`, `rncp_code`, `rncp_title`, `rncp_level`, `rncp_url`,
   `presentation_title`, `presentation_text`,
   `cta_title`, `cta_subtitle`,
   `status`, `meta_title`, `meta_description`, `created_by`, `updated_by`) VALUES
  (1, 1, 1,
   'Développeur Web Full Stack',
   'developpeur-web-full-stack',
   'HTML, CSS, JavaScript, React, Node.js, SQL',
   '12 mois (800h)', 7800.00, 1, 1,
   'RNCP', '37680',
   'Concepteur développeur d''applications',
   6,
   'https://www.francecompetences.fr/recherche/rncp/37680/',
   'Le métier de Développeur Full Stack',
   '<p>Le développeur web full stack maîtrise les deux faces d''une application web...</p>',
   'Lancez votre carrière dans le développement web',
   'Formation éligible CPF, en alternance ou en financement personnel.',
   'published',
   'Formation Développeur Web Full Stack | Alt Formation',
   'Devenez développeur full stack en 12 mois. Formation RNCP niveau 6, éligible CPF et alternance.',
   2, 1),
  (2, 1, 2,
   'Data Analyst – Python & Power BI',
   'data-analyst-python-power-bi',
   'Python, Pandas, SQL, Power BI, Machine Learning',
   '9 mois (600h)', 6200.00, 1, 1,
   'RNCP', '36129',
   'Analyste de données / Data Analyst',
   6,
   'https://www.francecompetences.fr/recherche/rncp/36129/',
   'Le métier de Data Analyst',
   '<p>Le Data Analyst transforme les données brutes en insights actionnables...</p>',
   'Devenez Data Analyst en 9 mois',
   'Une formation intensive et professionnalisante, financeable CPF.',
   'published',
   'Formation Data Analyst Python Power BI | Alt Formation',
   'Devenez Data Analyst en 9 mois. Maîtrisez Python, SQL et Power BI. RNCP niveau 6.',
   2, 2),
  (3, 1, 3,
   'Expert Cybersécurité',
   'expert-cybersecurite',
   'Pentest, SOC, ISO 27001, RGPD, Forensics',
   '18 mois (1200h)', 12500.00, 1, 1,
   'RNCP', '38430',
   'Expert en cybersécurité des systèmes d''information',
   7,
   'https://www.francecompetences.fr/recherche/rncp/38430/',
   'Le métier d''Expert Cybersécurité',
   '<p>L''expert cybersécurité protège les systèmes d''information contre les cybermenaces...</p>',
   'Devenez un expert en cybersécurité',
   'La cybersécurité est le secteur qui recrute le plus en 2025.',
   'published',
   'Formation Expert Cybersécurité | Alt Formation',
   'Devenez expert en cybersécurité en 18 mois. RNCP niveau 7, certifications incluses.',
   2, 1),
  (4, 1, 4,
   'Ingénieur DevOps & Cloud AWS',
   'ingenieur-devops-cloud-aws',
   'Docker, Kubernetes, Terraform, AWS, CI/CD',
   '12 mois (800h)', 8900.00, 1, 1,
   'RNCP', '35326',
   'Administrateur systèmes et réseaux',
   6,
   'https://www.francecompetences.fr/recherche/rncp/35326/',
   'Le métier d''Ingénieur DevOps',
   '<p>L''ingénieur DevOps fait le pont entre le développement et l''exploitation...</p>',
   'Devenez Ingénieur DevOps',
   'L''un des profils les plus recherchés du marché IT en 2025.',
   'published',
   'Formation Ingénieur DevOps Cloud AWS | Alt Formation',
   'Devenez ingénieur DevOps en 12 mois. Docker, Kubernetes, AWS, Terraform. RNCP niveau 6.',
   2, 2),
  (5, 1, 5,
   'Chef de Projet Digital – Certification PMP',
   'chef-de-projet-digital-pmp',
   'Agile, Scrum, Kanban, PMP, Gestion des risques',
   '6 mois (400h)', 4500.00, 1, 0,
   'RS', 'RS6635',
   'Chef de projet en transformation digitale',
   NULL,
   NULL,
   'Le métier de Chef de Projet Digital',
   '<p>Le chef de projet digital pilote des projets de transformation numérique...</p>',
   'Obtenez votre certification PMP',
   'La certification PMP est reconnue mondialement dans plus de 200 pays.',
   'published',
   'Formation Chef de Projet Digital PMP | Alt Formation',
   'Obtenez la certification PMP en 6 mois. Formation éligible CPF.',
   2, 2),
  (6, 1, 2,
   'Intelligence Artificielle & Machine Learning',
   'intelligence-artificielle-machine-learning',
   'Python, Deep Learning, TensorFlow, PyTorch, NLP',
   '12 mois (900h)', 9200.00, 1, 1,
   'RNCP', '36129',
   'Ingénieur en intelligence artificielle',
   7, NULL,
   'Le métier d''Ingénieur IA',
   '<p>L''ingénieur IA conçoit et déploie des systèmes intelligents...</p>',
   'Devenez Ingénieur en IA',
   'L''IA est la compétence la plus demandée du marché tech en 2025.',
   'draft',
   NULL, NULL, 2, NULL);

-- formation_courses_versions
INSERT INTO `formation_courses_versions`
  (`course_id`, `title`, `presentation_text`, `status`, `created_by`) VALUES
  (1, 'Développeur Web Full Stack (v1)',
   '<p>Version initiale du programme...</p>', 'draft', 2),
  (1, 'Développeur Web Full Stack (v2)',
   '<p>Programme enrichi avec Node.js et TypeScript...</p>', 'published', 1),
  (3, 'Expert Cybersécurité (v1)',
   '<p>Programme initial centré sur le pentest...</p>', 'draft', 2);

-- formation_modules
INSERT INTO `formation_modules`
  (`course_id`, `title`, `description`, `duration`, `sort_order`) VALUES
  -- Développeur Web Full Stack
  (1, 'Fondamentaux du Web',         'HTML5, CSS3, JavaScript ES6+',                         '6 semaines',  1),
  (1, 'React & Écosystème Frontend', 'React 18, Hooks, Redux, TypeScript',                   '8 semaines',  2),
  (1, 'Node.js & Backend',           'Express, API REST, authentification JWT',              '8 semaines',  3),
  (1, 'Bases de données',            'SQL (PostgreSQL), NoSQL (MongoDB), ORM',               '4 semaines',  4),
  (1, 'DevOps & Déploiement',        'Git, Docker, CI/CD, hébergement cloud',                '4 semaines',  5),
  (1, 'Projet de fin de formation',  'Réalisation d''un projet full stack professionnel',    '18 semaines', 6),
  -- Data Analyst
  (2, 'Python pour la Data',         'Python, Pandas, NumPy, Matplotlib',                   '6 semaines',  1),
  (2, 'SQL & Bases de données',      'SQL avancé, PostgreSQL, modélisation',                 '4 semaines',  2),
  (2, 'Statistiques appliquées',     'Statistiques descriptives et inférentielles',          '4 semaines',  3),
  (2, 'Power BI & Dataviz',          'Power BI Desktop et Service, DAX',                    '4 semaines',  4),
  (2, 'Machine Learning intro',      'Régression, classification, clustering',               '4 semaines',  5),
  (2, 'Projet Data Analyst',         'Analyse complète sur données réelles',                 '14 semaines', 6),
  -- Expert Cybersécurité
  (3, 'Fondamentaux Cybersécurité',  'Concepts, menaces, normes ISO 27001/27002',            '6 semaines',  1),
  (3, 'Réseaux & Protocoles',        'TCP/IP, firewalls, VPN, IDS/IPS',                     '6 semaines',  2),
  (3, 'Pentest & Ethical Hacking',   'Kali Linux, Metasploit, OWASP Top 10',                '10 semaines', 3),
  (3, 'Forensics & Réponse à incident','Analyse forensique, gestion des incidents',         '8 semaines',  4),
  (3, 'SOC & SIEM',                  'Splunk, Microsoft Sentinel, Blue Team',               '8 semaines',  5),
  (3, 'Projet final + certifs',      'Préparation CEH, CompTIA Security+',                  '36 semaines', 6);

-- formation_skills
INSERT INTO `formation_skills` (`course_id`, `name`, `sort_order`) VALUES
  (1, 'Créer des interfaces React modernes et réactives', 1),
  (1, 'Développer des API REST sécurisées avec Node.js', 2),
  (1, 'Concevoir et interroger des bases de données SQL et NoSQL', 3),
  (1, 'Déployer une application avec Docker et CI/CD', 4),
  (1, 'Travailler en méthode Agile/Scrum', 5),
  (2, 'Analyser et nettoyer des datasets complexes avec Python', 1),
  (2, 'Créer des tableaux de bord interactifs avec Power BI', 2),
  (2, 'Modéliser et interroger des bases de données relationnelles', 3),
  (2, 'Appliquer des algorithmes de Machine Learning basiques', 4),
  (3, 'Réaliser des tests d''intrusion sur des systèmes web', 1),
  (3, 'Analyser des incidents de sécurité et réagir efficacement', 2),
  (3, 'Mettre en place une politique de sécurité ISO 27001', 3),
  (3, 'Surveiller un SI avec des outils SIEM professionnels', 4),
  (4, 'Concevoir et maintenir des pipelines CI/CD robustes', 1),
  (4, 'Orchestrer des conteneurs avec Kubernetes', 2),
  (4, 'Provisionner une infrastructure AWS avec Terraform', 3);

-- formation_jobs
INSERT INTO `formation_jobs`
  (`course_id`, `title`, `salary_min`, `salary_max`, `sort_order`) VALUES
  (1, 'Développeur Frontend',         35000, 55000, 1),
  (1, 'Développeur Backend',          38000, 58000, 2),
  (1, 'Développeur Full Stack',       40000, 65000, 3),
  (1, 'Développeur React',            42000, 68000, 4),
  (2, 'Data Analyst',                 35000, 52000, 1),
  (2, 'Business Analyst',             38000, 55000, 2),
  (2, 'BI Developer',                 40000, 58000, 3),
  (3, 'Analyste SOC',                 38000, 55000, 1),
  (3, 'Pentesteur',                   42000, 65000, 2),
  (3, 'RSSI adjoint',                 50000, 75000, 3),
  (3, 'Consultant cybersécurité',     45000, 70000, 4),
  (4, 'Ingénieur DevOps',             42000, 68000, 1),
  (4, 'Ingénieur Cloud AWS',          45000, 72000, 2),
  (4, 'SRE – Site Reliability Engineer', 48000, 75000, 3),
  (5, 'Chef de Projet IT',            40000, 60000, 1),
  (5, 'Scrum Master',                 42000, 62000, 2),
  (5, 'Product Owner',                44000, 65000, 3);

-- =============================================================================
-- 5. COACHING MODULE
-- =============================================================================

-- coaching_cities
INSERT IGNORE INTO `coaching_cities` (`id`, `name`, `slug`) VALUES
  (1,  'Paris',              'paris'),
  (2,  'Lyon',               'lyon'),
  (3,  'Marseille',          'marseille'),
  (4,  'Bordeaux',           'bordeaux'),
  (5,  'Lille',              'lille'),
  (6,  'Nantes',             'nantes'),
  (7,  'Toulouse',           'toulouse'),
  (8,  'Strasbourg',         'strasbourg'),
  (9,  'Rennes',             'rennes'),
  (10, 'Remote – France',    'remote-france');

-- coaching_specialties
INSERT IGNORE INTO `coaching_specialties` (`id`, `name`, `slug`, `icon`) VALUES
  (1, 'Dirigeants',            'dirigeants',            'crown'),
  (2, 'Managers',              'managers',              'briefcase'),
  (3, 'Équipes',               'equipes',               'users'),
  (4, 'Reconversion',          'reconversion',          'refresh-cw'),
  (5, 'Bien-être au travail',  'bien-etre-travail',     'heart'),
  (6, 'Stress & burn-out',     'stress-burn-out',       'activity'),
  (7, 'Prise de parole',       'prise-de-parole',       'mic'),
  (8, 'Assertivité',           'assertivite',           'shield'),
  (9, 'Intelligence émotionnelle','intelligence-emotionnelle','zap');

-- coaching_certifications
INSERT IGNORE INTO `coaching_certifications` (`id`, `code`, `organization`, `level`) VALUES
  (1, 'ICF MCC',  'ICF',              3),
  (2, 'ICF PCC',  'ICF',              2),
  (3, 'ICF ACC',  'ICF',              1),
  (4, 'EMCC SP',  'EMCC',             3),
  (5, 'EMCC MP',  'EMCC',             2),
  (6, 'RNCP',     'France Compétences',1),
  (7, 'MBTI',     'The Myers-Briggs', NULL),
  (8, 'Process Com', 'Kahler Communications', NULL);

-- coaching_coaches
INSERT INTO `coaching_coaches`
  (`id`, `site_id`, `first_name`, `last_name`, `slug`, `email`, `phone`,
   `avatar_url`, `title`, `short_bio`, `full_bio`,
   `experience_years`, `city_id`, `languages`,
   `rating_avg`, `reviews_count`, `is_available`, `status`) VALUES
  (1, 6, 'Isabelle', 'Marchand', 'isabelle-marchand',
   'isabelle.marchand@coaching-nexytal.com', '06 11 22 33 44',
   '/uploads/coaches/isabelle-marchand.jpg',
   'Coach exécutif certifiée ICF MCC | Dirigeants & Transformations',
   'Isabelle accompagne des dirigeants et managers dans les transitions stratégiques depuis 15 ans.',
   '<h2>Mon parcours</h2><p>Ancienne DRH d''un groupe CAC40, j''ai rejoint le monde du coaching après avoir vécu de l''intérieur les transformations organisationnelles...</p>',
   15, 1, '["Français","Anglais","Espagnol"]', 4.90, 47, 1, 'active'),
  (2, 6, 'François', 'Beaumont', 'francois-beaumont',
   'francois.beaumont@coaching-nexytal.com', '07 33 44 55 66',
   '/uploads/coaches/francois-beaumont.jpg',
   'Coach de managers | Intelligence émotionnelle & Leadership',
   'François aide les managers à développer leur leadership authentique et à fédérer leurs équipes.',
   '<h2>Mon parcours</h2><p>Psychologue du travail de formation, j''exerce le coaching depuis 10 ans auprès de managers en prise de poste...</p>',
   10, 2, '["Français","Anglais"]', 4.75, 31, 1, 'active'),
  (3, 6, 'Stéphanie', 'Aubert', 'stephanie-aubert',
   'stephanie.aubert@coaching-nexytal.com', '06 44 55 66 77',
   '/uploads/coaches/stephanie-aubert.jpg',
   'Coach bien-être & prévention burn-out | Salariés & Managers',
   'Stéphanie spécialiste du bien-être au travail, aide ses clients à retrouver équilibre et sérénité.',
   '<h2>Mon parcours</h2><p>Infirmière reconvertie coach, j''ai développé une approche holistique du bien-être professionnel...</p>',
   8, 10, '["Français"]', 4.85, 28, 1, 'active'),
  (4, 6, 'Laurent', 'Defresne', 'laurent-defresne',
   'laurent.defresne@coaching-nexytal.com', '07 55 66 77 88',
   '/uploads/coaches/laurent-defresne.jpg',
   'Coach prise de parole & communication | Cadres dirigeants',
   'Laurent aide les leaders à développer un impact communicationnel fort et authentique.',
   '<h2>Mon parcours</h2><p>Ancien comédien et formateur en expression orale, je coach les dirigeants sur leurs prises de parole en public...</p>',
   12, 1, '["Français","Anglais"]', 4.70, 19, 1, 'active'),
  (5, 6, 'Amandine', 'Perrot', 'amandine-perrot',
   'amandine.perrot@coaching-nexytal.com', NULL,
   '/uploads/coaches/amandine-perrot.jpg',
   'Coach reconversion professionnelle | Bilan de compétences',
   'Amandine accompagne les professionnels en transition vers un nouveau projet de vie.',
   '<h2>Mon parcours</h2><p>Après 10 ans dans les RH, j''ai moi-même vécu une reconversion réussie et me suis formée au coaching pour aider les autres à faire de même...</p>',
   6, 10, '["Français"]', 4.80, 22, 1, 'active');

-- coaching_coach_specialties
INSERT IGNORE INTO `coaching_coach_specialties` (`coach_id`, `specialty_id`) VALUES
  (1, 1),(1, 2),(1, 3),
  (2, 2),(2, 9),(2, 3),
  (3, 5),(3, 6),(3, 4),
  (4, 7),(4, 8),(4, 2),
  (5, 4),(5, 5),(5, 8);

-- coaching_coach_certifications
INSERT IGNORE INTO `coaching_coach_certifications`
  (`coach_id`, `certification_id`, `year_obtained`) VALUES
  (1, 1, 2018),(1, 4, 2020),(1, 7, 2015),
  (2, 2, 2019),(2, 8, 2018),(2, 7, 2021),
  (3, 3, 2022),(3, 6, 2022),
  (4, 2, 2017),(4, 8, 2019),
  (5, 3, 2023),(5, 6, 2023);

-- coaching_reviews
INSERT INTO `coaching_reviews`
  (`coach_id`, `author_name`, `author_title`, `author_company`,
   `rating`, `comment`, `is_verified`, `is_published`) VALUES
  (1, 'Bertrand Lacour',    'CEO',             'Lacour Industries',
   5, 'Un accompagnement exceptionnel lors de ma prise de poste de PDG. Isabelle a su me challenger avec bienveillance et m''aider à clarifier ma vision stratégique.', 1, 1),
  (1, 'Sophie Tremblay',    'DRH',             'Groupe Santé+',
   5, 'Isabelle est une coach d''une rare finesse. Elle a transformé notre comité de direction en une équipe soudée et performante.', 1, 1),
  (1, 'Marc Fontaine',      'Directeur Général','StartupTech',
   4, 'Très bonne expérience. Quelques séances m''ont suffi pour prendre des décisions importantes avec plus de sérénité.', 1, 1),
  (2, 'Laura Renaud',       'Manager Équipe',  'BNP Paribas',
   5, 'François m''a aidée à mieux comprendre mes émotions au travail et à adapter mon style de management. Résultats bluffants sur la cohésion d''équipe.', 1, 1),
  (2, 'Éric Martineau',     'Responsable SI',  'Orange Business',
   5, '10 séances qui ont changé ma vie professionnelle. Je gère maintenant mes conflits d''équipe avec beaucoup plus de sérénité.', 1, 1),
  (3, 'Céline Rousset',     'Infirmière cadre','CHU Bordeaux',
   5, 'Stéphanie m''a sauvée du burn-out. Son approche bienveillante et ses outils concrets m''ont aidée à retrouver l''équilibre.', 1, 1),
  (3, 'Julien Barbier',     'Product Manager', 'E-commerce Corp',
   5, 'Un coaching qui change la vie. Stéphanie sait exactement comment aborder les problèmes de stress professionnel.', 1, 1),
  (4, 'Christine Moreau',   'Directrice',      'Fond d''investissement',
   4, 'Laurent m''a aidée à structurer mes prises de parole en comité. Mes présentations sont maintenant beaucoup plus impactantes.', 1, 1),
  (5, 'Franck Dumont',      'Ingénieur',       NULL,
   5, 'Grâce à Amandine j''ai clarifié mon projet de reconversion et j''ai trouvé un poste qui me correspond enfin. Merci !', 1, 1),
  (5, 'Nathalie Guerin',    'Commerciale',     'Mutuelle Santé',
   5, 'Un bilan de compétences transformateur. Amandine m''a accompagnée avec beaucoup de professionnalisme et d''humanité.', 1, 1);

-- coaching_bookings
INSERT INTO `coaching_bookings`
  (`coach_id`, `first_name`, `last_name`, `email`, `phone`,
   `booked_for`, `duration_minutes`, `status`, `notes`) VALUES
  (1, 'Antoine',  'Vernet',    'antoine.vernet@gmail.com',   '06 12 12 12 12',
   '2025-06-02 09:00:00', 60, 'confirmed',
   'Séance de découverte – prise de poste de DG prévue en septembre.'),
  (1, 'Marianne', 'Berthet',   'marianne.berthet@corp.fr',   '07 23 23 23 23',
   '2025-06-05 14:00:00', 90, 'confirmed',
   'Séance de suivi n°3 – travail sur la délégation.'),
  (2, 'David',    'Calmels',   'david.calmels@outlook.com',  '06 34 34 34 34',
   '2025-06-03 10:30:00', 60, 'pending',
   'Première séance. Manager depuis 6 mois, difficultés relationnelles avec l''équipe.'),
  (3, 'Julie',    'Simon',     'julie.simon@yahoo.fr',        NULL,
   '2025-06-10 11:00:00', 60, 'pending', NULL),
  (5, 'Paul',     'Auger',     'paul.auger@gmail.com',        '06 56 56 56 56',
   '2025-05-28 09:00:00', 90, 'completed',
   'Bilan de compétences – séance finale. Excellent déroulé.'),
  (5, 'Valérie',  'Tissot',    'valerie.tissot@gmail.com',    '07 67 67 67 67',
   '2025-06-15 15:00:00', 60, 'confirmed', NULL),
  (1, 'Olivier',  'Caron',     'olivier.caron@startup.io',    '06 78 78 78 78',
   '2025-05-15 09:00:00', 60, 'cancelled',
   'Annulé par le client 24h avant – à replanifier.');

-- coaching_diagnostic_requests
INSERT INTO `coaching_diagnostic_requests`
  (`coach_id`, `first_name`, `last_name`, `email`, `phone`,
   `company`, `job_title`, `coaching_type`,
   `message`, `budget_range`, `status`) VALUES
  (1, 'Henri',    'Vasseur',   'henri.vasseur@fintech.fr',    '06 90 90 90 90',
   'FinTech Solutions', 'Directeur Général',
   'Coaching de dirigeants',
   'Je prends la direction générale en septembre et souhaite un accompagnement de 6 mois.',
   '10k-20k', 'contacted'),
  (2, 'Karima',   'Boudali',   'karima.boudali@corp.com',     '07 01 01 01 01',
   'Grande Distribution', 'Responsable d''équipe',
   'Coaching de managers',
   'Mon équipe de 8 personnes traverse des tensions. J''ai besoin d''outils concrets.',
   '5k-10k', 'new'),
  (3, 'Thomas',   'Collin',    'thomas.collin@gmail.com',     NULL,
   NULL, 'Développeur senior',
   'Coaching bien-être',
   'Je ressens des signes de burn-out et souhaite un accompagnement préventif.',
   '<5k', 'new'),
  (5, 'Laure',    'Mignot',    'laure.mignot@gmail.com',      '06 22 22 22 22',
   'Assurance nationale', 'Conseillère clientèle',
   'Reconversion professionnelle',
   'Je veux changer de métier après 12 ans dans l''assurance. Je ne sais pas par où commencer.',
   '5k-10k', 'converted'),
  (NULL,'Pierre', 'Garnier',   'pierre.garnier@hotmail.fr',   '07 33 33 33 33',
   NULL, 'Enseignant',
   'Prise de parole en public',
   'Je dois animer des conférences et j''ai une peur intense de prendre la parole.',
   '<5k', 'contacted');

-- =============================================================================
-- 6. MARKETING MODULE
-- =============================================================================

-- marketing_newsletter_subs
INSERT INTO `marketing_newsletter_subs`
  (`site_id`, `email`, `first_name`, `is_active`, `unsub_token`) VALUES
  (1, 'flora.martin@gmail.com',     'Flora',    1, 'unsub_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7'),
  (1, 'kevin.dubois@outlook.fr',    'Kevin',    1, 'unsub_b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8'),
  (2, 'sarah.leclerc@gmail.com',    'Sarah',    1, 'unsub_c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9'),
  (2, 'remi.bonnet@yahoo.fr',       'Rémi',     1, 'unsub_d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0'),
  (3, 'infirmiere.pro@gmail.com',   NULL,       1, 'unsub_e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1'),
  (4, 'cherche.emploi@outlook.com', 'Alexandre',1, 'unsub_f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2'),
  (4, 'marie.truc@gmail.com',       'Marie',    0, 'unsub_g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3'),
  (5, 'formateur.indie@gmail.com',  'Bertrand', 1, 'unsub_h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4'),
  (6, 'manager.lyon@corp.fr',       'Sylvie',   1, 'unsub_i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5'),
  (6, 'dirigeant@pme.fr',           'Patrick',  1, 'unsub_j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6');

-- email_logs
INSERT INTO `email_logs`
  (`recipient_email`, `subject`, `email_type`, `site_id`, `status`) VALUES
  ('flora.martin@gmail.com',     'Bienvenue sur Alt Formation !',         'confirmation',    1, 'sent'),
  ('kevin.dubois@outlook.fr',    'Votre newsletter Alt Formation – Mai 2025', 'newsletter',  1, 'opened'),
  ('sarah.leclerc@gmail.com',    'Nouvelle offre DevOps AWS qui vous correspond', 'job_alert',2,'sent'),
  ('remi.bonnet@yahoo.fr',       'Bienvenue sur Nexytal Recrutement',     'confirmation',    2, 'sent'),
  ('marie.truc@gmail.com',       'Confirmez votre désinscription',        'unsub_confirm',   4, 'sent'),
  ('alexandre.morand@gmail.com', 'Votre candidature a bien été reçue',    'app_confirmation',2, 'opened'),
  ('camille.nguyen@outlook.fr',  'Mise à jour de votre candidature',      'status_update',   2, 'sent'),
  ('admin@nexytal.com',          'Nouveau message de contact – Coaching', 'admin_notif',     6, 'sent'),
  ('laure.mignot@gmail.com',     'Réinitialisation de votre mot de passe','password_reset',  4, 'sent'),
  ('dirigeant@pme.fr',           'Votre diagnostic coaching a été reçu',  'diag_confirm',    6, 'opened');

-- =============================================================================
-- 7. GDPR / RGPD MODULE
-- =============================================================================

-- gdpr_consents
INSERT INTO `gdpr_consents`
  (`user_type`, `user_email`, `user_id`, `consent_type`,
   `is_given`, `given_at`, `ip_address`) VALUES
  ('applicant',           'alexandre.morand@gmail.com', 1, 'data_processing', 1, '2025-04-10 14:32:00', '88.101.23.45'),
  ('applicant',           'camille.nguyen@outlook.fr',  2, 'data_processing', 1, '2025-04-12 09:15:00', '90.112.34.56'),
  ('subscriber',          'flora.martin@gmail.com',     NULL,'marketing',     1, '2025-03-01 11:00:00', '92.123.45.67'),
  ('subscriber',          'kevin.dubois@outlook.fr',    NULL,'marketing',     1, '2025-03-15 16:45:00', '78.134.56.78'),
  ('subscriber',          'marie.truc@gmail.com',       NULL,'marketing',     0, '2025-04-20 10:30:00', '82.145.67.89'),
  ('diagnostic_request',  'henri.vasseur@fintech.fr',   NULL,'data_processing',1,'2025-05-05 09:00:00','94.156.78.90'),
  ('review_author',       'bertrand.lacour@indus.fr',   NULL,'data_processing',1,'2025-04-01 14:00:00', '88.167.89.01'),
  ('applicant',           'aurore.tessier@gmail.com',   6,   'data_processing',1,'2025-05-10 11:00:00', '90.178.90.12');

-- gdpr_deletion_requests
INSERT INTO `gdpr_deletion_requests`
  (`user_type`, `user_email`, `user_id`, `reason`,
   `status`, `processed_at`, `processed_by`) VALUES
  ('applicant', 'romain.faure@yahoo.fr', 3,
   'Je souhaite que mes données soient supprimées suite à ma candidature.',
   'completed', '2025-05-01 10:00:00', 1),
  ('subscriber', 'marie.truc@gmail.com', NULL,
   'Je ne souhaite plus recevoir de communications.',
   'completed', '2025-04-21 09:00:00', 5),
  ('diagnostic_request', 'thomas.collin@gmail.com', NULL,
   'Droit à l''oubli RGPD.',
   'pending', NULL, NULL);

-- =============================================================================
-- 8. MEDIA LIBRARY
-- =============================================================================

INSERT INTO `media_library`
  (`site_id`, `file_name`, `file_path`, `mime_type`, `file_size`,
   `alt_text`, `uploaded_by`) VALUES
  (NULL, 'logo-nexytal.svg',              '/uploads/global/logo-nexytal.svg',             'image/svg+xml',  12400,  'Logo Nexytal Group',                    1),
  (1,    'hero-alt-formation.jpg',        '/uploads/alt/hero-alt-formation.jpg',           'image/jpeg',     384000, 'Étudiants en formation informatique',   2),
  (1,    'cover-dev-web.jpg',             '/uploads/alt/cover-dev-web.jpg',                'image/jpeg',     256000, 'Développeur web au travail',            2),
  (1,    'cover-data-analyst.jpg',        '/uploads/alt/cover-data-analyst.jpg',           'image/jpeg',     198000, 'Analyste de données',                   2),
  (1,    'cv-alexandre-morand.pdf',       '/uploads/cv/cv-alexandre-morand.pdf',           'application/pdf',145000, NULL,                                    NULL),
  (1,    'cv-camille-nguyen.pdf',         '/uploads/cv/cv-camille-nguyen.pdf',             'application/pdf',132000, NULL,                                    NULL),
  (2,    'hero-recrutement.jpg',          '/uploads/recrut/hero-recrutement.jpg',          'image/jpeg',     412000, 'Entretien d''embauche IT',               4),
  (3,    'hero-medical.jpg',              '/uploads/medical/hero-medical.jpg',             'image/jpeg',     389000, 'Professionnel de santé',                4),
  (4,    'entretien-2025.jpg',            '/uploads/blog/entretien-2025.jpg',              'image/jpeg',     220000, 'Candidat lors d''un entretien',         3),
  (4,    'cv-2025.jpg',                   '/uploads/blog/cv-2025.jpg',                     'image/jpeg',     185000, 'CV sur ordinateur',                     3),
  (4,    'reconversion.jpg',              '/uploads/blog/reconversion.jpg',                'image/jpeg',     240000, 'Chemin de reconversion professionnelle',3),
  (6,    'isabelle-marchand.jpg',         '/uploads/coaches/isabelle-marchand.jpg',        'image/jpeg',     178000, 'Coach Isabelle Marchand',               1),
  (6,    'francois-beaumont.jpg',         '/uploads/coaches/francois-beaumont.jpg',        'image/jpeg',     165000, 'Coach François Beaumont',               1),
  (6,    'leadership.jpg',               '/uploads/blog/leadership.jpg',                  'image/jpeg',     210000, 'Leader inspirant',                      6),
  (NULL, 'favicon.ico',                  '/uploads/global/favicon.ico',                   'image/x-icon',   4096,   'Favicon Nexytal',                       1);

-- =============================================================================
-- 9. SEO METADATA
-- =============================================================================

INSERT INTO `seo_metadata`
  (`site_id`, `entity_type`, `entity_id`,
   `canonical_url`, `og_title`, `og_description`, `og_image`,
   `schema_json`) VALUES
  (1, 'formation_course', 1,
   'https://alt-formation.fr/formations/developpeur-web-full-stack',
   'Formation Développeur Web Full Stack | Alt Formation',
   'Devenez développeur full stack en 12 mois. RNCP niveau 6, éligible CPF.',
   'https://alt-formation.fr/uploads/alt/cover-dev-web.jpg',
   '{"@context":"https://schema.org","@type":"Course","name":"Développeur Web Full Stack","provider":{"@type":"Organization","name":"Alt Formation"},"educationalLevel":"RNCP niveau 6"}'),
  (1, 'formation_course', 2,
   'https://alt-formation.fr/formations/data-analyst-python-power-bi',
   'Formation Data Analyst Python & Power BI | Alt Formation',
   'Devenez Data Analyst en 9 mois. Python, SQL, Power BI. RNCP niveau 6.',
   'https://alt-formation.fr/uploads/alt/cover-data-analyst.jpg',
   '{"@context":"https://schema.org","@type":"Course","name":"Data Analyst – Python & Power BI","provider":{"@type":"Organization","name":"Alt Formation"}}'),
  (2, 'recrutement_offer', 1,
   'https://recrutement.nexytal.com/offres/developpeur-full-stack-react-nodejs-senior',
   'Développeur Full Stack React/Node.js – Senior | Nexytal Recrutement',
   'CDI – Paris 8e – 55 à 70k. TechCorp Paris recrute son développeur full stack.',
   'https://recrutement.nexytal.com/uploads/recrut/hero-recrutement.jpg',
   '{"@context":"https://schema.org","@type":"JobPosting","title":"Développeur Full Stack React/Node.js – Senior","hiringOrganization":{"@type":"Organization","name":"TechCorp Paris"},"jobLocation":{"@type":"Place","address":{"@type":"PostalAddress","addressLocality":"Paris","postalCode":"75008","addressCountry":"FR"}},"employmentType":"FULL_TIME","baseSalary":{"@type":"MonetaryAmount","currency":"EUR","value":{"@type":"QuantitativeValue","minValue":55000,"maxValue":70000,"unitText":"YEAR"}}}'),
  (3, 'recrutement_profession', 2,
   'https://medical.nexytal.com/metiers/infirmier',
   'Emploi Infirmier(e) – Offres et conseils | Nexytal Médical',
   'Trouvez un poste d''infirmier(e) : CHU, cliniques, EHPAD. Offres CDI et CDD partout en France.',
   'https://medical.nexytal.com/uploads/medical/hero-medical.jpg',
   '{"@context":"https://schema.org","@type":"Occupation","name":"Infirmier(e) Diplômé(e) d''État","occupationalCategory":"2914","estimatedSalary":{"@type":"MonetaryAmountDistribution","currency":"EUR","median":29000}}'),
  (6, 'coaching_coach', 1,
   'https://coaching.nexytal.com/coachs/isabelle-marchand',
   'Isabelle Marchand – Coach exécutif certifiée ICF MCC | Nexytal Coaching',
   'Coach de dirigeants certifiée ICF MCC, 15 ans d''expérience. Transformations stratégiques.',
   'https://coaching.nexytal.com/uploads/coaches/isabelle-marchand.jpg',
   '{"@context":"https://schema.org","@type":"Person","name":"Isabelle Marchand","jobTitle":"Coach exécutif certifiée ICF MCC","worksFor":{"@type":"Organization","name":"Nexytal Coaching"},"knowsAbout":["Leadership","Coaching de dirigeants","Transformation organisationnelle"]}'),
  (4, 'blog_post', 1,
   'https://carriere.nexytal.com/blog/10-conseils-entretien-embauche-2025',
   '10 conseils pour réussir son entretien d''embauche en 2025',
   'Décrochez votre prochain poste grâce à nos 10 conseils d''experts pour réussir votre entretien.',
   'https://carriere.nexytal.com/uploads/blog/entretien-2025.jpg',
   '{"@context":"https://schema.org","@type":"BlogPosting","headline":"10 conseils pour réussir son entretien d''embauche en 2025","author":{"@type":"Person","name":"Claire Fontaine"},"datePublished":"2025-03-15","publisher":{"@type":"Organization","name":"Nexytal Carrière"}}');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- FIN DES INSERTS — bdd_nexytal v3.0
-- Résumé :
--   core_sites                        6 lignes
--   core_admin_users                  5 lignes
--   core_admin_site_access           14 lignes
--   core_admin_sessions               2 lignes
--   core_password_reset_tokens        2 lignes
--   core_admin_activity_logs          8 lignes
--   core_settings                    18 lignes
--   core_audit_logs                   5 lignes
--   blog_categories                  13 lignes
--   blog_tags                        16 lignes
--   blog_authors                      6 lignes
--   blog_posts                       10 lignes
--   blog_posts_versions               4 lignes
--   blog_post_tags                   17 lignes
--   blog_related_posts                8 lignes
--   blog_comments                     8 lignes
--   recrutement_sectors              10 lignes
--   recrutement_jobs                 17 lignes
--   recrutement_contract_types        6 lignes
--   recrutement_professions           6 lignes
--   recrutement_offers                8 lignes
--   recrutement_offer_missions       17 lignes
--   recrutement_offer_profiles       15 lignes
--   recrutement_offer_advantages     18 lignes
--   recrutement_tags                 15 lignes
--   recrutement_offer_tags           19 lignes
--   recrutement_applications          7 lignes
--   recrutement_application_history   7 lignes
--   formation_categories              6 lignes
--   formation_courses                 6 lignes
--   formation_courses_versions        3 lignes
--   formation_modules                18 lignes
--   formation_skills                 16 lignes
--   formation_jobs                   17 lignes
--   coaching_cities                  10 lignes
--   coaching_specialties              9 lignes
--   coaching_certifications           8 lignes
--   coaching_coaches                  5 lignes
--   coaching_coach_specialties       15 lignes
--   coaching_coach_certifications    12 lignes
--   coaching_reviews                 10 lignes
--   coaching_bookings                 7 lignes
--   coaching_diagnostic_requests      5 lignes
--   marketing_newsletter_subs        10 lignes
--   email_logs                       10 lignes
--   gdpr_consents                     8 lignes
--   gdpr_deletion_requests            3 lignes
--   media_library                    15 lignes
--   seo_metadata                      6 lignes
-- =============================================================================
