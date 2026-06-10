import { useMemo, useState } from 'react';
import { BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { blogPostFromApi, blogPostToApi, buildBlogArticleFields, buildBlogCategoryFields } from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { BookOpen } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#0891B2';

export default function SiteTrainer() {
  const [modal, setModal] = useState<{ item?: BlogArticle } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; label: string } | null>(null);

  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site_id=5');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: any[] }>('/blog/categories?site_id=5');

  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item;
    try {
      const payload = blogPostToApi(raw);
      if (item) {
        await api.put(`/blog/posts/${item.id}?site_id=5`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts?site_id=5', payload);
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
        await api.put(`/blog/categories/${item.id}?site_id=5`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories?site_id=5', raw);
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
      if ((deleteTarget as any).type === 'blog_category') {
        await api.delete(`/blog/categories/${deleteTarget.id}?site_id=5`);
        toast.success('Catégorie supprimée.');
        refetchBc();
      } else {
        await api.delete(`/blog/posts/${deleteTarget.id}?site_id=5`);
        toast.success('Article supprimé.');
        refetchA();
      }
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<BookOpen className="w-5 h-5" />}
        title="Nexytal Trainer"
        description="Articles du blog formateurs (pas de table formateurs en BDD v3)"
        color={COLOR}
        tabs={[
          { key: 'articles', label: 'Blog', count: articles.length },
          { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 }
        ]}
        activeTab={modal && typeof (modal as any).type === 'string' ? (modal as any).type === 'blog_category' ? 'blog_categories' : 'articles' : 'articles'}
        onTabChange={() => {}}
      />

      <div className="flex-1 overflow-y-auto p-6">
        <DataTable<BlogArticle>
          data={articles}
          accentColor={COLOR}
          addLabel="Nouvel article"
          onAdd={() => setModal({})}
          onEdit={item => setModal({ item })}
          onDelete={item => setDeleteTarget({ id: item.id, label: item.titre })}
          searchKeys={['titre', 'categorie', 'auteur']}
          columns={[
            { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
            { key: 'categorie', label: 'Catégorie', hidden: 'sm' },
            { key: 'auteur', label: 'Auteur', hidden: 'md' },
            { key: 'date', label: 'Date', hidden: 'lg' },
            { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
          ]}
        />

        <div className="mt-8">
          <DataTable<any>
            data={blogCategoriesData?.data ?? []}
            accentColor={COLOR}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' } as any)}
            onEdit={item => setModal({ type: 'blog_category', item } as any)}
            onDelete={item => setDeleteTarget({ id: item.id, label: item.name, type: 'blog_category' } as any)}
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
        </div>
      </div>

      <FormModal open={modal !== null && (modal as any).type !== 'blog_category'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={articleFields} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal !== null && (modal as any).type === 'blog_category'} onClose={() => setModal(null)} onSave={saveBlogCategory}
        title={modal?.item ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        fields={blogCategoryFields} initialData={modal?.item as any} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
