import { api } from '@/lib/api';

export type DataExportScope = 'recrutement' | 'blog' | 'formation' | 'full';

export interface DataExportPayload {
  version: number;
  site_id: number;
  scope: string;
  exported_at: string;
  tables: Record<string, Record<string, unknown>[]>;
}

export interface DataImportResult {
  site_id: number;
  mode: string;
  results: Record<string, { inserted: number; skipped: number; errors: number }>;
}

export const SITE_EXPORT_OPTIONS = [
  { value: '1', label: 'Alt Formation' },
  { value: '2', label: 'Recrutement IT' },
  { value: '3', label: 'Médical' },
  { value: '4', label: 'Carrière' },
  { value: '5', label: 'Trainer' },
  { value: '6', label: 'Coaching' },
];

export async function exportSiteData(siteId: string, scope: DataExportScope): Promise<DataExportPayload> {
  const res = await api.get<{ data: DataExportPayload }>(
    `/settings/export?site_id=${siteId}&scope=${scope}`,
  );
  return res.data.data;
}

export async function importSiteData(
  payload: DataExportPayload,
  mode: 'merge' | 'skip_existing',
): Promise<DataImportResult> {
  const res = await api.post<{ data: DataImportResult }>('/settings/import', {
    site_id: payload.site_id,
    tables: payload.tables,
    mode,
  });
  return res.data.data;
}

export function downloadJsonExport(data: DataExportPayload, filename?: string): void {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename ?? `nexytal-export-site-${data.site_id}-${data.scope}-${new Date().toISOString().slice(0, 10)}.json`;
  a.click();
  URL.revokeObjectURL(url);
}
