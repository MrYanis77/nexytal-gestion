import { useMemo, useState } from 'react';
import { Formation, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  blogPostFromApi,
  blogPostToApi,
  buildBlogArticleFields,
  buildFormationFields,
  courseFromApi,
  courseToApi,
  buildCategoryFields,
  buildBlogCategoryFields
} from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { GraduationCap } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#7C3AED';

export default function SiteFormation() {
  const [tab, setTab] = useState('formations');
  const [modal, setModal] = useState<{ type: 'formation' | 'article' | 'formation_category' | 'blog_category'; item?: any } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: formationsData, refetch: refetchF } = useFetch<{ data: Record<string, unknown>[] }>('/formation/courses');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site=formation');
  const { data: categoriesData, refetch: refetchC } = useFetch<{ data: any[] }>('/formation/categories');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: any[] }>('/blog/categories?site=formation');

  const categoryOptions = useMemo(
    () => (categoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [categoriesData],
  );
  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const formations = useMemo(() => (formationsData?.data ?? []).map(courseFromApi), [formationsData]);
  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const formationFields = useMemo(() => buildFormationFields(categoryOptions), [categoryOptions]);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const categoryFields = useMemo(() => buildCategoryFields(), []);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);

  const saveFormation = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Formation | undefined;
    try {
      const payload = courseToApi(raw);
      if (item) {
        await api.put(`/formation/courses/${item.id}`, payload);
        toast.success('Formation mise à jour.');
      } else {
        await api.post('/formation/courses', payload);
        toast.success('Formation créée.');
      }
      refetchF();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts', { ...payload, site: 'formation' });
        toast.success('Article créé.');
      }
      refetchA();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveCategory = async (raw: Record<string, unknown>) => {
    const item = modal?.item;
    try {
      if (item) {
        await api.put(`/formation/categories/${item.id}`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/formation/categories', raw);
        toast.success('Catégorie créée.');
      }
      refetchC();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveBlogCategory = async (raw: Record<string, unknown>) => {
    const item = modal?.item;
    try {
      if (item) {
        await api.put(`/blog/categories/${item.id}`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories', { ...raw, site: 'formation' });
        toast.success('Catégorie créée.');
      }
      refetchBc();
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
        await api.delete(`/blog/posts/${deleteTarget.id}`);
        refetchA();
      } else if (deleteTarget.type === 'formation_category') {
        await api.delete(`/formation/categories/${deleteTarget.id}`);
        refetchC();
      } else if (deleteTarget.type === 'blog_category') {
        await api.delete(`/blog/categories/${deleteTarget.id}`);
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
        description="Gestion des formations et articles du blog"
        color={COLOR}
        tabs={[
          { key: 'formations', label: 'Formations', count: formations.length },
          { key: 'articles', label: 'Blog', count: articles.length },
          { key: 'formation_categories', label: 'Catégories Formation', count: categoriesData?.data?.length ?? 0 },
          { key: 'blog_categories', label: 'Catégories Blog', count: blogCategoriesData?.data?.length ?? 0 },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'formations' && (
          <DataTable<Formation>
            data={formations}
            accentColor={COLOR}
            addLabel="Nouvelle formation"
            onAdd={() => setModal({ type: 'formation' })}
            onEdit={item => setModal({ type: 'formation', item })}
            onDelete={item => setDeleteTarget({ type: 'formation', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie']}
            columns={[
              { key: 'titre', label: 'Titre', render: f => <span className="font-medium text-foreground">{f.titre}</span> },
              { key: 'categorie', label: 'Catégorie', render: f => (
                <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: COLOR + '20', color: COLOR }}>{f.categorie}</span>
              ), hidden: 'sm' },
              { key: 'duree', label: 'Durée', hidden: 'lg' },
              { key: 'certifiante', label: 'CPF', render: f => (
                <span className={`text-xs px-2 py-0.5 rounded-full ${f.certifiante ? 'bg-purple-500/15 text-purple-400' : 'bg-secondary text-muted-foreground'}`}>
                  {f.certifiante ? 'Oui' : 'Non'}
                </span>
              ), hidden: 'md' },
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

        {tab === 'formation_categories' && (
          <DataTable<any>
            data={categoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'formation_category' })}
            onEdit={item => setModal({ type: 'formation_category', item })}
            onDelete={item => setDeleteTarget({ type: 'formation_category', id: item.id, label: item.name })}
            searchKeys={['name', 'slug']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{c.name}</span> },
              { key: 'slug', label: 'Slug' },
              { key: 'is_active', label: 'Statut', render: c => <StatusBadge statut={c.is_active ? 'active' : 'inactive'} /> },
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
      </div>

      <FormModal
        open={modal?.type === 'formation'}
        onClose={() => setModal(null)}
        onSave={saveFormation}
        title={modal?.item ? 'Modifier la formation' : 'Nouvelle formation'}
        fields={formationFields}
        initialData={modal?.item as unknown as Record<string, unknown>}
        accentColor={COLOR}
      />
      <FormModal
        open={modal?.type === 'article'}
        onClose={() => setModal(null)}
        onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={articleFields}
        initialData={modal?.item as unknown as Record<string, unknown>}
        accentColor={COLOR}
      />
      <FormModal
        open={modal?.type === 'formation_category'}
        onClose={() => setModal(null)}
        onSave={saveCategory}
        title={modal?.item ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        fields={categoryFields}
        initialData={modal?.item as any}
        accentColor={COLOR}
      />
      <FormModal
        open={modal?.type === 'blog_category'}
        onClose={() => setModal(null)}
        onSave={saveBlogCategory}
        title={modal?.item ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        fields={blogCategoryFields}
        initialData={modal?.item as any}
        accentColor={COLOR}
      />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
