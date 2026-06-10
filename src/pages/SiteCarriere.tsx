import { useState } from 'react';
import { useApp, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { TrendingUp } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';

const COLOR = '#D97706';

const ARTICLE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Reconversion', label: 'Reconversion' }, { value: 'Carrière', label: 'Carrière' },
    { value: 'Emploi', label: 'Emploi' }, { value: 'Conseils', label: 'Conseils' },
    { value: 'Formation', label: 'Formation' }, { value: 'Actualités', label: 'Actualités' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [
    { value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' },
  ]},
];

export default function SiteCarriere() {
  const { data, setData } = useApp();
  const [modal, setModal] = useState<{ item?: BlogArticle } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ id: string; label: string } | null>(null);

  const { data: articlesData, refetch } = useFetch<{ data: BlogArticle[] }>('/blog/posts?site=carriere');
  const articles = articlesData?.data || [];

  const publie = articles.filter(a => a.statut === 'publie').length;
  const brouillon = articles.filter(a => a.statut === 'brouillon').length;

  const saveArticle = async (raw: Record<string, unknown>) => {
    try {
      if (modal?.item) {
        await api.put(`/blog/posts/${modal.item.id}`, raw);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts', { ...raw, site: 'carriere' });
        toast.success('Article créé.');
      }
      refetch();
    } catch { toast.error('Erreur lors de la sauvegarde.'); }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await api.delete(`/blog/posts/${deleteTarget.id}`);
      toast.success('Article supprimé.');
      refetch();
    } catch { toast.error('Erreur lors de la suppression.'); }
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
        ]}
        activeTab="articles"
        onTabChange={() => {}}
      />

      <div className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* Stats */}
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
      </div>

      <FormModal open={modal !== null} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={ARTICLE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
