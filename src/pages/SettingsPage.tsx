import { useState, useRef } from 'react';
import { useApp } from '@/contexts/AppContext';
import { getApiErrorMessage } from '@/lib/api-errors';
import {
  SITE_EXPORT_OPTIONS,
  exportSiteData,
  importSiteData,
  downloadJsonExport,
  type DataExportPayload,
  type DataExportScope,
} from '@/lib/dataPortability';
import { Settings, Download, Upload, Database, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

export default function SettingsPage() {
  const { currentUser } = useApp();
  const isSuperadmin = currentUser?.role === 'superadmin';

  const [exportSiteId, setExportSiteId] = useState('2');
  const [exportScope, setExportScope] = useState<DataExportScope>('recrutement');
  const [exporting, setExporting] = useState(false);
  const [importing, setImporting] = useState(false);
  const [importMode, setImportMode] = useState<'merge' | 'skip_existing'>('skip_existing');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleExport = async () => {
    setExporting(true);
    try {
      const data = await exportSiteData(exportSiteId, exportScope);
      downloadJsonExport(data);
      const tableCount = Object.keys(data.tables).length;
      const rowCount = Object.values(data.tables).reduce((n, rows) => n + rows.length, 0);
      toast.success(`Export terminé — ${tableCount} tables, ${rowCount} enregistrements`);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Échec de l\'export'));
    } finally {
      setExporting(false);
    }
  };

  const handleImportFile = async (file: File) => {
    setImporting(true);
    try {
      const text = await file.text();
      const payload = JSON.parse(text) as DataExportPayload;

      if (!payload.site_id || !payload.tables) {
        throw new Error('Fichier JSON invalide (site_id ou tables manquants)');
      }

      const result = await importSiteData(payload, importMode);
      const inserted = Object.values(result.results).reduce((n, r) => n + r.inserted, 0);
      const skipped = Object.values(result.results).reduce((n, r) => n + r.skipped, 0);
      const errors = Object.values(result.results).reduce((n, r) => n + r.errors, 0);

      toast.success(`Import terminé — ${inserted} ajoutés, ${skipped} ignorés, ${errors} erreurs`);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Échec de l\'import'));
    } finally {
      setImporting(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  return (
    <div className="p-6 space-y-6 fade-up max-w-3xl">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background: '#6B728020' }}>
          <Settings className="w-5 h-5 text-muted-foreground" />
        </div>
        <div>
          <h1 className="text-xl font-bold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Paramètres</h1>
          <p className="text-xs text-muted-foreground">Profil, export / import des données par site</p>
        </div>
      </div>

      <div className="rounded-xl border border-border p-5 bg-card space-y-3">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>Mon profil</h2>
        <div className="grid grid-cols-2 gap-4 text-sm">
          <div>
            <p className="text-xs text-muted-foreground mb-0.5">Identifiant</p>
            <p className="font-medium text-foreground">{currentUser?.username}</p>
          </div>
          <div>
            <p className="text-xs text-muted-foreground mb-0.5">Email</p>
            <p className="font-medium text-foreground">{currentUser?.email}</p>
          </div>
          <div>
            <p className="text-xs text-muted-foreground mb-0.5">Rôle</p>
            <p className="font-medium text-foreground capitalize">{currentUser?.role}</p>
          </div>
          <div>
            <p className="text-xs text-muted-foreground mb-0.5">Sites accessibles</p>
            <p className="font-medium text-foreground">{currentUser?.sites?.join(', ') || '—'}</p>
          </div>
        </div>
      </div>

      {isSuperadmin && (
        <div className="rounded-xl border border-border p-5 bg-card space-y-4">
          <div className="flex items-center gap-2">
            <Database className="w-4 h-4 text-muted-foreground" />
            <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>
              Export / import des données
            </h2>
          </div>
          <p className="text-xs text-muted-foreground">
            Exportez les données d&apos;un site en JSON ou importez un fichier précédemment exporté.
            Recrutement IT (site 2) et Médical (site 3) sont des périmètres distincts — exportez/importez par site.
          </p>

          <div className="grid sm:grid-cols-2 gap-3">
            <label className="space-y-1">
              <span className="text-xs text-muted-foreground">Site</span>
              <select
                value={exportSiteId}
                onChange={e => setExportSiteId(e.target.value)}
                className="w-full bg-secondary border border-border rounded-md px-3 py-2 text-sm"
              >
                {SITE_EXPORT_OPTIONS.map(s => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </label>
            <label className="space-y-1">
              <span className="text-xs text-muted-foreground">Périmètre</span>
              <select
                value={exportScope}
                onChange={e => setExportScope(e.target.value as DataExportScope)}
                className="w-full bg-secondary border border-border rounded-md px-3 py-2 text-sm"
              >
                <option value="recrutement">Recrutement (secteurs, entreprises, offres…)</option>
                <option value="blog">Blog</option>
                <option value="formation">Formation</option>
                <option value="full">Complet (recrutement + blog + formation + médias)</option>
              </select>
            </label>
          </div>

          <Button onClick={handleExport} disabled={exporting} className="gap-2" size="sm">
            {exporting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}
            Exporter en JSON
          </Button>

          <div className="border-t border-border pt-4 space-y-3">
            <p className="text-xs font-medium text-foreground">Importer un fichier JSON</p>
            <label className="space-y-1 block">
              <span className="text-xs text-muted-foreground">Mode</span>
              <select
                value={importMode}
                onChange={e => setImportMode(e.target.value as 'merge' | 'skip_existing')}
                className="w-full bg-secondary border border-border rounded-md px-3 py-2 text-sm"
              >
                <option value="skip_existing">Ignorer les slugs déjà existants</option>
                <option value="merge">Insérer (doublons de slug sans slug)</option>
              </select>
            </label>
            <input
              ref={fileInputRef}
              type="file"
              accept="application/json,.json"
              className="hidden"
              onChange={e => {
                const file = e.target.files?.[0];
                if (file) handleImportFile(file);
              }}
            />
            <Button
              variant="outline"
              size="sm"
              className="gap-2 border-border"
              disabled={importing}
              onClick={() => fileInputRef.current?.click()}
            >
              {importing ? <Loader2 className="w-4 h-4 animate-spin" /> : <Upload className="w-4 h-4" />}
              Importer un fichier
            </Button>
          </div>
        </div>
      )}

      <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4 text-xs text-muted-foreground space-y-1">
        <p className="font-medium text-foreground">Séparation Recrutement / Médical</p>
        <p>
          Si des établissements médicaux apparaissent encore dans Recrutement, exécutez sur la BDD Ionos :
          <code className="mx-1 text-[11px] bg-secondary px-1 rounded">api/sql/migrate_site_scope.sql</code>
          puis
          <code className="mx-1 text-[11px] bg-secondary px-1 rounded">api/sql/migrate_site_scope_backfill.sql</code>
        </p>
      </div>

      <div className="rounded-xl border border-border p-5 bg-card space-y-2">
        <h2 className="text-sm font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>À propos</h2>
        <div className="text-xs text-muted-foreground space-y-1">
          <p><strong className="text-foreground">NEXYTAL Gestion</strong> — API PHP + React</p>
          <p>Version 2.1.0</p>
        </div>
      </div>
    </div>
  );
}
