/**
 * Bootstrap données minimales + tests insertion (API prod)
 */
const BASE = 'https://connexion.nexytal.com';
const EMAIL = process.env.TEST_EMAIL || 'admin@nexytal.com';
const PASSWORD = process.env.TEST_PASSWORD || 'password';
const suffix = Date.now().toString(36);

const created = {};
const results = [];

function ok(name, cond, detail) {
  const icon = cond ? '✅' : '❌';
  console.log(`${icon} ${name} — ${detail}`);
  results.push({ name, ok: cond, detail });
}

async function req(method, path, { token, siteId, body } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (siteId) headers['X-Site-Id'] = String(siteId);
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });
  let data;
  try { data = await res.json(); } catch { data = {}; }
  return { status: res.status, data };
}

async function main() {
  const login = await req('POST', '/api/admin/login', { body: { email: EMAIL, password: PASSWORD } });
  const token = login.data?.data?.token;
  if (!token) throw new Error('Login failed');

  console.log('\n=== Phase 1 : Bootstrap références ===\n');

  // Formation category
  let r = await req('POST', '/api/admin/formation/categories', {
    token, siteId: 1, body: { name: `Cat test ${suffix}`, slug: `cat-test-${suffix}`, is_active: 1 },
  });
  created.formCatId = r.data?.data?.id;
  ok('POST formation/categories', r.status === 201, `HTTP ${r.status} id=${created.formCatId} ${r.data?.error || ''}`);

  // Contract type
  r = await req('POST', '/api/admin/recrutement/contract-types', {
    token, body: { code: `CDI_${suffix}`, name: 'CDI Test' },
  });
  created.contractId = r.data?.data?.id;
  ok('POST contract-types', r.status === 201, `HTTP ${r.status} id=${created.contractId} ${r.data?.error || ''}`);

  // Sector + job IT
  r = await req('POST', '/api/admin/recrutement/sectors', {
    token, siteId: 2, body: { name: `Secteur IT ${suffix}`, slug: `secteur-it-${suffix}` },
  });
  created.sectorId = r.data?.data?.id;
  ok('POST recrutement/sectors', r.status === 201, `HTTP ${r.status} id=${created.sectorId} ${r.data?.error || ''}`);

  if (created.sectorId) {
    r = await req('POST', '/api/admin/recrutement/jobs', {
      token, siteId: 2,
      body: { sector_id: created.sectorId, name: `Job test ${suffix}`, slug: `job-test-${suffix}` },
    });
    created.jobId = r.data?.data?.id;
    ok('POST recrutement/jobs', r.status === 201, `HTTP ${r.status} id=${created.jobId} ${r.data?.error || ''}`);
  }

  // Blog category carriere
  r = await req('POST', '/api/admin/blog/categories', {
    token, siteId: 4, body: { name: `Blog cat ${suffix}`, slug: `blog-cat-${suffix}`, color: '#6366f1' },
  });
  created.blogCatId = r.data?.data?.id;
  ok('POST blog/categories', r.status === 201, `HTTP ${r.status} id=${created.blogCatId} ${r.data?.error || ''}`);

  // Coaching city
  r = await req('POST', '/api/admin/coaching/cities', {
    token, body: { name: `Ville test ${suffix}`, slug: `ville-test-${suffix}` },
  });
  created.cityId = r.data?.data?.id;
  ok('POST coaching/cities', r.status === 201, `HTTP ${r.status} id=${created.cityId} ${r.data?.error || ''}`);

  // Profession médical
  r = await req('POST', '/api/admin/recrutement/professions', {
    token, siteId: 3,
    body: { name: `Métier test ${suffix}`, sector: 'Test', description: 'desc' },
  });
  created.professionId = r.data?.data?.id;
  ok('POST recrutement/professions', r.status === 201, `HTTP ${r.status} id=${created.professionId} ${JSON.stringify(r.data?.errors || r.data?.error || '')}`);

  console.log('\n=== Phase 2 : Insertions métier ===\n');

  if (created.formCatId) {
    r = await req('POST', '/api/admin/formation/courses', {
      token, siteId: 1,
      body: {
        title: `Formation ${suffix}`,
        category_id: created.formCatId,
        presentation_text: 'Test',
        status: 'draft',
      },
    });
    ok('POST formation/courses', r.status === 201, `HTTP ${r.status} ${r.data?.error || ''}`);
  }

  if (created.contractId && created.jobId) {
    r = await req('POST', '/api/admin/recrutement/offers', {
      token, siteId: 2,
      body: {
        title: `Offre IT ${suffix}`,
        contract_type_id: created.contractId,
        job_id: created.jobId,
        company_name: 'Test SA',
        location: 'Paris',
        short_desc: 'Court',
        full_desc: 'Long desc',
        status: 'draft',
      },
    });
    ok('POST offre IT (avec job_id)', r.status === 201, `HTTP ${r.status} ${JSON.stringify(r.data?.errors || r.data?.error || '')}`);
  }

  if (created.contractId && created.professionId) {
    r = await req('POST', '/api/admin/recrutement/offers', {
      token, siteId: 3,
      body: {
        title: `Offre med ${suffix}`,
        contract_type_id: created.contractId,
        job_id: created.jobId || 1,
        profession_id: created.professionId,
        company_name: 'CHU',
        location: 'Nantes',
        short_desc: 'Court',
        full_desc: 'Long',
        status: 'draft',
      },
    });
    ok('POST offre médicale', r.status === 201, `HTTP ${r.status} ${JSON.stringify(r.data?.errors || r.data?.error || '')}`);
  }

  if (created.blogCatId) {
    r = await req('POST', '/api/admin/blog/posts', {
      token, siteId: 4,
      body: {
        title: `Article ${suffix}`,
        content: 'Contenu',
        category_id: created.blogCatId,
        status: 'draft',
      },
    });
    ok('POST blog/posts', r.status === 201, `HTTP ${r.status} ${r.data?.error || ''}`);
  }

  r = await req('POST', '/api/admin/coaching/coaches', {
    token, siteId: 6,
    body: {
      first_name: 'Test',
      last_name: suffix,
      email: `coach.${suffix}@test.com`,
      title: 'Coach certifié',
      city_id: created.cityId || null,
    },
  });
  ok('POST coaching/coaches', r.status === 201, `HTTP ${r.status} ${r.data?.error || ''}`);

  const passed = results.filter((x) => x.ok).length;
  console.log(`\n=== ${passed}/${results.length} réussis ===\n`);
  console.log('IDs créés:', JSON.stringify(created, null, 2));
}

main().catch(console.error);
