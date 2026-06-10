import { useState } from 'react';
import { useApp, Formateur, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { BookOpen } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';

const COLOR = '#0891B2';

const FORMATEUR_FIELDS: FieldDef[] = [
  { key: 'nom', label: 'Nom complet', type: 'text', required: true },
  { key: 'email', label: 'Email', type: 'email' },
  { key: 'region', label: 'Région', type: 'select', options: [
    { value: 'Île-de-France', label: 'Île-de-France' }, { value: 'Auvergne-Rhône-Alpes', label: 'Auvergne-Rhône-Alpes' },
    { value: 'Nouvelle-Aquitaine', label: 'Nouvelle-Aquitaine' }, { value: 'Occitanie', label: 'Occitanie' },
    { value: 'Hauts-de-France', label: 'Hauts-de-France' }, { value: 'PACA', label: 'PACA' },
    { value: 'Grand Est', label: 'Grand Est' }, { value: 'Bretagne', label: 'Bretagne' },
  ]},
  { key: 'tjm', label: 'TJM', type: 'text', placeholder: 'ex. 750 €' },
  { key: 'bio', label: 'Biographie', type: 'textarea', span: true },
  { key: 'disponibilite', label: 'Disponible', type: 'switch' },
  { key: 'statut', label: 'Statut', type: 'select', options: [
    { value: 'actif', label: 'Actif' }, { value: 'inactif', label: 'Inactif' },
  ]},
];

const ARTICLE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Formation', label: 'Formation' }, { value: 'IA', label: 'IA' },
    { value: 'Cybersécurité', label: 'Cybersécurité' }, { value: 'Cloud', label: 'Cloud' },
    { value: 'Management', label: 'Management' }, { value: 'RH', label: 'RH' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

export default function SiteTrainer() {
  const { data, setData } = useApp();
  const [tab, setTab] = useState('formateurs');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: formateursData, refetch: refetchF } = useFetch<{ data: Formateur[] }>('/formation/trainers');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: BlogArticle[] }>('/blog/posts?site=trainer');

  const formateurs = formateursData?.data || [];
  const articles = articlesData?.data || [];

  const saveFormateur = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Formateur | undefined;
    try {
      if (item) {
        await api.put(`/formation/trainers/${item.id}`, raw);
        toast.success('Formateur mis à jour.');
      } else {
        await api.post('/formation/trainers', raw);
        toast.success('Formateur créé.');
      }
      refetchF();
    } catch { toast.error('Erreur lors de la sauvegarde.'); }
  };

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      if (item) {
        await api.put(`/blog/posts/${item.id}`, raw);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts', { ...raw, site: 'trainer' });
        toast.success('Article créé.');
      }
      refetchA();
    } catch { toast.error('Erreur lors de la sauvegarde.'); }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      if (deleteTarget.type === 'formateur') { await api.delete(`/formation/trainers/${deleteTarget.id}`); refetchF(); }
      if (deleteTarget.type === 'article') { await api.delete(`/blog/posts/${deleteTarget.id}`); refetchA(); }
      toast.success('Élément supprimé.');
    } catch { toast.error('Erreur lors de la suppression.'); }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<BookOpen className="w-5 h-5" />}
        title="Nexytal Trainer"
        description="Gestion des formateurs et articles du blog"
        color={COLOR}
        tabs={[
          { key: 'formateurs', label: 'Formateurs', count: formateurs.length },
          { key: 'articles', label: 'Blog', count: articles.length },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'formateurs' && (
          <DataTable<Formateur>
            data={formateurs}
            accentColor={COLOR}
            addLabel="Nouveau formateur"
            onAdd={() => setModal({ type: 'formateur' })}
            onEdit={item => setModal({ type: 'formateur', item })}
            onDelete={item => setDeleteTarget({ type: 'formateur', id: item.id, label: item.nom })}
            searchKeys={['nom', 'email', 'region']}
            columns={[
              { key: 'nom', label: 'Formateur', render: f => (
                <div>
                  <p className="font-medium text-foreground">{f.nom}</p>
                  <p className="text-xs text-muted-foreground">{f.email}</p>
                </div>
              )},
              { key: 'region', label: 'Région', hidden: 'sm' },
              { key: 'tjm', label: 'TJM', hidden: 'md' },
              { key: 'disponibilite', label: 'Dispo', render: f => (
                <span className={`text-xs px-2 py-0.5 rounded-full ${f.disponibilite ? 'bg-green-500/15 text-green-400' : 'bg-secondary text-muted-foreground'}`}>
                  {f.disponibilite ? 'Oui' : 'Non'}
                </span>
              ), hidden: 'lg' },
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
      </div>

      <FormModal open={modal?.type === 'formateur'} onClose={() => setModal(null)} onSave={saveFormateur}
        title={modal?.item ? 'Modifier le formateur' : 'Nouveau formateur'}
        fields={FORMATEUR_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={ARTICLE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
