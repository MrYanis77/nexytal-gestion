import { useState } from 'react';
import { useApp, Coach, Creneau, BlogArticle } from '@/contexts/AppContext';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete, FieldDef } from '@/components/FormModal';
import { Heart, Eye } from 'lucide-react';
import { toast } from 'sonner';
import { nanoid } from 'nanoid';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';

const COLOR = '#DC2626';

const COACH_FIELDS: FieldDef[] = [
  { key: 'nom', label: 'Nom complet', type: 'text', required: true },
  { key: 'titre', label: 'Titre / Certification', type: 'text' },
  { key: 'localisation', label: 'Ville', type: 'text' },
  { key: 'bio', label: 'Biographie', type: 'textarea', span: true },
  { key: 'visible', label: 'Visible sur le site', type: 'switch' },
  { key: 'ordre', label: 'Ordre d\'affichage', type: 'number' },
];

const CRENEAU_FIELDS: FieldDef[] = [
  { key: 'date', label: 'Date', type: 'date', required: true },
  { key: 'heure', label: 'Heure', type: 'text', placeholder: 'ex. 09:00' },
  { key: 'capacite', label: 'Capacité (places)', type: 'number' },
  { key: 'statut', label: 'Statut', type: 'select', options: [
    { value: 'disponible', label: 'Disponible' }, { value: 'reserve', label: 'Réservé' }, { value: 'annule', label: 'Annulé' },
  ]},
];

