import { useMemo, useState, type ReactNode } from 'react';
import { OffreEmploi, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api, downloadPortalAttachment } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { saveBlogArticle } from '@/lib/blog-article-save';
import {
  blogPostDetailFromApi,
  blogCategoryToApi,
  blogAuthorToApi,
  blogTagToApi,
  buildOfferFields,
  buildMetierFields,
  buildMedicalMetierFields,
  buildSectorFields,
  buildExterneFields,
  externeDetailFromApi,
  externeToApi,
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
  recruteurToApi,
  pricingFromApi,
  pricingToApi,
  buildPricingFields,
  sitePricingWithBilanLabels,
  type SitePricingRow,
  type PricingPlan,
} from '@/lib/mappers';
import { useBlogAdmin } from '@/hooks/useBlogAdmin';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { siteQueryString, siteListQueryString } from '@/lib/nexytal-sites';
import { RecruteursValidationPanel } from '@/components/validation/RecruteursValidationPanel';
import { toast } from 'sonner';

interface RecrutementAdminPageProps {
  siteId: number | null;
  color: string;
  title: string;
  description: string;
  icon: ReactNode;
  entrepriseTabLabel?: string;
  mainRoleLabel?: string;
  addEntrepriseLabel?: string;
  showRecruteurs?: boolean;
  showMetiers?: boolean;
  medicalMetiers?: boolean;
  embedded?: boolean;
  /** Vue centralisée : pas de blog, recruteurs/entreprises globaux */
  hubMode?: boolean;
  /** Affiche uniquement le groupe Recruteur/Formateur (ex. embed dans Formation) */
  mainRoleOnly?: boolean;
  /** Masque la barre d'onglets interne (navigation gérée par la page parente) */
  suppressHeader?: boolean;
  /** Onglet affiché au montage (gestion | externes | val_recruteurs) */
  initialTab?: 'gestion' | 'externes' | 'val_recruteurs';
  /** Tarifs bilan (site_pricing, 3 lignes ordre id) — ex. site Carrière */
  showSitePricing?: boolean;
}

