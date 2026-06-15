import { useMemo, useState, type ReactNode } from 'react';
import { OffreEmploi, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import {
  blogPostFromApi,
  blogPostToApi,
  blogPostDetailFromApi,
  buildBlogArticleFields,
  buildBlogCategoryFields,
  buildOfferFields,
  buildMetierFields,
  buildSectorFields,
  buildApplicationFields,
  buildExterneFields,
  offerFromApi,
  offerToApi,
  offerDetailFromApi,
  metierFromApi,
  metierToApi,
  metierDetailFromApi,
  sectorToApi,
  entrepriseToApi,
  entrepriseDetailFromApi,
  buildEntrepriseFields,
  buildRecruteurFields,
  candidatFromApi,
  candidatToApi,
  candidatDetailFromApi,
  ensureCandidatUserId,
  buildCandidatFields,
  recruteurToApi,
} from '@/lib/mappers';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { toast } from 'sonner';

interface RecrutementAdminPageProps {
  siteId: number;
  color: string;
  title: string;
  description: string;
  icon: ReactNode;
  entrepriseTabLabel?: string;
  addEntrepriseLabel?: string;
  showRecruteurs?: boolean;
}

export function RecrutementAdminPage({
  siteId,
  color,
  title,
  description,
  icon,
  entrepriseTabLabel = 'Entreprises',
  addEntrepriseLabel = 'Nouvelle entreprise',
  showRecruteurs = true,
}: RecrutementAdminPageProps) {
  const SITE_QS = `?site_id=${siteId}`;
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const { data: offresData, refetch: refetchO } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/offers${SITE_QS}`);
  const { data: applicationsData, refetch: refetchApp } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/applications${SITE_QS}`);
  const { data: candidatsData, refetch: refetchCand } = useFetch<{ data: Record<string, unknown>[] }>('/recrutement/candidats');
  const { data: entreprisesData, refetch: refetchEnt } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/entreprises${SITE_QS}`);
  const { data: recruteursData, refetch: refetchRec } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/recruteurs${SITE_QS}`);
  const { data: jobsData, refetch: refetchJobs } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/jobs${SITE_QS}`);
  const { data: sectorsData, refetch: refetchSect } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/sectors${SITE_QS}`);
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/posts${SITE_QS}`);
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/categories${SITE_QS}`);
  const { data: externesData, refetch: refetchExt } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/externes${SITE_QS}`);

  const entrepriseOptions = useMemo(
    () => (entreprisesData?.data ?? []).map(e => ({ value: String(e.id), label: String(e.nom) })),
    [entreprisesData],
  );
  const metierOptions = useMemo(
    () => (jobsData?.data ?? []).map(j => ({ value: String(j.id), label: String(j.libelle ?? j.nom) })),
    [jobsData],
  );
  const recruteurOptions = useMemo(
    () => (recruteursData?.data ?? []).map(r => ({
      value: String(r.id),
      label: `${r.prenom} ${r.nom} (${r.entreprise_nom ?? '—'})`,
    })),
    [recruteursData],
  );
  const sectorOptions = useMemo(
    () => (sectorsData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.label ?? s.name) })),
    [sectorsData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [blogCategoriesData],
  );
  const offres = useMemo(() => (offresData?.data ?? []).map(offerFromApi), [offresData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);
  const metiers = useMemo(() => (jobsData?.data ?? []).map(metierFromApi), [jobsData]);
  const candidats = useMemo(() => (candidatsData?.data ?? []).map(candidatFromApi), [candidatsData]);
  const offreOptions = useMemo(
    () => offres.map(o => ({ value: o.id, label: o.titre })),
    [offres],
  );
  const candidatOptions = useMemo(
    () => candidats.map(c => ({ value: c.id, label: `${c.prenom} ${c.nom}` })),
    [candidats],
  );

  const offreFields = useMemo(() => buildOfferFields(entrepriseOptions, metierOptions, recruteurOptions), [entrepriseOptions, metierOptions, recruteurOptions]);
  const metierFields = useMemo(() => buildMetierFields(sectorOptions, siteId), [sectorOptions, siteId]);
  const entrepriseFields = useMemo(
    () => buildEntrepriseFields(
      sectorOptions,
      entrepriseTabLabel === 'Établissements' ? 'Nom de l\'établissement' : 'Nom de l\'entreprise',
    ),
    [sectorOptions, entrepriseTabLabel],
  );
  const recruteurFields = useMemo(() => buildRecruteurFields(entrepriseOptions), [entrepriseOptions]);
  const candidatFields = useMemo(() => buildCandidatFields(), []);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const externeFields = useMemo(() => buildExterneFields(offreOptions), [offreOptions]);
  const applicationCreateFields = useMemo(() => buildApplicationFields(offreOptions, candidatOptions, true), [offreOptions, candidatOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);
  const sectorFields = useMemo(() => buildSectorFields(), []);
  const applicationFields = useMemo(() => buildApplicationFields(offreOptions, candidatOptions, false), [offreOptions, candidatOptions]);

  const tabGroups = useMemo<TabGroup[]>(() => {
    const annuaireTabs = [
      { key: 'entreprises', label: entrepriseTabLabel, count: entreprisesData?.data?.length ?? 0 },
      ...(showRecruteurs ? [{ key: 'recruteurs', label: 'Recruteurs', count: recruteursData?.data?.length ?? 0 }] : []),
      { key: 'metiers', label: 'Métiers', count: metiers.length },
      { key: 'sectors', label: 'Secteurs', count: sectorsData?.data?.length ?? 0 },
    ];
    return [
      {
        key: 'activite',
        label: 'Offres & candidatures',
        tabs: [
          { key: 'offres', label: 'Offres', count: offres.length },
          { key: 'applications', label: 'Candidatures', count: applicationsData?.data?.length ?? 0 },
          { key: 'externes', label: 'Candidatures spontanées', count: externesData?.data?.length ?? 0 },
          { key: 'candidats', label: 'Candidats', count: candidats.length },
        ],
      },
      { key: 'annuaire', label: 'Annuaire', tabs: annuaireTabs },
      {
        key: 'actualites',
        label: 'Actualités',
        tabs: [
          { key: 'articles', label: 'Articles', count: articles.length },
          { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
        ],
      },
    ];
  }, [
    offres.length, applicationsData, externesData, candidats.length, entreprisesData, recruteursData,
    metiers.length, sectorsData, articles.length, blogCategoriesData,
    entrepriseTabLabel, showRecruteurs,
  ]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(tabGroups, 'activite', 'offres');

  const openDetail = async (type: string, path: string, mapper: (row: Record<string, unknown>) => Record<string, unknown>) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(path);
      setModal({ type, item: mapper(row) });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le détail.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveOffre = async (raw: Record<string, unknown>) => {
    const item = modal?.item as OffreEmploi | undefined;
    try {
      const payload = offerToApi(raw);
      if (item) {
        await api.put(`/recrutement/offers/${item.id}${SITE_QS}`, payload);
        toast.success('Offre mise à jour.');
      } else {
        await api.post(`/recrutement/offers${SITE_QS}`, payload);
        toast.success('Offre créée.');
      }
      refetchO();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const saveApplication = async (raw: Record<string, unknown>) => {
    const item = modal?.item as { id: string } | undefined;
    try {
      if (item) {
        await api.put(`/recrutement/applications/${item.id}${SITE_QS}`, raw);
        toast.success('Candidature mise à jour.');
      } else {
        await api.post(`/recrutement/applications${SITE_QS}`, {
          ...raw,
          offre_id: Number(raw.offre_id),
          candidat_id: Number(raw.candidat_id),
        });
        toast.success('Candidature créée.');
      }
      refetchApp();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur'));
      throw err;
    }
  };

  const saveCandidat = async (raw: Record<string, unknown>) => {
    const item = modal?.item as { id: string } | undefined;
    try {
      const payload = candidatToApi(raw);
      if (!item?.id && !payload.user_id) {
        payload.user_id = await ensureCandidatUserId(raw);
      }
      if (item) {
        await api.put(`/recrutement/candidats/${item.id}`, payload);
        toast.success('Candidat mis à jour.');
      } else {
        await api.post('/recrutement/candidats', payload);
        toast.success('Candidat créé.');
      }
      refetchCand();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur'));
      throw err;
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      const map: Record<string, () => Promise<void>> = {
        offre: async () => { await api.delete(`/recrutement/offers/${deleteTarget.id}${SITE_QS}`); refetchO(); },
        application: async () => { await api.delete(`/recrutement/applications/${deleteTarget.id}${SITE_QS}`); refetchApp(); },
        externe: async () => { await api.delete(`/recrutement/externes/${deleteTarget.id}${SITE_QS}`); refetchExt(); },
        candidat: async () => { await api.delete(`/recrutement/candidats/${deleteTarget.id}`); refetchCand(); },
        entreprise: async () => { await api.delete(`/recrutement/entreprises/${deleteTarget.id}`); refetchEnt(); },
        recruteur: async () => { await api.delete(`/recrutement/recruteurs/${deleteTarget.id}`); refetchRec(); },
        metier: async () => { await api.delete(`/recrutement/jobs/${deleteTarget.id}`); refetchJobs(); },
        sector: async () => { await api.delete(`/recrutement/sectors/${deleteTarget.id}`); refetchSect(); },
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchA(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchBc(); },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={icon}
        title={title}
        description={description}
        color={color}
        tabGroups={tabGroups}
        activeGroup={activeGroup}
        onGroupChange={onGroupChange}
        activeTab={tab}
        onTabChange={setTab}
      />

      {loadingDetail && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'offres' && (
          <DataTable<OffreEmploi>
            data={offres}
            accentColor={color}
            addLabel="Nouvelle offre"
            onAdd={() => setModal({ type: 'offre' })}
            onEdit={item => openDetail('offre', `/recrutement/offers/${item.id}${SITE_QS}`, offerDetailFromApi)}
            onDelete={item => setDeleteTarget({ type: 'offre', id: item.id, label: item.titre })}
            searchKeys={['titre', 'entreprise', 'lieu', 'contrat']}
            columns={[
              { key: 'titre', label: 'Poste', render: o => (
                <div>
                  <p className="font-medium text-foreground">{o.titre}</p>
                  <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                </div>
              )},
              { key: 'contrat', label: 'Contrat', hidden: 'md' },
              { key: 'lieu', label: 'Ville', hidden: 'lg' },
              { key: 'urgent', label: 'Urgent', render: o => o.urgent ? (
                <span className="text-xs px-2 py-0.5 rounded-full bg-red-500/15 text-red-400">Urgent</span>
              ) : <span className="text-muted-foreground text-xs">—</span>, hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: o => <StatusBadge statut={o.statut} /> },
            ]}
          />
        )}

        {tab === 'applications' && (
          <DataTable<Record<string, unknown>>
            data={applicationsData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle candidature"
            onAdd={() => setModal({ type: 'application' })}
            onEdit={item => setModal({ type: 'application', item })}
            onDelete={item => setDeleteTarget({ type: 'application', id: String(item.id), label: `${item.candidat_prenom} ${item.candidat_nom}` })}
            searchKeys={['candidat_prenom', 'candidat_nom', 'candidat_email', 'offre_titre']}
            columns={[
              { key: 'candidat', label: 'Candidat', render: c => (
                <div>
                  <p className="font-medium text-foreground">{String(c.candidat_prenom)} {String(c.candidat_nom)}</p>
                  <p className="text-xs text-muted-foreground">{String(c.candidat_email)}</p>
                </div>
              )},
              { key: 'offre_titre', label: 'Offre' },
              { key: 'statut', label: 'Statut', render: c => <StatusBadge statut={String(c.statut)} /> },
            ]}
          />
        )}

        {tab === 'externes' && (
          <DataTable<Record<string, unknown>>
            data={externesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle candidature spontanée"
            onAdd={() => setModal({ type: 'externe' })}
            onEdit={item => setModal({ type: 'externe', item })}
            onDelete={item => setDeleteTarget({ type: 'externe', id: String(item.id), label: `${item.prenom} ${item.nom}` })}
            searchKeys={['prenom', 'nom', 'email', 'offre_titre']}
            columns={[
              { key: 'nom', label: 'Candidat', render: e => <span className="font-medium text-foreground">{String(e.prenom)} {String(e.nom)}</span> },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'offre_titre', label: 'Offre' },
              { key: 'statut', label: 'Statut', render: e => <StatusBadge statut={String(e.statut)} /> },
            ]}
          />
        )}

        {tab === 'candidats' && (
          <DataTable
            data={candidats}
            accentColor={color}
            addLabel="Nouveau candidat"
            onAdd={() => setModal({ type: 'candidat' })}
            onEdit={item => openDetail('candidat', `/recrutement/candidats/${item.id}`, candidatDetailFromApi)}
            onDelete={item => setDeleteTarget({ type: 'candidat', id: item.id, label: `${item.prenom} ${item.nom}` })}
            searchKeys={['prenom', 'nom', 'email', 'ville']}
            columns={[
              { key: 'nom', label: 'Candidat', render: c => (
                <div>
                  <p className="font-medium text-foreground">{c.prenom} {c.nom}</p>
                  <p className="text-xs text-muted-foreground">{c.email}</p>
                </div>
              )},
              { key: 'ville', label: 'Ville', hidden: 'md' },
              { key: 'recherche_active', label: 'Actif', render: c => c.recherche_active ? 'Oui' : 'Non', hidden: 'lg' },
            ]}
          />
        )}

        {tab === 'entreprises' && (
          <DataTable<Record<string, unknown>>
            data={entreprisesData?.data ?? []}
            accentColor={color}
            addLabel={addEntrepriseLabel}
            onAdd={() => setModal({ type: 'entreprise' })}
            onEdit={item => setModal({ type: 'entreprise', item: entrepriseDetailFromApi(item) })}
            onDelete={item => setDeleteTarget({ type: 'entreprise', id: String(item.id), label: String(item.nom) })}
            searchKeys={['nom', 'ville', 'siret']}
            columns={[
              { key: 'nom', label: 'Nom', render: e => <span className="font-medium text-foreground">{String(e.nom)}</span> },
              { key: 'ville', label: 'Ville', hidden: 'md' },
              { key: 'taille', label: 'Taille', hidden: 'lg' },
              { key: 'validee', label: 'Validée', render: e => e.validee ? 'Oui' : 'Non', hidden: 'lg' },
            ]}
          />
        )}

        {showRecruteurs && tab === 'recruteurs' && (
          <DataTable<Record<string, unknown>>
            data={recruteursData?.data ?? []}
            accentColor={color}
            addLabel="Nouveau recruteur"
            onAdd={() => setModal({ type: 'recruteur' })}
            onEdit={item => setModal({ type: 'recruteur', item })}
            onDelete={item => setDeleteTarget({ type: 'recruteur', id: String(item.id), label: `${item.prenom} ${item.nom}` })}
            searchKeys={['prenom', 'nom', 'entreprise_nom', 'email']}
            columns={[
              { key: 'nom', label: 'Nom', render: r => <span className="font-medium text-foreground">{String(r.prenom)} {String(r.nom)}</span> },
              { key: 'entreprise_nom', label: 'Entreprise' },
              { key: 'email', label: 'Email', hidden: 'md' },
            ]}
          />
        )}

        {tab === 'metiers' && (
          <DataTable
            data={metiers}
            accentColor={color}
            addLabel="Nouveau métier"
            onAdd={() => setModal({ type: 'metier' })}
            onEdit={item => openDetail('metier', `/recrutement/jobs/${item.id}`, metierDetailFromApi)}
            onDelete={item => setDeleteTarget({ type: 'metier', id: item.id, label: item.nom })}
            searchKeys={['nom', 'secteur', 'code_rome']}
            columns={[
              { key: 'nom', label: 'Métier', render: m => <span className="font-medium text-foreground">{m.nom}</span> },
              { key: 'secteur', label: 'Secteur', hidden: 'md' },
              { key: 'code_rome', label: 'ROME', hidden: 'lg', render: m => String((m as Record<string, unknown>).code_rome ?? '—') },
              { key: 'statut', label: 'Statut', render: m => <StatusBadge statut={m.statut} /> },
            ]}
          />
        )}

        {tab === 'sectors' && (
          <DataTable<Record<string, unknown>>
            data={sectorsData?.data ?? []}
            accentColor={color}
            addLabel="Nouveau secteur"
            onAdd={() => setModal({ type: 'sector' })}
            onEdit={item => setModal({ type: 'sector', item })}
            onDelete={item => setDeleteTarget({ type: 'sector', id: String(item.id), label: String(item.label ?? item.name) })}
            searchKeys={['label']}
            columns={[
              { key: 'label', label: 'Secteur', render: s => <span className="font-medium text-foreground">{String(s.label ?? s.name)}</span> },
            ]}
          />
        )}

        {tab === 'articles' && (
          <DataTable<BlogArticle>
            data={articles}
            accentColor={color}
            addLabel="Nouvel article"
            onAdd={() => setModal({ type: 'article' })}
            onEdit={item => setModal({ type: 'article', item })}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<Record<string, unknown>>
            data={blogCategoriesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.name)}</span> },
            ]}
          />
        )}

      </div>

      <FormModal open={modal?.type === 'offre'} onClose={() => setModal(null)} onSave={saveOffre} wide
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre'}
        fields={offreFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'application'} onClose={() => setModal(null)} onSave={saveApplication}
        title={modal?.item ? 'Modifier la candidature' : 'Nouvelle candidature'}
        fields={modal?.item ? applicationFields : applicationCreateFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'externe'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = { ...raw, offre_id: Number(raw.offre_id) };
        if (item) await api.put(`/recrutement/externes/${item.id}${SITE_QS}`, payload);
        else await api.post(`/recrutement/externes${SITE_QS}`, payload);
        toast.success('Candidature externe enregistrée'); refetchExt(); setModal(null);
      }} title={modal?.item ? 'Modifier' : 'Nouvelle candidature spontanée'} fields={externeFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'candidat'} onClose={() => setModal(null)} onSave={saveCandidat} wide
        title={modal?.item ? 'Modifier le candidat' : 'Nouveau candidat'}
        fields={candidatFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'entreprise'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = entrepriseToApi(raw, siteId);
          if (item?.id) await api.put(`/recrutement/entreprises/${item.id}`, payload);
          else await api.post('/recrutement/entreprises', payload);
          toast.success('Entreprise enregistrée'); refetchEnt(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier l\'entreprise' : addEntrepriseLabel} fields={entrepriseFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} wide />
      <FormModal open={modal?.type === 'recruteur'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = recruteurToApi(raw);
          if (item?.id) await api.put(`/recrutement/recruteurs/${item.id}`, payload);
          else await api.post('/recrutement/recruteurs', payload);
          toast.success('Recruteur enregistré'); refetchRec(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier le recruteur' : 'Nouveau recruteur'} fields={recruteurFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'metier'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = metierToApi({ ...raw, site_id: siteId }, siteId);
          if (item?.id) await api.put(`/recrutement/jobs/${item.id}`, payload);
          else await api.post('/recrutement/jobs', payload);
          toast.success('Métier enregistré'); refetchJobs(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier le métier' : 'Nouveau métier'} fields={metierFields}
        initialData={(modal?.item ?? { statut: 'publie' }) as Record<string, unknown>} accentColor={color} wide />
      <FormModal open={modal?.type === 'sector'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id?: string } | undefined;
          const payload = sectorToApi(raw, siteId);
          if (item?.id) await api.put(`/recrutement/sectors/${item.id}`, payload);
          else await api.post('/recrutement/sectors', payload);
          toast.success('Secteur enregistré'); refetchSect(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier le secteur' : 'Nouveau secteur'} fields={sectorFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as BlogArticle | undefined;
          const payload = blogPostToApi(raw);
          if (item) await api.put(`/blog/posts/${item.id}${SITE_QS}`, payload);
          else await api.post(`/blog/posts${SITE_QS}`, payload);
          toast.success('Article enregistré'); refetchA(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'} fields={articleFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id: string } | undefined;
          if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, raw);
          else await api.post(`/blog/categories${SITE_QS}`, raw);
          toast.success('Catégorie enregistrée'); refetchBc(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
