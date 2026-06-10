/**
 * Tests d'INSERTION uniquement (POST) — toutes les tables accessibles via l'API
 *
 * Usage:
 *   node scripts/api-insert-tests.mjs [baseUrl]
 *   TEST_EMAIL=... TEST_PASSWORD=... node scripts/api-insert-tests.mjs
 *
 * Prérequis: core_sites peuplé (importer api/sql/seed_data_v3.sql)
 * Login: POST /api/admin/login (seul POST "système", pas de GET)
 */

const args = process.argv.slice(2);
const BASE = args.find((a) => !a.startsWith('--')) || 'https://connexion.nexytal.com';
const EMAIL = process.env.TEST_EMAIL || 'admin@nexytal.com';
const PASSWORD = process.env.TEST_PASSWORD || 'password';

const SUFFIX = Date.now().toString(36);
const ctx = {};
const results = [];

function log(icon, table, detail) {
  const line = `${icon} POST ${table}${detail ? ` — ${detail}` : ''}`;
  console.log(line);
  results.push({ icon, table, detail });
}

function skip(table, reason) {
  log('⏭️', table, `SKIP — ${reason}`);
}

function errMsg(data) {
  if (data?.errors) return Object.values(data.errors).join(', ');
  const base = data?.error || data?.message || '';
  return data?.detail ? `${base} (${data.detail})` : base;
}

async function postJson(path, { token, siteId, body, accept200 = false } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (siteId) headers['X-Site-Id'] = String(siteId);

  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });

  let data;
  try {
    data = await res.json();
  } catch {
    data = {};
  }
  const ok = accept200 ? res.status === 200 || res.status === 201 : res.status === 201;
  return { ok, status: res.status, data, id: data?.data?.id };
}

async function postForm(path, fields) {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams(fields),
  });
  let data;
  try {
    data = await res.json();
  } catch {
    data = {};
  }
  return { ok: res.status === 201, status: res.status, data, id: data?.data?.id };
}

async function postTable(table, path, opts) {
  const r = await postJson(path, opts);
  if (r.ok) {
    log('✅', table, `HTTP ${r.status} id=${r.id ?? '—'}`);
  } else {
    log('❌', table, `HTTP ${r.status} ${errMsg(r.data)}`);
  }
  return r;
}