const ARTICLE_FIELDS: FieldDef[] = [
  { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
  { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
  { key: 'categorie', label: 'Catégorie', type: 'select', options: [
    { value: 'Leadership', label: 'Leadership' }, { value: 'Coaching', label: 'Coaching' },
    { value: 'Management', label: 'Management' }, { value: 'Méthode', label: 'Méthode' },
    { value: 'Équipe', label: 'Équipe' }, { value: 'Bien-être', label: 'Bien-être' },
  ]},
  { key: 'auteur', label: 'Auteur', type: 'text' },
  { key: 'date', label: 'Date', type: 'date' },
  { key: 'statut', label: 'Statut', type: 'select', options: [{ value: 'publie', label: 'Publié' }, { value: 'brouillon', label: 'Brouillon' }] },
];

export default function SiteCoaching() {
  const { data, setData } = useApp();
  const [tab, setTab] = useState('coachs');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [viewCreneau, setViewCreneau] = useState<Creneau | null>(null);

  const coachs = data.coachs;
  const creneaux = data.creneaux;
  const articles = data.articles.filter(a => a.site === 'coaching');

  const getCoachName = (id?: string) => coachs.find(c => c.id === id)?.nom ?? '—';

  const saveCoach = (raw: Record<string, unknown>) => {
    const item = modal?.item as Coach | undefined;
    if (item) {
      setData(d => ({ ...d, coachs: d.coachs.map(c => c.id === item.id ? { ...c, ...raw } as Coach : c) }));
      toast.success('Coach mis à jour.');
    } else {
      setData(d => ({ ...d, coachs: [...d.coachs, { id: nanoid(8), createdAt: new Date().toISOString().slice(0, 10), specialites: [], certifications: [], langues: [], ...raw } as unknown as Coach] }));
      toast.success('Coach créé.');
    }
  };

  const saveCreneau = (raw: Record<string, unknown>) => {
    const item = modal?.item as Creneau | undefined;
    if (item) {
      setData(d => ({ ...d, creneaux: d.creneaux.map(c => c.id === item.id ? { ...c, ...raw } as Creneau : c) }));
      toast.success('Créneau mis à jour.');
    } else {
      setData(d => ({ ...d, creneaux: [...d.creneaux, { id: nanoid(8), ...raw } as Creneau] }));
      toast.success('Créneau créé.');
    }
  };

  const saveArticle = (raw: Record<string, unknown>) => {
    const item = modal?.item as BlogArticle | undefined;
    if (item) {
      setData(d => ({ ...d, articles: d.articles.map(a => a.id === item.id ? { ...a, ...raw } as BlogArticle : a) }));
      toast.success('Article mis à jour.');
    } else {
      setData(d => ({ ...d, articles: [...d.articles, { id: nanoid(8), site: 'coaching', ...raw } as BlogArticle] }));
      toast.success('Article créé.');
    }
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    if (deleteTarget.type === 'coach') setData(d => ({ ...d, coachs: d.coachs.filter(c => c.id !== deleteTarget.id) }));
    if (deleteTarget.type === 'creneau') setData(d => ({ ...d, creneaux: d.creneaux.filter(c => c.id !== deleteTarget.id) }));
    if (deleteTarget.type === 'article') setData(d => ({ ...d, articles: d.articles.filter(a => a.id !== deleteTarget.id) }));
    toast.success('Élément supprimé.');
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<Heart className="w-5 h-5" />}
        title="Nexytal Coaching"
        description="Gestion des coachs, créneaux de diagnostic et articles"
        color={COLOR}
        tabs={[
          { key: 'coachs', label: 'Coachs', count: coachs.length },
          { key: 'creneaux', label: 'Créneaux', count: creneaux.length },
          { key: 'articles', label: 'Blog', count: articles.length },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'coachs' && (
          <DataTable<Coach>
            data={coachs}
            accentColor={COLOR}
            addLabel="Nouveau coach"
            onAdd={() => setModal({ type: 'coach' })}
            onEdit={item => setModal({ type: 'coach', item })}
            onDelete={item => setDeleteTarget({ type: 'coach', id: item.id, label: item.nom })}
            searchKeys={['nom', 'titre', 'localisation']}
            columns={[
              { key: 'nom', label: 'Coach', render: c => (
                <div>
                  <p className="font-medium text-foreground">{c.nom}</p>
                  <p className="text-xs text-muted-foreground">{c.titre}</p>
                </div>
              )},
              { key: 'localisation', label: 'Ville', hidden: 'sm' },
              { key: 'visible', label: 'Visible', render: c => (
                <span className={`text-xs px-2 py-0.5 rounded-full ${c.visible ? 'bg-green-500/15 text-green-400' : 'bg-secondary text-muted-foreground'}`}>
                  {c.visible ? 'Oui' : 'Non'}
                </span>
              ), hidden: 'md' },
              { key: 'ordre', label: 'Ordre', hidden: 'lg' },
            ]}
          />
        )}

        {tab === 'creneaux' && (
          <DataTable<Creneau>
            data={creneaux}
            accentColor={COLOR}
            addLabel="Nouveau créneau"
            onAdd={() => setModal({ type: 'creneau' })}
            onEdit={item => setModal({ type: 'creneau', item })}
            onDelete={item => setDeleteTarget({ type: 'creneau', id: item.id, label: `${item.date} ${item.heure}` })}
            onView={item => setViewCreneau(item)}
            searchKeys={['date', 'heure']}
            columns={[
              { key: 'date', label: 'Date', render: c => <span className="font-mono text-sm text-foreground">{c.date}</span> },
              { key: 'heure', label: 'Heure', render: c => <span className="font-mono text-sm text-foreground">{c.heure}</span> },
              { key: 'coach', label: 'Coach', render: c => <span className="text-muted-foreground text-sm">{getCoachName(c.coach)}</span>, hidden: 'sm' },
              { key: 'capacite', label: 'Places', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: c => <StatusBadge statut={c.statut} /> },
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
      <FormModal open={modal?.type === 'coach'} onClose={() => setModal(null)} onSave={saveCoach}
        title={modal?.item ? 'Modifier le coach' : 'Nouveau coach'}
        fields={COACH_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'creneau'} onClose={() => setModal(null)} onSave={saveCreneau}
        title={modal?.item ? 'Modifier le créneau' : 'Nouveau créneau'}
        fields={CRENEAU_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={saveArticle}
        title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'}
        fields={ARTICLE_FIELDS} initialData={modal?.item as unknown as Record<string, unknown>} accentColor={COLOR} />
      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />

      {/* View reservation */}
      <Dialog open={!!viewCreneau} onOpenChange={v => !v && setViewCreneau(null)}>
        <DialogContent className="max-w-sm bg-card border-border text-foreground">
          <DialogHeader>
            <DialogTitle style={{ fontFamily: 'Space Grotesk' }}>Détail du créneau</DialogTitle>
          </DialogHeader>
          {viewCreneau && (
            <div className="space-y-3 text-sm">
              <div className="grid grid-cols-2 gap-2">
                <div><p className="text-xs text-muted-foreground">Date</p><p className="font-mono">{viewCreneau.date}</p></div>
                <div><p className="text-xs text-muted-foreground">Heure</p><p className="font-mono">{viewCreneau.heure}</p></div>
                <div><p className="text-xs text-muted-foreground">Coach</p><p>{getCoachName(viewCreneau.coach)}</p></div>
                <div><p className="text-xs text-muted-foreground">Statut</p><StatusBadge statut={viewCreneau.statut} /></div>
              </div>
              {viewCreneau.reservation && (
                <div className="border border-border rounded-lg p-3 space-y-2 bg-secondary/50">
                  <p className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">Réservation</p>
                  <p><span className="text-muted-foreground">Nom :</span> {viewCreneau.reservation.prenom} {viewCreneau.reservation.nom}</p>
                  <p><span className="text-muted-foreground">Email :</span> {viewCreneau.reservation.email}</p>
                  <p><span className="text-muted-foreground">Tél :</span> {viewCreneau.reservation.telephone}</p>
                  <p><span className="text-muted-foreground">Profil :</span> {viewCreneau.reservation.profil}</p>
                </div>
              )}
              {!viewCreneau.reservation && <p className="text-muted-foreground text-xs italic">Aucune réservation pour ce créneau.</p>}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
