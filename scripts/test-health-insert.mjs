/**
 * Appelle l'URL /api/health/insert sur le déploiement (comme health/db)
 *
 * Usage:
 *   npm run test:health:insert
 *   INSERT_TEST_KEY=ma-cle node scripts/test-health-insert.mjs [baseUrl]
 */

const BASE = process.argv[2] || 'https://connexion.nexytal.com';
const KEY = process.env.INSERT_TEST_KEY || 'nexytal-insert-test';

async function get(path) {
  const res = await fetch(`${BASE}${path}`);
  const data = await res.json().catch(() => ({}));
  console.log(`\nGET ${path} → HTTP ${res.status}`);
  console.log(JSON.stringify(data, null, 2));
  return { res, data };
}

async function main() {
  console.log(`\n═══ Health INSERT — ${BASE} ═══`);

  await get('/api/health/insert');

  const run = await get(`/api/health/insert/run?key=${encodeURIComponent(KEY)}`);
  const summary = run.data?.data?.summary;
  if (summary) {
    console.log(`\n── Résultat : ${summary.ok} OK, ${summary.failed} échec(s) ──\n`);
    process.exit(summary.failed > 0 ? 1 : 0);
  }
  process.exit(run.res.status === 200 ? 0 : 1);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
