const fs = require('fs');
const file = 'c:\\nexytal-gestion\\src\\pages\\RecrutementAdminPage.tsx';
let content = fs.readFileSync(file, 'utf8');

// 1. Update Props
content = content.replace(
  /entrepriseTabLabel\?: string;/g,
  "entrepriseTabLabel?: string;\n  mainRoleLabel?: string;"
);
content = content.replace(
  /entrepriseTabLabel = 'Entreprises',/g,
  "entrepriseTabLabel = 'Entreprises',\n  mainRoleLabel = 'Recruteur / Formateur',"
);

// 2. Remove score and verify imports and elements
content = content.replace(/import ScoreBadge from '@\/components\/ScoreBadge';\n/g, "");

// 3. Add useFetch for competences and villes
content = content.replace(
  /const { data: secteursData, refetch: refetchSect } = useFetch.*?;\n/gs,
  (match) => match
); // Wait, variable is sectorsData

content = content.replace(
  /const { data: sectorsData, refetch: refetchSect } = useFetch.*?;\n/gs,
  (match) => match + `  const { data: competencesData, refetch: refetchComp } = useFetch<{ data: Record<string, unknown>[] }>(siteScoped ? \`/recrutement/competences\${SITE_QS}\` : '/recrutement/competences');\n  const { data: villesData, refetch: refetchVilles } = useFetch<{ data: Record<string, unknown>[] }>(siteScoped ? \`/recrutement/villes\${SITE_QS}\` : '/recrutement/villes');\n`
);

// 4. Update tabGroups logic
const newTabGroupsLogic = `
  const tabGroups = useMemo<TabGroup[]>(() => {
    const mainRoleTabs = [
      { key: 'externes', label: 'Candidatures', count: externesData?.data?.length ?? 0 },
      { key: 'offres', label: 'Offres d\\'emploi', count: offres.length },
      ...(showRecruteurs ? [{ key: 'recruteurs', label: \`Validation \${mainRoleLabel.toLowerCase()}s\`, count: recruteursData?.data?.length ?? 0 }] : []),
    ];

    const referentielsTabs = [
      { key: 'entreprises', label: entrepriseTabLabel, count: entreprisesData?.data?.length ?? 0 },
      ...(showMetiers ? [{ key: 'metiers', label: 'Métiers', count: metiers.length }] : []),
      { key: 'competences', label: 'Compétences', count: competencesData?.data?.length ?? 0 },
      { key: 'villes', label: 'Villes', count: villesData?.data?.length ?? 0 },
      { key: 'sectors', label: 'Secteurs', count: sectorsData?.data?.length ?? 0 },
    ];

    if (showValidationTabs && siteId) {
      return [
        buildRecrutementTabGroup(recrutementCounts),
        { key: 'mainRole', label: mainRoleLabel, tabs: mainRoleTabs },
        { key: 'referentiels', label: 'Référentiels', tabs: referentielsTabs },
        {
          key: 'actualites',
          label: 'Actualités',
          tabs: [
            { key: 'articles', label: 'Articles', count: articles.length },
            { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
            { key: 'blog_authors', label: 'Auteurs', count: authorsData?.data?.length ?? 0 },
            { key: 'blog_tags', label: 'Tags', count: tagsData?.data?.length ?? 0 },
          ],
        },
      ];
    }

    return [
      { key: 'mainRole', label: mainRoleLabel, tabs: mainRoleTabs },
      { key: 'referentiels', label: 'Référentiels', tabs: referentielsTabs },
      {
        key: 'actualites',
        label: 'Actualités',
        tabs: [
          { key: 'articles', label: 'Articles', count: articles.length },
          { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
          { key: 'blog_authors', label: 'Auteurs', count: authorsData?.data?.length ?? 0 },
          { key: 'blog_tags', label: 'Tags', count: tagsData?.data?.length ?? 0 },
        ],
      },
    ];
  }, [
    offres.length, externesData, entreprisesData, recruteursData,
    metiers.length, sectorsData, competencesData, villesData, articles.length, blogCategoriesData, authorsData, tagsData,
    entrepriseTabLabel, mainRoleLabel, showRecruteurs, showMetiers, siteScoped,
    showValidationTabs, siteId, recrutementCounts,
  ]);
`;

// Replace the old tabGroups useMemo
content = content.replace(/const tabGroups = useMemo<TabGroup\[\]>\(\(\) => \{[\s\S]*?\]\);/m, newTabGroupsLogic.trim());

// 5. Update useTabGroups default tabs
content = content.replace(
  /const \{ activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange \} = useTabGroups\([\s\S]*?\);/m,
  "const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(\n    visibleTabGroups,\n    showValidationTabs && siteId ? 'recrutement' : 'mainRole',\n    showValidationTabs && siteId ? 'rec_recruteurs' : 'externes',\n  );"
);

