# Refonte admin multi-sites Nexytal - specification d'execution

Date: 2026-07-09
Source: dump `dbs15772578` fourni a 14:52 + code local.

## Navigation cible

- Global: Dashboard, Logs & exports, Couverture BDD, Administrateurs, Sites, Comptes candidats.
- Site actif persistant: Formation, Recrutement, Medical, Carriere, Trainer, Coaching.
- Sous-menu stable par site: Dashboard site, Contenu metier, Blog, Mediatheque, SEO, Newsletter, Logs filtres site.
- Hubs metier: Validation recruteurs, Validation offres, Validation trainers, Validation coaches, Pipeline candidatures, Scoring.

## Endpoints transverses ajoutes ou branches

| Methode | Route | Source | Usage |
|---|---|---|---|
| GET | `/api/admin/logs` | definitions internes | liste des journaux exportables |
| GET | `/api/admin/logs/{type}` | tables de logs whitelist | lecture paginee |
| GET | `/api/admin/logs/{type}/export` | tables de logs whitelist | export CSV/JSON serveur |
| GET/POST/PUT/DELETE | `/api/admin/blog/comments` | `blog_comments` | moderation commentaires |
| GET/POST/PUT/DELETE | `/api/admin/marketing/lists` | `newsletter_lists` | listes newsletter |
| GET/POST/DELETE | `/api/admin/marketing/subscriptions` | `newsletter_subscriptions` | abonnements aux listes |
| GET/POST/PUT/DELETE | `/api/admin/marketing/campaigns` | `newsletter_campaigns` | campagnes newsletter |
| GET | `/api/admin/marketing/events` | `newsletter_events` | suivi campagne |
| GET/POST | `/api/admin/marketing/emails` | `marketing_email_logs` | logs emails |
| GET/PUT/POST public | `/api/admin/gdpr/deletion-requests` | `gdpr_deletion_requests` | file RGPD suppression |
| GET/PUT | `/api/admin/recrutement/config/scoring` | `recrutement_scoring_config/history` | scoring IA |

## Ecran ajoute

- `/logs`: `src/pages/LogsExportPage.tsx`.
- Navigation: entree superadmin/admin `Logs & exports`.
- Formats: CSV et JSON, generes par l'API.

## Checklist couverture table -> API -> ecran

