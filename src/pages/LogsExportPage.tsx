import { useMemo, useState } from 'react';
import { api } from '@/lib/api';
import { useFetch } from '@/hooks/useFetch';
import { SiteHeader, type TabGroup } from '@/components/SiteHeader';
import { useTabGroups } from '@/lib/use-tab-groups';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Download, FileJson, ScrollText } from 'lucide-react';
import { toast } from 'sonner';

const COLOR = '#475569';

const SITE_OPTIONS = [
  { value: '', label: 'Tous les sites' },
  { value: '1', label: 'Alt Formation' },
  { value: '2', label: 'Recrutement' },
  { value: '3', label: 'Medical' },
  { value: '4', label: 'Carriere' },
  { value: '5', label: 'Trainer' },
  { value: '6', label: 'Coaching' },
];

const LOG_TYPES = [
  { key: 'audit', label: 'Audit admin', siteScoped: true, search: ['action', 'entity_type', 'ip_address'] },
  { key: 'emails', label: 'Emails', siteScoped: true, search: ['recipient_email', 'subject', 'status'] },
  { key: 'gdpr-consents', label: 'Consentements', siteScoped: true, search: ['user_email', 'consent_type'] },
  { key: 'gdpr-deletions', label: 'Suppressions RGPD', siteScoped: true, search: ['user_email', 'status'] },
  { key: 'candidature-history', label: 'Historique candidatures', siteScoped: true, search: ['nouveau_statut', 'auteur_type'] },
  { key: 'admin-sessions', label: 'Sessions admin', siteScoped: false, search: ['admin_id', 'ip_address', 'user_agent'] },
  { key: 'system', label: 'System logs', siteScoped: false, search: ['file', 'level', 'message'] },
] as const;

type LogType = typeof LOG_TYPES[number]['key'];
type LogRow = { id: string } & Record<string, unknown>;

type ApiList = {
  data?: Record<string, unknown>[];
  pagination?: { total?: number; page?: number; total_pages?: number };
  files?: Array<{ key: string; name: string; size_bytes?: number; modified_at?: string; selected?: boolean }>;
  selected_file?: { key: string; name: string };
};

function buildQuery(type: LogType, siteId: string, from: string, to: string, systemFile: string) {
  const params = new URLSearchParams({ limit: '100' });
  const def = LOG_TYPES.find(t => t.key === type);
  if (siteId && def?.siteScoped) params.set('site_id', siteId);
  if (from && type !== 'system') params.set('from', from);
  if (to && type !== 'system') params.set('to', to);
  if (type === 'system' && systemFile) params.set('file', systemFile);
  return params.toString();
}

function saveBlob(blob: Blob, fallbackName: string, disposition?: string) {
  const match = disposition?.match(/filename="?([^";]+)"?/i);
  const filename = match?.[1] ?? fallbackName;
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

