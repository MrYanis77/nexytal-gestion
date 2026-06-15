-- Séparation des données recrutement (site 2) / médical (site 3)
-- À exécuter une fois sur la base de production

ALTER TABLE `secteurs_activite`
  ADD COLUMN `site_id` int(11) DEFAULT NULL AFTER `id`,
  ADD INDEX `idx_secteur_site` (`site_id`);

ALTER TABLE `entreprises`
  ADD COLUMN `site_id` int(11) DEFAULT NULL AFTER `id`,
  ADD INDEX `idx_entreprise_site` (`site_id`);

ALTER TABLE `recruteurs`
  MODIFY COLUMN `user_id` int(11) UNSIGNED DEFAULT NULL;

-- Optionnel : rattacher les données existantes au recrutement IT
-- UPDATE secteurs_activite SET site_id = 2 WHERE site_id IS NULL;
-- UPDATE entreprises SET site_id = 2 WHERE site_id IS NULL;
-- UPDATE metiers SET site_id = 2 WHERE site_id IS NULL;
