import { useMemo, useState } from 'react';
import { BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { saveBlogArticle } from '@/lib/blog-article-save';
import {
  blogPostDetailFromApi,
  blogCategoryToApi,
  blogAuthorToApi,
  blogTagToApi,
  coachFromApi,
  coachToApi,
  buildCoachFields,
  buildCoachingSpecialtyFields,
  buildCoachingCertificationFields,
  buildCoachingCityFields,
  buildCoachingLanguageFields,
  buildCoachingContactSlotFields,
  buildCoachingAppointmentSlotFields,
  buildCoachingContactRequestFields,
  buildCoachingDiagnosticRequestFields,
} from '@/lib/mappers';
import { useBlogAdmin } from '@/hooks/useBlogAdmin';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { CoachesValidationPanel } from '@/components/validation/CoachesValidationPanel';
import { Target } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#F59E0B'; // Amber
const SITE_ID = 6;

export default function SiteCoaching() {
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  // Coaches Data
  const { data: coachesData, refetch: refetchCoaches } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/coaches');
  
  // Reference Data
  const { data: specialtiesData, refetch: refetchSpec } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/specialties');
  const { data: certificationsData, refetch: refetchCert } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/certifications');
  const { data: citiesData, refetch: refetchCities } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/cities');
  const { data: languagesData, refetch: refetchLang } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/languages');
  const { data: contactSlotsData, refetch: refetchCS } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/contact-slots');
  const { data: apptSlotsData, refetch: refetchAS } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/appointment-slots');
  
  // Requests Data
  const { data: contactRequestsData, refetch: refetchCR } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/contact-requests');
  const { data: diagnosticRequestsData, refetch: refetchDR } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/diagnostic-requests');

  const { data: pendingCoachesData } = useFetch<{ data?: { count: number } }>(
    `/coaching/coaches/pending-count?site_id=${SITE_ID}`,
  );
  const pendingCoachesCount = pendingCoachesData?.data?.count ?? 0;

  // Blog Data
  const blog = useBlogAdmin(6);
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

  // Options for dropdowns
  const specialtyOptions = useMemo(() => (specialtiesData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.name) })), [specialtiesData]);
  const certificationOptions = useMemo(() => (certificationsData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })), [certificationsData]);
  const languageOptions = useMemo(() => (languagesData?.data ?? []).map(l => ({ value: String(l.id), label: `${l.flag_emoji || ''} ${l.name}`.trim() })), [languagesData]);
  const cityOptions = useMemo(() => (citiesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })), [citiesData]);
  const coachOptions = useMemo(() => (coachesData?.data ?? []).map(c => ({ value: String(c.id), label: `${c.first_name} ${c.last_name}` })), [coachesData]);

  const coaches = useMemo(() => (coachesData?.data ?? []).map(coachFromApi), [coachesData]);

  // Form Fields
  const coachFields = useMemo(() => buildCoachFields(specialtyOptions, certificationOptions, languageOptions, cityOptions), [specialtyOptions, certificationOptions, languageOptions, cityOptions]);
  const specialtyFields = useMemo(() => buildCoachingSpecialtyFields(), []);
  const certificationFields = useMemo(() => buildCoachingCertificationFields(), []);
  const cityFields = useMemo(() => buildCoachingCityFields(), []);
  const languageFields = useMemo(() => buildCoachingLanguageFields(), []);
  const contactSlotFields = useMemo(() => buildCoachingContactSlotFields(), []);
  const apptSlotFields = useMemo(() => buildCoachingAppointmentSlotFields(coachOptions), [coachOptions]);
  const contactRequestFields = useMemo(() => buildCoachingContactRequestFields(), []);
  const diagnosticRequestFields = useMemo(() => buildCoachingDiagnosticRequestFields(), []);

  const tabGroups = useMemo<TabGroup[]>(() => [
    {
      key: 'coachs',
      label: 'Coachs',
      tabs: [
        { key: 'coaches', label: 'Profils', count: coaches.length },
        { key: 'val_coaches', label: 'Profils à valider', count: pendingCoachesCount },
      ],
    },
    {
      key: 'demandes',
      label: 'Demandes',
      tabs: [
        { key: 'diagnostic_reqs', label: 'Diagnostics', count: diagnosticRequestsData?.data?.length ?? 0 },
        { key: 'contact_reqs', label: 'Contacts', count: contactRequestsData?.data?.length ?? 0 },
      ],
    },
    {
      key: 'referentiels',
      label: 'Référentiels',
      tabs: [
        { key: 'specialties', label: 'Spécialités', count: specialtiesData?.data?.length ?? 0 },
        { key: 'certifications', label: 'Certifications', count: certificationsData?.data?.length ?? 0 },
        { key: 'cities', label: 'Villes', count: citiesData?.data?.length ?? 0 },
        { key: 'languages', label: 'Langues', count: languagesData?.data?.length ?? 0 },
        { key: 'appt_slots', label: 'Créneaux RDV', count: apptSlotsData?.data?.length ?? 0 },
        { key: 'contact_slots', label: 'Créneaux Contact', count: contactSlotsData?.data?.length ?? 0 },
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
    coaches.length, pendingCoachesCount, diagnosticRequestsData, contactRequestsData, specialtiesData, certificationsData,
    citiesData, languagesData, apptSlotsData, contactSlotsData, articles.length, blogCategoriesData,
    authorsData, tagsData,
  ]);

  const { activeGroup, activeTab: tab, setActiveTab: setTab, onGroupChange } = useTabGroups(tabGroups, 'coachs', 'coaches');

  const openCoachEdit = async (item: Record<string, unknown>) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/coaching/coaches/${item.id}`);
      const mapped = coachFromApi(row);
      if (Array.isArray(row.specialties)) mapped.specialty_ids = (row.specialties as number[]).join(',');
      if (Array.isArray(row.certifications)) mapped.certification_ids = (row.certifications as number[]).join(',');
      if (Array.isArray(row.languages)) mapped.language_ids = (row.languages as number[]).join(',');
      setModal({ type: 'coach', item: mapped });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le coach.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveCoach = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Record<string, unknown> | undefined;
    try {
      const payload = coachToApi(raw);
      if (item?.id) {
        await api.put(`/coaching/coaches/${item.id}`, payload);
        toast.success('Coach mis à jour.');
      } else {
        await api.post('/coaching/coaches', payload);
        toast.success('Coach créé.');
      }
      refetchCoaches();
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
        coach: async () => { await api.delete(`/coaching/coaches/${deleteTarget.id}`); refetchCoaches(); },
        specialty: async () => { await api.delete(`/coaching/specialties/${deleteTarget.id}`); refetchSpec(); },
        certification: async () => { await api.delete(`/coaching/certifications/${deleteTarget.id}`); refetchCert(); },
        city: async () => { await api.delete(`/coaching/cities/${deleteTarget.id}`); refetchCities(); },
        language: async () => { await api.delete(`/coaching/languages/${deleteTarget.id}`); refetchLang(); },
        contact_slot: async () => { await api.delete(`/coaching/contact-slots/${deleteTarget.id}`); refetchCS(); },
        appt_slot: async () => { await api.delete(`/coaching/appointment-slots/${deleteTarget.id}`); refetchAS(); },
        contact_req: async () => { await api.delete(`/coaching/contact-requests/${deleteTarget.id}`); refetchCR(); },
        diagnostic_req: async () => { await api.delete(`/coaching/diagnostic-requests/${deleteTarget.id}`); refetchDR(); },
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchArticles(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchCategories(); },
        blog_author: async () => { await api.delete(`/blog/authors/${deleteTarget.id}${SITE_QS}`); refetchAuthors(); },
        blog_tag: async () => { await api.delete(`/blog/tags/${deleteTarget.id}${SITE_QS}`); refetchTags(); },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression'));
    }
    setDeleteTarget(null);
  };

  const saveGeneric = async (type: string, path: string, refetch: () => void, raw: Record<string, unknown>) => {
    const item = modal?.item as Record<string, unknown> | undefined;
    try {
      if (item?.id) await api.put(`${path}/${item.id}`, raw);
      else await api.post(path, raw);
      toast.success('Enregistré avec succès');
      refetch();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur'));
    }
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Target className="w-5 h-5" />}
        title="Nexytal Coaching"
        description="Gérez les coachs, les demandes et les actualités"
        color={COLOR}
        tabGroups={tabGroups}
        activeGroup={activeGroup}
        onGroupChange={onGroupChange}
        activeTab={tab}
        onTabChange={setTab}
      />

      {loadingDetail && tab !== 'val_coaches' && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className={`flex-1 overflow-y-auto min-h-0 ${tab === 'val_coaches' ? 'flex flex-col px-6' : 'p-6'}`}>
        {tab === 'val_coaches' && (
          <CoachesValidationPanel mode="embedded" siteId={SITE_ID} accentColor={COLOR} />
        )}

        {tab === 'coaches' && (
          <DataTable<any>
            data={coaches}
            accentColor={COLOR}
            addLabel="Nouveau coach"
            onAdd={() => setModal({ type: 'coach' })}
            onEdit={openCoachEdit}
            onDelete={item => setDeleteTarget({ type: 'coach', id: String(item.id), label: String(item.name) })}
            searchKeys={['name', 'email', 'title']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.name)}</span> },
              { key: 'title', label: 'Titre', hidden: 'md' },
              { key: 'location', label: 'Ville', hidden: 'lg' },
              { key: 'status', label: 'Statut', render: c => <StatusBadge statut={String(c.status)} /> },
            ]}
          />
        )}

        {tab === 'diagnostic_reqs' && (
          <DataTable<any>
            data={diagnosticRequestsData?.data ?? []}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'diagnostic_req', item })}
            onDelete={item => setDeleteTarget({ type: 'diagnostic_req', id: String(item.id), label: `${item.prenom} ${item.nom || ''}` })}
            searchKeys={['prenom', 'nom', 'email']}
            columns={[
              { key: 'name', label: 'Contact', render: r => `${String(r.prenom)} ${String(r.nom || '')}` },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'coach', label: 'Coach', render: r => r.coach_first_name ? `${r.coach_first_name} ${r.coach_last_name}` : '-' },
              { key: 'statut', label: 'Statut', render: r => <StatusBadge statut={String(r.statut)} /> },
            ]}
          />
        )}

        {tab === 'contact_reqs' && (
          <DataTable<any>
            data={contactRequestsData?.data ?? []}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'contact_req', item })}
            onDelete={item => setDeleteTarget({ type: 'contact_req', id: String(item.id), label: `${item.prenom} ${item.nom}` })}
            searchKeys={['prenom', 'nom', 'email']}
            columns={[
              { key: 'name', label: 'Contact', render: r => `${String(r.prenom)} ${String(r.nom)}` },
              { key: 'profil', label: 'Profil', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: r => <StatusBadge statut={String(r.statut)} /> },
            ]}
          />
        )}

        {tab === 'specialties' && (
          <DataTable<any>
            data={specialtiesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle spécialité"
            onAdd={() => setModal({ type: 'specialty' })}
            onEdit={item => setModal({ type: 'specialty', item })}
            onDelete={item => setDeleteTarget({ type: 'specialty', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[{ key: 'name', label: 'Spécialité', render: s => <span className="font-medium">{String(s.name)}</span> }]}
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
            columns={[{ key: 'name', label: 'Certification', render: c => <span className="font-medium">{String(c.name)}</span> }]}
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

        {tab === 'languages' && (
          <DataTable<any>
            data={languagesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle langue"
            onAdd={() => setModal({ type: 'language' })}
            onEdit={item => setModal({ type: 'language', item })}
            onDelete={item => setDeleteTarget({ type: 'language', id: String(item.id), label: String(item.name) })}
            searchKeys={['name', 'code']}
            columns={[
              { key: 'name', label: 'Langue', render: l => `${l.flag_emoji || ''} ${l.name}` },
              { key: 'code', label: 'Code', hidden: 'md' },
            ]}
          />
        )}

        {tab === 'contact_slots' && (
          <DataTable<any>
            data={contactSlotsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau créneau"
            onAdd={() => setModal({ type: 'contact_slot' })}
            onEdit={item => setModal({ type: 'contact_slot', item })}
            onDelete={item => setDeleteTarget({ type: 'contact_slot', id: String(item.id), label: String(item.label) })}
            searchKeys={['label']}
            columns={[{ key: 'label', label: 'Créneau', render: s => <span className="font-medium">{String(s.label)}</span> }]}
          />
        )}

        {tab === 'appt_slots' && (
          <DataTable<any>
            data={apptSlotsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau créneau RDV"
            onAdd={() => setModal({ type: 'appt_slot' })}
            onEdit={item => setModal({ type: 'appt_slot', item })}
            onDelete={item => setDeleteTarget({ type: 'appt_slot', id: String(item.id), label: `${item.slot_date} ${item.start_time}` })}
            searchKeys={['slot_date', 'coach_name']}
            columns={[
              { key: 'slot_date', label: 'Date', render: s => String(s.slot_date) },
              { key: 'start_time', label: 'Heure', render: s => String(s.start_time) },
              { key: 'coach_name', label: 'Coach' },
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

      <FormModal open={modal?.type === 'coach'} onClose={() => setModal(null)} onSave={saveCoach} wide
        title={modal?.item ? 'Modifier le coach' : 'Nouveau coach'}
        fields={coachFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'specialty'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('specialty', '/coaching/specialties', refetchSpec, { ...r, is_active: r.is_active ? 1 : 0 })}
        title="Spécialité" fields={specialtyFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'certification'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('certification', '/coaching/certifications', refetchCert, r)}
        title="Certification" fields={certificationFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'city'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('city', '/coaching/cities', refetchCities, { ...r, is_active: r.is_active ? 1 : 0 })}
        title="Ville" fields={cityFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'language'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('language', '/coaching/languages', refetchLang, r)}
        title="Langue" fields={languageFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'contact_slot'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('contact_slot', '/coaching/contact-slots', refetchCS, { ...r, is_active: r.is_active ? 1 : 0 })}
        title="Créneau Contact" fields={contactSlotFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'appt_slot'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('appt_slot', '/coaching/appointment-slots', refetchAS, { ...r, is_active: r.is_active ? 1 : 0 })}
        title="Créneau Rendez-vous" fields={apptSlotFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'diagnostic_req'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('diagnostic_req', '/coaching/diagnostic-requests', refetchDR, r)}
        title="Demande de Diagnostic" fields={diagnosticRequestFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

      <FormModal open={modal?.type === 'contact_req'} onClose={() => setModal(null)} onSave={(r) => saveGeneric('contact_req', '/coaching/contact-requests', refetchCR, r)}
        title="Demande de Contact" fields={contactRequestFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />

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