export default function LogsExportPage() {
  const [siteId, setSiteId] = useState('');
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [systemFile, setSystemFile] = useState('');

  const tabGroups = useMemo<TabGroup[]>(() => [{
    key: 'logs',
    label: 'Journaux',
    tabs: LOG_TYPES.map(t => ({ key: t.key, label: t.label })),
  }], []);

  const { activeGroup, activeTab, setActiveTab, onGroupChange } = useTabGroups(tabGroups, 'logs', 'audit');
  const type = activeTab as LogType;
  const query = buildQuery(type, siteId, from, to, systemFile);
  const { data, refetch } = useFetch<ApiList>(`/logs/${type}?${query}`);
  const rows: LogRow[] = (data?.data ?? []).map((row, index) => ({ ...row, id: String(row.id ?? index) }));
  const activeDef = LOG_TYPES.find(t => t.key === type) ?? LOG_TYPES[0];
  const systemFiles = data?.files ?? [];
  const selectedSystemFile = systemFile || data?.selected_file?.key || systemFiles.find(f => f.selected)?.key || systemFiles[0]?.key || '';

  const downloadSystemLog = async () => {
    try {
      const params = new URLSearchParams();
      if (selectedSystemFile) params.set('file', selectedSystemFile);
      const response = await api.get(`/logs/system/download?${params.toString()}`, { responseType: 'blob' });
      saveBlob(response.data, 'system.log', response.headers['content-disposition']);
      toast.success('Log système téléchargé.');
    } catch {
      toast.error('Téléchargement impossible.');
    }
  };

  const exportLog = async (format: 'csv' | 'json') => {
    if (type === 'system') {
      await downloadSystemLog();
      return;
    }
    try {
      const exportQuery = new URLSearchParams(query);
      exportQuery.set('format', format);
      const response = await api.get(`/logs/${type}/export?${exportQuery.toString()}`, { responseType: 'blob' });
      saveBlob(response.data, `${type}.${format}`, response.headers['content-disposition']);
      toast.success(`Export ${format.toUpperCase()} prêt.`);
    } catch {
      toast.error('Export impossible.');
    }
  };

  const columns = useMemo(() => {
    const keys = rows.length > 0 ? Object.keys(rows[0]).slice(0, 8) : ['id', 'created_at'];
    return keys.map(key => ({
      key,
      label: key,
      render: (row: LogRow) => {
        const value = row[key];
        if (key === 'status' || key === 'action' || key === 'nouveau_statut') {
          return <StatusBadge statut={String(value ?? '')} />;
        }
        if (key.endsWith('_at') || key === 'created_at') {
          return String(value ?? '').replace('T', ' ').slice(0, 19);
        }
        if (key === 'old_data' || key === 'new_data') {
          return <span className="font-mono text-xs text-muted-foreground">{value ? 'JSON' : '-'}</span>;
        }
        return <span className="truncate block max-w-[22rem]">{String(value ?? '-')}</span>;
      },
    }));
  }, [rows]);

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={<ScrollText className="w-5 h-5" />}
        title="Logs & exports"
        description="Audit, conformite et telechargements serveur"
        color={COLOR}
        tabGroups={tabGroups}
        activeGroup={activeGroup}
        onGroupChange={onGroupChange}
        activeTab={type}
        onTabChange={(key) => setActiveTab(key)}
      />

      <div className="px-6 pt-4 flex flex-wrap items-end gap-3">
        {activeDef.siteScoped && (
          <label className="grid gap-1 text-sm text-muted-foreground">
            Site
            <select value={siteId} onChange={e => setSiteId(e.target.value)} className="bg-secondary border border-border rounded-md px-3 py-2 text-sm text-foreground min-w-48">
              {SITE_OPTIONS.map(site => <option key={site.value} value={site.value}>{site.label}</option>)}
            </select>
          </label>
        )}
        {type === 'system' && systemFiles.length > 0 && (
          <label className="grid gap-1 text-sm text-muted-foreground">
            Fichier
            <select value={selectedSystemFile} onChange={e => setSystemFile(e.target.value)} className="bg-secondary border border-border rounded-md px-3 py-2 text-sm text-foreground min-w-56">
              {systemFiles.map(file => <option key={file.key} value={file.key}>{file.name}</option>)}
            </select>
          </label>
        )}
        <label className="grid gap-1 text-sm text-muted-foreground">
          Debut
          <input value={from} onChange={e => setFrom(e.target.value)} type="date" className="bg-secondary border border-border rounded-md px-3 py-2 text-sm text-foreground" />
        </label>
        <label className="grid gap-1 text-sm text-muted-foreground">
          Fin
          <input value={to} onChange={e => setTo(e.target.value)} type="date" className="bg-secondary border border-border rounded-md px-3 py-2 text-sm text-foreground" />
        </label>
        <Button variant="outline" onClick={() => refetch()}>Actualiser</Button>
        <div className="ml-auto flex items-center gap-2">
          <Badge variant="outline">{data?.pagination?.total ?? rows.length} lignes</Badge>
          {type === 'system' ? (
            <Button variant="outline" disabled={!selectedSystemFile} onClick={downloadSystemLog}><Download className="w-4 h-4 mr-2" />Télécharger</Button>
          ) : (
            <>
              <Button variant="outline" onClick={() => exportLog('csv')}><Download className="w-4 h-4 mr-2" />CSV</Button>
              <Button variant="outline" onClick={() => exportLog('json')}><FileJson className="w-4 h-4 mr-2" />JSON</Button>
            </>
          )}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6">
        <DataTable<LogRow>
          data={rows}
          accentColor={COLOR}
          searchKeys={[...activeDef.search]}
          columns={columns}
        />
      </div>
    </div>
  );
}