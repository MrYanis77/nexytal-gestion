import type { NexytalSite } from '@/lib/nexytal-sites';

interface ValidationSiteFilterProps {
  jobSites: NexytalSite[];
  siteId: number | null;
  onSiteChange: (id: number | null) => void;
  description?: string;
}

export function ValidationSiteFilter({
  jobSites,
  siteId,
  onSiteChange,
  description,
}: ValidationSiteFilterProps) {
  return (
    <div className="px-6 py-3 border-b border-border flex flex-wrap gap-3 items-center justify-between">
      <div className="flex flex-wrap gap-3 items-center">
        <select
          value={siteId ?? 'all'}
          onChange={e => {
            const v = e.target.value;
            onSiteChange(v === 'all' ? null : parseInt(v, 10));
          }}
          className="text-sm rounded-lg border border-border bg-card px-3 py-1.5 min-w-[220px]"
        >
          <option value="all">Tous les sites recrutement</option>
          {jobSites.map(s => (
            <option key={s.id} value={s.id}>{s.label}</option>
          ))}
        </select>
        {description && (
          <p className="text-xs text-muted-foreground">{description}</p>
        )}
      </div>
      {siteId && (
        <span
          className="text-xs font-medium px-2.5 py-1 rounded-full"
          style={{
            background: `${jobSites.find(s => s.id === siteId)?.color ?? '#2563EB'}22`,
            color: jobSites.find(s => s.id === siteId)?.color ?? '#2563EB',
          }}
        >
          Filtre : {jobSites.find(s => s.id === siteId)?.label}
        </span>
      )}
    </div>
  );
}
