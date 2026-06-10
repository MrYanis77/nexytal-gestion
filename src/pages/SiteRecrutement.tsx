import { useMemo, useState } from 'react';
import { OffreEmploi, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  buildBlogArticleFields,
  buildOfferFieldsIT,
  offerFromApi,
  offerToApi,
  buildContractTypeFields,
  buildMetierFields,
  buildSectorFields,
  professionToApi
} from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { Briefcase } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#2563EB';
const SITE_ID = 2;

const RESSOURCE_FIELDS_BASE = [
  { key: 'titre', label: 'Titre', type: 'text' as const, required: true, span: true },
  { key: 'extrait', label: 'Description', type: 'textarea' as const, span: true },
  { key: 'contenu', label: 'Contenu', type: 'textarea' as const, span: true },
  { key: 'date', label: 'Date', type: 'date' as const },
  {
    key: 'statut',
    label: 'Statut',
    type: 'select' as const,
    options: [
      { value: 'publie', label: 'Publié' },
      { value: 'brouillon', label: 'Brouillon' },
    ],
  },
];

export default function SiteRecrutement() {
  const [tab, setTab] = useState('offres');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: offresData, refetch: refetchO } = useFetch<{ data: Record<string, unknown>[] }>('/recrutement/offers?site_id=2');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site_id=2');
  const { data: tagsData } = useFetch<{ data: { id: number; name: string }[] }>('/recrutement/tags?site_id=2');
  const { data: blogCategoriesData } = useFetch<{ data: { id: number; name: string }[] }>('/blog/categories?site_id=2');
  const { data: applicationsData, refetch: refetchApp } = useFetch<{ data: any[] }>('/recrutement/applications?site_id=2');
  const { data: professionsData, refetch: refetchProf } = useFetch<{ data: any[] }>('/recrutement/professions?site_id=2');
  const { data: contractTypesData, refetch: refetchCt } = useFetch<{ data: any[] }>('/recrutement/contract-types?site_id=2');
  const { data: sectorsData, refetch: refetchSect } = useFetch<{ data: any[] }>('/recrutement/sectors?site_id=2');

  const tagOptions = useMemo(
    () => (tagsData?.data ?? []).map(t => ({ value: String(t.id), label: t.name })),
    [tagsData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const offres = useMemo(() => (offresData?.data ?? []).map(offerFromApi), [offresData]);
  const ressources = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const offreFields = useMemo(() => buildOfferFieldsIT(tagOptions), [tagOptions]);
  const ressourceFields = useMemo(
    () => [...RESSOURCE_FIELDS_BASE.slice(0, 3), ...buildBlogArticleFields(blogCategoryOptions).slice(3)],
    [blogCategoryOptions],
  );
  const professionFields = useMemo(() => buildMetierFields(), []);
  const contractTypeFields = useMemo(() => buildContractTypeFields(), []);
  const sectorFields = useMemo(() => buildSectorFields(), []);
  const applicationFields = useMemo(() => [
    { key: 'status', label: 'Statut', type: 'select', options: [
      { value: 'new', label: 'Nouveau' },
      { value: 'reviewing', label: 'En revue' },
      { value: 'interview', label: 'Entretien' },
      { value: 'rejected', label: 'Refusé' },
      { value: 'hired', label: 'Embauché' }
    ]}
  ], []);

  const saveOffre = async (raw: Record<string, unknown>) => {
    const item = modal?.item as OffreEmploi | undefined;
    try {
      const payload = offerToApi(raw, SITE_ID);
      if (item) {
        await api.put(`/recrutement/offers/${item.id}?site_id=2`, payload);
        toast.success('Offre mise à jour.');
      } else {
        await api.post('/recrutement/offers?site_id=2', payload);
        toast.success('Offre créée.');
      }
      refetchO();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveRessource = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}?site_id=2`, payload);
        toast.success('Ressource mise à jour.');
      } else {
        await api.post('/blog/posts?site_id=2', payload);
        toast.success('Ressource créée.');
      }
      refetchA();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveProfession = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      const payload = professionToApi(raw);
      if (item) {
        await api.put(`/recrutement/professions/${item.id}?site_id=2`, payload);
        toast.success('Métier mis à jour.');
      } else {
        await api.post('/recrutement/professions?site_id=2', payload);
        toast.success('Métier créé.');
      }
      refetchProf();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveContractType = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/recrutement/contract-types/${item.id}?site_id=2`, raw);
        toast.success('Type mis à jour.');
      } else {
        await api.post('/recrutement/contract-types?site_id=2', raw);
        toast.success('Type créé.');
      }
      refetchCt();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveSector = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/recrutement/sectors/${item.id}?site_id=2`, raw);
        toast.success('Secteur mis à jour.');
      } else {
        await api.post('/recrutement/sectors?site_id=2', raw);
        toast.success('Secteur créé.');
      }
      refetchSect();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveApplication = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    if (!item) return;
    try {
      await api.put(`/recrutement/applications/${item.id}?site_id=2`, raw);
      toast.success('Statut mis à jour.');
      refetchApp();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      if (deleteTarget.type === 'offre') {
        await api.delete(`/recrutement/offers/${deleteTarget.id}?site_id=2`);
        refetchO();
      } else if (deleteTarget.type === 'ressource') {
        await api.delete(`/blog/posts/${deleteTarget.id}?site_id=2`);
        refetchA();
      } else if (deleteTarget.type === 'profession') {
        await api.delete(`/recrutement/professions/${deleteTarget.id}?site_id=2`);
        refetchProf();
      } else if (deleteTarget.type === 'contract_type') {
        await api.delete(`/recrutement/contract-types/${deleteTarget.id}?site_id=2`);
        refetchCt();
      } else if (deleteTarget.type === 'sector') {
        await api.delete(`/recrutement/sectors/${deleteTarget.id}?site_id=2`);
        refetchSect();
      } else if (deleteTarget.type === 'application') {
        await api.delete(`/recrutement/applications/${deleteTarget.id}?site_id=2`);
        refetchApp();
      }
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Briefcase className="w-5 h-5" />}
        title="Nexytal Recrutement"
        description="Gestion des offres IT et ressources blog"
        color={COLOR}
        tabs={[
          { key: 'offres', label: 'Offres IT', count: offres.length },
          { key: 'applications', label: 'Candidatures', count: applicationsData?.data?.length ?? 0 },
          { key: 'ressources', label: 'Ressources / Blog', count: ressources.length },
          { key: 'professions', label: 'Métiers', count: professionsData?.data?.length ?? 0 },
          { key: 'contract_types', label: 'Types de contrat', count: contractTypesData?.data?.length ?? 0 },
          { key: 'sectors', label: 'Secteurs', count: sectorsData?.data?.length ?? 0 },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'offres' && (
          <DataTable<OffreEmploi>
            data={offres}
            accentColor={COLOR}
            addLabel="Nouvelle offre IT"
            onAdd={() => setModal({ type: 'offre' })}
            onEdit={item => setModal({ type: 'offre', item })}
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
              { key: 'salaire', label: 'Salaire', hidden: 'lg' },
              { key: 'urgent', label: 'Urgent', render: o => o.urgent ? (
                <span className="text-xs px-2 py-0.5 rounded-full bg-red-500/15 text-red-400">Urgent</span>
              ) : <span className="text-muted-foreground text-xs">—</span>, hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: o => <StatusBadge statut={o.statut} /> },
            ]}
          />
        )}

        {tab === 'ressources' && (
          <DataTable<BlogArticle>
            data={ressources}
            accentColor={COLOR}
            addLabel="Nouvelle ressource"
            onAdd={() => setModal({ type: 'ressource' })}
            onEdit={item => setModal({ type: 'ressource', item })}
            onDelete={item => setDeleteTarget({ type: 'ressource', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie', 'auteur']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'categorie', label: 'Catégorie', hidden: 'sm' },
              { key: 'auteur', label: 'Auteur', hidden: 'md' },
              { key: 'date', label: 'Date', hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}
        {tab === 'applications' && (
          <DataTable<any>
            data={applicationsData?.data ?? []}
            accentColor={COLOR}
            onEdit={item => setModal({ type: 'application', item })}
            onDelete={item => setDeleteTarget({ type: 'application', id: item.id, label: `${item.first_name} ${item.last_name}` })}
            searchKeys={['first_name', 'last_name', 'email', 'offer_title']}
            columns={[
              { key: 'candidat', label: 'Candidat', render: c => (
                <div>
                  <p className="font-medium text-foreground">{c.first_name} {c.last_name}</p>
                  <p className="text-xs text-muted-foreground">{c.email}</p>
                </div>
              )},
              { key: 'offer_title', label: 'Offre' },
              { key: 'status', label: 'Statut', render: c => <StatusBadge statut={c.status} /> },
            ]}
          />
        )}
        {tab === 'professions' && (
          <DataTable<any>
            data={professionsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau métier"
            onAdd={() => setModal({ type: 'profession' })}
            onEdit={item => setModal({ type: 'profession', item })}
            onDelete={item => setDeleteTarget({ type: 'profession', id: item.id, label: item.name ?? item.nom })}
            searchKeys={['name', 'slug', 'nom']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name ?? c.nom}</span> },
              { key: 'slug', label: 'Slug' },
            ]}
          />
        )}
        {tab === 'contract_types' && (
          <DataTable<any>
            data={contractTypesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau type"
            onAdd={() => setModal({ type: 'contract_type' })}
            onEdit={item => setModal({ type: 'contract_type', item })}
            onDelete={item => setDeleteTarget({ type: 'contract_type', id: item.id, label: item.name })}
            searchKeys={['name', 'code']}
            columns={[
              { key: 'code', label: 'Code', render: c => <span className="font-medium text-foreground">{c.code}</span> },
              { key: 'name', label: 'Nom' },
            ]}
          />
        )}
        {tab === 'sectors' && (
          <DataTable<any>
            data={sectorsData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau secteur"
            onAdd={() => setModal({ type: 'sector' })}
            onEdit={item => setModal({ type: 'sector', item })}
            onDelete={item => setDeleteTarget({ type: 'sector', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
            ]}
          />
        )}
      </div>

      <FormModal open={modal?.type === 'offre'} onClose={() => setModal(null)} onSave={saveOffre}
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre IT'}
        fields={offreFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'ressource'} onClose={() => setModal(null)} onSave={saveRessource}
        title={modal?.item ? 'Modifier la ressource' : 'Nouvelle ressource'}
        fields={ressourceFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'application'} onClose={() => setModal(null)} onSave={saveApplication} title="Modifier le statut" fields={applicationFields as any} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'profession'} onClose={() => setModal(null)} onSave={saveProfession} title={modal?.item ? 'Modifier' : 'Nouveau'} fields={professionFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'contract_type'} onClose={() => setModal(null)} onSave={saveContractType} title={modal?.item ? 'Modifier' : 'Nouveau'} fields={contractTypeFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'sector'} onClose={() => setModal(null)} onSave={saveSector} title={modal?.item ? 'Modifier' : 'Nouveau'} fields={sectorFields} initialData={modal?.item as any} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