export function RecrutementAdminPage({
  siteId,
  color,
  title,
  description,
  icon,
  entrepriseTabLabel = 'Entreprises',
  mainRoleLabel = 'Recruteur / Formateur',
  addEntrepriseLabel = 'Nouvelle entreprise',
  showRecruteurs = true,
  showMetiers = true,
  medicalMetiers = false,
  embedded = false,
  hubMode = false,
  mainRoleOnly = false,
  suppressHeader = false,
  initialTab = 'gestion',
  showSitePricing = false,
}: RecrutementAdminPageProps) {
  const SITE_QS = siteQueryString(siteId);
  const siteScoped = siteId !== null;

  const { data: pendingRecruteursData } = useFetch<{ data?: { count: number } }>(
    showRecruteurs && siteId ? `/recrutement/recruteurs/pending-count?site_id=${siteId}` : null,
  );
  const pendingRecruteursCount = pendingRecruteursData?.data?.count ?? 0;

  const [offreStatutFilter, setOffreStatutFilter] = useState('');
  const [offerCandidatures, setOfferCandidatures] = useState<{ id: string; titre: string } | null>(null);
  const [candidaturesOffre, setCandidaturesOffre] = useState<Record<string, unknown>[]>([]);
  const [loadingCandidatures, setLoadingCandidatures] = useState(false);
  const blog = useBlogAdmin(hubMode ? null : siteId);
  const {
    articles,
    blogCategoriesData,
    authorsData,
    tagsData,
    articleFields,
    blogCategoryFields,
    authorFields,
    tagFields,
    refetchArticles,
    refetchCategories,
    refetchAuthors,
    refetchTags,
  } = blog;
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const offresUrl = `/recrutement/offers${siteListQueryString(siteId, { limit: 500, statut: offreStatutFilter || undefined })}`;
  const { data: offresData, refetch: refetchO } = useFetch<{ data: Record<string, unknown>[] }>(offresUrl);
  const { data: entreprisesData, refetch: refetchEnt } = useFetch<{ data: Record<string, unknown>[] }>(`/recrutement/entreprises${SITE_QS}`);
  const recruteursUrl = siteId ? `/recrutement/recruteurs?site_id=${siteId}` : '/recrutement/recruteurs';
  const { data: recruteursData, refetch: refetchRec } = useFetch<{ data: Record<string, unknown>[] }>(recruteursUrl);
  const { data: jobsData, refetch: refetchJobs } = useFetch<{ data: Record<string, unknown>[] }>(
    siteScoped ? `/recrutement/jobs${SITE_QS}` : null,
  );
  const { data: sectorsData, refetch: refetchSect } = useFetch<{ data: Record<string, unknown>[] }>(
    siteScoped ? `/recrutement/sectors${SITE_QS}` : null,
  );
  const { data: sitePricingData, refetch: refetchSitePricing } = useFetch<{ data: Record<string, unknown>[] }>(
    showSitePricing && siteId ? `/formation/pricing${SITE_QS}` : null,
  );
  const candidaturesUrl = siteScoped
    ? `/recrutement/candidatures${siteListQueryString(siteId, { limit: 500 })}`
    : '/recrutement/candidatures?_all=1&limit=500';
  const { data: candidaturesData, refetch: refetchCand } = useFetch<{ data: Record<string, unknown>[] }>(candidaturesUrl);

  const entrepriseOptions = useMemo(
    () => (entreprisesData?.data ?? []).map(e => ({ value: String(e.id), label: String(e.nom) })),
    [entreprisesData],
  );
  const metierOptions = useMemo(
    () => showMetiers
      ? (jobsData?.data ?? []).map(j => ({ value: String(j.id), label: String(j.libelle ?? j.nom) }))
      : [],
    [jobsData, showMetiers],
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
  const offres = useMemo(
    () => (offresData?.data ?? []).map(row => ({
      ...offerFromApi(row),
      site_name: row.site_name,
      site_id: row.site_id,
      recruteur_id: row.recruteur_id,
    })),
    [offresData],
  );
  const candidatures = useMemo(
    () => (candidaturesData?.data ?? []).map(r => ({
      ...r,
      id: r.candidature_id ?? r.id,
      email: r.email ?? r.candidat_email,
    })),
    [candidaturesData],
  );
  const metiers = useMemo(
    () => showMetiers ? (jobsData?.data ?? []).map(metierFromApi) : [],
    [jobsData, showMetiers],
  );
  const sitePricingRows = useMemo(
    () => sitePricingWithBilanLabels((sitePricingData?.data ?? []).map(pricingFromApi)),
    [sitePricingData],
  );
  const offreOptions = useMemo(
    () => offres.map(o => ({ value: o.id, label: o.titre })),
    [offres],
  );

  const offreFields = useMemo(
    () => buildOfferFields(entrepriseOptions, metierOptions, recruteurOptions, { includeMetier: showMetiers }),
    [entrepriseOptions, metierOptions, recruteurOptions, showMetiers],
  );
  const metierFields = useMemo(
    () => medicalMetiers ? buildMedicalMetierFields(sectorOptions) : buildMetierFields(sectorOptions),
    [sectorOptions, medicalMetiers],
  );
  const entrepriseFields = useMemo(
    () => buildEntrepriseFields(
      sectorOptions,
      entrepriseTabLabel === 'Établissements' ? 'Nom de l\'établissement' : 'Nom de l\'entreprise',
    ),
    [sectorOptions, entrepriseTabLabel],
  );
  const recruteurFields = useMemo(() => buildRecruteurFields(entrepriseOptions), [entrepriseOptions]);
  const externeFields = useMemo(() => buildExterneFields(offreOptions), [offreOptions]);
  const sectorFields = useMemo(() => buildSectorFields(), []);
  const pricingFields = useMemo(() => buildPricingFields(), []);

  const tabGroups = useMemo<TabGroup[]>(() => {
    const mainRoleTabs = [
      ...(showRecruteurs ? [{
        key: 'gestion',
        label: 'Offres d\'emploi',
        count: offres.length,
      }] : []),
      { key: 'externes', label: 'Candidatures', count: candidatures.length },
    ];

    const referentielsTabs = [
      { key: 'entreprises', label: entrepriseTabLabel, count: entreprisesData?.data?.length ?? 0 },
      ...(showRecruteurs && siteScoped ? [{
        key: 'val_recruteurs',
        label: 'Comptes recruteurs',
        count: pendingRecruteursCount,
      }] : []),
      ...(showMetiers ? [{ key: 'metiers', label: 'Métiers', count: metiers.length }] : []),
      { key: 'sectors', label: 'Secteurs', count: sectorsData?.data?.length ?? 0 },
    ];

    const actualitesGroup = {
      key: 'actualites',
      label: 'Actualités',
      tabs: [
        { key: 'articles', label: 'Articles', count: articles.length },
        { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
        { key: 'blog_authors', label: 'Auteurs', count: authorsData?.data?.length ?? 0 },
        { key: 'blog_tags', label: 'Tags', count: tagsData?.data?.length ?? 0 },
      ],
    };

    if (mainRoleOnly) {
      const roleTabs = [
        ...(showRecruteurs ? [{
          key: 'gestion',
          label: 'Offres d\'emploi',
          count: offres.length,
        }] : []),
        ...(showRecruteurs && siteScoped ? [{
          key: 'val_recruteurs',
          label: 'Comptes recruteurs',
          count: pendingRecruteursCount,
        }] : []),
        { key: 'externes', label: 'Candidatures', count: candidatures.length },
      ];
      return [{ key: 'mainRole', label: mainRoleLabel, tabs: roleTabs }];
    }

    return [
      { key: 'mainRole', label: mainRoleLabel, tabs: mainRoleTabs },
      { key: 'referentiels', label: 'Référentiels', tabs: referentielsTabs },
      ...(showSitePricing && siteScoped ? [{
        key: 'tarifs',
        label: 'Tarifs',
        tabs: [{ key: 'pricing', label: 'Tarifs bilan', count: sitePricingRows.length }],
      }] : []),
      actualitesGroup,
    ];
  }, [
    offres.length, candidatures.length, entreprisesData, recruteursData,
    metiers.length, sectorsData, articles.length, blogCategoriesData, authorsData, tagsData,
    entrepriseTabLabel, mainRoleLabel, showRecruteurs, showMetiers, siteScoped,
    siteId, mainRoleOnly, pendingRecruteursCount, showSitePricing, sitePricingRows.length,
  ]);

  const visibleTabGroups = useMemo(() => {
    let groups = tabGroups;
    if (embedded || hubMode) {
      groups = groups.filter(g => g.key !== 'actualites');
    }
    if (hubMode && !siteScoped) {
      groups = groups.map(g => g.key === 'annuaire'
        ? { ...g, tabs: g.tabs.filter(t => t.key !== 'metiers' && t.key !== 'sectors') }
        : g);
    }
    return groups;
  }, [tabGroups, embedded, hubMode, siteScoped]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(
    visibleTabGroups,
    'mainRole',
    initialTab,
  );

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

  const openOfferCandidatures = async (offre: OffreEmploi) => {
    setOfferCandidatures({ id: offre.id, titre: offre.titre });
    setLoadingCandidatures(true);
    try {
      const res = await api.get<{ data: Array<Record<string, unknown>> }>(
        `/recrutement/candidatures?offre_id=${offre.id}&_all=1`,
      );
      const rows = (res.data.data ?? []).map(r => ({
        id: `${r.type}-${r.candidature_id ?? r.id}`,
        candidature_id: Number(r.candidature_id ?? r.id),
        type: r.type === 'interne' ? 'Profil' : 'Externe',
        typeRaw: r.type === 'interne' ? 'interne' : 'externe',
        nom: `${r.prenom ?? ''} ${r.nom ?? ''}`.trim(),
        email: r.email ?? r.candidat_email ?? '—',
        statut: r.statut,
        experience: r.experience_candidat,
        disponibilite: r.disponibilite,
        cv: r.cv_filename,
        lettre: r.lettre_motivation ?? r.message,
        date: r.date_candidature ?? r.created_at,
      }));
      setCandidaturesOffre(rows);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger les candidatures.'));
      setCandidaturesOffre([]);
    } finally {
      setLoadingCandidatures(false);
    }
  };

  const saveOffre = async (raw: Record<string, unknown>) => {
    const item = modal?.item as OffreEmploi | undefined;
    if (!siteScoped && !item) {
      toast.error('Sélectionnez un site de publication pour créer une offre.');
      return;
    }
    const qs = siteScoped ? SITE_QS : '';
    try {
      const payload = offerToApi(raw);
      if (item) {
        await api.put(`/recrutement/offers/${item.id}${qs}`, payload);
        toast.success('Offre mise à jour.');
      } else {
        await api.post(`/recrutement/offers${qs}`, payload);
        toast.success('Offre créée.');
      }
      refetchO();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const saveSitePricing = async (raw: Record<string, unknown>) => {
    const item = modal?.item as PricingPlan | undefined;
    if (!item?.id) return;
    try {
      const payload = pricingToApi(raw);
      await api.put(`/formation/pricing/${item.id}${SITE_QS}`, payload);
      toast.success('Tarif mis à jour.');
      refetchSitePricing();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      const map: Record<string, () => Promise<void>> = {
        offre: async () => { await api.delete(`/recrutement/offers/${deleteTarget.id}`); refetchO(); },
        externe: async () => { await api.delete(`/recrutement/externes/${deleteTarget.id}${SITE_QS}`); refetchCand(); },
        entreprise: async () => { await api.delete(`/recrutement/entreprises/${deleteTarget.id}`); refetchEnt(); },
        recruteur: async () => { await api.delete(`/recrutement/recruteurs/${deleteTarget.id}`); refetchRec(); },
        metier: async () => { await api.delete(`/recrutement/jobs/${deleteTarget.id}${SITE_QS}`); refetchJobs(); },
        sector: async () => { await api.delete(`/recrutement/sectors/${deleteTarget.id}`); refetchSect(); },
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchArticles(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchCategories(); },
        blog_author: async () => { await api.delete(`/blog/authors/${deleteTarget.id}${SITE_QS}`); refetchAuthors(); },
        blog_tag: async () => { await api.delete(`/blog/tags/${deleteTarget.id}${SITE_QS}`); refetchTags(); },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up min-h-0">
      {!suppressHeader && (mainRoleOnly ? (
        <SiteHeader
          icon={icon}
          title=""
          description=""
          color={color}
          tabGroups={visibleTabGroups}
          activeGroup={activeGroup}
          onGroupChange={onGroupChange}
          activeTab={tab}
          onTabChange={setTab}
          compact
        />
      ) : (hubMode && !title) ? (
          <SiteHeader
            icon={icon}
            title=""
            description=""
            color={color}
            tabGroups={visibleTabGroups}
            activeGroup={activeGroup}
            onGroupChange={onGroupChange}
            activeTab={tab}
            onTabChange={setTab}
            compact
          />
        ) : (
          <SiteHeader
            icon={icon}
            title={title}
            description={description}
            color={color}
            tabGroups={visibleTabGroups}
            activeGroup={activeGroup}
            onGroupChange={onGroupChange}
            activeTab={tab}
            onTabChange={setTab}
            compact={embedded}
          />
        ))}

      {loadingDetail && tab !== 'gestion' && tab !== 'val_recruteurs' && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className={`flex-1 overflow-y-auto min-h-0 ${tab === 'val_recruteurs' ? 'flex flex-col' : 'p-6'}`}>
        {tab === 'val_recruteurs' && showRecruteurs && siteId && (
          <RecruteursValidationPanel mode="embedded" siteId={siteId} accentColor={color} />
        )}

        {showRecruteurs && tab === 'gestion' && (
          <>
            <div className="flex flex-wrap gap-2 mb-4">
              {[
                { value: '', label: 'Toutes' },
                { value: 'en_attente', label: 'En attente validation' },
                { value: 'publiee', label: 'Publiées' },
                { value: 'brouillon', label: 'Brouillons' },
                { value: 'refusee', label: 'Archivées / refusées' },
              ].map(f => (
                <button
                  key={f.value || 'all'}
                  type="button"
                  onClick={() => setOffreStatutFilter(f.value)}
                  className={`text-xs px-3 py-1.5 rounded-full border transition-colors ${
                    offreStatutFilter === f.value
                      ? 'border-transparent text-white'
                      : 'border-border text-muted-foreground hover:text-foreground'
                  }`}
                  style={offreStatutFilter === f.value ? { background: color } : undefined}
                >
                  {f.label}
                </button>
              ))}
            </div>
            <DataTable<OffreEmploi & { recruteur_id?: unknown; recruteur_email?: string }>
              data={offres}
              accentColor={color}
              addLabel="Nouvelle offre"
              onAdd={siteScoped ? () => setModal({ type: 'offre' }) : undefined}
              onEdit={item => openDetail('offre', `/recrutement/offers/${item.id}`, offerDetailFromApi)}
              onView={item => openOfferCandidatures(item)}
              onDelete={item => setDeleteTarget({ type: 'offre', id: item.id, label: item.titre })}
              searchKeys={['titre', 'entreprise', 'lieu', 'contrat', 'recruteur_email']}
              columns={[
                {
                  key: 'titre',
                  label: 'Poste',
                  render: o => (
                    <div>
                      <p className="font-medium text-foreground">{o.titre}</p>
                      <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                    </div>
                  ),
                },
                {
                  key: 'source',
                  label: 'Publiée par',
                  hidden: 'md',
                  render: o => (
                    <span className="text-xs">
                      {o.recruteur_id ? 'Recruteur' : 'Admin Nexytal'}
                    </span>
                  ),
                },
                {
                  key: 'recruteur_email',
                  label: 'Contact',
                  hidden: 'lg',
                  render: o => String(o.recruteur_email || '—'),
                },
                ...(hubMode && !siteScoped ? [{
                  key: 'site_name',
                  label: 'Site',
                  hidden: 'md' as const,
                  render: (o: OffreEmploi & { site_name?: string }) => String((o as Record<string, unknown>).site_name ?? '—'),
                }] : []),
                { key: 'contrat', label: 'Contrat', hidden: 'md' },
                { key: 'lieu', label: 'Ville', hidden: 'lg' },
                { key: 'statut', label: 'Statut', render: o => <StatusBadge statut={o.statut} /> },
              ]}
            />
          </>
        )}

        {tab === 'externes' && (
          <DataTable<any>
            data={candidatures}
            accentColor={color}
            addLabel="Nouvelle candidature liée à une offre"
            onAdd={siteScoped && offreOptions.length ? () => setModal({ type: 'externe' }) : undefined}
            onEdit={item => {
              if (item.type === 'interne') {
                toast.info('Les candidatures profil se gèrent depuis l\'espace candidat.');
                return;
              }
              setModal({ type: 'externe', item: externeDetailFromApi(item) });
            }}
            onDelete={item => {
              if (item.type === 'interne') {
                toast.info('Suppression non disponible pour les candidatures profil.');
                return;
              }
              setDeleteTarget({ type: 'externe', id: String(item.id), label: `${item.prenom} ${item.nom}` });
            }}
            searchKeys={['prenom', 'nom', 'email', 'offre_titre']}
            columns={[
              { key: 'nom', label: 'Candidat', render: e => <span className="font-medium text-foreground">{String(e.prenom)} {String(e.nom)}</span> },
              { key: 'type', label: 'Source', hidden: 'md', render: e => e.type === 'interne' ? 'Profil' : 'Externe' },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'offre_titre', label: 'Offre' },
              { key: 'experience_candidat', label: 'Expérience', hidden: 'lg', render: e => String(e.experience_candidat ?? '—') },
              { key: 'disponibilite', label: 'Dispo.', hidden: 'xl', render: e => e.disponibilite ? new Date(String(e.disponibilite)).toLocaleDateString('fr-FR') : '—' },
              { key: 'statut', label: 'Statut pipeline', render: e => <StatusBadge statut={String(e.statut)} /> },
            ]}
          />
        )}

        {tab === 'entreprises' && (
          <DataTable<any>
            data={entreprisesData?.data ?? []}
            accentColor={color}
            addLabel={addEntrepriseLabel}
            onAdd={() => setModal({ type: 'entreprise' })}
            onEdit={item => setModal({ type: 'entreprise', item: entrepriseDetailFromApi(item) })}
            onDelete={item => setDeleteTarget({ type: 'entreprise', id: String(item.id), label: String(item.nom) })}
            searchKeys={['nom', 'ville', 'region', 'siret']}
            columns={[
              { key: 'nom', label: 'Nom', render: e => <span className="font-medium text-foreground">{String(e.nom)}</span> },
              { key: 'ville', label: 'Ville', hidden: 'md' },
              { key: 'region', label: 'Région', hidden: 'lg', render: e => String(e.region ?? '—') },
              { key: 'taille', label: 'Taille', hidden: 'lg' },
              { key: 'validee', label: 'Validée', render: e => e.validee ? 'Oui' : 'Non', hidden: 'lg' },
            ]}
          />
        )}

        {showMetiers && tab === 'metiers' && (
          <DataTable
            data={metiers}
            accentColor={color}
            addLabel="Nouveau métier"
            onAdd={() => setModal({ type: 'metier' })}
            onEdit={item => openDetail('metier', `/recrutement/jobs/${item.id}${SITE_QS}`, metierDetailFromApi)}
            onDelete={item => setDeleteTarget({ type: 'metier', id: item.id, label: item.nom })}
            searchKeys={['nom', 'secteur', 'titre']}
            columns={[
              { key: 'nom', label: 'Métier', render: m => <span className="font-medium text-foreground">{m.nom}</span> },
              { key: 'secteur', label: 'Secteur', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: m => <StatusBadge statut={m.statut} /> },
            ]}
          />
        )}

        {tab === 'sectors' && (
          <DataTable<any>
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

        {tab === 'pricing' && showSitePricing && (
          <>
            <p className="text-sm text-muted-foreground mb-4">
              3 tarifs de bilan de compétences : distanciel, présentiel, mixte.
            </p>
            <DataTable<SitePricingRow>
              data={sitePricingRows}
              accentColor={color}
              onEdit={item => setModal({ type: 'pricing', item })}
              searchKeys={['bilan_label', 'site_label', 'amount_eur']}
              columns={[
                { key: 'bilan_label', label: 'Bilan', render: p => <span className="font-medium text-foreground">{p.bilan_label}</span> },
                { key: 'amount_eur', label: 'Prix', render: p => `${p.amount_eur.toLocaleString('fr-FR')} €` },
                { key: 'site_label', label: 'Site', hidden: 'sm' },
              ]}
            />
          </>
        )}

        {tab === 'articles' && (
          <DataTable<BlogArticle>
            data={articles}
            accentColor={color}
            addLabel="Nouvel article"
            onAdd={() => setModal({ type: 'article' })}
            onEdit={item => openDetail('article', `/blog/posts/${item.id}${SITE_QS}`, blogPostDetailFromApi)}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie', 'auteur']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'categorie', label: 'Catégorie', hidden: 'sm' },
              { key: 'auteur', label: 'Auteur', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<any>
            data={blogCategoriesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.name)}</span> },
              { key: 'is_active', label: 'Visible', render: c => c.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'blog_authors' && (
          <DataTable<Record<string, unknown>>
            data={authorsData?.data ?? []}
            accentColor={color}
            addLabel="Nouvel auteur"
            onAdd={() => setModal({ type: 'blog_author' })}
            onEdit={item => setModal({ type: 'blog_author', item })}
            onDelete={item => setDeleteTarget({
              type: 'blog_author',
              id: String(item.id),
              label: `${item.first_name} ${item.last_name}`,
            })}
            searchKeys={['first_name', 'last_name', 'email']}
            columns={[
              {
                key: 'name',
                label: 'Auteur',
                render: a => <span className="font-medium text-foreground">{String(a.first_name)} {String(a.last_name)}</span>,
              },
              { key: 'email', label: 'Email', hidden: 'sm' },
              { key: 'is_active', label: 'Actif', render: a => a.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'blog_tags' && (
          <DataTable<Record<string, unknown>>
            data={tagsData?.data ?? []}
            accentColor={color}
            addLabel="Nouveau tag"
            onAdd={() => setModal({ type: 'blog_tag' })}
            onEdit={item => setModal({ type: 'blog_tag', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_tag', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Tag', render: t => <span className="font-medium text-foreground">{String(t.name)}</span> },
            ]}
          />
        )}

      </div>

      <FormModal open={modal?.type === 'offre'} onClose={() => setModal(null)} onSave={saveOffre} wide
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre'}
        fields={offreFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'externe'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = externeToApi(raw);
        if (item) await api.put(`/recrutement/externes/${item.id}${SITE_QS}`, payload);
        else await api.post(`/recrutement/externes${SITE_QS}`, payload);
        toast.success('Candidature enregistrée'); refetchCand(); setModal(null);
      }} title={modal?.item ? 'Modifier la candidature' : 'Nouvelle candidature (offre)'} fields={externeFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} siteId={siteId != null ? String(siteId) : undefined} />
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
          if (item?.id) await api.put(`/recrutement/jobs/${item.id}${SITE_QS}`, payload);
          else await api.post(`/recrutement/jobs${SITE_QS}`, payload);
          toast.success('Métier enregistré'); refetchJobs(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier le métier' : 'Nouveau métier'} fields={metierFields}
        initialData={(modal?.item ?? { statut: 'publie' }) as Record<string, unknown>} accentColor={color}
        wide={medicalMetiers} siteId={siteId != null ? String(siteId) : undefined} />
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
          await saveBlogArticle(raw, SITE_QS, item?.id);
          toast.success('Article enregistré'); refetchArticles(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'} fields={articleFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} wide
        siteId={siteId != null ? String(siteId) : undefined} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id: string } | undefined;
          const payload = blogCategoryToApi(raw);
          if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, payload);
          else await api.post(`/blog/categories${SITE_QS}`, payload);
          toast.success('Catégorie enregistrée'); refetchCategories(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />
      <FormModal open={modal?.type === 'blog_author'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id: string } | undefined;
          const payload = blogAuthorToApi(raw);
          if (item) await api.put(`/blog/authors/${item.id}${SITE_QS}`, payload);
          else await api.post(`/blog/authors${SITE_QS}`, payload);
          toast.success('Auteur enregistré'); refetchAuthors(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier l\'auteur' : 'Nouvel auteur'} fields={authorFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color}
        siteId={siteId != null ? String(siteId) : undefined} />
      <FormModal open={modal?.type === 'blog_tag'} onClose={() => setModal(null)} onSave={async (raw) => {
        try {
          const item = modal?.item as { id: string } | undefined;
          const payload = blogTagToApi(raw);
          if (item) await api.put(`/blog/tags/${item.id}${SITE_QS}`, payload);
          else await api.post(`/blog/tags${SITE_QS}`, payload);
          toast.success('Tag enregistré'); refetchTags(); setModal(null);
        } catch (e) { toast.error(getApiErrorMessage(e, 'Erreur')); throw e; }
      }} title={modal?.item ? 'Modifier le tag' : 'Nouveau tag'} fields={tagFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <FormModal open={modal?.type === 'pricing'} onClose={() => setModal(null)} onSave={saveSitePricing}
        title={modal?.item
          ? `Modifier — ${(modal.item as SitePricingRow).bilan_label ?? 'tarif'}`
          : 'Modifier le tarif'}
        fields={pricingFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      {offerCandidatures && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl w-full max-w-4xl max-h-[80vh] flex flex-col">
            <div className="p-5 border-b border-border">
              <h3 className="font-semibold text-foreground">Candidatures — {offerCandidatures.titre}</h3>
            </div>
            <div className="flex-1 overflow-y-auto p-5">
              {loadingCandidatures ? (
                <p className="text-sm text-muted-foreground">Chargement…</p>
              ) : candidaturesOffre.length === 0 ? (
                <p className="text-sm text-muted-foreground">Aucune candidature pour cette offre.</p>
              ) : (
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-muted-foreground border-b border-border">
                      <th className="pb-2 font-medium">Candidat</th>
                      <th className="pb-2 font-medium hidden md:table-cell">Email</th>
                      <th className="pb-2 font-medium">Type</th>
                      <th className="pb-2 font-medium">Statut</th>
                      <th className="pb-2 font-medium">Pièces</th>
                    </tr>
                  </thead>
                  <tbody>
                    {candidaturesOffre.map(c => (
                      <tr key={String(c.id)} className="border-b border-border/50">
                        <td className="py-2.5 font-medium text-foreground">{String(c.nom)}</td>
                        <td className="py-2.5 hidden md:table-cell text-muted-foreground">{String(c.email ?? '—')}</td>
                        <td className="py-2.5 text-xs text-muted-foreground">{String(c.type)}</td>
                        <td className="py-2.5"><StatusBadge statut={String(c.statut)} /></td>
                        <td className="py-2.5">
                          <div className="flex gap-2">
                            {c.cv ? (
                              <button
                                type="button"
                                className="text-xs text-primary hover:underline"
                                onClick={async () => {
                                  try {
                                    await downloadPortalAttachment(
                                      `/recruteur/candidatures/${c.candidature_id}/cv?type=${c.typeRaw}`,
                                      `CV_${c.nom}.pdf`,
                                    );
                                  } catch (err) {
                                    toast.error(getApiErrorMessage(err, 'CV indisponible'));
                                  }
                                }}
                              >
                                CV
                              </button>
                            ) : null}
                            {c.lettre ? (
                              <button
                                type="button"
                                className="text-xs text-primary hover:underline"
                                onClick={async () => {
                                  try {
                                    await downloadPortalAttachment(
                                      `/recruteur/candidatures/${c.candidature_id}/lettre?type=${c.typeRaw}`,
                                      `Lettre_${c.nom}.txt`,
                                    );
                                  } catch (err) {
                                    toast.error(getApiErrorMessage(err, 'Lettre indisponible'));
                                  }
                                }}
                              >
                                Lettre
                              </button>
                            ) : null}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
            <div className="p-4 border-t border-border flex justify-end">
              <button
                type="button"
                className="text-sm px-4 py-2 rounded-lg border border-border hover:bg-secondary"
                onClick={() => { setOfferCandidatures(null); setCandidaturesOffre([]); }}
              >
                Fermer
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
