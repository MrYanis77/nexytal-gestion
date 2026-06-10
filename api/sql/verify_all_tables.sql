-- Vérification des 49 tables — attendu : count > 0 pour chaque table peuplée
-- Les tables sans données affichent cnt = 0 (à corriger avec seed_empty_tables.sql ou bdd_nexytal_inserts.sql)

USE `dbs15772578`;

SELECT tbl, cnt,
  CASE WHEN cnt = 0 THEN 'VIDE' ELSE 'OK' END AS status
FROM (
  SELECT 'blog_authors' AS tbl, COUNT(*) AS cnt FROM blog_authors
  UNION ALL SELECT 'blog_categories', COUNT(*) FROM blog_categories
  UNION ALL SELECT 'blog_comments', COUNT(*) FROM blog_comments
  UNION ALL SELECT 'blog_posts', COUNT(*) FROM blog_posts
  UNION ALL SELECT 'blog_posts_versions', COUNT(*) FROM blog_posts_versions
  UNION ALL SELECT 'blog_post_tags', COUNT(*) FROM blog_post_tags
  UNION ALL SELECT 'blog_related_posts', COUNT(*) FROM blog_related_posts
  UNION ALL SELECT 'blog_tags', COUNT(*) FROM blog_tags
  UNION ALL SELECT 'coaching_bookings', COUNT(*) FROM coaching_bookings
  UNION ALL SELECT 'coaching_certifications', COUNT(*) FROM coaching_certifications
  UNION ALL SELECT 'coaching_cities', COUNT(*) FROM coaching_cities
  UNION ALL SELECT 'coaching_coaches', COUNT(*) FROM coaching_coaches
  UNION ALL SELECT 'coaching_coach_certifications', COUNT(*) FROM coaching_coach_certifications
  UNION ALL SELECT 'coaching_coach_specialties', COUNT(*) FROM coaching_coach_specialties
  UNION ALL SELECT 'coaching_diagnostic_requests', COUNT(*) FROM coaching_diagnostic_requests
  UNION ALL SELECT 'coaching_reviews', COUNT(*) FROM coaching_reviews
  UNION ALL SELECT 'coaching_specialties', COUNT(*) FROM coaching_specialties
  UNION ALL SELECT 'core_admin_activity_logs', COUNT(*) FROM core_admin_activity_logs
  UNION ALL SELECT 'core_admin_sessions', COUNT(*) FROM core_admin_sessions
  UNION ALL SELECT 'core_admin_site_access', COUNT(*) FROM core_admin_site_access
  UNION ALL SELECT 'core_admin_users', COUNT(*) FROM core_admin_users
  UNION ALL SELECT 'core_audit_logs', COUNT(*) FROM core_audit_logs
  UNION ALL SELECT 'core_password_reset_tokens', COUNT(*) FROM core_password_reset_tokens
  UNION ALL SELECT 'core_settings', COUNT(*) FROM core_settings
  UNION ALL SELECT 'core_sites', COUNT(*) FROM core_sites
  UNION ALL SELECT 'email_logs', COUNT(*) FROM email_logs
  UNION ALL SELECT 'formation_categories', COUNT(*) FROM formation_categories
  UNION ALL SELECT 'formation_courses', COUNT(*) FROM formation_courses
  UNION ALL SELECT 'formation_courses_versions', COUNT(*) FROM formation_courses_versions
  UNION ALL SELECT 'formation_jobs', COUNT(*) FROM formation_jobs
  UNION ALL SELECT 'formation_modules', COUNT(*) FROM formation_modules
  UNION ALL SELECT 'formation_skills', COUNT(*) FROM formation_skills
  UNION ALL SELECT 'gdpr_consents', COUNT(*) FROM gdpr_consents
  UNION ALL SELECT 'gdpr_deletion_requests', COUNT(*) FROM gdpr_deletion_requests
  UNION ALL SELECT 'marketing_newsletter_subs', COUNT(*) FROM marketing_newsletter_subs
  UNION ALL SELECT 'media_library', COUNT(*) FROM media_library
  UNION ALL SELECT 'recrutement_applications', COUNT(*) FROM recrutement_applications
  UNION ALL SELECT 'recrutement_application_history', COUNT(*) FROM recrutement_application_history
  UNION ALL SELECT 'recrutement_contract_types', COUNT(*) FROM recrutement_contract_types
  UNION ALL SELECT 'recrutement_jobs', COUNT(*) FROM recrutement_jobs
  UNION ALL SELECT 'recrutement_offers', COUNT(*) FROM recrutement_offers
  UNION ALL SELECT 'recrutement_offer_advantages', COUNT(*) FROM recrutement_offer_advantages
  UNION ALL SELECT 'recrutement_offer_missions', COUNT(*) FROM recrutement_offer_missions
  UNION ALL SELECT 'recrutement_offer_profiles', COUNT(*) FROM recrutement_offer_profiles
  UNION ALL SELECT 'recrutement_offer_tags', COUNT(*) FROM recrutement_offer_tags
  UNION ALL SELECT 'recrutement_professions', COUNT(*) FROM recrutement_professions
  UNION ALL SELECT 'recrutement_sectors', COUNT(*) FROM recrutement_sectors
  UNION ALL SELECT 'recrutement_tags', COUNT(*) FROM recrutement_tags
  UNION ALL SELECT 'seo_metadata', COUNT(*) FROM seo_metadata
) AS counts
ORDER BY status DESC, tbl;
