import { useMemo, useState } from 'react';
import { BlogArticle, Formateur } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  buildBlogArticleFields,
  buildBlogCategoryFields,
  trainerFromApi,
  trainerToApi,
  trainerDetailFromApi,
  buildTrainerFields,
  buildExpertiseFields,
  expertiseToApi,
  buildTrainerApplicationFields,
  buildTrainerSkillFields,
  buildTrainerCityFields,
  buildTrainerCertificationFields,
  buildTrainerLanguageFields,
  buildTrainerReviewFields,
} from '@/lib/mappers';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { BookOpen } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#0891B2';
const SITE_QS = '?site_id=5';

export default function SiteTrainer() {
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const { data: trainersData, refetch: refetchT } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/trainers');
  const { data: applicationsData, refetch: refetchApp } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/applications');
  const { data: expertisesData, refetch: refetchExp } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/expertises');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/posts${SITE_QS}`);
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/categories${SITE_QS}`);
  const { data: skillsData, refetch: refetchSk } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/skills');
  const { data: citiesData, refetch: refetchCi } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/cities');
  const { data: certificationsData, refetch: refetchCert } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/certifications');
  const { data: languagesData, refetch: refetchLang } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/languages');
  const { data: reviewsData, refetch: refetchRev } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/reviews');

  const expertiseOptions = useMemo(
    () => (expertisesData?.data ?? []).map(e => ({ value: String(e.id), label: String(e.label) })),
    [expertisesData],
  );
  const skillOptions = useMemo(
    () => (skillsData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.name) })),
    [skillsData],
  );
  const certificationOptions = useMemo(
    () => (certificationsData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [certificationsData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [blogCategoriesData],
  );

  const trainers = useMemo(() => (trainersData?.data ?? []).map(trainerFromApi), [trainersData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const trainerFields = useMemo(
    () => buildTrainerFields(expertiseOptions, skillOptions, certificationOptions),
    [expertiseOptions, skillOptions, certificationOptions],
  );
  const expertiseFields = useMemo(() => buildExpertiseFields(), []);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);
  const applicationFields = useMemo(() => buildTrainerApplicationFields(), []);
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
        { key: 'applications', label: 'Candidatures', count: applicationsData?.data?.length ?? 0 },
        { key: 'reviews', label: 'Avis clients', count: reviewsData?.data?.length ?? 0 },
      ],
    },
    {
      key: 'referentiels',
      label: 'Référentiels',
      tabs: [
        { key: 'expertises', label: 'Spécialités', count: expertisesData?.data?.length ?? 0 },
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
      ],
    },
  ], [
    trainers.length, applicationsData, reviewsData, expertisesData, skillsData,
    citiesData, certificationsData, languagesData, articles.length, blogCategoriesData,
  ]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(tabGroups, 'formateurs', 'trainers');

  const openTrainerEdit = async (item: Formateur) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/trainer/trainers/${item.id}`);
      setModal({ type: 'trainer', item: trainerDetailFromApi(row) });
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
        application: async () => { await api.delete(`/trainer/applications/${deleteTarget.id}`); refetchApp(); },
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchA(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchBc(); },
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
        description="Gérez les formateurs, les référentiels et les articles du site"
        color={COLOR}
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
        {tab === 'trainers' && (
          <DataTable<Formateur>
            data={trainers}
            accentColor={COLOR}
            addLabel="Nouveau formateur"
            onAdd={() => setModal({ type: 'trainer' })}
            onEdit={openTrainerEdit}
            onDelete={item => setDeleteTarget({ type: 'trainer', id: item.id, label: item.nomComplet })}
            searchKeys={['nomComplet', 'email', 'titre']}
            columns={[
              { key: 'nomComplet', label: 'Nom', render: t => <span className="font-medium text-foreground">{t.nomComplet}</span> },
              { key: 'titre', label: 'Titre', hidden: 'md' },
              { key: 'tjm', label: 'TJM', hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: t => <StatusBadge statut={t.statut} /> },
            ]}
          />
        )}

        {tab === 'applications' && (
          <DataTable<Record<string, unknown>>
            data={applicationsData?.data ?? []}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'application', item })}
            onDelete={item => setDeleteTarget({ type: 'application', id: String(item.id), label: `${item.first_name} ${item.last_name}` })}
            searchKeys={['first_name', 'last_name', 'email']}
            columns={[
              { key: 'name', label: 'Candidat', render: a => `${String(a.first_name)} ${String(a.last_name)}` },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'status', label: 'Statut', render: a => <StatusBadge statut={String(a.status)} /> },
            ]}
          />
        )}

        {tab === 'expertises' && (
          <DataTable<Record<string, unknown>>
            data={expertisesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle spécialité"
            onAdd={() => setModal({ type: 'expertise' })}
            onEdit={item => setModal({ type: 'expertise', item })}
            onDelete={item => setDeleteTarget({ type: 'expertise', id: String(item.id), label: String(item.label) })}
            searchKeys={['label']}
            columns={[
              { key: 'label', label: 'Spécialité', render: e => <span className="font-medium text-foreground">{String(e.label)}</span> },
            ]}
          />
        )}

        {tab === 'skills' && (
          <DataTable<Record<string, unknown>>
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
          <DataTable<Record<string, unknown>>
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
          <DataTable<Record<string, unknown>>
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
          <DataTable<Record<string, unknown>>
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
          <DataTable<Record<string, unknown>>
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
            onEdit={item => setModal({ type: 'article', item })}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<Record<string, unknown>>
            data={blogCategoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[{ key: 'name', label: 'Nom', render: c => String(c.name) }]}
          />
        )}

      </div>

      <FormModal open={modal?.type === 'trainer'} onClose={() => setModal(null)} onSave={saveTrainer} wide
        title={modal?.item ? 'Modifier le formateur' : 'Nouveau formateur'}
        fields={trainerFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'expertise'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = expertiseToApi(raw);
        if (item) await api.put(`/trainer/expertises/${item.id}`, payload);
        else await api.post('/trainer/expertises', payload);
        toast.success('Expertise enregistrée'); refetchExp(); setModal(null);
      }} title="Spécialité" fields={expertiseFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
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
        const payload = { ...raw, is_active: raw.is_active ? 1 : 0 };
        if (item) await api.put(`/trainer/cities/${item.id}`, payload);
        else await api.post('/trainer/cities', payload);
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
      <FormModal open={modal?.type === 'application'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string };
        await api.put(`/trainer/applications/${item.id}`, raw);
        toast.success('Candidature mise à jour'); refetchApp(); setModal(null);
      }} title="Candidature formateur" fields={applicationFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as BlogArticle | undefined;
        const payload = blogPostToApi(raw);
        if (item) await api.put(`/blog/posts/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/posts${SITE_QS}`, payload);
        toast.success('Article enregistré'); refetchA(); setModal(null);
      }} title="Article" fields={articleFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, raw);
        else await api.post(`/blog/categories${SITE_QS}`, raw);
        toast.success('Catégorie enregistrée'); refetchBc(); setModal(null);
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