// 6. Delete handleDelete entries for Ville and Competence
content = content.replace(
  /sector: async \(\) => \{ await api\.delete\(`\/recrutement\/sectors\/\$\{deleteTarget\.id\}`\); refetchSect\(\); \},/g,
  "sector: async () => { await api.delete(`/recrutement/sectors/${deleteTarget.id}`); refetchSect(); },\n        competence: async () => { await api.delete(`/recrutement/competences/${deleteTarget.id}`); refetchComp(); },\n        ville: async () => { await api.delete(`/recrutement/villes/${deleteTarget.id}`); refetchVilles(); },"
);

// 7. Render DataTables for Competence and Ville
const competencesDataTable = `
        {tab === 'competences' && (
          <DataTable<any>
            data={competencesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle compétence"
            onAdd={() => setModal({ type: 'competence' })}
            onEdit={item => setModal({ type: 'competence', item })}
            onDelete={item => setDeleteTarget({ type: 'competence', id: String(item.id), label: String(item.label) })}
            searchKeys={['label']}
            columns={[
              { key: 'label', label: 'Compétence', render: c => <span className="font-medium text-foreground">{String(c.label)}</span> },
              { key: 'categorie', label: 'Catégorie', render: c => String(c.categorie ?? 'technique') },
            ]}
          />
        )}
`;
const villesDataTable = `
        {tab === 'villes' && (
          <DataTable<any>
            data={villesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle ville"
            onAdd={() => setModal({ type: 'ville' })}
            onEdit={item => setModal({ type: 'ville', item })}
            onDelete={item => setDeleteTarget({ type: 'ville', id: String(item.id), label: String(item.nom) })}
            searchKeys={['nom', 'code_postal']}
            columns={[
              { key: 'nom', label: 'Ville', render: v => <span className="font-medium text-foreground">{String(v.nom)}</span> },
              { key: 'code_postal', label: 'Code Postal', render: v => String(v.code_postal ?? '—') },
            ]}
          />
        )}
`;

content = content.replace(/\{tab === 'sectors' && \([\s\S]*?<\/DataTable>\s*\)\s*\}/m, (match) => match + "\n" + competencesDataTable + "\n" + villesDataTable);

// 8. Add FormModals for Competence and Ville
const formModals = `
      <FormModal open={modal?.type === 'competence'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = { ...raw, site_id: siteId };
          if (item?.id) await api.put(\`/recrutement/competences/\${item.id}\`, payload);
          else await api.post('/recrutement/competences', payload);
          toast.success('Compétence enregistrée'); refetchComp(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier la compétence' : 'Nouvelle compétence'} fields={[
        { key: 'label', label: 'Libellé', type: 'text', required: true },
        { key: 'categorie', label: 'Catégorie', type: 'select', options: [
          {value:'technique', label:'Technique'},
          {value:'soft_skill', label:'Soft Skill'},
          {value:'langue', label:'Langue'},
          {value:'outil', label:'Outil'},
          {value:'certification', label:'Certification'}
        ] }
      ]} initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <FormModal open={modal?.type === 'ville'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = { ...raw, site_id: siteId };
          if (item?.id) await api.put(\`/recrutement/villes/\${item.id}\`, payload);
          else await api.post('/recrutement/villes', payload);
          toast.success('Ville enregistrée'); refetchVilles(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier la ville' : 'Nouvelle ville'} fields={[
        { key: 'nom', label: 'Nom de la ville', type: 'text', required: true },
        { key: 'code_postal', label: 'Code postal', type: 'text' }
      ]} initialData={modal?.item as Record<string, unknown>} accentColor={color} />
`;

content = content.replace(/<FormModal open=\{modal\?\.type === 'sector'\}[\s\S]*? accentColor=\{color\} \/>/m, (match) => match + "\n" + formModals);

// 9. Remove verifie_nexytal and score fields from Externes DataTable
content = content.replace(/\{ key: 'verifie', label: 'Vérifié'.*?\n/g, "");
content = content.replace(/\{ key: 'score', label: 'Score'.*?\n/g, "");

// 10. Also remove verifie_nexytal and score from offerCandidatures modal inside RecrutementAdminPage.tsx
content = content.replace(/verifie_nexytal: Number\(r\.verifie_nexytal\) \? 1 : 0,\n/g, "");
content = content.replace(/score: r\.score_nexytal != null \? Number\(r\.score_nexytal\) : null,\n/g, "");
content = content.replace(/\.sort\(\(a, b\) => \(b\.score \?\? -1\) - \(a\.score \?\? -1\)\)/g, "");

content = content.replace(/<th className="pb-2 font-medium">Vérifié<\/th>\n/g, "");
content = content.replace(/<th className="pb-2 font-medium">Score<\/th>\n/g, "");

content = content.replace(/<td className="py-2\.5">\{c\.verifie_nexytal \? 'Oui' : 'Non'\}<\/td>\n/g, "");
content = content.replace(/<td className="py-2\.5"><ScoreBadge score=\{c\.score as number \| null\} \/><\/td>\n/g, "");

fs.writeFileSync(file, content, 'utf8');
console.log("Patched RecrutementAdminPage.tsx");
