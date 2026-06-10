import { useMemo, useState } from 'react';
import { OffreEmploi, Metier, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  buildBlogArticleFields,
  buildMetierFields,
  buildOfferFieldsMedical,
  offerFromApi,
  offerToApi,
  professionFromApi,
  professionToApi,
  buildContractTypeFields,
  buildSectorFields,
  buildBlogCategoryFields
} from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { Stethoscope } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#059669';
const SITE_ID = 3;

export default function SiteMedical() {
  const [tab, setTab] = useState('offres');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: offresData, refetch: refetchO } = useFetch<{ data: Record<string, unknown>[] }>('/recrutement/offers?site_id=3');
  const { data: metiersData, refetch: refetchM } = useFetch<{ data: Record<string, unknown>[] }>('/recrutement/professions?site_id=3');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site_id=3');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: any[] }>('/blog/categories?site_id=3');
  const { data: contractTypesData, refetch: refetchCt } = useFetch<{ data: any[] }>('/recrutement/contract-types?site_id=3');
  const { data: sectorsData, refetch: refetchSect } = useFetch<{ data: any[] }>('/recrutement/sectors?site_id=3');
  const { data: applicationsData, refetch: refetchApp } = useFetch<{ data: any[] }>('/recrutement/applications?site_id=3');

  const professionOptions = useMemo(
    () => (metiersData?.data ?? []).map(p => ({ value: String(p.id), label: String(p.name) })),
    [metiersData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const offres = useMemo(() => (offresData?.data ?? []).map(offerFromApi), [offresData]);
  const metiers = useMemo(() => (metiersData?.data ?? []).map(professionFromApi), [metiersData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const offreFields = useMemo(() => buildOfferFieldsMedical(professionOptions), [professionOptions]);
  const metierFields = useMemo(() => buildMetierFields(), []);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);
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
        await api.put(`/recrutement/offers/${item.id}?site_id=3`, payload);
        toast.success('Offre mise à jour.');
      } else {
        await api.post('/recrutement/offers?site_id=3', payload);
        toast.success('Offre créée.');
      }
      refetchO();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveMetier = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Metier | undefined;
    try {
      const payload = professionToApi(raw);
      if (item) {
        await api.put(`/recrutement/professions/${item.id}?site_id=3`, payload);
        toast.success('Métier mis à jour.');
      } else {
        await api.post('/recrutement/professions?site_id=3', payload);
        toast.success('Métier créé.');
      }
      refetchM();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}?site_id=3`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts?site_id=3', payload);
        toast.success('Article créé.');
      }
      refetchA();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveBlogCategory = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/blog/categories/${item.id}?site_id=3`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories?site_id=3', raw);
        toast.success('Catégorie créée.');
      }
      refetchBc();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveContractType = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/recrutement/contract-types/${item.id}?site_id=3`, raw);
        toast.success('Type mis à jour.');
      } else {
        await api.post('/recrutement/contract-types?site_id=3', raw);
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
        await api.put(`/recrutement/sectors/${item.id}?site_id=3`, raw);
        toast.success('Secteur mis à jour.');
      } else {
        await api.post('/recrutement/sectors?site_id=3', raw);
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
      await api.put(`/recrutement/applications/${item.id}?site_id=3`, raw);
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
        await api.delete(`/recrutement/offers/${deleteTarget.id}?site_id=3`);
        refetchO();
      } else if (deleteTarget.type === 'metier') {
        await api.delete(`/recrutement/professions/${deleteTarget.id}?site_id=3`);
        refetchM();
      } else if (deleteTarget.type === 'article') {
        await api.delete(`/blog/posts/${deleteTarget.id}?site_id=3`);
        refetchA();
      } else if (deleteTarget.type === 'blog_category') {
        await api.delete(`/blog/categories/${deleteTarget.id}?site_id=3`);
        refetchBc();
      } else if (deleteTarget.type === 'contract_type') {
        await api.delete(`/recrutement/contract-types/${deleteTarget.id}?site_id=3`);
        refetchCt();
      } else if (deleteTarget.type === 'sector') {
        await api.delete(`/recrutement/sectors/${deleteTarget.id}?site_id=3`);
        refetchSect();
      } else if (deleteTarget.type === 'application') {
        await api.delete(`/recrutement/applications/${deleteTarget.id}?site_id=3`);
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
        icon={<Stethoscope className="w-5 h-5" />}
        title="Nexytal Medical"
        description="Offres médicales, pages métiers et blog"
        color={COLOR}
        tabs={[
          { key: 'offres', label: 'Offres', count: offres.length },
          { key: 'applications', label: 'Candidatures', count: applicationsData?.data?.length ?? 0 },
          { key: 'metiers', label: 'Métiers', count: metiers.length },
          { key: 'articles', label: 'Blog', count: articles.length },
          { key: 'blog_categories', label: 'Catégories Blog', count: blogCategoriesData?.data?.length ?? 0 },
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
            addLabel="Nouvelle offre"
            onAdd={() => setModal({ type: 'offre' })}
            onEdit={item => setModal({ type: 'offre', item })}
            onDelete={item => setDeleteTarget({ type: 'offre', id: item.id, label: item.titre })}
            searchKeys={['titre', 'entreprise', 'lieu']}
            columns={[
              { key: 'titre', label: 'Poste', render: o => (
                <div>
                  <p className="font-medium text-foreground">{o.titre}</p>
                  <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                </div>
              )},
              { key: 'secteur', label: 'Métier', hidden: 'sm' },
              { key: 'contrat', label: 'Contrat', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: o => <StatusBadge statut={o.statut} /> },
            ]}
          />
        )}

        {tab === 'metiers' && (
          <DataTable<Metier>
            data={metiers}
            accentColor={COLOR}
            addLabel="Nouveau métier"
            onAdd={() => setModal({ type: 'metier' })}
            onEdit={item => setModal({ type: 'metier', item })}
            onDelete={item => setDeleteTarget({ type: 'metier', id: item.id, label: item.nom })}
            searchKeys={['nom', 'secteur']}
            columns={[
              { key: 'nom', label: 'Métier', render: m => <span className="font-medium text-foreground">{m.nom}</span> },
              { key: 'secteur', label: 'Secteur', hidden: 'sm' },
              { key: 'statut', label: 'Statut', render: m => <StatusBadge statut={m.statut} /> },
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
        {tab === 'blog_categories' && (
          <DataTable<any>
            data={blogCategoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
              { key: 'color', label: 'Couleur', render: c => (
                c.color ? <div className="flex items-center gap-2"><div className="w-4 h-4 rounded-full" style={{ background: c.color }} />{c.color}</div> : '-'
              ) },
              { key: 'is_active', label: 'Statut', render: c => <StatusBadge statut={c.is_active ? 'active' : 'inactive'} /> },
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
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre médicale'}
        fields={offreFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'metier'} onClose={() => setModal(null)} onSave={saveMetier}
        title={modal?.item ? 'Modifier le métier' : 'Nouveau métier'}
        fields={metierFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={articleFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'application'} onClose={() => setModal(null)} onSave={saveApplication} title="Modifier le statut" fields={applicationFields as any} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={saveBlogCategory} title={modal?.item ? 'Modifier' : 'Nouvelle catégorie'} fields={blogCategoryFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'contract_type'} onClose={() => setModal(null)} onSave={saveContractType} title={modal?.item ? 'Modifier' : 'Nouveau'} fields={contractTypeFields} initialData={modal?.item as any} accentColor={COLOR} />
      <FormModal open={modal?.type === 'sector'} onClose={() => setModal(null)} onSave={saveSector} title={modal?.item ? 'Modifier' : 'Nouveau'} fields={sectorFields} initialData={modal?.item as any} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
