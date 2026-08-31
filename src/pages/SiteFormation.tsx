import { useMemo, useState } from 'react';

import { Formation, BlogArticle } from '@/contexts/AppContext';

import { useFetch } from '@/hooks/useFetch';

import { api } from '@/lib/api';

import { getApiErrorMessage } from '@/lib/api-errors';

import { saveBlogArticle } from '@/lib/blog-article-save';

import {

  blogPostDetailFromApi,

  blogCategoryToApi,

  blogAuthorToApi,

  blogTagToApi,

  buildFormationFields,

  courseFromApi,

  courseToApi,

  courseDetailFromApi,

  FORMATION_COURSE_TYPE_OPTIONS,

  buildCategoryFields,

  categoryToApi,

  pricingFromApi,

  pricingToApi,

  buildPricingFields,

  careerOfferFromApi,

  careerOfferToApi,

  buildCareerOfferFields,

  careerApplicationFromApi,

  buildCareerApplicationFields,

  CAREER_APPLICATION_STATUS_OPTIONS,

  type PricingPlan,

  type CareerOffer,

  type CareerApplication,

} from '@/lib/mappers';

import { useBlogAdmin } from '@/hooks/useBlogAdmin';

import { useTabGroups } from '@/lib/use-tab-groups';

import type { TabGroup } from '@/components/SiteHeader';

import { fetchApiDetail } from '@/lib/detail-fetch';

import { SiteHeader } from '@/components/SiteHeader';

import { DataTable, StatusBadge } from '@/components/DataTable';

import { FormModal, ConfirmDelete } from '@/components/FormModal';

import { GraduationCap } from 'lucide-react';

import { toast } from 'sonner';



const COLOR = '#7C3AED';