| Table/vue | Endpoint API | Ecran admin |
|---|---|---|
| core_sites | `/api/admin/settings/sites` a finaliser | Parametres > Sites |
| core_admin_users | `/api/admin/users` | Utilisateurs > Administrateurs |
| core_admin_site_access | `/api/admin/users/{id}/sites` via payload users | Utilisateurs > Sites autorises |
| core_admin_sessions | `/api/admin/logs/admin-sessions` | Logs & exports > Sessions admin |
| core_admin_password_resets | `/api/admin/users/{id}/password-reset` a finaliser | Utilisateurs > Securite |
| core_audit_logs | `/api/admin/logs/audit` | Logs & exports > Audit admin |
| users | `/api/admin/recrutement/users` | Comptes candidats |
| blog_categories | `/api/admin/blog/categories` | Site > Blog > Categories |
| blog_authors | `/api/admin/blog/authors` | Site > Blog > Auteurs |
| blog_tags | `/api/admin/blog/tags` | Site > Blog > Tags |
| blog_posts | `/api/admin/blog/posts` | Site > Blog > Articles |
| blog_post_tags | `/api/admin/blog/posts/{id}` associations | Fiche article > Tags |
| blog_related_posts | `/api/admin/blog/posts/{id}` associations | Fiche article > Articles lies |
| blog_posts_versions | `/api/admin/blog/posts/{id}` versions | Fiche article > Versions |
| blog_comments | `/api/admin/blog/comments` | Site > Blog > Commentaires |
| media_library | `/api/admin/media` | Mediatheque |
| newsletter_lists | `/api/admin/marketing/lists` | Donnees > Newsletter > Listes |
| newsletter_subscribers | `/api/admin/marketing/newsletter` | Donnees > Newsletter > Abonnes |
| newsletter_subscriptions | `/api/admin/marketing/subscriptions` | Donnees > Newsletter > Inscriptions |
| newsletter_campaigns | `/api/admin/marketing/campaigns` | Donnees > Newsletter > Campagnes |
| newsletter_events | `/api/admin/marketing/events` | Donnees > Suivi > Historique |
| marketing_email_logs | `/api/admin/logs/emails`, `/api/admin/marketing/emails` | Logs & exports > Emails |
| seo_metadata | `/api/admin/seo` | Donnees > SEO |
| site_pricing | `/api/admin/formation/pricing`, `/api/admin/settings/pricing-plans` | Tarification par site |
| secteurs_activite | `/api/admin/recrutement/sectors` | Referentiels > Secteurs |
| villes | `/api/admin/recrutement/villes` | Referentiels > Villes |
| competences | `/api/admin/recrutement/competences` | Referentiels > Competences |
| gdpr_consents_log | `/api/admin/logs/gdpr-consents`, `/api/admin/gdpr/consents` | Logs & exports > Consentements |
| gdpr_deletion_requests | `/api/admin/logs/gdpr-deletions`, `/api/admin/gdpr/deletion-requests` | Donnees > RGPD > Suppressions |
| formation_categories | `/api/admin/formation/categories` | Alt Formation > Categories |
| formation_courses | `/api/admin/formation/courses` | Alt Formation > Formations |
| formation_modules | `/api/admin/formation/courses/{id}` enfants | Fiche formation > Programme |
| formation_skills | `/api/admin/formation/courses/{id}` enfants | Fiche formation > Competences |
| formation_jobs | `/api/admin/formation/courses/{id}` enfants | Fiche formation > Debouches |
| career_job_offers | `/api/admin/formation/career-offers` | Formation/Carriere > Offres internes |
| career_applications | `/api/admin/formation/career-applications` | Formation/Carriere > Candidatures |
| entreprises | `/api/admin/recrutement/entreprises` | Recrutement/Medical > Entreprises |
| recruteurs | `/api/admin/recrutement/recruteurs` | Recrutement/Medical > Recruteurs |
| recruteur_sites | `/api/admin/recrutement/recruteurs/{id}` associations | Fiche recruteur > Sites |
| recruteur_activation_tokens | endpoint securite a finaliser | Fiche recruteur > Activation |
| recruteur_tokens | portail recruteur | Fiche recruteur > Sessions portail |
| offres_emploi | `/api/admin/recrutement/offers` | Recrutement/Medical > Offres |
| offre_competences | `/api/admin/recrutement/offers/{id}` associations | Fiche offre > Competences |
| metiers | `/api/admin/recrutement/jobs` | Recrutement/Medical > Metiers |
| metier_competences | `/api/admin/recrutement/jobs/{id}` associations | Fiche metier > Competences |
| candidats | `/api/admin/recrutement/candidats` | Recrutement/Medical > Candidats |
| candidat_competences | `/api/admin/recrutement/candidats/{id}` associations | Fiche candidat > Competences |
| candidat_metiers_souhaites | `/api/admin/recrutement/candidats/{id}` associations | Fiche candidat > Metiers souhaites |
| candidat_tokens | endpoint securite a finaliser | Fiche candidat > Connexions sans mot de passe |
| alertes_emploi | `/api/admin/recrutement/alertes` | Recrutement/Medical > Alertes emploi |
| offres_favorites | `/api/admin/recrutement/favorites` | Fiche offre > Favoris |
| candidatures | `/api/admin/recrutement/applications`, `v_gestion_candidatures` | Pipeline candidatures |
| candidatures_externes | `/api/admin/recrutement/externes`, `v_gestion_candidatures` | Pipeline candidatures |
| candidature_historique | `/api/admin/logs/candidature-history` | Fiche candidature > Timeline |
| demandes_urgentes | endpoint a finaliser | Recrutement/Medical > Demandes urgentes |
| recrutement_scoring_config | `/api/admin/recrutement/config/scoring` | Recrutement > Configuration scoring |
| recrutement_scoring_history | `/api/admin/recrutement/config/scoring` historique | Recrutement > Historique scoring |
| trainers | `/api/admin/trainer/trainers` | Trainer > Formateurs |
| expertises | `/api/admin/trainer/expertises`, `v_expertises_catalog` | Trainer > Expertises |
| trainer_skills | `/api/admin/trainer/skills` | Trainer > Referentiels |
| trainer_skill_links | `/api/admin/trainer/trainers/{id}` associations | Fiche formateur > Competences |
| trainer_certifications | `/api/admin/trainer/certifications` | Trainer > Certifications |
| trainer_certification_links | `/api/admin/trainer/trainers/{id}` associations | Fiche formateur > Certifications |
| trainer_languages | `/api/admin/trainer/languages` | Trainer > Langues |
| trainer_language_links | `/api/admin/trainer/trainers/{id}` associations | Fiche formateur > Langues |
| trainer_cities | `/api/admin/trainer/cities` | Trainer > Villes |
| trainer_city_links | `/api/admin/trainer/trainers/{id}` associations | Fiche formateur > Zones |
| trainer_modalities | `/api/admin/trainer/trainers/{id}` associations | Fiche formateur > Modalites |
| trainer_courses | `/api/admin/trainer/trainers/{id}` enfants | Fiche formateur > Cours |
| trainer_reviews | `/api/admin/trainer/reviews` | Trainer > Avis |
| trainer_appointment_slots | endpoint a finaliser | Trainer > Planning |
| trainer_session_bookings | endpoint a finaliser | Trainer > Reservations |
| trainer_client_profiles | endpoint a finaliser | Trainer > Clients B2B |
| trainer_client_links | endpoint a finaliser | Fiche client/formateur > Liaisons |
| trainer_portal_accounts | endpoint a finaliser | Trainer > Portail |
| trainer_portal_tokens | endpoint a finaliser | Trainer > Sessions portail |
| trainer_portal_password_resets | endpoint a finaliser | Trainer > Resets portail |
| coaches | `/api/admin/coaching/coaches` | Coaching > Coachs |
| coaching_specialties | `/api/admin/coaching/specialties` | Coaching > Specialites |
| coach_specialty_links | `/api/admin/coaching/coaches/{id}` associations | Fiche coach > Specialites |
| coaching_certifications | `/api/admin/coaching/certifications` | Coaching > Certifications |
| coach_certification_links | `/api/admin/coaching/coaches/{id}` associations | Fiche coach > Certifications |
| coaching_languages | `/api/admin/coaching/languages` | Coaching > Langues |
| coach_language_links | `/api/admin/coaching/coaches/{id}` associations | Fiche coach > Langues |
| coaching_cities | `/api/admin/coaching/cities` | Coaching > Villes |
| coaching_appointment_slots | `/api/admin/coaching/appointment-slots` | Coaching > Planning |
| coaching_session_bookings | endpoint a finaliser | Coaching > Reservations |
| coaching_client_profiles | endpoint a finaliser | Coaching > Clients |
| coaching_coach_client_links | endpoint a finaliser | Fiche coach/client > Liaisons |
| coaching_portal_accounts | endpoint a finaliser | Coaching > Portail |
| coaching_portal_tokens | endpoint a finaliser | Coaching > Sessions portail |
| coaching_portal_password_resets | endpoint a finaliser | Coaching > Resets portail |
| coaching_contact_slots | `/api/admin/coaching/contact-slots` | Coaching > Creneaux contact |
| coaching_contact_requests | `/api/admin/coaching/contact-requests` | Coaching > Demandes contact |
| coaching_diagnostic_requests | `/api/admin/coaching/diagnostic-requests` | Coaching > Diagnostics |
| v_trainers_catalog | `/api/public/{site}/trainers` | Trainer > Catalogue enrichi |
| v_trainers_pending_validation | `/api/admin/trainer/trainers/pending` | Validation trainers |
| v_coaches_catalog | `/api/public/{site}/coaches` | Coaching > Catalogue enrichi |
| v_coaches_pending_validation | `/api/admin/coaching/coaches/pending` | Validation coachs |
| v_expertises_catalog | `/api/admin/trainer/expertises/catalog` | Trainer > Expertises |
| v_gestion_candidatures | `/api/admin/recrutement/gestion-candidatures` | Pipeline candidatures |
| v_recruteur_offres | `/api/admin/recrutement/recruteur-offres` a finaliser | Portail recruteur > Offres |
| v_recruteur_sites_actifs | portail recruteur | Fiche recruteur > Sites actifs |

## Plan migration/refactor

1. Stabiliser la base et les vues: appliquer le patch de hardening puis verifier les vues catalogue/pipeline.
2. Finir les endpoints marques `a finaliser` en priorite: demandes urgentes, portails trainer/coaching, reservations, tokens.
3. Centraliser la navigation site-first dans `DashboardLayout`: selecteur site persistant et sous-menus transverses.
4. Transformer les pages site existantes en modules par onglets: contenu metier, blog, media, SEO, newsletter, logs site.
5. Ajouter tests API par module avec verification audit CUD et controle `core_admin_site_access`.
6. Activer exports logs en production apres verification volumetrie et index.