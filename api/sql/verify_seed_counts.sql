-- Vérification rapide après import de seed_data_v3.sql
-- Attendu : toutes les lignes avec count > 0

SELECT 'core_sites' AS tbl, COUNT(*) AS cnt FROM core_sites
UNION ALL SELECT 'core_settings', COUNT(*) FROM core_settings
UNION ALL SELECT 'blog_categories', COUNT(*) FROM blog_categories
UNION ALL SELECT 'blog_tags', COUNT(*) FROM blog_tags
UNION ALL SELECT 'blog_authors', COUNT(*) FROM blog_authors
UNION ALL SELECT 'blog_posts', COUNT(*) FROM blog_posts
UNION ALL SELECT 'blog_comments', COUNT(*) FROM blog_comments
UNION ALL SELECT 'recrutement_sectors', COUNT(*) FROM recrutement_sectors
UNION ALL SELECT 'recrutement_jobs', COUNT(*) FROM recrutement_jobs
UNION ALL SELECT 'recrutement_contract_types', COUNT(*) FROM recrutement_contract_types
UNION ALL SELECT 'recrutement_professions', COUNT(*) FROM recrutement_professions
UNION ALL SELECT 'recrutement_offers', COUNT(*) FROM recrutement_offers
UNION ALL SELECT 'recrutement_tags', COUNT(*) FROM recrutement_tags
UNION ALL SELECT 'recrutement_applications', COUNT(*) FROM recrutement_applications
UNION ALL SELECT 'formation_categories', COUNT(*) FROM formation_categories
UNION ALL SELECT 'formation_courses', COUNT(*) FROM formation_courses
UNION ALL SELECT 'coaching_cities', COUNT(*) FROM coaching_cities
UNION ALL SELECT 'coaching_coaches', COUNT(*) FROM coaching_coaches
UNION ALL SELECT 'coaching_bookings', COUNT(*) FROM coaching_bookings
UNION ALL SELECT 'marketing_newsletter_subs', COUNT(*) FROM marketing_newsletter_subs
UNION ALL SELECT 'media_library', COUNT(*) FROM media_library
UNION ALL SELECT 'seo_metadata', COUNT(*) FROM seo_metadata
ORDER BY tbl;
