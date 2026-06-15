<?php
/**
 * modules/health/insert_tests.php — Tests d'insertion sur TOUTES les tables v2.1
 *
 * GET  /api/health/insert       → comptages tables
 * GET  /api/health/insert/run?key=XXX → exécute les smoke INSERT
 * POST /api/health/insert       → idem
 */

function registerHealthInsertRoutes(Router $router): void
{
    $router->get('/api/health/insert', function () {
        ProductionSecurity::assertDiagnosticsAllowed();
        if (!assertInsertDbConnection()) {
            return;
        }
        Response::success(buildInsertHealthStatus(false));
    });

    $router->get('/api/health/insert/run', function () {
        ProductionSecurity::assertDiagnosticsAllowed();
        if (!ProductionSecurity::assertInsertTestKeyConfigured() || !assertInsertTestKey() || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });

    $router->post('/api/health/insert', function () {
        ProductionSecurity::assertDiagnosticsAllowed();
        if (!ProductionSecurity::assertInsertTestKeyConfigured() || !assertInsertTestKey() || !assertInsertDbConnection()) {
            return;
        }
        Response::success(runInsertSmokeTests());
    });
}

function getInsertTestTables(): array
{
    return [
        'core_sites',
        'core_admin_users',
        'core_admin_site_access',
        'core_admin_sessions',
        'core_audit_logs',
        'core_admin_password_resets',
        'blog_categories',
        'blog_tags',
        'blog_authors',
        'blog_posts',
        'blog_post_tags',
        'blog_related_posts',
        'blog_posts_versions',
        'blog_comments',
        'formation_categories',
        'formations',
        'formation_stats',
        'formation_modules',
        'formation_list_items',
        'formation_job_outcomes',
        'formation_official_certifications',
        'users',
        'secteurs_activite',
        'entreprises',
        'recruteurs',
        'metiers',
        'competences',
        'metier_competences',
        'candidats',
        'candidat_metiers_souhaites',
        'candidat_competences',
        'candidat_experiences',
        'candidat_formations',
        'offres_emploi',
        'offre_competences',
        'candidatures',
        'candidatures_externes',
        'candidature_historique',
        'offres_favorites',
        'alertes_emploi',
        'expertises',
        'trainer_skills',
        'trainer_certifications',
        'trainer_cities',
        'trainer_languages',
        'trainers',
        'trainer_expertise_links',
        'trainer_skill_links',
        'trainer_certification_links',
        'trainer_modalities',
        'trainer_language_links',
        'trainer_city_links',
        'trainer_courses',
        'trainer_reviews',
        'trainer_applications',
        'newsletter_lists',
        'newsletter_subscribers',
        'newsletter_subscriptions',
        'newsletter_campaigns',
        'newsletter_events',
        'gdpr_consents_log',
        'gdpr_deletion_requests',
        'seo_metadata',
        'marketing_email_logs',
    ];
}

function assertInsertDbConnection(): bool
{
    $conn = testDbConnection();
    if ($conn['connected']) {
        return true;
    }
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Database connection failed', 'data' => $conn]);
    exit;
}

function assertInsertTestKey(): bool
{
    $expected = defined('INSERT_TEST_KEY') ? INSERT_TEST_KEY : '';
    if ($expected === '') {
        Response::forbidden('INSERT_TEST_KEY non configurée dans api/config/.env');
        return false;
    }

    $provided = $_GET['key']
        ?? $_SERVER['HTTP_X_TEST_KEY']
        ?? (Router::getJsonBody()['key'] ?? null);

    if (APP_ENV === 'production' && hash_equals(ProductionSecurity::DEFAULT_INSERT_TEST_KEY, $expected)) {
        Response::forbidden('INSERT_TEST_KEY par défaut interdite en production');
        return false;
    }

    if (!is_string($provided) || !hash_equals($expected, $provided)) {
        Response::forbidden('Clé invalide — utilisez ?key=VOTRE_CLE ou header X-Test-Key');
        return false;
    }
    return true;
}

function buildInsertHealthStatus(bool $afterRun): array
{
    $db = getDb();
    $tables = getInsertTestTables();
    $counts = [];

    foreach ($tables as $table) {
        try {
            $counts[$table] = (int) $db->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
        } catch (\PDOException $e) {
            $counts[$table] = null;
        }
    }

    $sites = $counts['core_sites'] ?? 0;
    $withData = count(array_filter($counts, fn ($c) => $c !== null && $c > 0));
    $missing = count(array_filter($counts, fn ($c) => $c === 0));

    return [
        'status'       => $sites >= 6 ? 'ok' : 'warning',
        'time'         => date('Y-m-d H:i:s'),
        'database'     => DB_NAME,
        'sites_count'  => $sites,
        'tables_total' => count($tables),
        'tables_with_data' => $withData,
        'tables_empty' => $missing,
        'tables'       => $counts,
        'run_url'      => '/api/health/insert/run?key=VOTRE_INSERT_TEST_KEY',
        'seed_file'    => 'api/sql/seed_demo.sql',
        'hint'         => $sites < 6
            ? 'Importez schema_v2.sql puis api/sql/seed_demo.sql'
            : ($afterRun
                ? 'Smoke INSERT terminé — vérifiez results[]'
                : 'GET run ou POST avec clé INSERT_TEST_KEY, ou importez seed_demo.sql'),
    ];
}

function runInsertSmokeTests(): array
{
    $db = getDb();
    $suffix = substr(bin2hex(random_bytes(4)), 0, 8);
    $results = [];
    $ctx = ['adminId' => 1, 'siteId' => 1];

    $ok = function (string $table, ?int $id = null, ?string $detail = null) use (&$results) {
        $results[] = ['table' => $table, 'ok' => true, 'id' => $id, 'detail' => $detail];
    };
    $ko = function (string $table, string $error) use (&$results) {
        $results[] = ['table' => $table, 'ok' => false, 'error' => $error];
    };
    $run = function (string $table, string $sql, array $params = []) use ($db, $ok, $ko, &$ctx) {
        try {
            $stmt = $db->prepare($sql);
            $stmt->execute($params);
            $id = (int) $db->lastInsertId();
            if ($id > 0) {
                $ctx["last_{$table}"] = $id;
            }
            $ok($table, $id > 0 ? $id : null);
            return true;
        } catch (\Throwable $e) {
            $ko($table, $e->getMessage());
            return false;
        }
    };

    // ── CORE ──────────────────────────────────────────────────────────────────
    $run('core_admin_sessions',
        "INSERT INTO core_admin_sessions (id, admin_id, ip_address, user_agent, expires_at, created_at)
         VALUES (:id, 1, '127.0.0.1', 'HealthTest/1.0', DATE_ADD(NOW(), INTERVAL 1 HOUR), NOW())",
        [':id' => "health-sess-$suffix"]
    );
    $run('core_audit_logs',
        "INSERT INTO core_audit_logs (admin_id, site_id, action, entity_type, entity_id, ip_address)
         VALUES (1, 1, 'health_insert', 'test', NULL, '127.0.0.1')"
    );
    $run('core_admin_password_resets',
        "INSERT INTO core_admin_password_resets (admin_id, token_hash, expires_at, created_at)
         VALUES (1, :hash, DATE_ADD(NOW(), INTERVAL 1 HOUR), NOW())",
        [':hash' => password_hash("health-$suffix", PASSWORD_BCRYPT)]
    );

    // Tables déjà peuplées par schema (comptées OK sans INSERT)
    foreach (['core_sites', 'core_admin_users', 'core_admin_site_access', 'newsletter_lists'] as $preseeded) {
        try {
            $count = (int) $db->query("SELECT COUNT(*) FROM `$preseeded`")->fetchColumn();
            if ($count > 0) {
                $ok($preseeded, null, "pré-rempli ($count)");
            } else {
                $ko($preseeded, 'table vide — importez schema_v2.sql');
            }
        } catch (\Throwable $e) {
            $ko($preseeded, $e->getMessage());
        }
    }

    // ── BLOG ──────────────────────────────────────────────────────────────────
    $run('blog_categories',
        "INSERT INTO blog_categories (site_id, name, slug, is_active, created_at)
         VALUES (1, :name, :slug, 1, NOW())",
        [':name' => "Health cat $suffix", ':slug' => "health-cat-$suffix"]
    );
    if (!empty($ctx['last_blog_categories'])) {
        $ctx['blogCatId'] = $ctx['last_blog_categories'];
    }

    $run('blog_tags',
        "INSERT INTO blog_tags (site_id, name, slug, created_at) VALUES (1, :name, :slug, NOW())",
        [':name' => "Tag $suffix", ':slug' => "health-tag-$suffix"]
    );
    if (!empty($ctx['last_blog_tags'])) {
        $ctx['blogTagId'] = $ctx['last_blog_tags'];
    }

    $run('blog_authors',
        "INSERT INTO blog_authors (site_id, first_name, last_name, email, slug, is_active, created_at)
         VALUES (1, 'Health', :ln, :email, :slug, 1, NOW())",
        [
            ':ln' => "Author $suffix",
            ':email' => "health.author.$suffix@test.com",
            ':slug' => "health-author-$suffix",
        ]
    );
    if (!empty($ctx['last_blog_authors'])) {
        $ctx['blogAuthorId'] = $ctx['last_blog_authors'];
    }

    if (!empty($ctx['blogCatId'])) {
        $run('blog_posts',
            "INSERT INTO blog_posts (site_id, category_id, author_id, title, slug, content, status, published_at, created_at)
             VALUES (1, :cat, :auth, :title, :slug, :content, 'published', NOW(), NOW())",
            [
                ':cat' => $ctx['blogCatId'],
                ':auth' => $ctx['blogAuthorId'] ?? null,
                ':title' => "Health post $suffix",
                ':slug' => "health-post-$suffix",
                ':content' => '<p>Test insertion health</p>',
            ]
        );
        if (!empty($ctx['last_blog_posts'])) {
            $ctx['blogPostId'] = $ctx['last_blog_posts'];
        }
    } else {
        $ko('blog_posts', 'catégorie blog manquante');
    }

    if (!empty($ctx['blogPostId']) && !empty($ctx['blogTagId'])) {
        $run('blog_post_tags',
            'INSERT INTO blog_post_tags (post_id, tag_id) VALUES (:pid, :tid)',
            [':pid' => $ctx['blogPostId'], ':tid' => $ctx['blogTagId']]
        );
    } else {
        $ko('blog_post_tags', 'post ou tag manquant');
    }

    if (!empty($ctx['blogPostId'])) {
        $run('blog_related_posts',
            'INSERT INTO blog_related_posts (post_id, related_post_id) VALUES (:p1, :p2)',
            [':p1' => $ctx['blogPostId'], ':p2' => $ctx['blogPostId']]
        );
        $run('blog_posts_versions',
            "INSERT INTO blog_posts_versions (post_id, title, content, status, created_by, created_at)
             VALUES (:pid, 'v1', 'content', 'draft', 1, NOW())",
            [':pid' => $ctx['blogPostId']]
        );
        $run('blog_comments',
            "INSERT INTO blog_comments (post_id, author_name, author_email, content, status, created_at)
             VALUES (:pid, 'Test', 'test@test.com', 'Commentaire health', 'pending', NOW())",
            [':pid' => $ctx['blogPostId']]
        );
    } else {
        $ko('blog_related_posts', 'post manquant');
        $ko('blog_posts_versions', 'post manquant');
        $ko('blog_comments', 'post manquant');
    }

    // ── FORMATION ─────────────────────────────────────────────────────────────
    $run('formation_categories',
        "INSERT INTO formation_categories (site_id, slug, label, is_active, created_at)
         VALUES (1, :slug, :label, 1, NOW())",
        [':slug' => "health-fcat-$suffix", ':label' => "Health fcat $suffix"]
    );
    if (!empty($ctx['last_formation_categories'])) {
        $ctx['formCatId'] = $ctx['last_formation_categories'];
    }

    if (!empty($ctx['formCatId'])) {
        $run('formations',
            "INSERT INTO formations (site_id, slug, type, category_id, status, hero_title, created_at)
             VALUES (1, :slug, 'longue', :cat, 'draft', :title, NOW())",
            [':slug' => "health-form-$suffix", ':cat' => $ctx['formCatId'], ':title' => "Health form $suffix"]
        );
        if (!empty($ctx['last_formations'])) {
            $ctx['formationId'] = $ctx['last_formations'];
        }
    } else {
        $ko('formations', 'catégorie formation manquante');
    }

    if (!empty($ctx['formationId'])) {
        $fid = $ctx['formationId'];
        $run('formation_stats', 'INSERT INTO formation_stats (formation_id, label, value, sort_order) VALUES (:fid, :l, :v, 0)',
            [':fid' => $fid, ':l' => 'Durée', ':v' => '5 jours']);
        $run('formation_modules', 'INSERT INTO formation_modules (formation_id, title, sort_order) VALUES (:fid, :t, 0)',
            [':fid' => $fid, ':t' => 'Module test']);
        $run('formation_list_items', "INSERT INTO formation_list_items (formation_id, list_type, content, sort_order) VALUES (:fid, 'objectif', 'Objectif test', 0)",
            [':fid' => $fid]);
        $run('formation_job_outcomes', 'INSERT INTO formation_job_outcomes (formation_id, job_title, sort_order) VALUES (:fid, :j, 0)',
            [':fid' => $fid, ':j' => 'Développeur']);
        $run('formation_official_certifications',
            "INSERT INTO formation_official_certifications (formation_id, repertoire, code, official_title, france_competences_url)
             VALUES (:fid, 'RNCP', '99999', 'Titre test', 'https://example.com')",
            [':fid' => $fid]
        );
    } else {
        foreach (['formation_stats', 'formation_modules', 'formation_list_items', 'formation_job_outcomes', 'formation_official_certifications'] as $t) {
            $ko($t, 'formation manquante');
        }
    }

    // ── RECRUTEMENT ───────────────────────────────────────────────────────────
    $run('secteurs_activite', 'INSERT INTO secteurs_activite (slug, label) VALUES (:s, :l)',
        [':s' => "health-sec-$suffix", ':l' => "Secteur $suffix"]);
    if (!empty($ctx['last_secteurs_activite'])) {
        $ctx['secteurId'] = $ctx['last_secteurs_activite'];
    }

    $run('competences', "INSERT INTO competences (slug, label, categorie) VALUES (:s, :l, 'technique')",
        [':s' => "health-comp-$suffix", ':l' => "Compétence $suffix"]);
    if (!empty($ctx['last_competences'])) {
        $ctx['competenceId'] = $ctx['last_competences'];
    }

    $run('metiers',
        "INSERT INTO metiers (site_id, slug, libelle, secteur_id, actif, created_at, updated_at)
         VALUES (2, :slug, :lib, :sid, 1, NOW(), NOW())",
        [':slug' => "health-metier-$suffix", ':lib' => "Métier $suffix", ':sid' => $ctx['secteurId'] ?? null]
    );
    if (!empty($ctx['last_metiers'])) {
        $ctx['metierId'] = $ctx['last_metiers'];
    }

    if (!empty($ctx['metierId']) && !empty($ctx['competenceId'])) {
        $run('metier_competences',
            'INSERT INTO metier_competences (metier_id, competence_id, importance) VALUES (:m, :c, :i)',
            [':m' => $ctx['metierId'], ':c' => $ctx['competenceId'], ':i' => 'essentielle']
        );
    } else {
        $ko('metier_competences', 'métier ou compétence manquant');
    }

    $run('entreprises',
        "INSERT INTO entreprises (nom, slug, secteur_id, ville, validee, created_at, updated_at)
         VALUES (:nom, :slug, :sid, 'Lyon', 1, NOW(), NOW())",
        [':nom' => "Entreprise $suffix", ':slug' => "health-ent-$suffix", ':sid' => $ctx['secteurId'] ?? null]
    );
    if (!empty($ctx['last_entreprises'])) {
        $ctx['entrepriseId'] = $ctx['last_entreprises'];
    }

    $run('users',
        "INSERT INTO users (email, password_hash, role, email_verifie, actif, created_at, updated_at)
         VALUES (:email, :hash, 'recruteur', 1, 1, NOW(), NOW())",
        [
            ':email' => "health.recruteur.$suffix@test.com",
            ':hash' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        ]
    );
    if (!empty($ctx['last_users'])) {
        $ctx['recruteurUserId'] = $ctx['last_users'];
    }

    $run('users',
        "INSERT INTO users (email, password_hash, role, email_verifie, actif, created_at, updated_at)
         VALUES (:email, :hash, 'candidat', 1, 1, NOW(), NOW())",
        [
            ':email' => "health.candidat.$suffix@test.com",
            ':hash' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        ]
    );
    if (!empty($ctx['last_users'])) {
        $ctx['candidatUserId'] = $ctx['last_users'];
    }

    if (!empty($ctx['recruteurUserId']) && !empty($ctx['entrepriseId'])) {
        $run('recruteurs',
            "INSERT INTO recruteurs (user_id, entreprise_id, prenom, nom, created_at, updated_at)
             VALUES (:uid, :eid, 'Health', :nom, NOW(), NOW())",
            [':uid' => $ctx['recruteurUserId'], ':eid' => $ctx['entrepriseId'], ':nom' => "Recruteur $suffix"]
        );
        if (!empty($ctx['last_recruteurs'])) {
            $ctx['recruteurId'] = $ctx['last_recruteurs'];
        }
    } else {
        $ko('recruteurs', 'user recruteur ou entreprise manquant');
    }

    if (!empty($ctx['candidatUserId'])) {
        $run('candidats',
            "INSERT INTO candidats (user_id, prenom, nom, rgpd_consent_at, created_at, updated_at)
             VALUES (:uid, 'Health', :nom, NOW(), NOW(), NOW())",
            [':uid' => $ctx['candidatUserId'], ':nom' => "Candidat $suffix"]
        );
        if (!empty($ctx['last_candidats'])) {
            $ctx['candidatId'] = $ctx['last_candidats'];
        }
    } else {
        $ko('candidats', 'user candidat manquant');
    }

    if (!empty($ctx['candidatId']) && !empty($ctx['metierId'])) {
        $run('candidat_metiers_souhaites',
            'INSERT INTO candidat_metiers_souhaites (candidat_id, metier_id, priorite) VALUES (:c, :m, 1)',
            [':c' => $ctx['candidatId'], ':m' => $ctx['metierId']]
        );
    } else {
        $ko('candidat_metiers_souhaites', 'candidat ou métier manquant');
    }

    if (!empty($ctx['candidatId']) && !empty($ctx['competenceId'])) {
        $run('candidat_competences',
            "INSERT INTO candidat_competences (candidat_id, competence_id, niveau) VALUES (:c, :comp, 'intermediaire')",
            [':c' => $ctx['candidatId'], ':comp' => $ctx['competenceId']]
        );
    } else {
        $ko('candidat_competences', 'candidat ou compétence manquant');
    }

    if (!empty($ctx['candidatId'])) {
        $run('candidat_experiences',
            "INSERT INTO candidat_experiences (candidat_id, entreprise, poste, date_debut) VALUES (:c, 'ACME', 'Dev', '2020-01-01')",
            [':c' => $ctx['candidatId']]
        );
        $run('candidat_formations',
            "INSERT INTO candidat_formations (candidat_id, diplome) VALUES (:c, 'Bac+3 Info')",
            [':c' => $ctx['candidatId']]
        );
    } else {
        $ko('candidat_experiences', 'candidat manquant');
        $ko('candidat_formations', 'candidat manquant');
    }

    if (!empty($ctx['entrepriseId'])) {
        $run('offres_emploi',
            "INSERT INTO offres_emploi (site_id, entreprise_id, recruteur_id, metier_id, slug, titre, description, type_contrat, statut, created_at, updated_at)
             VALUES (2, :eid, :rid, :mid, :slug, :titre, 'Desc health', 'cdi', 'brouillon', NOW(), NOW())",
            [
                ':eid' => $ctx['entrepriseId'],
                ':rid' => $ctx['recruteurId'] ?? null,
                ':mid' => $ctx['metierId'] ?? null,
                ':slug' => "health-offre-$suffix",
                ':titre' => "Offre $suffix",
            ]
        );
        if (!empty($ctx['last_offres_emploi'])) {
            $ctx['offreId'] = $ctx['last_offres_emploi'];
        }
    } else {
        $ko('offres_emploi', 'entreprise manquante');
    }

    if (!empty($ctx['offreId']) && !empty($ctx['competenceId'])) {
        $run('offre_competences',
            'INSERT INTO offre_competences (offre_id, competence_id, importance) VALUES (:o, :c, :i)',
            [':o' => $ctx['offreId'], ':c' => $ctx['competenceId'], ':i' => 'essentielle']
        );
    } else {
        $ko('offre_competences', 'offre ou compétence manquant');
    }

    if (!empty($ctx['offreId']) && !empty($ctx['candidatId'])) {
        $run('candidatures',
            "INSERT INTO candidatures (offre_id, candidat_id, message_motivation, statut) VALUES (:o, :c, 'Motivation', 'recue')",
            [':o' => $ctx['offreId'], ':c' => $ctx['candidatId']]
        );
        if (!empty($ctx['last_candidatures'])) {
            $ctx['candidatureId'] = $ctx['last_candidatures'];
        }
    } else {
        $ko('candidatures', 'offre ou candidat manquant');
    }

    if (!empty($ctx['offreId'])) {
        $run('candidatures_externes',
            "INSERT INTO candidatures_externes (offre_id, site_id, prenom, nom, email, rgpd_consent_at)
             VALUES (:o, 2, 'Ext', :nom, :email, NOW())",
            [':o' => $ctx['offreId'], ':nom' => "Ext $suffix", ':email' => "health.ext.$suffix@test.com"]
        );
    } else {
        $ko('candidatures_externes', 'offre manquante');
    }

    if (!empty($ctx['candidatureId'])) {
        $run('candidature_historique',
            "INSERT INTO candidature_historique (candidature_id, nouveau_statut, commentaire, auteur_admin_id)
             VALUES (:cid, 'recue', 'Health test', 1)",
            [':cid' => $ctx['candidatureId']]
        );
    } else {
        $ko('candidature_historique', 'candidature manquante');
    }

    if (!empty($ctx['candidatId']) && !empty($ctx['offreId'])) {
        $run('offres_favorites',
            'INSERT INTO offres_favorites (candidat_id, offre_id) VALUES (:c, :o)',
            [':c' => $ctx['candidatId'], ':o' => $ctx['offreId']]
        );
    } else {
        $ko('offres_favorites', 'candidat ou offre manquant');
    }

    if (!empty($ctx['candidatId'])) {
        $run('alertes_emploi',
            'INSERT INTO alertes_emploi (candidat_id, metier_id, frequence, active) VALUES (:c, :m, :f, 1)',
            [':c' => $ctx['candidatId'], ':m' => $ctx['metierId'] ?? null, ':f' => 'hebdomadaire']
        );
    } else {
        $ko('alertes_emploi', 'candidat manquant');
    }

    // ── TRAINERS ──────────────────────────────────────────────────────────────
    $run('expertises', 'INSERT INTO expertises (slug, label) VALUES (:s, :l)',
        [':s' => "health-exp-$suffix", ':l' => "Expertise $suffix"]);
    if (!empty($ctx['last_expertises'])) {
        $ctx['expertiseId'] = $ctx['last_expertises'];
    }

    $run('trainer_skills', 'INSERT INTO trainer_skills (name, slug) VALUES (:n, :s)',
        [':n' => "Skill $suffix", ':s' => "health-skill-$suffix"]);
    if (!empty($ctx['last_trainer_skills'])) {
        $ctx['skillId'] = $ctx['last_trainer_skills'];
    }

    $run('trainer_certifications', 'INSERT INTO trainer_certifications (name, slug) VALUES (:n, :s)',
        [':n' => "Cert $suffix", ':s' => "health-cert-$suffix"]);
    if (!empty($ctx['last_trainer_certifications'])) {
        $ctx['certId'] = $ctx['last_trainer_certifications'];
    }

    $run('trainer_cities', "INSERT INTO trainer_cities (slug, name, region) VALUES (:s, :n, 'IDF')",
        [':s' => "health-city-$suffix", ':n' => "Ville $suffix"]);
    if (!empty($ctx['last_trainer_cities'])) {
        $ctx['cityId'] = $ctx['last_trainer_cities'];
    }

    $run('trainer_languages', 'INSERT INTO trainer_languages (code, name) VALUES (:c, :n)',
        [':c' => 'h' . substr($suffix, 0, 4), ':n' => "Lang $suffix"]);
    if (!empty($ctx['last_trainer_languages'])) {
        $ctx['langId'] = $ctx['last_trainer_languages'];
    }

    $run('trainers',
        "INSERT INTO trainers (slug, first_name, last_name, title, email, city_id, primary_expertise_id, status, created_at)
         VALUES (:slug, 'Health', :ln, 'Formateur', :email, :city, :exp, 'active', NOW())",
        [
            ':slug' => "health-trainer-$suffix",
            ':ln' => "Trainer $suffix",
            ':email' => "health.trainer.$suffix@test.com",
            ':city' => $ctx['cityId'] ?? null,
            ':exp' => $ctx['expertiseId'] ?? null,
        ]
    );
    if (!empty($ctx['last_trainers'])) {
        $ctx['trainerId'] = $ctx['last_trainers'];
    }

    if (!empty($ctx['trainerId']) && !empty($ctx['expertiseId'])) {
        $run('trainer_expertise_links',
            'INSERT INTO trainer_expertise_links (trainer_id, expertise_id, is_primary) VALUES (:t, :e, 1)',
            [':t' => $ctx['trainerId'], ':e' => $ctx['expertiseId']]
        );
    } else {
        $ko('trainer_expertise_links', 'trainer ou expertise manquant');
    }

    if (!empty($ctx['trainerId']) && !empty($ctx['skillId'])) {
        $run('trainer_skill_links',
            'INSERT INTO trainer_skill_links (trainer_id, skill_id) VALUES (:t, :s)',
            [':t' => $ctx['trainerId'], ':s' => $ctx['skillId']]
        );
    } else {
        $ko('trainer_skill_links', 'trainer ou skill manquant');
    }

    if (!empty($ctx['trainerId']) && !empty($ctx['certId'])) {
        $run('trainer_certification_links',
            'INSERT INTO trainer_certification_links (trainer_id, certification_id) VALUES (:t, :c)',
            [':t' => $ctx['trainerId'], ':c' => $ctx['certId']]
        );
    } else {
        $ko('trainer_certification_links', 'trainer ou cert manquant');
    }

    if (!empty($ctx['trainerId'])) {
        $run('trainer_modalities',
            "INSERT INTO trainer_modalities (trainer_id, modality) VALUES (:t, 'presentiel')",
            [':t' => $ctx['trainerId']]
        );
        $run('trainer_courses',
            'INSERT INTO trainer_courses (trainer_id, title, sort_order) VALUES (:t, :title, 0)',
            [':t' => $ctx['trainerId'], ':title' => "Cours $suffix"]
        );
        $run('trainer_reviews',
            "INSERT INTO trainer_reviews (trainer_id, author_name, rating, comment) VALUES (:t, 'Client', 5, 'Top')",
            [':t' => $ctx['trainerId']]
        );
    } else {
        $ko('trainer_modalities', 'trainer manquant');
        $ko('trainer_courses', 'trainer manquant');
        $ko('trainer_reviews', 'trainer manquant');
    }

    if (!empty($ctx['trainerId']) && !empty($ctx['langId'])) {
        $run('trainer_language_links',
            'INSERT INTO trainer_language_links (trainer_id, language_id) VALUES (:t, :l)',
            [':t' => $ctx['trainerId'], ':l' => $ctx['langId']]
        );
    } else {
        $ko('trainer_language_links', 'trainer ou langue manquant');
    }

    if (!empty($ctx['trainerId']) && !empty($ctx['cityId'])) {
        $run('trainer_city_links',
            'INSERT INTO trainer_city_links (trainer_id, city_id) VALUES (:t, :c)',
            [':t' => $ctx['trainerId'], ':c' => $ctx['cityId']]
        );
    } else {
        $ko('trainer_city_links', 'trainer ou ville manquant');
    }

    $run('trainer_applications',
        "INSERT INTO trainer_applications (first_name, last_name, email, message, status)
         VALUES ('App', :ln, :email, 'Candidature health', 'new')",
        [':ln' => "Health $suffix", ':email' => "health.tapp.$suffix@test.com"]
    );

    // ── NEWSLETTER ────────────────────────────────────────────────────────────
    $run('newsletter_subscribers',
        "INSERT INTO newsletter_subscribers (site_id, email, status, rgpd_consent_at, created_at)
         VALUES (1, :email, 'active', NOW(), NOW())",
        [':email' => "health.nl.$suffix@test.com"]
    );
    if (!empty($ctx['last_newsletter_subscribers'])) {
        $ctx['subscriberId'] = $ctx['last_newsletter_subscribers'];
    }

    if (!empty($ctx['subscriberId'])) {
        try {
            $listId = (int) $db->query("SELECT id FROM newsletter_lists WHERE site_id = 1 LIMIT 1")->fetchColumn();
            if ($listId) {
                $run('newsletter_subscriptions',
                    'INSERT INTO newsletter_subscriptions (subscriber_id, list_id) VALUES (:s, :l)',
                    [':s' => $ctx['subscriberId'], ':l' => $listId]
                );
            } else {
                $ko('newsletter_subscriptions', 'liste newsletter manquante');
            }
        } catch (\Throwable $e) {
            $ko('newsletter_subscriptions', $e->getMessage());
        }
    } else {
        $ko('newsletter_subscriptions', 'subscriber manquant');
    }

    $run('newsletter_campaigns',
        "INSERT INTO newsletter_campaigns (site_id, created_by, subject, content_html, status)
         VALUES (1, 1, :subj, '<p>Health</p>', 'draft')",
        [':subj' => "Campagne health $suffix"]
    );
    if (!empty($ctx['last_newsletter_campaigns'])) {
        $ctx['campaignId'] = $ctx['last_newsletter_campaigns'];
    }

    if (!empty($ctx['campaignId']) && !empty($ctx['subscriberId'])) {
        $run('newsletter_events',
            "INSERT INTO newsletter_events (campaign_id, subscriber_id, event_type) VALUES (:c, :s, 'sent')",
            [':c' => $ctx['campaignId'], ':s' => $ctx['subscriberId']]
        );
    } else {
        $ko('newsletter_events', 'campagne ou subscriber manquant');
    }

    // ── TRANSVERSE ──────────────────────────────────────────────────────────
    $run('gdpr_consents_log',
        "INSERT INTO gdpr_consents_log (site_id, ip_address, consent_type, granted) VALUES (1, '127.0.0.1', 'health', 1)"
    );
    $run('gdpr_deletion_requests',
        "INSERT INTO gdpr_deletion_requests (site_id, user_email, status, requested_at) VALUES (1, :email, 'pending', NOW())",
        [':email' => "health.gdpr.$suffix@test.com"]
    );

    if (!empty($ctx['formationId'])) {
        $run('seo_metadata',
            "INSERT INTO seo_metadata (site_id, entity_type, entity_id, canonical_url, og_title)
             VALUES (1, 'formation', :eid, :url, :og)",
            [
                ':eid' => $ctx['formationId'],
                ':url' => "https://alt-formation.fr/health-$suffix",
                ':og' => "SEO $suffix",
            ]
        );
    } else {
        $ko('seo_metadata', 'formation manquante');
    }

    $run('marketing_email_logs',
        "INSERT INTO marketing_email_logs (site_id, recipient_email, subject, status)
         VALUES (1, :email, 'Health email', 'sent')",
        [':email' => "health.mail.$suffix@test.com"]
    );

    $passed = count(array_filter($results, fn ($r) => $r['ok']));
    $failed = count($results) - $passed;
    $status = buildInsertHealthStatus(true);

    $testedTables = array_unique(array_column($results, 'table'));
    $allTables = getInsertTestTables();
    $notTested = array_values(array_diff($allTables, $testedTables));

    return [
        'status'        => $failed === 0 ? 'ok' : 'error',
        'suffix'        => $suffix,
        'summary'       => [
            'ok'         => $passed,
            'failed'     => $failed,
            'total'      => count($results),
            'tables_all' => count($allTables),
            'tables_tested' => count($testedTables),
        ],
        'not_tested'    => $notTested,
        'results'       => $results,
        'ids'           => $ctx,
        'tables'        => $status['tables'],
        'time'          => date('Y-m-d H:i:s'),
    ];
}
