import { useState } from 'react';
import { useApp, defaultData } from '@/contexts/AppContext';
import { Button } from '@/components/ui/button';
import { Settings, RotateCcw, Download, Upload, AlertTriangle } from 'lucide-react';
import { toast } from 'sonner';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';

export default function SettingsPage() {
  const { data, setData, currentUser } = useApp();
  const [confirmReset, setConfirmReset] = useState(false);

  const exportData = () => {
    const json = JSON.stringify(data, null, 2);
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `nexytal-data-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    toast.success('Données exportées avec succès.');
  };

  const importData = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (ev) => {
        try {
          const parsed = JSON.parse(ev.target?.result as string);
          setData(parsed);
          toast.success('Données importées avec succès.');
        } catch {
          toast.error('Fichier JSON invalide.');
        }
      };
      reader.readAsText(file);
    };
    input.click();
  };

  const resetData = () => {
    setData(defaultData);
    localStorage.removeItem('nexytal_data');
    toast.success('Données réinitialisées aux valeurs par défaut.');
    setConfirmReset(false);
  };

  const totalItems =
    data.formations.length + data.offresEmploi.length + data.metiers.length +
    data.offresIT.length + data.articles.length + data.coachs.length +
    data.creneaux.length + data.formateurs.length;

  return (
    <div className="p-6 space-y-6 fade-up">
      {/* Header */}
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#6B728020' }}>
          <Settings className="w-5 h-5 text-muted-foreground" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Paramètres</h1>
          <p className="text-xs text-muted-foreground">Gestion des données et configuration de l'application</p>
        </div>
      </div>

      {/* Profile */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-3">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Mon profil</h2>
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div><p className="text-xs text-muted-foreground mb-0.5">Identifiant</p><p className="font-medium text-foreground">{currentUser?.username}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Email</p><p className="font-medium text-foreground">{currentUser?.email}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Rôle</p><p className="font-medium text-foreground capitalize">{currentUser?.role}</p></div>
          <div><p className="text-xs text-muted-foreground mb-0.5">Compte créé le</p><p className="font-mono text-foreground">{currentUser?.createdAt}</p></div>
        </div>
      </div>

      {/* Data stats */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-4">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Statistiques des données</h2>
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 text-sm">
          {[
            { label: 'Formations', value: data.formations.length },
            { label: 'Offres santé', value: data.offresEmploi.length },
            { label: 'Offres IT', value: data.offresIT.length },
            { label: 'Articles', value: data.articles.length },
            { label: 'Métiers', value: data.metiers.length },
            { label: 'Coachs', value: data.coachs.length },
            { label: 'Créneaux', value: data.creneaux.length },
            { label: 'Formateurs', value: data.formateurs.length },
          ].map(s => (
            <div key={s.label} className="text-center p-3 rounded-lg bg-secondary/50">
              <p className="text-lg font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>{s.value}</p>
              <p className="text-xs text-muted-foreground">{s.label}</p>
            </div>
          ))}
        </div>
        <p className="text-xs text-muted-foreground border-t border-border pt-3">
          Total : <strong className="text-foreground">{totalItems}</strong> éléments stockés localement dans le navigateur.
        </p>
      </div>

      {/* Data management */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-4">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Gestion des données</h2>
        <p className="text-xs text-muted-foreground">
          Les données sont stockées dans le <strong className="text-foreground">localStorage</strong> du navigateur. Vous pouvez les exporter, importer ou réinitialiser.
        </p>
        <div className="flex flex-wrap gap-3">
          <Button onClick={exportData} variant="outline" className="gap-2 border-border text-sm h-9">
            <Download className="w-4 h-4" />
            Exporter JSON
          </Button>
          <Button onClick={importData} variant="outline" className="gap-2 border-border text-sm h-9">
            <Upload className="w-4 h-4" />
            Importer JSON
          </Button>
          {currentUser?.role === 'superadmin' && (
            <Button onClick={() => setConfirmReset(true)} variant="outline"
              className="gap-2 border-red-500/30 text-red-400 hover:bg-red-500/10 hover:text-red-300 text-sm h-9">
              <RotateCcw className="w-4 h-4" />
              Réinitialiser
            </Button>
          )}
        </div>
      </div>

      {/* About */}
      <div className="rounded-xl border border-border p-5 bg-card space-y-2">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>À propos</h2>
        <div className="text-xs text-muted-foreground space-y-1">
          <p><strong className="text-foreground">NEXYTAL Gestion</strong> — Application de gestion front-end</p>
          <p>Version 1.0.0 — React 19 + TypeScript + Tailwind CSS 4</p>
          <p>Données stockées localement (localStorage) — Aucune base de données requise</p>
        </div>
      </div>

      {/* Confirm reset */}
      <Dialog open={confirmReset} onOpenChange={v => !v && setConfirmReset(false)}>
        <DialogContent className="max-w-sm bg-card border-border text-foreground">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2" style={{ fontFamily: 'Space Grotesk' }}>
              <AlertTriangle className="w-5 h-5 text-destructive" />
              Réinitialiser les données
            </DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground py-2">
            Toutes les données seront remplacées par les valeurs par défaut. Cette action est <strong className="text-foreground">irréversible</strong>.
          </p>
          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={() => setConfirmReset(false)} className="border-border">Annuler</Button>
            <Button variant="destructive" onClick={resetData}>Réinitialiser</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
