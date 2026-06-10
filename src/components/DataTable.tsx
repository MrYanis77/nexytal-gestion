import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Search, Plus, Pencil, Trash2, Eye, ChevronLeft, ChevronRight } from 'lucide-react';

export interface Column<T> {
  key: keyof T | string;
  label: string;
  render?: (item: T) => React.ReactNode;
  className?: string;
  hidden?: 'sm' | 'md' | 'lg';
}

interface DataTableProps<T extends { id: string }> {
  data: T[];
  columns: Column<T>[];
  onAdd?: () => void;
  onEdit?: (item: T) => void;
  onDelete?: (item: T) => void;
  onView?: (item: T) => void;
  searchKeys?: (keyof T)[];
  addLabel?: string;
  emptyMessage?: string;
  accentColor?: string;
  pageSize?: number;
}

export function DataTable<T extends { id: string }>({
  data,
  columns,
  onAdd,
  onEdit,
  onDelete,
  onView,
  searchKeys = [],
  addLabel = 'Ajouter',
  emptyMessage = 'Aucun élément trouvé.',
  accentColor = '#2563EB',
  pageSize = 10,
}: DataTableProps<T>) {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);

  const filtered = data.filter(item => {
    if (!search) return true;
    return searchKeys.some(key => {
      const val = item[key];
      return typeof val === 'string' && val.toLowerCase().includes(search.toLowerCase());
    });
  });

  const totalPages = Math.max(1, Math.ceil(filtered.length / pageSize));
  const paginated = filtered.slice((page - 1) * pageSize, page * pageSize);

  const hiddenClass: Record<string, string> = {
    sm: 'hidden sm:table-cell',
    md: 'hidden md:table-cell',
    lg: 'hidden lg:table-cell',
  };

  return (
    <div className="space-y-4">
      {/* Toolbar */}
      <div className="flex items-center gap-3 flex-wrap">
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Rechercher…"
            value={search}
            onChange={e => { setSearch(e.target.value); setPage(1); }}
            className="pl-9 h-9 bg-secondary border-border text-sm"
          />
        </div>
        {onAdd && (
          <Button size="sm" onClick={onAdd} className="h-9 gap-2 text-sm font-medium"
            style={{ background: accentColor, boxShadow: `0 2px 12px ${accentColor}40` }}>
            <Plus className="w-4 h-4" />
            {addLabel}
          </Button>
        )}
      </div>

      {/* Count */}
      <p className="text-xs text-muted-foreground">
        {filtered.length} résultat{filtered.length !== 1 ? 's' : ''}
      </p>

      {/* Table */}
      <div className="rounded-xl border border-border overflow-hidden bg-card">
        {paginated.length === 0 ? (
          <div className="py-16 text-center text-muted-foreground text-sm">{emptyMessage}</div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-border bg-secondary/50">
                  {columns.map(col => (
                    <th key={String(col.key)}
                      className={`text-left px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider whitespace-nowrap ${col.hidden ? hiddenClass[col.hidden] : ''} ${col.className ?? ''}`}>
                      {col.label}
                    </th>
                  ))}
                  {(onEdit || onDelete || onView) && (
                    <th className="text-right px-4 py-3 text-xs font-semibold text-muted-foreground uppercase tracking-wider">
                      Actions
                    </th>
                  )}
                </tr>
              </thead>
              <tbody>
                {paginated.map((item, i) => (
                  <tr key={item.id}
                    className={`border-b border-border/50 hover:bg-secondary/30 transition-colors ${i === paginated.length - 1 ? 'border-0' : ''}`}>
                    {columns.map(col => (
                      <td key={String(col.key)}
                        className={`px-4 py-3 ${col.hidden ? hiddenClass[col.hidden] : ''} ${col.className ?? ''}`}>
                        {col.render ? col.render(item) : String((item as Record<string, unknown>)[String(col.key)] ?? '')}
                      </td>
                    ))}
                    {(onEdit || onDelete || onView) && (
                      <td className="px-4 py-3">
                        <div className="flex items-center justify-end gap-1">
                          {onView && (
                            <Button variant="ghost" size="icon" onClick={() => onView(item)}
                              className="w-7 h-7 text-muted-foreground hover:text-foreground hover:bg-secondary">
                              <Eye className="w-3.5 h-3.5" />
                            </Button>
                          )}
                          {onEdit && (
                            <Button variant="ghost" size="icon" onClick={() => onEdit(item)}
                              className="w-7 h-7 text-muted-foreground hover:text-foreground hover:bg-secondary">
                              <Pencil className="w-3.5 h-3.5" />
                            </Button>
                          )}
                          {onDelete && (
                            <Button variant="ghost" size="icon" onClick={() => onDelete(item)}
                              className="w-7 h-7 text-muted-foreground hover:text-destructive hover:bg-destructive/10">
                              <Trash2 className="w-3.5 h-3.5" />
                            </Button>
                          )}
                        </div>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-between text-sm">
          <p className="text-muted-foreground text-xs">
            Page {page} sur {totalPages}
          </p>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="icon" className="w-7 h-7" disabled={page === 1} onClick={() => setPage(p => p - 1)}>
              <ChevronLeft className="w-3.5 h-3.5" />
            </Button>
            <Button variant="outline" size="icon" className="w-7 h-7" disabled={page === totalPages} onClick={() => setPage(p => p + 1)}>
              <ChevronRight className="w-3.5 h-3.5" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

export function StatusBadge({ statut }: { statut: string }) {
  const map: Record<string, { label: string; class: string }> = {
    publie: { label: 'Publié', class: 'bg-green-500/15 text-green-400' },
    published: { label: 'Publié', class: 'bg-green-500/15 text-green-400' },
    brouillon: { label: 'Brouillon', class: 'bg-yellow-500/15 text-yellow-400' },
    draft: { label: 'Brouillon', class: 'bg-yellow-500/15 text-yellow-400' },
    actif: { label: 'Actif', class: 'bg-green-500/15 text-green-400' },
    active: { label: 'Actif', class: 'bg-green-500/15 text-green-400' },
    inactif: { label: 'Inactif', class: 'bg-red-500/15 text-red-400' },
    inactive: { label: 'Inactif', class: 'bg-red-500/15 text-red-400' },
    pending: { label: 'En attente', class: 'bg-yellow-500/15 text-yellow-400' },
    confirmed: { label: 'Confirmée', class: 'bg-blue-500/15 text-blue-400' },
    completed: { label: 'Terminée', class: 'bg-green-500/15 text-green-400' },
    cancelled: { label: 'Annulée', class: 'bg-red-500/15 text-red-400' },
    disponible: { label: 'Disponible', class: 'bg-green-500/15 text-green-400' },
    reserve: { label: 'Réservé', class: 'bg-blue-500/15 text-blue-400' },
    annule: { label: 'Annulé', class: 'bg-red-500/15 text-red-400' },
  };
  const s = map[statut] ?? { label: statut, class: 'bg-secondary text-muted-foreground' };
  return <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${s.class}`}>{s.label}</span>;
}
