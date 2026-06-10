/**
 * Vérification post-déploiement — API sur connexion.nexytal.com
 *
 * Usage:
 *   npm run test:deploy              # smoke (rapide, ~15s)
 *   npm run test:deploy:full         # smoke + tous les POST d'insertion
 *   node scripts/test-deploy.mjs https://connexion.nexytal.com --full
 */

import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const args = process.argv.slice(2);
const FULL = args.includes('--full');
const BASE = args.find((a) => !a.startsWith('--')) || 'https://connexion.nexytal.com';
const EMAIL = process.env.TEST_EMAIL || 'admin@nexytal.com';
const PASSWORD = process.env.TEST_PASSWORD || 'password';
const SUFFIX = Date.now().toString(36);

let token = null;
let ctx = {};
const lines = [];

function log(icon, label, detail = '') {
  const line = `${icon} ${label}${detail ? ` — ${detail}` : ''}`;
  console.log(line);
  lines.push({ icon, label, detail });
}

async function json(method, path, { body, siteId } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (siteId) headers['X-Site-Id'] = String(siteId);
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  const data = await res.json().catch(() => ({}));
  return { ok: res.ok, status: res.status, data };
}

function err(data) {
  if (data?.errors) return Object.values(data.errors).join(', ');
  const base = data?.error || data?.message || '';
  return data?.detail ? `${base} (${data.detail})` : base;
}

async function phaseHealth() {
  console.log(`\n═══ Déploiement : ${BASE} ═══`);
  console.log(`Suffixe test : ${SUFFIX}\n`);

  const health = await json('GET', '/api/health');
  if (health.status === 200) log('✅', 'Health API', health.data?.data?.version || 'ok');
  else { log('❌', 'Health API', `HTTP ${health.status}`); return false; }

  const db = await json('GET', '/api/health/db');
  if (db.status === 200 && db.data?.data?.connected) {
    log('✅', 'Health DB', db.data.data.database || 'connectée');
  } else {
    log('❌', 'Health DB', `HTTP ${db.status}`);
    return false;
  }

  const insertHealth = await json('GET', '/api/health/insert');
  if (insertHealth.status === 200) {
    const sites = insertHealth.data?.data?.sites_count ?? '?';
    log('✅', 'Health INSERT (lecture)', `${sites} site(s) en BDD`);
  } else {
    log('⚠️', 'Health INSERT', `HTTP ${insertHealth.status} — déployez insert_tests.php`);
  }

  const login = await json('POST', '/api/admin/login', {
    body: { email: EMAIL, password: PASSWORD },
  });
  token = login.data?.data?.token;
  const sites = login.data?.data?.sites?.length ?? 0;
  if (login.status === 200 && token) {
    log('✅', 'Login admin', `${sites} site(s)`);
  } else {
    log('❌', 'Login admin', err(login.data) || `HTTP ${login.status}`);
    return false;
  }

  if (sites < 6) {
    log('⚠️', 'core_sites', `attendu 6, reçu ${sites} — importez bdd_nexytal_inserts.sql`);
  }
  return true;
}

