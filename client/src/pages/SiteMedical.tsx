import { useState } from 'react';
import { useApp, OffreEmploi, Metier, BlogArticle } from '@/contexts/AppContext';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { Stethoscope } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';

const COLOR = '#059669';

const OFFRE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre du poste', type: 'text', required: true, span: true },
  { key: 'entreprise', label: 'Établissement', type: 'text', required: true },
  { key: 'lieu', label: 'Lieu', type: 'text' },
  { key: 'contrat', label: 'Type de contrat', type: 'select', options: [
    { value: 'CDI', label: 'CDI' }, { value: 'CDD', label: 'CDD' }, { value: 'Intérim', label: 'Intérim' }, { value: 'Stage', label: 'Stage' },
  ]},
  { key: 'secteur', label: 'Secteur', type: 'select', options: [
    { value: 'medecin', label: 'Médecin' }, { value: 'infirmier', label: 'Infirmier' }, { value: 'aide-soignant', label: 'Aide-soignant' },
    { value: 'pharmacien', label: 'Pharmacien' }, { value: 'kinesitherapeute', label: 'Kinésithérapeute' }, { value: 'auxiliaire-vie', label: 'Auxiliaire de vie' },
  ]},
  { key: 'salaire', label: 'Salaire', type: 'text', placeholder: 'ex. 3 000 – 4 000 €/mois' },
  { key: 'experience', label: 'Expérience requise', type: 'text', placeholder: 'ex. 2 ans minimum' },
  { key: 'description', label: 'Description', type: 'textarea', span: true },
  { key: 'urgent', label: 'Offre urgente', type: 'switch' },
  { key: 'date', label: 'Date de publication', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

const METIER_FIELDS: FieldDef[] = [
  { key: 'nom', label: 'Nom du métier', type: 'text', required: true },
  { key: 'slug', label: 'Slug URL', type: 'text', placeholder: 'ex. medecin-generaliste' },
  { key: 'secteur', label: 'Secteur', type: 'text' },
  { key: 'salaire', label: 'Fourchette salariale', type: 'text' },
  { key: 'description', label: 'Description', type: 'textarea', span: true },
  { key: 'debouches', label: 'Débouchés', type: 'textarea', span: true },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

const ARTICLE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Recrutement médical', label: 'Recrutement médical' }, { value: 'Intérim médical', label: 'Intérim médical' },
    { value: 'Carrière santé', label: 'Carrière santé' }, { value: 'IA & Santé', label: 'IA & Santé' },
    { value: 'Actualités', label: 'Actualités' }, { value: 'Gestion RH', label: 'Gestion RH' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

export default function SiteMedical() {
  const { data, setData } = useApp();
  const [tab, setTab] = useState('offres');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);

  const offres = data.offresEmploi;
  const metiers = data.metiers;
  const articles = data.articles.filter(a => a.site === 'medical');

  const saveOffre = (raw: Record<string, unknown>) => {
    const item = modal?.item as OffreEmploi | undefined;
    if (item) {
      setData(d => ({ ...d, offresEmploi: d.offresEmploi.map(o => o.id === item.id ? { ...o, ...raw } as OffreEmploi : o) }));
      toast.success('Offre mise à jour.');
    } else {
      setData(d => ({ ...d, offresEmploi: [...d.offresEmploi, { id: nanoid(8), site: 'medical', ...raw } as OffreEmploi] }));
      toast.success('Offre créée.');
    }
  };

  const saveMetier = (raw: Record<string, unknown>) => {
    const item = modal?.item as Metier | undefined;
    if (item) {
      setData(d => ({ ...d, metiers: d.metiers.map(m => m.id === item.id ? { ...m, ...raw } as Metier : m) }));
      toast.success('Métier mis à jour.');
    } else {
      setData(d => ({ ...d, metiers: [...d.metiers, { id: nanoid(8), ...raw } as Metier] }));
      toast.success('Métier créé.');
    }
  };

  const saveArticle = (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    if (item) {
      setData(d => ({ ...d, articles: d.articles.map(a => a.id === item.id ? { ...a, ...raw } as BlogArticle : a) }));
      toast.success('Article mis à jour.');
    } else {
      setData(d => ({ ...d, articles: [...d.articles, { id: nanoid(8), site: 'medical', ...raw } as BlogArticle] }));
      toast.success('Article créé.');
    }
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    if (deleteTarget.type === 'offre') setData(d => ({ ...d, offresEmploi: d.offresEmploi.filter(o => o.id !== deleteTarget.id) }));
    if (deleteTarget.type === 'metier') setData(d => ({ ...d, metiers: d.metiers.filter(m => m.id !== deleteTarget.id) }));
    if (deleteTarget.type === 'article') setData(d => ({ ...d, articles: d.articles.filter(a => a.id !== deleteTarget.id) }));
    toast.success('Élément supprimé.');
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Stethoscope className="w-5 h-5" />}
        title="Nexytal Medical"
        description="Gestion des offres d'emploi santé, métiers et articles"
        color={COLOR}
        tabs={[
          { key: 'offres', label: 'Offres d\'emploi', count: offres.length },
          { key: 'metiers', label: 'Métiers', count: metiers.length },
          { key: 'articles', label: 'Blog', count: articles.length },
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
            searchKeys={['titre', 'entreprise', 'lieu', 'secteur']}
            columns={[
              { key: 'titre', label: 'Poste', render: o => (
                <div>
                  <p className="font-medium text-foreground">{o.titre}</p>
                  <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                </div>
              )},
              { key: 'lieu', label: 'Lieu', hidden: 'sm' },
              { key: 'contrat', label: 'Contrat', render: o => (
                <span className="text-xs px-2 py-0.5 rounded-full bg-secondary text-muted-foreground">{o.contrat}</span>
              ), hidden: 'md' },
              { key: 'urgent', label: 'Urgent', render: o => o.urgent ? (
                <span className="text-xs px-2 py-0.5 rounded-full bg-red-500/15 text-red-400">Urgent</span>
              ) : <span className="text-muted-foreground text-xs">—</span>, hidden: 'lg' },
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
              { key: 'salaire', label: 'Salaire', hidden: 'md' },
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
      </div>

      <FormModal open={modal?.type === 'offre'} onClose={() => setModal(null)} onSave={saveOffre}
        title={modal?.item ? 'Modifier l\'offre' : 'Nouvelle offre d\'emploi'}
        fields={OFFRE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'metier'} onClose={() => setModal(null)} onSave={saveMetier}
        title={modal?.item ? 'Modifier le métier' : 'Nouveau métier'}
        fields={METIER_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={ARTICLE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
