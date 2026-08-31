import { useMemo, useState, useEffect } from 'react';
import { BlogArticle, Formateur } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { saveBlogArticle } from '@/lib/blog-article-save';
import {
  blogPostDetailFromApi,
  blogCategoryToApi,
  blogAuthorToApi,
  blogTagToApi,
  trainerFromApi,
  trainerToApi,
  trainerDetailFromApi,
  buildTrainerFields,
  buildExpertiseFields,
  expertiseFromApi,
  expertiseToApi,
  buildTrainerSkillFields,
  buildTrainerCityFields,
  buildTrainerCertificationFields,
  buildTrainerLanguageFields,
  buildTrainerReviewFields,
} from '@/lib/mappers';
import { useBlogAdmin } from '@/hooks/useBlogAdmin';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { TrainersValidationPanel } from '@/components/validation/TrainersValidationPanel';
import { ExpertisesCatalogPanel } from '@/components/trainer/ExpertisesCatalogPanel';
import { BookOpen } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#0891B2';
const SITE_ID = 5;
const REFERENTIEL_TABS = new Set(['skills', 'cities', 'certifications', 'languages']);

function trainerInitialTabs(): { group: string; tab: string } {
  if (typeof window === 'undefined') {
    return { group: 'formateurs', tab: 'trainers' };
  }
  const urlTab = new URLSearchParams(window.location.search).get('tab') ?? '';
  if (urlTab === 'expertises') {
    return { group: 'formateurs', tab: 'expertises' };
  }
  if (REFERENTIEL_TABS.has(urlTab)) {
    return { group: 'referentiels', tab: urlTab };
  }
  if (urlTab) {
    return { group: 'formateurs', tab: urlTab };
  }
  return { group: 'formateurs', tab: 'trainers' };
}