async function phaseSmoke() {
  console.log('\n── Smoke POST (5 endpoints corrigés) ──\n');

  let r = await json('POST', '/api/admin/formation/categories', {
    siteId: 1,
    body: { name: `Smoke cat ${SUFFIX}`, slug: `smoke-cat-${SUFFIX}`, is_active: 1 },
  });
  if (r.status === 201) {
    ctx.formCatId = r.data?.data?.id;
    log('✅', 'formation_categories', `id=${ctx.formCatId}`);
  } else {
    log('❌', 'formation_categories', `HTTP ${r.status} ${err(r.data)}`);
    return false;
  }

  r = await json('POST', '/api/admin/formation/courses', {
    siteId: 1,
    body: {
      title: `Smoke formation ${SUFFIX}`,
      category_id: ctx.formCatId,
      presentation_text: 'Test déploiement',
      status: 'draft',
      jobs: [{ title: 'Métier', salary_min: 30000, salary_max: 40000, sort_order: 0 }],
    },
  });
  if (r.status === 201) {
    ctx.courseId = r.data?.data?.id;
    log('✅', 'formation_courses', `id=${ctx.courseId}`);
  } else {
    log('❌', 'formation_courses', `HTTP ${r.status} ${err(r.data)}`);
  }

  r = await json('POST', '/api/admin/coaching/cities', {
    body: { name: `Smoke ville ${SUFFIX}`, slug: `smoke-ville-${SUFFIX}` },
  });
  const cityId = r.data?.data?.id;
  r = await json('POST', '/api/admin/coaching/specialties', {
    body: { name: `Smoke spec ${SUFFIX}`, slug: `smoke-spec-${SUFFIX}`, icon: 'star' },
  });
  const specId = r.data?.data?.id;
  r = await json('POST', '/api/admin/coaching/certifications', {
    body: { code: `SMK_${SUFFIX}`, organization: 'Test', level: 1 },
  });
  const certId = r.data?.data?.id;

  r = await json('POST', '/api/admin/coaching/coaches', {
    siteId: 6,
    body: {
      first_name: 'Smoke',
      last_name: `Coach ${SUFFIX}`,
      email: `smoke.coach.${SUFFIX}@test.com`,
      title: 'Coach test déploiement',
      city_id: cityId,
      status: 'active',
      specialty_ids: specId ? [specId] : [],
      certifications: certId ? [{ id: certId, year_obtained: 2024 }] : [],
    },
  });
  if (r.status === 201) {
    ctx.coachId = r.data?.data?.id;
    log('✅', 'coaching_coaches', `id=${ctx.coachId}`);
  } else {
    log('❌', 'coaching_coaches', `HTTP ${r.status} ${err(r.data)}`);
  }

  r = await json('POST', '/api/public/alt-formation/newsletter/subscribe', {
    body: { email: `smoke.nl.${SUFFIX}@test.com`, first_name: 'Test', gdpr_consent: 1 },
  });
  if (r.status === 201 || (r.status === 200 && r.data?.message?.includes('subscribed'))) {
    log('✅', 'marketing_newsletter_subs', `HTTP ${r.status}`);
  } else {
    log('❌', 'marketing_newsletter_subs', `HTTP ${r.status} ${err(r.data)}`);
  }

  r = await json('POST', '/api/public/nexytal-carriere/gdpr/deletion-request', {
    body: {
      email: `smoke.gdpr.${SUFFIX}@test.com`,
      first_name: 'Test',
      last_name: 'RGPD',
      request_type: 'data_deletion',
      details: 'Smoke test déploiement',
    },
  });
  if (r.status === 201) log('✅', 'gdpr_deletion_requests', `id=${r.data?.data?.id ?? '—'}`);
  else log('❌', 'gdpr_deletion_requests', `HTTP ${r.status} ${err(r.data)}`);

  r = await json('POST', '/api/public/nexytal-coaching/coaching/diagnostics', {
    body: {
      first_name: 'Diag',
      last_name: `Smoke ${SUFFIX}`,
      email: `smoke.diag.${SUFFIX}@test.com`,
      request_type: 'leadership',
      message: 'Test déploiement',
      gdpr_consent: 1,
    },
  });
  if (r.status === 201) log('✅', 'coaching_diagnostic_requests', `id=${r.data?.data?.id ?? '—'}`);
  else log('❌', 'coaching_diagnostic_requests', `HTTP ${r.status} ${err(r.data)}`);

  if (ctx.courseId) {
    r = await json('POST', '/api/admin/seo', {
      siteId: 1,
      body: {
        entity_type: 'formation_course',
        entity_id: ctx.courseId,
        og_title: `Smoke SEO ${SUFFIX}`,
        canonical_url: `https://alt-formation.fr/smoke-${SUFFIX}`,
      },
    });
    if (r.status === 200 || r.status === 201) log('✅', 'seo_metadata', `HTTP ${r.status}`);
    else log('❌', 'seo_metadata', `HTTP ${r.status} ${err(r.data)}`);
  } else {
    log('⏭️', 'seo_metadata', 'SKIP — formation_courses en échec');
  }

  if (ctx.coachId) {
    r = await json('POST', '/api/public/nexytal-coaching/coaching/bookings', {
      body: {
        coach_id: ctx.coachId,
        client_first_name: 'Client',
        client_last_name: `Smoke ${SUFFIX}`,
        client_email: `smoke.book.${SUFFIX}@test.com`,
        requested_date: '2026-08-01 10:00:00',
        gdpr_consent: 1,
      },
    });
    if (r.status === 201) log('✅', 'coaching_bookings', `id=${r.data?.data?.id ?? '—'}`);
    else log('❌', 'coaching_bookings', `HTTP ${r.status} ${err(r.data)}`);
  } else {
    log('⏭️', 'coaching_bookings', 'SKIP — coach en échec');
  }

  const failed = lines.filter((l) => l.icon === '❌').length;
  const ok = lines.filter((l) => l.icon === '✅').length;
  console.log(`\n── Smoke : ${ok} OK, ${failed} échec(s) ──\n`);
  return failed === 0;
}

function runFullInsertTests() {
  return new Promise((resolve) => {
    console.log('── Suite complète (api-insert-tests.mjs) ──\n');
    const script = path.join(path.dirname(fileURLToPath(import.meta.url)), 'api-insert-tests.mjs');
    const child = spawn(process.execPath, [script, BASE], {
      stdio: 'inherit',
      env: { ...process.env, TEST_EMAIL: EMAIL, TEST_PASSWORD: PASSWORD },
    });
    child.on('close', (code) => resolve(code === 0));
  });
}

async function main() {
  const healthOk = await phaseHealth();
  if (!healthOk) {
    console.log('\n❌ Arrêt : API ou login inaccessible. Vérifiez le déploiement FTP.\n');
    process.exit(1);
  }

  const smokeOk = await phaseSmoke();

  if (FULL) {
    const fullOk = await runFullInsertTests();
    process.exit(smokeOk && fullOk ? 0 : 1);
  }

  if (smokeOk) {
    console.log('✅ Déploiement OK — lancez npm run test:deploy:full pour la suite complète.\n');
    process.exit(0);
  }
  console.log('❌ Corrigez les échecs ci-dessus (fichiers PHP non déployés ?).\n');
  console.log('Fichiers à uploader sur le serveur :');
  console.log('  api/modules/formation/courses.php');
  console.log('  api/modules/coaching/coaches.php');
  console.log('  api/modules/coaching/public_coaching.php');
  console.log('  api/modules/marketing/newsletter.php');
  console.log('  api/modules/gdpr/deletion_requests.php');
  console.log('  api/modules/seo/seo.php\n');
  process.exit(1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
