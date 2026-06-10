-- Import minimal si bdd_nexytal_inserts.sql a été exécuté avec USE bdd_nexytal (mauvaise base)
-- À lancer dans phpMyAdmin sur la base dbs15772578

SET NAMES utf8mb4;
USE `dbs15772578`;

INSERT IGNORE INTO `core_sites` (`id`, `name`, `slug`, `domain`, `is_active`) VALUES
  (1, 'Alt Formation',       'alt-formation',       'alt-formation.fr',           1),
  (2, 'Nexytal Recrutement', 'nexytal-recrutement', 'recrutement.nexytal.com',    1),
  (3, 'Nexytal Médical',     'nexytal-medical',     'medical.nexytal.com',        1),
  (4, 'Nexytal Carrière',    'nexytal-carriere',    'carriere.nexytal.com',       1),
  (5, 'Nexytal Trainer',     'nexytal-trainer',     'trainer.nexytal.com',        1),
  (6, 'Nexytal Coaching',    'nexytal-coaching',    'coaching.nexytal.com',       1);