export default function SiteFormation() {

  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);

  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const [loadingDetail, setLoadingDetail] = useState(false);

  const [categoryFilter, setCategoryFilter] = useState('');



  const { data: formationsData, refetch: refetchF } = useFetch<{ data: Record<string, unknown>[] }>('/formation/courses?limit=500');

  const { data: categoriesData, refetch: refetchC } = useFetch<{ data: Record<string, unknown>[] }>('/formation/categories');

  const { data: pricingData, refetch: refetchPricing } = useFetch<{ data: Record<string, unknown>[] }>('/formation/pricing');

  const { data: careerOffersData, refetch: refetchCareerOffers } = useFetch<{ data: Record<string, unknown>[] }>('/formation/career-offers');

  const { data: careerAppsData, refetch: refetchCareerApps } = useFetch<{ data: Record<string, unknown>[] }>('/formation/career-applications?limit=500');



  const blog = useBlogAdmin(1);

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



  const formationCategoryOptions = useMemo(

    () => (categoriesData?.data ?? [])

      .filter(c => c.is_active !== 0 && c.is_active !== false)

      .map(c => ({ value: String(c.id), label: String(c.label ?? c.name ?? '') })),

    [categoriesData],

  );

  const formations = useMemo(() => (formationsData?.data ?? []).map(courseFromApi), [formationsData]);

  const pricingPlans = useMemo(() => (pricingData?.data ?? []).map(pricingFromApi), [pricingData]);

  const careerOffers = useMemo(() => (careerOffersData?.data ?? []).map(careerOfferFromApi), [careerOffersData]);

  const careerApplications = useMemo(() => (careerAppsData?.data ?? []).map(careerApplicationFromApi), [careerAppsData]);



  const formationFields = useMemo(

    () => buildFormationFields(formationCategoryOptions),

    [formationCategoryOptions],

  );

  const categoryFields = useMemo(() => buildCategoryFields(), []);

  const pricingFields = useMemo(() => buildPricingFields(), []);

  const careerOfferFields = useMemo(() => buildCareerOfferFields(), []);

  const careerApplicationFields = useMemo(() => buildCareerApplicationFields(), []);



  const tabGroups = useMemo<TabGroup[]>(() => [

    {

      key: 'formations',

      label: 'Formations',

      tabs: [

        { key: 'formations', label: 'Catalogue', count: formations.length },

        { key: 'formation_categories', label: 'Types de formation', count: categoriesData?.data?.length ?? 0 },

      ],

    },

    {

      key: 'tarifs',

      label: 'Tarifs',

      tabs: [

        { key: 'pricing', label: 'Tarifs', count: pricingPlans.length },

      ],

    },

    {

      key: 'carrieres',

      label: 'Nous rejoindre',

      tabs: [

        { key: 'career_offers', label: 'Offres Alt RH', count: careerOffers.length },

        { key: 'career_applications', label: 'Candidatures', count: careerApplications.length },

      ],

    },

    {

      key: 'blog',

      label: 'Actualités',

      tabs: [

        { key: 'articles', label: 'Articles', count: articles.length },

        { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },

        { key: 'blog_authors', label: 'Auteurs', count: authorsData?.data?.length ?? 0 },

        { key: 'blog_tags', label: 'Tags', count: tagsData?.data?.length ?? 0 },

      ],

    },

  ], [

    formations.length, articles.length, categoriesData, blogCategoriesData, authorsData, tagsData,

    pricingPlans.length, careerOffers.length, careerApplications.length,

  ]);



  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(tabGroups, 'formations', 'formations');



  const openFormationEdit = async (item: Formation) => {

    setLoadingDetail(true);

    try {

      const row = await fetchApiDetail<Record<string, unknown>>(`/formation/courses/${item.id}`);

      setModal({ type: 'formation', item: courseDetailFromApi(row) });

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Impossible de charger la formation.'));

    } finally {

      setLoadingDetail(false);

    }

  };



  const saveFormation = async (raw: Record<string, unknown>) => {

    const item = modal?.item as Formation | undefined;

    try {

      const payload = courseToApi(raw);

      if (item?.id) {

        await api.put(`/formation/courses/${item.id}`, payload);

        toast.success('Formation mise à jour.');

      } else {

        await api.post('/formation/courses', payload);

        toast.success('Formation créée.');

      }

      refetchF();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

      throw err;

    }

  };



  const savePricing = async (raw: Record<string, unknown>) => {

    const item = modal?.item as PricingPlan | undefined;

    try {

      const payload = pricingToApi(raw);

      if (item?.id) {

        await api.put(`/formation/pricing/${item.id}`, payload);

        toast.success('Tarif mis à jour.');

      } else {

        await api.post('/formation/pricing', payload);

        toast.success('Tarif créé.');

      }

      refetchPricing();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

      throw err;

    }

  };



  const saveCareerOffer = async (raw: Record<string, unknown>) => {

    const item = modal?.item as CareerOffer | undefined;

    try {

      const payload = careerOfferToApi(raw);

      if (item?.id) {

        await api.put(`/formation/career-offers/${item.id}`, payload);

        toast.success('Offre mise à jour.');

      } else {

        await api.post('/formation/career-offers', payload);

        toast.success('Offre créée.');

      }

      refetchCareerOffers();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

      throw err;

    }

  };



  const saveCareerApplication = async (raw: Record<string, unknown>) => {

    const item = modal?.item as CareerApplication | undefined;

    if (!item?.id) return;

    try {

      await api.put(`/formation/career-applications/${item.id}`, { status: raw.statut });

      toast.success('Candidature mise à jour.');

      refetchCareerApps();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

      throw err;

    }

  };



  const saveArticle = async (raw: Record<string, unknown>) => {

    const item = modal?.item as BlogArticle | undefined;

    try {

      await saveBlogArticle(raw, SITE_QS, item?.id);

      toast.success(item ? 'Article mis à jour.' : 'Article créé.');

      refetchArticles();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

      throw err;

    }

  };



  const saveCategory = async (raw: Record<string, unknown>) => {

    const item = modal?.item as { id: string } | undefined;

    try {

      const payload = categoryToApi(raw);

      if (item) {

        await api.put(`/formation/categories/${item.id}`, payload);

        toast.success('Catégorie mise à jour.');

      } else {

        await api.post('/formation/categories', payload);

        toast.success('Catégorie créée.');

      }

      refetchC();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

    }

  };



  const saveBlogCategory = async (raw: Record<string, unknown>) => {

    const item = modal?.item as { id: string } | undefined;

    try {

      const payload = blogCategoryToApi(raw);

      if (item) {

        await api.put(`/blog/categories/${item.id}${SITE_QS}`, payload);

        toast.success('Catégorie mise à jour.');

      } else {

        await api.post(`/blog/categories${SITE_QS}`, payload);

        toast.success('Catégorie créée.');

      }

      refetchCategories();

      setModal(null);

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));

    }

  };



  const handleDelete = async () => {

    if (!deleteTarget) return;

    try {

      if (deleteTarget.type === 'formation') {

        await api.delete(`/formation/courses/${deleteTarget.id}`);

        refetchF();

      } else if (deleteTarget.type === 'pricing') {

        await api.delete(`/formation/pricing/${deleteTarget.id}`);

        refetchPricing();

      } else if (deleteTarget.type === 'career_offer') {

        await api.delete(`/formation/career-offers/${deleteTarget.id}`);

        refetchCareerOffers();

      } else if (deleteTarget.type === 'career_application') {

        await api.delete(`/formation/career-applications/${deleteTarget.id}`);

        refetchCareerApps();

      } else if (deleteTarget.type === 'article') {

        await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`);

        refetchArticles();

      } else if (deleteTarget.type === 'formation_category') {

        await api.delete(`/formation/categories/${deleteTarget.id}`);

        refetchC();

      } else if (deleteTarget.type === 'blog_category') {

        await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`);

        refetchCategories();

      } else if (deleteTarget.type === 'blog_author') {

        await api.delete(`/blog/authors/${deleteTarget.id}${SITE_QS}`);

        refetchAuthors();

      } else if (deleteTarget.type === 'blog_tag') {

        await api.delete(`/blog/tags/${deleteTarget.id}${SITE_QS}`);

        refetchTags();

      }

      toast.success('Élément supprimé.');

    } catch (err) {

      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));

    }

    setDeleteTarget(null);

  };



  const careerStatusLabel = (statut: string) => {
    const labels: Record<string, string> = {
      publie: 'Publiée',
      brouillon: 'Brouillon',
      archivee: 'Archivée',
      pourvue: 'Pourvue',
      expiree: 'Expirée',
      ferme: 'Archivée',
    };
    return labels[statut] ?? statut;
  };



  return (

    <div className="h-full flex flex-col fade-up min-h-0">

      <SiteHeader

        icon={<GraduationCap className="w-5 h-5" />}

        title="Alt Formation"

        description="Catalogue, tarifs bilan, offres Alt RH et actualités"

        color={COLOR}

        tabGroups={tabGroups}

        activeGroup={activeGroup}

        onGroupChange={onGroupChange}

        activeTab={tab}

        onTabChange={setTab}

      />



      <>

          {loadingDetail && (

            <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>

          )}



          <div className="flex-1 overflow-y-auto p-6">

            {tab === 'formations' && (

              <DataTable<Formation>

                data={formations}

                accentColor={COLOR}

                addLabel="Nouvelle formation"

                onAdd={() => setModal({
                  type: 'formation',
                  item: {
                    statut: 'brouillon',
                    course_type: 'diplomante',
                    sort_order: '0',
                    presentation_title: 'Le métier',
                    info_modalities_title: 'Modalités d\'apprentissage',
                    info_prerequisites_title: 'Public concerné & Prérequis',
                    pour_qui_title: 'Public',
                    evaluation_steps_title: 'Étapes d\'évaluation',
                    modules_list: [{ title: '', description: '', duration: '' }],
                  },
                })}

                onEdit={openFormationEdit}

                onDelete={item => setDeleteTarget({ type: 'formation', id: item.id, label: item.titre })}

                searchKeys={['titre', 'categorie', 'slug', 'course_type', 'reference_code']}

                selectFilter={{
                  value: categoryFilter,
                  onChange: setCategoryFilter,
                  filterKey: 'category_id',
                  allLabel: 'Toutes les catégories',
                  options: formationCategoryOptions,
                }}

                columns={[

                  { key: 'titre', label: 'Titre', render: f => <span className="font-medium text-foreground">{f.titre}</span> },

                  { key: 'categorie', label: 'Catégorie', render: f => (

                    <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: COLOR + '20', color: COLOR }}>{f.categorie}</span>

                  ), hidden: 'sm' },

                  { key: 'course_type', label: 'Type', render: f => {
                    const t = (f as Record<string, unknown>).course_type as string;
                    return FORMATION_COURSE_TYPE_OPTIONS.find(o => o.value === t)?.label ?? t;
                  }, hidden: 'md' },

                  { key: 'duree', label: 'Durée', hidden: 'lg' },

                  { key: 'sort_order', label: 'Ordre', hidden: 'xl' },

                  { key: 'statut', label: 'Statut', render: f => <StatusBadge statut={f.statut} /> },

                ]}

              />

            )}



            {tab === 'pricing' && (

              <DataTable<PricingPlan>

                data={pricingPlans}

                accentColor={COLOR}

                addLabel="Nouveau tarif"

                onAdd={() => setModal({ type: 'pricing', item: {} })}

                onEdit={item => setModal({ type: 'pricing', item })}

                onDelete={item => setDeleteTarget({ type: 'pricing', id: item.id, label: `${item.amount_eur.toLocaleString('fr-FR')} €` })}

                searchKeys={['amount_eur']}

                columns={[

                  { key: 'id', label: 'ID', hidden: 'sm' },

                  { key: 'amount_eur', label: 'Prix', render: p => `${p.amount_eur.toLocaleString('fr-FR')} €` },

                ]}

              />

            )}



            {tab === 'career_offers' && (

              <DataTable<CareerOffer>

                data={careerOffers}

                accentColor={COLOR}

                addLabel="Nouvelle offre"

                onAdd={() => setModal({
                  type: 'career_offer',
                  item: {
                    statut: 'brouillon',
                    department: 'collaborateur',
                    contract_type: 'cdi',
                    teletravail: 'non',
                    temps_travail: 'temps_plein',
                    salaire_afficher: false,
                    sort_order: 0,
                  },
                })}

                onEdit={item => setModal({ type: 'career_offer', item })}

                onDelete={item => setDeleteTarget({ type: 'career_offer', id: item.id, label: item.title })}

                searchKeys={['title', 'location', 'contract_type', 'reference', 'slug']}

                columns={[

                  { key: 'title', label: 'Poste', render: o => <span className="font-medium">{o.title}</span> },

                  { key: 'department', label: 'Département', render: o => o.department === 'formateur' ? 'Formateur' : 'Collaborateur', hidden: 'sm' },

                  { key: 'contract_type', label: 'Contrat', render: o => o.contract_type?.toUpperCase(), hidden: 'md' },

                  { key: 'location', label: 'Lieu', hidden: 'lg' },

                  { key: 'statut', label: 'Statut', render: o => careerStatusLabel(o.statut) },

                ]}

              />

            )}



            {tab === 'career_applications' && (

              <DataTable<CareerApplication>

                data={careerApplications}

                accentColor={COLOR}

                onEdit={item => setModal({ type: 'career_application', item })}

                onDelete={item => setDeleteTarget({

                  type: 'career_application',

                  id: item.id,

                  label: `${item.first_name} ${item.last_name}`,

                })}

                searchKeys={['first_name', 'last_name', 'email', 'offer_title']}

                columns={[

                  {

                    key: 'name',

                    label: 'Candidat',

                    render: a => <span className="font-medium">{a.first_name} {a.last_name}</span>,

                  },

                  { key: 'offer_title', label: 'Offre', hidden: 'sm' },

                  { key: 'application_type', label: 'Type', hidden: 'md' },

                  { key: 'email', label: 'Email', hidden: 'lg' },

                  {

                    key: 'statut',

                    label: 'Statut',

                    render: a => CAREER_APPLICATION_STATUS_OPTIONS.find(o => o.value === a.statut)?.label ?? a.statut,

                  },

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

                  } catch (e) {

                    toast.error(getApiErrorMessage(e, 'Erreur'));

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



            {tab === 'formation_categories' && (

              <DataTable<any>

                data={categoriesData?.data ?? []}

                accentColor={COLOR}

                addLabel="Nouveau type"

                onAdd={() => setModal({ type: 'formation_category' })}

                onEdit={item => setModal({ type: 'formation_category', item })}

                onDelete={item => setDeleteTarget({ type: 'formation_category', id: String(item.id), label: String(item.label ?? item.name) })}

                searchKeys={['label', 'name']}

                columns={[

                  { key: 'label', label: 'Type', render: c => <span className="font-medium">{String(c.label ?? c.name)}</span> },

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

      </>



      <FormModal open={modal?.type === 'formation'} onClose={() => setModal(null)} onSave={saveFormation} wide

        title={modal?.item ? 'Modifier la formation' : 'Nouvelle formation'}

        fields={formationFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'formation_category'} onClose={() => setModal(null)} onSave={saveCategory}

        title="Type de formation" fields={categoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'pricing'} onClose={() => setModal(null)} onSave={savePricing}

        title={modal?.item && (modal.item as PricingPlan).id ? 'Modifier le tarif' : 'Nouveau tarif'}

        fields={pricingFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'career_offer'} onClose={() => setModal(null)} onSave={saveCareerOffer} wide

        title={modal?.item && (modal.item as CareerOffer).id ? 'Modifier l\'offre' : 'Nouvelle offre interne'}

        fields={careerOfferFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'career_application'} onClose={() => setModal(null)} onSave={saveCareerApplication}

        title={`Candidature — ${(modal?.item as CareerApplication)?.first_name ?? ''} ${(modal?.item as CareerApplication)?.last_name ?? ''}`}

        fields={careerApplicationFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle} wide

        title="Article" fields={articleFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={saveBlogCategory}

        title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />



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


