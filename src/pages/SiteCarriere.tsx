import { useMemo, useState } from 'react';
import { BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { blogPostFromApi, blogPostToApi, buildBlogArticleFields, buildBlogCategoryFields } from '@/lib/mappers';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { TrendingUp } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#D97706';

export default function SiteCarriere() {
  const [modal, setModal] = useState<{ item?: BlogArticle } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; label: string } | null>(null);

  const { data: articlesData, refetch } = useFetch<{ data: Record<string, unknown>[] }>('/blog/posts?site_id=4');
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: any[] }>('/blog/categories?site_id=4');

  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: c.name })),
    [blogCategoriesData],
  );

  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);

  const publie = articles.filter(a => a.statut === 'publie').length;
  const brouillon = articles.filter(a => a.statut === 'brouillon').length;

  const saveArticle = async (raw: Record<string, unknown>) => {
    try {
      const payload = blogPostToApi(raw);
      if (modal?.item) {
        await api.put(`/blog/posts/${modal.item.id}?site_id=4`, payload);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts?site_id=4', payload);
        toast.success('Article créé.');
      }
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
    }
  };

  const saveBlogCategory = async (raw: Record<string, unknown>) => {
    const item = modal?.item as any;
    try {
      if (item) {
        await api.put(`/blog/categories/${item.id}?site_id=4`, raw);
        toast.success('Catégorie mise à jour.');
      } else {
        await api.post('/blog/categories?site_id=4', raw);
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
        await api.delete(`/blog/categories/${deleteTarget.id}?site_id=4`);
        toast.success('Catégorie supprimée.');
        refetchBc();
      } else {
        await api.delete(`/blog/posts/${deleteTarget.id}?site_id=4`);
        toast.success('Article supprimé.');
        refetch();
      }
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<TrendingUp className="w-5 h-5" />}
        title="Nexytal Carrière"
        description="Gestion des articles du blog carrière"
        color={COLOR}
        tabs={[
          { key: 'articles', label: 'Articles blog', count: articles.length },
          { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 }
        ]}
        activeTab={modal && typeof (modal as any).type === 'string' ? (modal as any).type === 'blog_category' ? 'blog_categories' : 'articles' : 'articles'}
        onTabChange={(k) => setModal(null)}
      />

      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        <div className="grid grid-cols-3 gap-3">
          {[
            { label: 'Total', value: articles.length, color: COLOR },
            { label: 'Publiés', value: publie, color: '#059669' },
            { label: 'Brouillons', value: brouillon, color: '#D97706' },
          ].map(s => (
            <div key={s.label} className="rounded-xl border border-border p-4 bg-card text-center">
              <p className="text-2xl font-bold" style={{ fontFamily: 'Space Grotesk', color: s.color }}>{s.value}</p>
              <p className="text-xs text-muted-foreground mt-1">{s.label}</p>
            </div>
          ))}
        </div>

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
            { key: 'categorie', label: 'Catégorie', render: a => (
              <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: COLOR + '20', color: COLOR }}>{a.categorie}</span>
            ), hidden: 'sm' },
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
