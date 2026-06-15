import { useMemo, useState } from 'react';
import { Formation, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  blogPostDetailFromApi,
  buildBlogArticleFields,
  buildFormationFields,
  courseFromApi,
  courseToApi,
  courseDetailFromApi,
  buildCategoryFields,
  buildBlogCategoryFields,
  categoryToApi,
} from '@/lib/mappers';
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

  const { data: formationsData, refetch: refetchF } = useFetch<{ data: Record<string, unknown>[] }>('/formation/courses');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site_id=1');
  const { data: categoriesData, refetch: refetchC } = useFetch<{ data: Record<string, unknown>[] }>('/formation/categories');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: Record<string, unknown>[] }>('/blog/categories?site_id=1');
  const SITE_QS = '?site_id=1';

  const formationCategoryOptions = useMemo(
    () => (categoriesData?.data ?? [])
      .filter(c => c.is_active !== 0 && c.is_active !== false)
      .map(c => ({ value: String(c.id), label: String(c.label ?? c.name ?? '') })),
    [categoriesData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name ?? '') })),
    [blogCategoriesData],
  );

  const formations = useMemo(() => (formationsData?.data ?? []).map(courseFromApi), [formationsData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const formationFields = useMemo(
    () => buildFormationFields(formationCategoryOptions),
    [formationCategoryOptions],
  );
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const categoryFields = useMemo(() => buildCategoryFields(), []);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);

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
      key: 'blog',
      label: 'Actualités',
      tabs: [
        { key: 'articles', label: 'Articles', count: articles.length },
        { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
      ],
    },
  ], [formations.length, articles.length, categoriesData, blogCategoriesData]);

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

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}?site_id=1`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts?site_id=1', payload);
        toast.success('Article créé.');
      }
      refetchA();
      setModal(null);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
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
      if (item) {
        await api.put(`/blog/categories/${item.id}?site_id=1`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories?site_id=1', raw);
        toast.success('Catégorie créée.');
      }
      refetchBc();
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
      } else if (deleteTarget.type === 'article') {
        await api.delete(`/blog/posts/${deleteTarget.id}?site_id=1`);
        refetchA();
      } else if (deleteTarget.type === 'formation_category') {
        await api.delete(`/formation/categories/${deleteTarget.id}`);
        refetchC();
      } else if (deleteTarget.type === 'blog_category') {
        await api.delete(`/blog/categories/${deleteTarget.id}?site_id=1`);
        refetchBc();
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
        icon={<GraduationCap className="w-5 h-5" />}
        title="Alt Formation"
        description="Gérez le catalogue de formations et les articles du site"
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
        {tab === 'formations' && (
          <DataTable<Formation>
            data={formations}
            accentColor={COLOR}
            addLabel="Nouvelle formation"
            onAdd={() => setModal({ type: 'formation' })}
            onEdit={openFormationEdit}
            onDelete={item => setDeleteTarget({ type: 'formation', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie']}
            columns={[
              { key: 'titre', label: 'Titre', render: f => <span className="font-medium text-foreground">{f.titre}</span> },
              { key: 'categorie', label: 'Catégorie', render: f => (
                <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: COLOR + '20', color: COLOR }}>{f.categorie}</span>
              ), hidden: 'sm' },
              { key: 'duree', label: 'Durée', hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: f => <StatusBadge statut={f.statut} /> },
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

        {tab === 'formation_categories' && (
          <DataTable<Record<string, unknown>>
            data={categoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouveau type"
            onAdd={() => setModal({ type: 'formation_category' })}
            onEdit={item => setModal({ type: 'formation_category', item })}
            onDelete={item => setDeleteTarget({ type: 'formation_category', id: String(item.id), label: String(item.label ?? item.name) })}
            searchKeys={['label']}
            columns={[
              { key: 'label', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.label ?? c.name ?? '')}</span> },
              { key: 'is_active', label: 'Visible', render: c => c.is_active ? 'Oui' : 'Non' },
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
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.name)}</span> },
              { key: 'is_active', label: 'Visible', render: c => c.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}
      </div>

      <FormModal open={modal?.type === 'formation'} onClose={() => setModal(null)} onSave={saveFormation} wide
        title={modal?.item ? 'Modifier la formation' : 'Nouvelle formation'}
        fields={formationFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle} wide
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={articleFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'formation_category'} onClose={() => setModal(null)} onSave={saveCategory}
        title={modal?.item ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        fields={categoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={saveBlogCategory}
        title={modal?.item ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
