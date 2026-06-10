import { useState } from 'react';
import { useApp, OffreEmploi, BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { Briefcase } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';

const COLOR = '#2563EB';

const OFFRE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre du poste', type: 'text', required: true, span: true },
  { key: 'entreprise', label: 'Entreprise', type: 'text', required: true },
  { key: 'lieu', label: 'Lieu', type: 'text' },
  { key: 'contrat', label: 'Type de contrat', type: 'select', options: [
    { value: 'CDI', label: 'CDI' }, { value: 'CDD', label: 'CDD' }, { value: 'Freelance', label: 'Régie / Freelance' }, { value: 'Stage', label: 'Stage' },
  ]},
  { key: 'secteur', label: 'Spécialité IT', type: 'select', options: [
    { value: 'cyber', label: 'Cybersécurité' }, { value: 'devops', label: 'DevOps & Cloud' },
    { value: 'data', label: 'IA & Data' }, { value: 'dev', label: 'Développement' }, { value: 'infra', label: 'Infrastructures & Réseaux' },
  ]},
  { key: 'salaire', label: 'Salaire / TJM', type: 'text', placeholder: 'ex. 55 000 – 70 000 €/an' },
  { key: 'experience', label: 'Expérience requise', type: 'text', placeholder: 'ex. 3 ans' },
  { key: 'description', label: 'Description du poste', type: 'textarea', span: true },
  { key: 'urgent', label: 'Offre urgente', type: 'switch' },
  { key: 'date', label: 'Date de publication', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

const RESSOURCE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Description', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Cybersécurité', label: 'Cybersécurité' }, { value: 'Salaires & Marché', label: 'Salaires & Marché' },
    { value: 'Guides Recruteurs', label: 'Guides Recruteurs' }, { value: 'Conseils Candidats', label: 'Conseils Candidats' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

const SECTEUR_COLORS: Record<string, string> = {
  cyber: '#DC2626', devops: '#0891B2', data: '#7C3AED', dev: '#059669', infra: '#D97706',
};

export default function SiteRecrutement() {
  const { data, setData } = useApp();
  const [tab, setTab] = useState('offres');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const { data: offresData, refetch: refetchO } = useFetch<{ data: OffreEmploi[] }>('/recrutement/offers?site=recrutement');
  const { data: articlesData, refetch: refetchA } = useFetch<{ data: BlogArticle[] }>('/blog/posts?site=recrutement');

  const offres = offresData?.data || [];
  const ressources = articlesData?.data || [];

  const saveOffre = async (raw: Record<string, unknown>) => {
    const item = modal?.item as OffreEmploi | undefined;
    try {
      if (item) {
        await api.put(`/recrutement/offers/${item.id}`, raw);
        toast.success('Offre mise à jour.');
      } else {
        await api.post('/recrutement/offers', { ...raw, site: 'recrutement' });
        toast.success('Offre créée.');
      }
      refetchO();
    } catch { toast.error('Erreur lors de la sauvegarde.'); }
  };

  const saveRessource = async (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    try {
      if (item) {
        await api.put(`/blog/posts/${item.id}`, raw);
        toast.success('Ressource mise à jour.');
      } else {
        await api.post('/blog/posts', { ...raw, site: 'recrutement' });
        toast.success('Ressource créée.');
      }
      refetchA();
    } catch { toast.error('Erreur lors de la sauvegarde.'); }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      if (deleteTarget.type === 'offre') { await api.delete(`/recrutement/offers/${deleteTarget.id}`); refetchO(); }
      if (deleteTarget.type === 'ressource') { await api.delete(`/blog/posts/${deleteTarget.id}`); refetchA(); }
      toast.success('Élément supprimé.');
    } catch { toast.error('Erreur lors de la suppression.'); }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Briefcase className="w-5 h-5" />}
        title="Nexytal Recrutement"
        description="Gestion des offres IT, ressources et articles"
        color={COLOR}
        tabs={[
          { key: 'offres', label: 'Offres IT', count: offres.length },
          { key: 'ressources', label: 'Ressources / Blog', count: ressources.length },
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
            searchKeys={['titre', 'entreprise', 'lieu', 'secteur']}
            columns={[
              { key: 'titre', label: 'Poste', render: o => (
                <div>
                  <p className="font-medium text-foreground">{o.titre}</p>
                  <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                </div>
              )},
              { key: 'secteur', label: 'Spécialité', render: o => (
                <span className="text-xs px-2 py-0.5 rounded-full font-medium"
                  style={{ background: (SECTEUR_COLORS[o.secteur] ?? COLOR) + '20', color: SECTEUR_COLORS[o.secteur] ?? COLOR }}>
                  {o.secteur}
                </span>
              ), hidden: 'sm' },
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
      </div>

      <FormModal open={modal?.type === 'offre'} onClose={() => setModal(null)} onSave={saveOffre}
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre IT'}
        fields={OFFRE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'ressource'} onClose={() => setModal(null)} onSave={saveRessource}
        title={modal?.item ? 'Modifier la ressource' : 'Nouvelle ressource'}
        fields={RESSOURCE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
