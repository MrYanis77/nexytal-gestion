import { useState } from 'react';
import { useApp, Formation, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { GraduationCap } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';

const COLOR = '#7C3AED';

const FORMATION_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'cybersécurité', label: 'Cybersécurité' },
    { value: 'digital', label: 'Digital' },
    { value: 'RH', label: 'Ressources Humaines' },
    { value: 'management', label: 'Management' },
    { value: 'finance', label: 'Finance' },
    { value: 'santé', label: 'Santé' },
  ]},
  { key: 'niveau', label: 'Niveau', type: 'select', options: [
    { value: 'Débutant', label: 'Débutant' },
    { value: 'Intermédiaire', label: 'Intermédiaire' },
    { value: 'Avancé', label: 'Avancé' },
  ]},
  { key: 'duree', label: 'Durée', type: 'text', placeholder: 'ex. 5 jours' },
  { key: 'description', label: 'Description', type: 'textarea', span: true },
  { key: 'programme', label: 'Programme', type: 'textarea', span: true },
  { key: 'certifiante', label: 'Formation certifiante', type: 'switch' },
  { key: 'rncp', label: 'Code RNCP', type: 'text', placeholder: 'ex. RNCP36399' },
  { key: 'statut', label: 'Statut', type: 'select', options: [
    { value: 'publie', label: 'Publié' },
    { value: 'brouillon', label: 'Brouillon' },
  ]},
];

const ARTICLE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Formation', label: 'Formation' },
    { value: 'Certification', label: 'Certification' },
    { value: 'Actualités', label: 'Actualités' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [
    { value: 'publie', label: 'Publié' },
    { value: 'brouillon', label: 'Brouillon' },
  ]},
];

export default function SiteFormation() {
  const [tab, setTab] = useState('formations');
  const [modal, setModal] = useState<{ type: 'formation' | 'article'; item?: Formation | BlogArticle } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: formationsData, loading: loadingF, refetch: refetchF } = useFetch<{ data: Formation[] }>('/formation/courses');
  const { data: articlesData, loading: loadingA, refetch: refetchA } = useFetch<{ data: BlogArticle[] }>('/blog/posts?site=formation');

  const formations = formationsData?.data || [];
  const articles = articlesData?.data || [];

  // ─── Formations ───────────────────────────────────────────────────────────

  const saveFormation = async (raw: Record<string, unknown>) => {
    const item = modal?.item as Formation | undefined;
    try {
      if (item) {
        await api.put(`/formation/courses/${item.id}`, raw);
        toast.success('Formation mise à jour.');
      } else {
        await api.post('/formation/courses', raw);
        toast.success('Formation créée.');
      }
      refetchF();
    } catch (err) {
      toast.error('Erreur lors de la sauvegarde.');
    }
  };

  const deleteFormation = async (id: string) => {
    try {
      await api.delete(`/formation/courses/${id}`);
      toast.success('Formation supprimée.');
      refetchF();
    } catch (err) {
      toast.error('Erreur lors de la suppression.');
    }
  };

  // ─── Articles ─────────────────────────────────────────────────────────────

  const saveArticle = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      if (item) {
        await api.put(`/blog/posts/${item.id}`, raw);
        toast.success('Article mis à jour.');
      } else {
        await api.post('/blog/posts', { ...raw, site: 'formation' });
        toast.success('Article créé.');
      }
      refetchA();
    } catch (err) {
      toast.error('Erreur lors de la sauvegarde.');
    }
  };

  const deleteArticle = async (id: string) => {
    try {
      await api.delete(`/blog/posts/${id}`);
      toast.success('Article supprimé.');
      refetchA();
    } catch (err) {
      toast.error('Erreur lors de la suppression.');
    }
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<GraduationCap className="w-5 h-5" />}
        title="Alt Formation"
        description="Gestion des formations, certifications et articles du blog"
        color={COLOR}
        tabs={[
          { key: 'formations', label: 'Formations', count: formations.length },
          { key: 'articles', label: 'Blog', count: articles.length },
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
            searchKeys={['titre', 'categorie', 'niveau']}
            columns={[
              { key: 'titre', label: 'Titre', render: f => <span className="font-medium text-foreground">{f.titre}</span> },
              { key: 'categorie', label: 'Catégorie', render: f => (
                <span className="text-xs px-2 py-0.5 rounded-full" style={{ background: COLOR + '20', color: COLOR }}>{f.categorie}</span>
              ), hidden: 'sm' },
              { key: 'niveau', label: 'Niveau', hidden: 'md' },
              { key: 'duree', label: 'Durée', hidden: 'lg' },
              { key: 'certifiante', label: 'Certifiante', render: f => (
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
      </div>

      {/* Modals */}
      <FormModal
        open={modal?.type === 'formation'}
        onClose={() => setModal(null)}
        onSave={saveFormation}
        title={modal?.item ? 'Modifier la formation' : 'Nouvelle formation'}
        fields={FORMATION_FIELDS}
        initialData={modal?.item as unknown as Record<string, unknown>}
        accentColor={COLOR}
      />
      <FormModal
        open={modal?.type === 'article'}
        onClose={() => setModal(null)}
        onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={ARTICLE_FIELDS}
        initialData={modal?.item as unknown as Record<string, unknown>}
        accentColor={COLOR}
      />
      <ConfirmDelete
        open={!!deleteTarget}
        onClose={() => setDeleteTarget(null)}
        onConfirm={() => {
          if (!deleteTarget) return;
          if (deleteTarget.type === 'formation') deleteFormation(deleteTarget.id);
          else deleteArticle(deleteTarget.id);
          setDeleteTarget(null);
        }}
        label={deleteTarget?.label}
      />
    </div>
  );
}
