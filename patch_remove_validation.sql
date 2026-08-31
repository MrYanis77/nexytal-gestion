-- patch_remove_validation.sql

-- 1. Modification des tables de candidatures pour supprimer les colonnes de validation
ALTER TABLE `candidatures`
  DROP COLUMN IF EXISTS `verifie_nexytal`,
  DROP COLUMN IF EXISTS `score_nexytal`,
  DROP COLUMN IF EXISTS `note_nexytal`;

ALTER TABLE `candidatures_externes`
  DROP COLUMN IF EXISTS `verifie_nexytal`,
  DROP COLUMN IF EXISTS `score_nexytal`,
  DROP COLUMN IF EXISTS `note_nexytal`;

-- 2. Création de la table villes (pour les référentiels de lieux)
CREATE TABLE IF NOT EXISTS `villes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `site_id` INT NULL COMMENT 'Site (optionnel, pour lier une ville à un site particulier)',
  `nom` VARCHAR(150) NOT NULL,
  `slug` VARCHAR(150) NOT NULL,
  `code_postal` VARCHAR(10) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_villes_slug` (`slug`, `site_id`),
  CONSTRAINT `fk_villes_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Ajout de site_id à la table competences
ALTER TABLE `competences`
  ADD COLUMN `site_id` INT NULL AFTER `id`;

ALTER TABLE `competences`
  ADD CONSTRAINT `fk_competences_site` FOREIGN KEY (`site_id`) REFERENCES `core_sites` (`id`) ON DELETE CASCADE;

-- Optionnel: Si la contrainte uk_competence_slug existe, on la droppe pour permettre les mêmes slugs sur différents sites
-- ALTER TABLE `competences` DROP INDEX `uk_competence_slug`;
-- ALTER TABLE `competences` ADD UNIQUE KEY `uk_competence_slug_site` (`slug`, `site_id`);

-- 4. Recréer la vue v_gestion_candidatures sans les colonnes supprimées
CREATE OR REPLACE VIEW v_gestion_candidatures AS
SELECT 
  'externe' AS type,
  ce.id AS candidature_id,
  ce.site_id,
  cs.site_code,
  ce.offre_id,
  o.titre AS offre_titre,
  o.statut AS offre_statut,
  o.recruteur_id,
  COALESCE(e.nom, r.nom_entreprise) AS entreprise_nom,
  r.email AS recruteur_email,
  ce.prenom,
  ce.nom,
  ce.email AS candidat_email,
  ce.telephone,
  ce.lettre_motivation AS message,
  ce.cv_filename,
  ce.experience_candidat,
  ce.competences_reponses,
  ce.disponibilite,
  ce.statut,
  ce.created_at AS date_candidature
FROM candidatures_externes ce
JOIN core_sites cs ON cs.id = ce.site_id
JOIN offres_emploi o ON o.id = ce.offre_id
LEFT JOIN recruteurs r ON r.id = o.recruteur_id
LEFT JOIN entreprises e ON e.id = o.entreprise_id

UNION ALL

SELECT 
  'interne' AS type,
  c.id AS candidature_id,
  o.site_id,
  cs.site_code,
  c.offre_id,
  o.titre AS offre_titre,
  o.statut AS offre_statut,
  o.recruteur_id,
  COALESCE(e.nom, r.nom_entreprise) AS entreprise_nom,
  r.email AS recruteur_email,
  ca.prenom,
  ca.nom,
  COALESCE(u.email, '') AS candidat_email,
  ca.telephone,
  c.message_motivation AS message,
  NULL AS cv_filename,
  NULL AS experience_candidat,
  NULL AS competences_reponses,
  ca.disponibilite,
  c.statut,
  c.date_candidature
FROM candidatures c
JOIN candidats ca ON ca.id = c.candidat_id
LEFT JOIN users u ON u.id = ca.user_id
JOIN offres_emploi o ON o.id = c.offre_id
JOIN core_sites cs ON cs.id = o.site_id
LEFT JOIN recruteurs r ON r.id = o.recruteur_id
LEFT JOIN entreprises e ON e.id = o.entreprise_id;
