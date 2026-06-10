const BASE = 'https://connexion.nexytal.com';
const EMAIL = process.env.TEST_EMAIL || 'admin@nexytal.com';
const PASSWORD = process.env.TEST_PASSWORD || 'password';

async function req(method, path, { token, siteId, body } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers.Authorization = `Bearer ${token}`;
  if (siteId) headers['X-Site-Id'] = String(siteId);
  const res = await fetch(`${BASE}${path}`, { method, headers, body: body ? JSON.stringify(body) : undefined });
  return { status: res.status, data: await res.json().catch(() => ({})) };
}

async function main() {
  const login = await req('POST', '/api/admin/login', { body: { email: EMAIL, password: PASSWORD } });
  const token = login.data?.data?.token;
  console.log('Login:', login.status, login.data?.message || login.data?.error);

  const checks = [
    ['formation/categories', 1],
    ['formation/courses', 1],
    ['recrutement/contract_types', 2],
    ['recrutement/professions', 3],
    ['blog/categories', 3],
    ['blog/categories', 4],
    ['coaching/cities', 6],
  ];

  for (const [path, site] of checks) {
    const r = await req('GET', `/api/admin/${path}`, { token, siteId: site });
    const d = r.data?.data;
    const n = Array.isArray(d) ? d.length : '?';
    console.log(`\nGET ${path} (site ${site}): HTTP ${r.status}, count=${n}`);
    if (Array.isArray(d) && d[0]) console.log('  sample:', JSON.stringify(d[0]).slice(0, 120));
  }

  const suffix = Date.now().toString(36);

  const tests = [
    ['POST formation/courses', 1, {
      title: `Diag formation ${suffix}`,
      category_id: 1,
      presentation_text: 'test',
      status: 'draft',
    }],
    ['POST recrutement/professions', 3, { name: `Diag métier ${suffix}`, sector: 'Test' }],
    ['POST recrutement/offers IT', 2, {
      title: `Diag offre ${suffix}`,
      contract_type_id: 1,
      company_name: 'Test',
      location: 'Paris',
      short_desc: 'court',
      full_desc: 'long',
      status: 'draft',
    }],
    ['POST recrutement/offers med', 3, {
      title: `Diag med ${suffix}`,
      contract_type_id: 1,
      company_name: 'CHU',
      location: 'Nantes',
      short_desc: 'court',
      full_desc: 'long',
      profession_id: null,
      status: 'draft',
    }],
    ['POST blog/posts', 4, {
      title: `Diag blog ${suffix}`,
      content: 'contenu',
      category_id: null,
      status: 'draft',
    }],
    ['POST coaching/coaches', 6, {
      first_name: 'Diag',
      last_name: suffix,
      email: `diag.${suffix}@test.com`,
      title: 'Coach',
    }],
  ];

  for (const [label, site, body] of tests) {
    const path = label.includes('formation') ? '/api/admin/formation/courses'
      : label.includes('professions') ? '/api/admin/recrutement/professions'
      : label.includes('offers') ? '/api/admin/recrutement/offers'
      : label.includes('blog') ? '/api/admin/blog/posts'
      : '/api/admin/coaching/coaches';
    const r = await req('POST', path, { token, siteId: site, body });
    console.log(`\n${label}: HTTP ${r.status}`);
    console.log(JSON.stringify(r.data, null, 2));
  }
}

main();
