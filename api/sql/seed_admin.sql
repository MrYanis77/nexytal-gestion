-- =============================================================================
-- NEXYTAL — Création / réinitialisation du compte superadmin
-- À exécuter dans phpMyAdmin (Ionos) sur la BDD dbu12345678 / bdd_nexytal
-- =============================================================================
--
-- IDENTIFIANTS DE CONNEXION :
--   Identifiant (champ email) : admin@nexytal.com
--   Mot de passe              : password
--
-- Hash bcrypt vérifié compatible PHP password_verify()
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Option A : Réinitialiser le compte existant (email = "admin" dans votre phpMyAdmin)
UPDATE `core_admin_users`
SET
  `password_hash` = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  `first_name`    = 'Jean',
  `last_name`     = 'Dupont',
  `role`          = 'superadmin',
  `is_active`     = 1,
  `updated_at`    = NOW()
WHERE `email` = 'admin';

SET @admin_id = (SELECT `id` FROM `core_admin_users` WHERE `email` = 'admin' LIMIT 1);

INSERT IGNORE INTO `core_admin_site_access` (`admin_id`, `site_id`) VALUES
(@admin_id, 1), (@admin_id, 2), (@admin_id, 3), (@admin_id, 4), (@admin_id, 5), (@admin_id, 6);

-- Option B : Créer ou mettre à jour admin@nexytal.com (identifiant email classique)
INSERT INTO `core_admin_users` (
  `email`,
  `password_hash`,
  `first_name`,
  `last_name`,
  `role`,
  `avatar_url`,
  `is_active`
) VALUES (
  'admin@nexytal.com',
  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'Super',
  'Admin',
  'superadmin',
  NULL,
  1
)
ON DUPLICATE KEY UPDATE
  `password_hash` = VALUES(`password_hash`),
  `first_name`    = VALUES(`first_name`),
  `last_name`     = VALUES(`last_name`),
  `role`          = VALUES(`role`),
  `is_active`     = 1,
  `updated_at`    = NOW();

-- Récupérer l'id de l'admin (pour les accès sites)
SET @admin_id = (SELECT `id` FROM `core_admin_users` WHERE `email` = 'admin@nexytal.com' LIMIT 1);

-- Accès à tous les sites (1 à 6)
INSERT IGNORE INTO `core_admin_site_access` (`admin_id`, `site_id`) VALUES
(@admin_id, 1),
(@admin_id, 2),
(@admin_id, 3),
(@admin_id, 4),
(@admin_id, 5),
(@admin_id, 6);

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- Après exécution, connectez-vous sur https://connexion.nexytal.com/login avec :
--   admin              /  password   (Option A)
--   admin@nexytal.com  /  password   (Option B)
-- =============================================================================
