import { DataTable } from '@/components/DataTable';
import { Button } from '@/components/ui/button';
import { ExternalLink, Layers, Plus } from 'lucide-react';

const PUBLIC_BASE = 'https://trainer.nexytal.com/expertises';

export interface ExpertiseRow {
  id: string | number;
  slug?: string;
  label?: string;
  name?: string;
  subtitle?: string;
  icon?: string;
  sort_order?: number;
  is_active?: boolean | number;
  trainers_count?: number;
}

interface Props {
  data: ExpertiseRow[];
  loading?: boolean;
  accentColor?: string;
  onAdd: () => void;
  onEdit: (item: ExpertiseRow) => void;
  onDelete: (item: ExpertiseRow) => void;
}

export function ExpertisesCatalogPanel({
  data,
  loading,
  accentColor = '#0891B2',
  onAdd,
  onEdit,
  onDelete,
}: Props) {
  return (
    <div className="space-y-4">
      <div
        className="rounded-xl border border-border bg-card/60 p-5 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4"
        style={{ borderLeftWidth: 4, borderLeftColor: accentColor }}
      >
        <div className="flex gap-3">
          <div
            className="flex h-11 w-11 shrink-0 items-center justify-center rounded-lg text-white"
            style={{ backgroundColor: accentColor }}
          >
            <Layers className="h-5 w-5" />
          </div>
          <div>
            <h2 className="text-base font-semibold text-foreground">Catalogue expertises</h2>
            <p className="text-sm text-muted-foreground mt-0.5 max-w-2xl">
              Pages SEO du site trainer.nexytal.com (menu, FAQ, compétences). Table BDD{' '}
              <code className="text-xs bg-muted px-1 py-0.5 rounded">expertises</code>
              {' '}— liens formateurs via{' '}
              <code className="text-xs bg-muted px-1 py-0.5 rounded">trainer_expertise_links</code>.
            </p>
          </div>
        </div>
        <Button
          type="button"
          onClick={onAdd}
          className="shrink-0 gap-2 text-white"
          style={{ backgroundColor: accentColor }}
        >
          <Plus className="h-4 w-4" />
          Nouvelle expertise
        </Button>
      </div>

      {loading && (
        <p className="text-sm text-muted-foreground px-1">Chargement du catalogue…</p>
      )}

      <DataTable<ExpertiseRow>
        data={data}
        accentColor={accentColor}
        addLabel="Nouvelle expertise"
        emptyMessage="Aucune expertise. Cliquez sur « Nouvelle expertise » ou exécutez migrate_expertises_catalog.sql pour le seed (IA, Cloud, Cybersécurité…)."
        onAdd={onAdd}
        onEdit={onEdit}
        onDelete={onDelete}
        searchKeys={['label', 'slug', 'name', 'subtitle', 'icon']}
        columns={[
          {
            key: 'sort_order',
            label: '#',
            render: e => <span className="text-muted-foreground tabular-nums">{String(e.sort_order ?? 0)}</span>,
          },
          {
            key: 'label',
            label: 'Titre (label)',
            render: e => (
              <div>
                <span className="font-medium text-foreground block">{String(e.label ?? '—')}</span>
                {e.subtitle ? (
                  <span className="text-xs text-muted-foreground line-clamp-1">{String(e.subtitle)}</span>
                ) : null}
              </div>
            ),
          },
          { key: 'name', label: 'Nom court', hidden: 'md', render: e => String(e.name ?? '—') },
          { key: 'slug', label: 'Slug URL', hidden: 'lg', render: e => String(e.slug ?? '—') },
          { key: 'icon', label: 'Icône', hidden: 'xl', render: e => String(e.icon ?? '—') },
          {
            key: 'is_active',
            label: 'Active',
            hidden: 'md',
            render: e =>
              e.is_active === 0 || e.is_active === false ? (
                <span className="text-xs text-muted-foreground">Non</span>
              ) : (
                <span className="text-xs font-medium text-emerald-600">Oui</span>
              ),
          },
          {
            key: 'trainers_count',
            label: 'Formateurs',
            hidden: 'sm',
            render: e => String(e.trainers_count ?? 0),
          },
          {
            key: 'public',
            label: 'Site',
            hidden: 'lg',
            render: e =>
              e.slug && e.is_active !== 0 && e.is_active !== false ? (
                <a
                  href={`${PUBLIC_BASE}/${e.slug}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1 text-xs hover:underline"
                  style={{ color: accentColor }}
                  onClick={ev => ev.stopPropagation()}
                >
                  Voir <ExternalLink className="h-3 w-3" />
                </a>
              ) : (
                <span className="text-xs text-muted-foreground">—</span>
              ),
          },
        ]}
      />
    </div>
  );
}