export default function SiteTrainer() {
  const initialTabs = useMemo(() => trainerInitialTabs(), []);
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const { data: trainersData, refetch: refetchT } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/trainers');
  const { data: expertisesData, refetch: refetchExp, error: expertisesError, loading: expertisesLoading } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/expertises');
  const blog = useBlogAdmin(5);
  const {
    SITE_QS,
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
  const { data: skillsData, refetch: refetchSk } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/skills');
  const { data: citiesData, refetch: refetchCi } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/cities');
  const { data: certificationsData, refetch: refetchCert } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/certifications');
  const { data: languagesData, refetch: refetchLang } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/languages');
  const { data: reviewsData, refetch: refetchRev } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/reviews');

  const { data: pendingTrainersData } = useFetch<{ data?: { count: number } }>(
    `/trainer/trainers/pending-count?site_id=${SITE_ID}`,
  );
  const pendingTrainersCount = pendingTrainersData?.data?.count ?? 0;

  useEffect(() => {
    if (expertisesError) {
      toast.error(`Spécialités indisponibles : ${expertisesError}`);
    }
  }, [expertisesError]);

  const expertises = useMemo(
    () => (expertisesData?.data ?? []).map(row => expertiseFromApi(row)),
    [expertisesData],
  );

  const expertiseOptions = useMemo(
    () => expertises.filter(e => e.is_active !== false).map(e => ({ value: String(e.id), label: String(e.label) })),
    [expertises],
  );
  const skillOptions = useMemo(
    () => (skillsData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.name) })),
    [skillsData],
  );
  const certificationOptions = useMemo(
    () => (certificationsData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [certificationsData],
  );
  const trainers = useMemo(() => (trainersData?.data ?? []).map(trainerFromApi), [trainersData]);

  const trainerFields = useMemo(
    () => buildTrainerFields(expertiseOptions, skillOptions, certificationOptions),
    [expertiseOptions, skillOptions, certificationOptions],
  );
  const expertiseFields = useMemo(() => buildExpertiseFields(), []);
  const skillFields = useMemo(() => buildTrainerSkillFields(), []);
  const cityFields = useMemo(() => buildTrainerCityFields(), []);
  const certificationFields = useMemo(() => buildTrainerCertificationFields(), []);
  const languageFields = useMemo(() => buildTrainerLanguageFields(), []);
  const reviewFields = useMemo(
    () => buildTrainerReviewFields(trainers.map(t => ({ value: t.id, label: t.nomComplet }))),
    [trainers],
  );
  const tabGroups = useMemo<TabGroup[]>(() => [
    {
      key: 'formateurs',
      label: 'Formateurs',
      tabs: [
        { key: 'trainers', label: 'Profils', count: trainers.length },
        { key: 'expertises', label: 'Expertises', count: expertises.length },
        { key: 'val_trainers', label: 'Profils à valider', count: pendingTrainersCount },
        { key: 'reviews', label: 'Avis clients', count: reviewsData?.data?.length ?? 0 },
      ],
    },
    {
      key: 'referentiels',
      label: 'Référentiels',
      tabs: [
        { key: 'skills', label: 'Compétences', count: skillsData?.data?.length ?? 0 },
        { key: 'cities', label: 'Villes', count: citiesData?.data?.length ?? 0 },
        { key: 'certifications', label: 'Certifications', count: certificationsData?.data?.length ?? 0 },
        { key: 'languages', label: 'Langues', count: languagesData?.data?.length ?? 0 },
      ],
    },
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
  ], [
    trainers.length, expertises.length, pendingTrainersCount, reviewsData, skillsData,
    citiesData, certificationsData, languagesData, articles.length, blogCategoriesData,
    authorsData, tagsData,
  ]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(
    tabGroups,
    initialTabs.group,
    initialTabs.tab,
  );

  const saveExpertise = async (raw: Record<string, unknown>) => {
    const item = modal?.item as { id: string } | undefined;
    try {
      const payload = expertiseToApi(raw);
      if (!payload.label) {
        toast.error('Le titre de la spécialité est obligatoire.');
        throw new Error('label required');
      }
      if (item?.id) {
        await api.put(`/trainer/expertises/${item.id}`, payload);
        toast.success('Spécialité mise à jour.');
      } else {
        await api.post('/trainer/expertises', payload);
        toast.success('Spécialité créée.');
      }
      refetchExp();
      setModal(null);
    } catch (err) {
      if (String((err as Error).message) !== 'label required') {
        toast.error(getApiErrorMessage(err, 'Impossible d\'enregistrer la spécialité.'));
      }
      throw err;
    }
  };

  const openTrainerEdit = async (item: Formateur) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/trainer/trainers/${item.id}`);
      const detail = trainerDetailFromApi(row);
      if (Array.isArray(row.expertises)) {
        detail.expertise_ids = (row.expertises as Array<{ id: number }>).map(e => String(e.id)).join(',');
        const primary = (row.expertises as Array<{ id: number; is_primary?: number }>).find(e => e.is_primary);
        if (primary) detail.primary_expertise_id = String(primary.id);
      }
      if (Array.isArray(row.skills)) {
        detail.skill_ids = (row.skills as Array<{ id: number }>).map(s => String(s.id)).join(',');
      }
      if (Array.isArray(row.certifications)) {
        detail.certification_ids = (row.certifications as Array<{ id: number }>).map(c => String(c.id)).join(',');
      }
      setModal({ type: 'trainer', item: detail });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le formateur.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveTrainer = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Formateur | undefined;
    try {
      const payload = trainerToApi(raw);
      if (item?.id) {
        await api.put(`/trainer/trainers/${item.id}`, payload);
        toast.success('Formateur mis à jour.');
      } else {
        await api.post('/trainer/trainers', payload);
        toast.success('Formateur créé.');
      }
      refetchT();
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
        trainer: async () => { await api.delete(`/trainer/trainers/${deleteTarget.id}`); refetchT(); },
        expertise: async () => { await api.delete(`/trainer/expertises/${deleteTarget.id}`); refetchExp(); },
        skill: async () => { await api.delete(`/trainer/skills/${deleteTarget.id}`); refetchSk(); },
        city: async () => { await api.delete(`/trainer/cities/${deleteTarget.id}`); refetchCi(); },
        certification: async () => { await api.delete(`/trainer/certifications/${deleteTarget.id}`); refetchCert(); },
        language: async () => { await api.delete(`/trainer/languages/${deleteTarget.id}`); refetchLang(); },
        review: async () => { await api.delete(`/trainer/reviews/${deleteTarget.id}`); refetchRev(); },
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchArticles(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchCategories(); },
        blog_author: async () => { await api.delete(`/blog/authors/${deleteTarget.id}${SITE_QS}`); refetchAuthors(); },
        blog_tag: async () => { await api.delete(`/blog/tags/${deleteTarget.id}${SITE_QS}`); refetchTags(); },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<BookOpen className="w-5 h-5" />}
        title="Nexytal Trainer"
        description="Gérez les formateurs, les offres d'emploi et les référentiels"
        color={COLOR}
        tabGroups={tabGroups}
        activeGroup={activeGroup}
        onGroupChange={onGroupChange}
        activeTab={tab}
        onTabChange={setTab}
      />

      {loadingDetail && tab !== 'val_trainers' && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className={`flex-1 overflow-y-auto min-h-0 ${tab === 'val_trainers' ? 'flex flex-col px-6' : 'p-6'}`}>
        {tab === 'val_trainers' && (
          <TrainersValidationPanel mode="embedded" siteId={SITE_ID} accentColor={COLOR} />
        )}

        {tab === 'trainers' && (
          <DataTable<Formateur>
            data={trainers}
            accentColor={COLOR}
            addLabel="Nouveau formateur"
            onAdd={() => setModal({ type: 'trainer' })}
            onEdit={openTrainerEdit}
            onDelete={item => setDeleteTarget({ type: 'trainer', id: item.id, label: item.nomComplet })}
            searchKeys={['nomComplet', 'email', 'titre', 'expertise_display']}
            columns={[
              { key: 'nomComplet', label: 'Nom', render: t => <span className="font-medium text-foreground">{t.nomComplet}</span> },
              { key: 'titre', label: 'Titre', hidden: 'md' },
              {
                key: 'expertise_display',
                label: 'Spécialités',
                hidden: 'lg',
                render: t => String((t as Formateur & { expertise_display?: string }).expertise_display || '—'),
              },
              { key: 'tjm', label: 'TJM', hidden: 'lg' },
              {
                key: 'on_catalog',
                label: 'Site public',
                hidden: 'md',
                render: t => {
                  const onCatalog = (t as Formateur & { on_catalog?: boolean }).on_catalog;
                  return onCatalog
                    ? <span className="text-emerald-600 text-xs font-medium">Visible</span>
                    : <span className="text-amber-600 text-xs font-medium">Hors catalogue</span>;
                },
              },
              { key: 'statut', label: 'Statut', render: t => <StatusBadge statut={t.statut} /> },
            ]}
          />
        )}

        {tab === 'expertises' && (
          <ExpertisesCatalogPanel
            data={expertises as Record<string, unknown>[]}
            loading={expertisesLoading}
            accentColor={COLOR}
            onAdd={() => setModal({ type: 'expertise' })}
            onEdit={item => setModal({ type: 'expertise', item })}
            onDelete={item => setDeleteTarget({ type: 'expertise', id: String(item.id), label: String(item.label) })}
          />
        )}

        {tab === 'skills' && (
          <DataTable<any>
            data={skillsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle compétence"
            onAdd={() => setModal({ type: 'skill' })}
            onEdit={item => setModal({ type: 'skill', item })}
            onDelete={item => setDeleteTarget({ type: 'skill', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[{ key: 'name', label: 'Compétence', render: s => <span className="font-medium text-foreground">{String(s.name)}</span> }]}
          />
        )}

        {tab === 'cities' && (
          <DataTable<any>
            data={citiesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle ville"
            onAdd={() => setModal({ type: 'city' })}
            onEdit={item => setModal({ type: 'city', item })}
            onDelete={item => setDeleteTarget({ type: 'city', id: String(item.id), label: String(item.name) })}
            searchKeys={['name', 'region']}
            columns={[
              { key: 'name', label: 'Ville', render: c => String(c.name) },
              { key: 'region', label: 'Région', hidden: 'md' },
            ]}
          />
        )}

        {tab === 'certifications' && (
          <DataTable<any>
            data={certificationsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle certification"
            onAdd={() => setModal({ type: 'certification' })}
            onEdit={item => setModal({ type: 'certification', item })}
            onDelete={item => setDeleteTarget({ type: 'certification', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[{ key: 'name', label: 'Nom', render: c => String(c.name) }]}
          />
        )}

        {tab === 'languages' && (
          <DataTable<any>
            data={languagesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle langue"
            onAdd={() => setModal({ type: 'language' })}
            onEdit={item => setModal({ type: 'language', item })}
            onDelete={item => setDeleteTarget({ type: 'language', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Langue', render: l => <span className="font-medium text-foreground">{String(l.name)}</span> },
            ]}
          />
        )}

        {tab === 'reviews' && (
          <DataTable<any>
            data={reviewsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvel avis"
            onAdd={() => setModal({ type: 'review' })}
            onEdit={item => setModal({ type: 'review', item })}
            onDelete={item => setDeleteTarget({ type: 'review', id: String(item.id), label: String(item.author_name) })}
            searchKeys={['author_name', 'trainer_name']}
            columns={[
              { key: 'author_name', label: 'Auteur' },
              { key: 'trainer_name', label: 'Formateur', hidden: 'md' },
              { key: 'rating', label: 'Note' },
              { key: 'is_published', label: 'Publié', render: r => r.is_published ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'articles' && (
          <DataTable<BlogArticle>
            data={articles}
            accentColor={COLOR}
            addLabel="Nouvel article"
            onAdd={() => setModal({ type: 'article' })}
            onEdit={async (item) => {
              setLoadingDetail(true);
              try {
                const row = await fetchApiDetail<Record<string, unknown>>(`/blog/posts/${item.id}${SITE_QS}`);
                setModal({ type: 'article', item: blogPostDetailFromApi(row) });
              } catch (err) {
                toast.error(getApiErrorMessage(err, 'Impossible de charger l\'article.'));
              } finally {
                setLoadingDetail(false);
              }
            }}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<any>
            data={blogCategoriesData?.data ?? []}
            accentColor={COLOR}
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
            accentColor={COLOR}
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
            accentColor={COLOR}
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

      <FormModal open={modal?.type === 'trainer'} onClose={() => setModal(null)} onSave={saveTrainer} wide
        title={modal?.item ? 'Modifier le formateur' : 'Nouveau formateur'}
        fields={trainerFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'expertise'} onClose={() => setModal(null)} onSave={saveExpertise}
        title={modal?.item ? 'Modifier l\'expertise' : 'Nouvelle expertise'}
        fields={expertiseFields}
        initialData={modal?.item ? expertiseFromApi(modal.item as Record<string, unknown>) : undefined}
        accentColor={COLOR} wide />
      {(['skill', 'certification'] as const).map(type => (
        <FormModal key={type} open={modal?.type === type} onClose={() => setModal(null)} onSave={async (raw) => {
          const item = modal?.item as { id: string } | undefined;
          const path = `/trainer/${type === 'skill' ? 'skills' : 'certifications'}`;
          if (item) await api.put(`${path}/${item.id}`, raw);
          else await api.post(path, raw);
          toast.success('Enregistré');
          if (type === 'skill') refetchSk(); else refetchCert();
          setModal(null);
        }} title={type === 'skill' ? 'Compétence' : 'Certification'}
          fields={type === 'skill' ? skillFields : certificationFields}
          initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      ))}
      <FormModal open={modal?.type === 'city'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        if (item) await api.put(`/trainer/cities/${item.id}`, raw);
        else await api.post('/trainer/cities', raw);
        toast.success('Ville enregistrée'); refetchCi(); setModal(null);
      }} title="Ville" fields={cityFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'language'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const name = String(raw.name ?? '').trim();
        const payload = { name, code: String(raw.code ?? name.slice(0, 2).toLowerCase()) };
        if (item) await api.put(`/trainer/languages/${item.id}`, payload);
        else await api.post('/trainer/languages', payload);
        toast.success('Langue enregistrée'); refetchLang(); setModal(null);
      }} title="Langue" fields={languageFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'review'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = { ...raw, trainer_id: Number(raw.trainer_id), rating: Number(raw.rating), is_published: raw.is_published ? 1 : 0 };
        if (item) await api.put(`/trainer/reviews/${item.id}`, payload);
        else await api.post('/trainer/reviews', payload);
        toast.success('Avis enregistré'); refetchRev(); setModal(null);
      }} title="Avis formateur" fields={reviewFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as BlogArticle | undefined;
        await saveBlogArticle(raw, SITE_QS, item?.id);
        toast.success('Article enregistré'); refetchArticles(); setModal(null);
      }} title="Article" fields={articleFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} wide />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogCategoryToApi(raw);
        if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/categories${SITE_QS}`, payload);
        toast.success('Catégorie enregistrée'); refetchCategories(); setModal(null);
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_author'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogAuthorToApi(raw);
        if (item) await api.put(`/blog/authors/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/authors${SITE_QS}`, payload);
        toast.success('Auteur enregistré'); refetchAuthors(); setModal(null);
      }} title={modal?.item ? 'Modifier l\'auteur' : 'Nouvel auteur'} fields={authorFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_tag'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogTagToApi(raw);
        if (item) await api.put(`/blog/tags/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/tags${SITE_QS}`, payload);
        toast.success('Tag enregistré'); refetchTags(); setModal(null);
      }} title={modal?.item ? 'Modifier le tag' : 'Nouveau tag'} fields={tagFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