async function main() {
  console.log(`\n=== Tests POST uniquement — ${BASE} ===`);
  console.log(`Suffixe: ${SUFFIX}\n`);

  // ── Login (POST obligatoire pour token admin) ─────────────────────────────
  const login = await postJson('/api/admin/login', {
    body: { email: EMAIL, password: PASSWORD },
    accept200: true,
  });
  if (!login.ok || !login.data?.data?.token) {
    log('❌', 'core_admin_users (login)', `HTTP ${login.status} — ${errMsg(login.data)}`);
    console.log('\nArrêt : token admin requis pour les POST admin.\n');
    process.exit(1);
  }
  const token = login.data.data.token;
  const siteCount = login.data.data.sites?.length ?? 0;
  log('✅', 'core_admin_users (login)', `token OK, ${siteCount} site(s) accessibles`);
  if (siteCount < 1) {
    console.log('\n⚠️  Importez seed_data_v3.sql (core_sites) avant de relancer.\n');
  }

  // ── Tables sans endpoint POST ─────────────────────────────────────────────
  skip('core_sites', 'pas de POST admin — seed SQL');
  skip('core_settings', 'pas de POST admin — seed SQL');
  skip('core_admin_site_access', 'commenté — seed SQL');
  skip('core_admin_sessions', 'commenté — seed SQL');
  skip('core_password_reset_tokens', 'commenté — seed SQL');
  skip('core_admin_activity_logs', 'commenté — seed SQL');
  skip('core_audit_logs', 'commenté — seed SQL');
  skip('email_logs', 'pas de POST API');
  skip('gdpr_consents', 'pas de POST API (lecture seule)');
  skip('recrutement_application_history', 'créé via workflow candidature');
  skip('blog_posts_versions', 'créé via PUT article');
  skip('formation_courses_versions', 'créé via PUT formation');
  skip('coaching_reviews', 'pas de POST (PUT modération)');
  skip('media_library', 'POST multipart upload — hors scope auto');

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASE 1 — Références (ordre FK)
  // ═══════════════════════════════════════════════════════════════════════════

  let r;

  r = await postTable('recrutement_contract_types', '/api/admin/recrutement/contract-types', {
    token,
    body: { code: `TST_${SUFFIX}`, name: `Type test ${SUFFIX}` },
  });
  ctx.contractId = r.id;

  r = await postTable('formation_categories', '/api/admin/formation/categories', {
    token, siteId: 1,
    body: { name: `Cat formation ${SUFFIX}`, slug: `cat-form-${SUFFIX}`, is_active: 1 },
  });
  ctx.formCatId = r.id;

  r = await postTable('recrutement_sectors', '/api/admin/recrutement/sectors', {
    token, siteId: 2,
    body: { name: `Secteur IT ${SUFFIX}`, slug: `sect-it-${SUFFIX}` },
  });
  ctx.sectorItId = r.id;

  if (ctx.sectorItId) {
    r = await postTable('recrutement_jobs', '/api/admin/recrutement/jobs', {
      token,
      body: { sector_id: ctx.sectorItId, name: `Job IT ${SUFFIX}`, slug: `job-it-${SUFFIX}` },
    });
    ctx.jobItId = r.id;
  } else {
    skip('recrutement_jobs', 'secteur IT manquant');
  }

  r = await postTable('recrutement_sectors', '/api/admin/recrutement/sectors', {
    token, siteId: 3,
    body: { name: `Secteur médical ${SUFFIX}`, slug: `sect-med-${SUFFIX}` },
  });
  ctx.sectorMedId = r.id;

  if (ctx.sectorMedId) {
    r = await postTable('recrutement_jobs', '/api/admin/recrutement/jobs', {
      token,
      body: { sector_id: ctx.sectorMedId, name: `Job médical ${SUFFIX}`, slug: `job-med-${SUFFIX}` },
    });
    ctx.jobMedId = r.id;
  }

  r = await postTable('recrutement_tags', '/api/admin/recrutement/tags', {
    token, siteId: 2,
    body: { name: `TagTest ${SUFFIX}`, slug: `tag-test-${SUFFIX}` },
  });
  ctx.recrutTagId = r.id;

  r = await postTable('recrutement_professions', '/api/admin/recrutement/professions', {
    token, siteId: 3,
    body: { name: `Métier test ${SUFFIX}`, sector: 'Test', description: 'Desc test' },
  });
  ctx.professionId = r.id;

  const blogSites = [
    [1, 'alt-formation'],
    [2, 'recrutement-it'],
    [3, 'medical-blog'],
    [4, 'carriere'],
    [5, 'trainer'],
    [6, 'coaching'],
  ];
  for (const [siteId, label] of blogSites) {
    r = await postTable('blog_categories', '/api/admin/blog/categories', {
      token, siteId,
      body: { name: `Blog cat ${label} ${SUFFIX}`, slug: `blog-cat-${siteId}-${SUFFIX}`, color: '#6366f1' },
    });
    if (siteId === 4) ctx.blogCatCarriere = r.id;
    if (siteId === 3) ctx.blogCatMedical = r.id;
  }

  r = await postTable('blog_tags', '/api/admin/blog/tags', {
    token, siteId: 4,
    body: { name: `Tag blog ${SUFFIX}`, slug: `tag-blog-${SUFFIX}` },
  });
  ctx.blogTagId = r.id;

  r = await postTable('blog_authors', '/api/admin/blog/authors', {
    token, siteId: 4,
    body: {
      first_name: 'Test', last_name: `Auteur ${SUFFIX}`,
      email: `auteur.${SUFFIX}@test.com`, bio: 'Bio test',
    },
  });
  ctx.blogAuthorId = r.id;

  r = await postTable('coaching_cities', '/api/admin/coaching/cities', {
    token,
    body: { name: `Ville ${SUFFIX}`, slug: `ville-${SUFFIX}` },
  });
  ctx.cityId = r.id;

  r = await postTable('coaching_specialties', '/api/admin/coaching/specialties', {
    token,
    body: { name: `Spécialité ${SUFFIX}`, slug: `spec-${SUFFIX}`, icon: 'star' },
  });
  ctx.specialtyId = r.id;

  r = await postTable('coaching_certifications', '/api/admin/coaching/certifications', {
    token,
    body: { code: `CERT_${SUFFIX}`, organization: 'Test Org', level: 1 },
  });
  ctx.certId = r.id;

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASE 2 — Entités principales (+ pivots enfants)
  // ═══════════════════════════════════════════════════════════════════════════

  if (ctx.formCatId) {
    r = await postTable('formation_courses', '/api/admin/formation/courses', {
      token, siteId: 1,
      body: {
        title: `Formation ${SUFFIX}`,
        category_id: ctx.formCatId,
        presentation_text: 'Présentation test',
        status: 'draft',
        modules: [{ title: 'Module 1', description: 'Desc', duration: '2 sem', sort_order: 0 }],
        skills: [{ name: 'Compétence test', sort_order: 0 }],
        jobs: [{ title: 'Métier visé', salary_min: 35000, salary_max: 45000, sort_order: 0 }],
      },
    });
    ctx.courseId = r.id;
    if (r.ok) log('✅', 'formation_modules / skills / jobs', 'inclus dans POST formation_courses');
  } else {
    skip('formation_courses', 'catégorie manquante');
    skip('formation_modules', '—');
    skip('formation_skills', '—');
    skip('formation_jobs', '—');
  }

  if (ctx.contractId && ctx.jobItId) {
    r = await postTable('recrutement_offers', '/api/admin/recrutement/offers', {
      token, siteId: 2,
      body: {
        title: `Offre IT ${SUFFIX}`,
        contract_type_id: ctx.contractId,
        job_id: ctx.jobItId,
        company_name: 'Test IT SA',
        location: 'Paris',
        short_desc: 'Description courte test',
        full_desc: 'Description complète test insertion',
        status: 'published',
        tag_ids: ctx.recrutTagId ? [ctx.recrutTagId] : [],
        missions: ['Mission 1 test', 'Mission 2 test'],
        profiles: ['Profil Bac+5', 'Expérience 3 ans'],
        advantages: ['Télétravail', 'Mutuelle'],
      },
    });
    ctx.offerItId = r.id;
    if (r.ok) {
      log('✅', 'recrutement_offer_missions', 'inclus dans POST offers');
      log('✅', 'recrutement_offer_profiles', 'inclus dans POST offers');
      log('✅', 'recrutement_offer_advantages', 'inclus dans POST offers');
      log('✅', 'recrutement_offer_tags', 'inclus dans POST offers');
    }
  } else {
    skip('recrutement_offers (IT)', 'contract_type ou job manquant');
  }

  if (ctx.contractId && (ctx.jobMedId || ctx.jobItId)) {
    r = await postTable('recrutement_offers', '/api/admin/recrutement/offers', {
      token, siteId: 3,
      body: {
        title: `Offre médicale ${SUFFIX}`,
        contract_type_id: ctx.contractId,
        job_id: ctx.jobMedId || ctx.jobItId,
        profession_id: ctx.professionId || null,
        company_name: 'CHU Test',
        location: 'Nantes',
        short_desc: 'Poste médical test',
        full_desc: 'Description poste médical',
        status: 'published',
      },
    });
    ctx.offerMedId = r.id;
  } else {
    skip('recrutement_offers (médical)', 'références manquantes');
  }

  const postSlug = `article-pub-${SUFFIX}`;
  if (ctx.blogCatCarriere) {
    r = await postTable('blog_posts', '/api/admin/blog/posts', {
      token, siteId: 4,
      body: {
        title: `Article publié ${SUFFIX}`,
        slug: postSlug,
        content: '<p>Contenu test insertion POST</p>',
        excerpt: 'Extrait test',
        category_id: ctx.blogCatCarriere,
        author_id: ctx.blogAuthorId || null,
        status: 'published',
        tag_ids: ctx.blogTagId ? [ctx.blogTagId] : [],
      },
    });
    ctx.blogPostId = r.id;
    if (r.ok) log('✅', 'blog_post_tags', 'inclus dans POST blog_posts');
  } else {
    skip('blog_posts', 'catégorie carrière manquante');
  }

  if (ctx.blogPostId) {
    r = await postTable('blog_posts (+ blog_related_posts)', '/api/admin/blog/posts', {
      token, siteId: 4,
      body: {
        title: `Article lié ${SUFFIX}`,
        content: '<p>Article pour related_posts</p>',
        category_id: ctx.blogCatCarriere,
        status: 'draft',
        related_post_ids: [ctx.blogPostId],
      },
    });
    if (r.ok) log('✅', 'blog_related_posts', 'inclus dans 2e POST blog_posts');
  }

  if (ctx.cityId && ctx.specialtyId && ctx.certId) {
    r = await postTable('coaching_coaches', '/api/admin/coaching/coaches', {
      token, siteId: 6,
      body: {
        first_name: 'Coach',
        last_name: `Test ${SUFFIX}`,
        email: `coach.${SUFFIX}@test.com`,
        title: 'Coach certifié test',
        city_id: ctx.cityId,
        status: 'active',
        is_available: 1,
        specialty_ids: [ctx.specialtyId],
        certifications: [{ id: ctx.certId, year_obtained: 2024 }],
      },
    });
    ctx.coachId = r.id;
    if (r.ok) {
      log('✅', 'coaching_coach_specialties', 'inclus dans POST coaches');
      log('✅', 'coaching_coach_certifications', 'inclus dans POST coaches');
    }
  } else {
    skip('coaching_coaches', 'ville/spécialité/cert manquante');
  }

  const seoEntity = ctx.courseId
    ? { type: 'formation_course', id: ctx.courseId, siteId: 1, url: `https://alt-formation.fr/test-${SUFFIX}` }
    : ctx.offerItId
      ? { type: 'recrutement_offer', id: ctx.offerItId, siteId: 2, url: `https://recrutement.nexytal.com/test-${SUFFIX}` }
      : null;

  if (seoEntity) {
    r = await postTable('seo_metadata', '/api/admin/seo', {
      token, siteId: seoEntity.siteId,
      body: {
        entity_type: seoEntity.type,
        entity_id: seoEntity.id,
        og_title: `SEO test ${SUFFIX}`,
        og_description: 'Meta test',
        canonical_url: seoEntity.url,
      },
      accept200: true,
    });
  } else {
    skip('seo_metadata', 'formation/offre manquante');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHASE 3 — POST publics (front / candidats / RGPD)
  // ═══════════════════════════════════════════════════════════════════════════

  r = await postTable('marketing_newsletter_subs', '/api/public/alt-formation/newsletter/subscribe', {
    body: {
      email: `newsletter.${SUFFIX}@test.com`,
      first_name: 'Test',
      gdpr_consent: 1,
    },
    accept200: true,
  });

  r = await postTable('gdpr_deletion_requests', '/api/public/nexytal-carriere/gdpr/deletion-request', {
    body: {
      email: `gdpr.${SUFFIX}@test.com`,
      first_name: 'Test',
      last_name: 'RGPD',
      request_type: 'data_deletion',
      details: 'Test insertion POST',
    },
  });

  if (postSlug) {
    r = await postJson('/api/public/nexytal-carriere/blog/posts/' + postSlug + '/comments', {
      body: {
        author_name: 'Visiteur Test',
        author_email: `comment.${SUFFIX}@test.com`,
        content: 'Commentaire test POST public',
      },
    });
    if (r.status === 201) log('✅', 'blog_comments', `HTTP ${r.status} id=${r.id ?? '—'}`);
    else log('❌', 'blog_comments', `HTTP ${r.status} ${errMsg(r.data)}`);
  } else {
    skip('blog_comments', 'article publié manquant');
  }

  r = await postJson('/api/public/nexytal-coaching/coaching/diagnostics', {
    body: {
      first_name: 'Diag',
      last_name: `Test ${SUFFIX}`,
      email: `diag.${SUFFIX}@test.com`,
      request_type: 'leadership',
      message: 'Demande diagnostic test',
      gdpr_consent: 1,
      coach_id: ctx.coachId || null,
    },
  });
  if (r.status === 201) log('✅', 'coaching_diagnostic_requests', `HTTP ${r.status} id=${r.id ?? '—'}`);
  else log('❌', 'coaching_diagnostic_requests', `HTTP ${r.status} ${errMsg(r.data)}`);

  if (ctx.coachId) {
    r = await postJson('/api/public/nexytal-coaching/coaching/bookings', {
      body: {
        coach_id: ctx.coachId,
        client_first_name: 'Client',
        client_last_name: `Test ${SUFFIX}`,
        client_email: `booking.${SUFFIX}@test.com`,
        requested_date: '2026-07-15 10:00:00',
        message: 'Réservation test',
        gdpr_consent: 1,
      },
    });
    if (r.status === 201) log('✅', 'coaching_bookings', `HTTP ${r.status} id=${r.id ?? '—'}`);
    else log('❌', 'coaching_bookings', `HTTP ${r.status} ${errMsg(r.data)}`);
  } else {
    skip('coaching_bookings', 'coach manquant');
  }

  if (ctx.offerItId) {
    const apply = await postForm('/api/public/nexytal-recrutement/recrutement/apply', {
      offer_id: String(ctx.offerItId),
      first_name: 'Candidat',
      last_name: `Test ${SUFFIX}`,
      email: `candidat.${SUFFIX}@test.com`,
      phone: '0600000000',
      cover_letter: 'Lettre test POST',
      gdpr_consent: '1',
    });
    if (apply.ok) log('✅', 'recrutement_applications', `HTTP ${apply.status} id=${apply.id ?? '—'}`);
    else log('❌', 'recrutement_applications', `HTTP ${apply.status} ${errMsg(apply.data)}`);
  } else {
    skip('recrutement_applications', 'offre IT publiée manquante');
  }

  // ── Résumé ────────────────────────────────────────────────────────────────
  const ok = results.filter((x) => x.icon === '✅').length;
  const ko = results.filter((x) => x.icon === '❌').length;
  const sk = results.filter((x) => x.icon === '⏭️').length;
  console.log(`\n=== Résultat POST : ${ok} OK, ${ko} échecs, ${sk} ignorés (total ${results.length}) ===\n`);
  if (Object.keys(ctx).length) {
    console.log('IDs créés:', JSON.stringify(ctx, null, 2));
  }
  process.exit(ko > 0 ? 1 : 0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
