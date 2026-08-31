import { useMemo, useState } from 'react';
import { useLocation } from 'wouter';
import { useFetch } from '@/hooks/useFetch';
import { offerFromApi } from '@/lib/mappers';
import { NEXYTAL_SITES } from '@/lib/nexytal-sites';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { Briefcase, Users } from 'lucide-react';

export default function OffresPublieesPage() {
  const [, setLocation] = useLocation();
  const [siteFilter, setSiteFilter] = useState('all');

  const qs = siteFilter === 'all'
    ? '?statut=publiee'
    : `?site_id=${siteFilter}&statut=publiee`;
  const { data, loading } = useFetch<{ data: Record<string, unknown>[] }>(
    `/recrutement/offers${qs}`,
  );

  const offres = useMemo(
    () => (data?.data ?? []).map(row => {
      const o = offerFromApi(row);
      return {
        id: o.id,
        site_id: row.site_id != null ? Number(row.site_id) : null,
        titre: o.titre,
        entreprise: o.entreprise,
        ville: o.ville,
        date: o.date,
        statut: o.statut,
        site_name: row.site_name != null ? String(row.site_name) : null,
        nb_candidatures: Number(row.nb_candidatures ?? 0),
        score_moyen: row.score_moyen != null ? Number(row.score_moyen) : null,
      };
    }),
    [data],
  );

  const columns = [
    { key: 'titre', label: 'Titre' },
    ...(siteFilter === 'all' ? [{ key: 'site_name', label: 'Site', hidden: 'md' as const }] : []),
    { key: 'entreprise', label: 'Entreprise', hidden: 'md' as const },
    { key: 'ville', label: 'Ville', hidden: 'lg' as const },
    {
      key: 'nb_candidatures',
      label: 'Candidatures',
      render: (row: { nb_candidatures: number }) => (
        <span className="inline-flex items-center gap-1 text-sm">
          <Users className="w-3.5 h-3.5 text-muted-foreground" />
          {row.nb_candidatures}
        </span>
      ),
    },
    {
      key: 'score_moyen',
      label: 'Score moy.',
      render: (row: { score_moyen: number | null }) => (
        row.score_moyen != null ? `${row.score_moyen}/100` : '—'
      ),
    },
    {
      key: 'statut',
      label: 'Statut',
      render: (row: { statut: string }) => <StatusBadge statut={row.statut} />,
    },
  ];

  return (
    <div className="p-6 space-y-6 fade-up">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-foreground flex items-center gap-2" style={{ fontFamily: 'Space Grotesk' }}>
            <Briefcase className="w-6 h-6 text-blue-500" />
            Offres publiées
          </h1>
          <p className="text-sm text-muted-foreground mt-1">
            Offres validées et visibles sur les sites publics
          </p>
        </div>
        <select
          value={siteFilter}
          onChange={e => setSiteFilter(e.target.value)}
          className="text-sm rounded-lg border border-border bg-card px-3 py-2"
        >
          <option value="all">Tous les sites</option>
          {NEXYTAL_SITES.map(s => (
            <option key={s.id} value={String(s.id)}>{s.label}</option>
          ))}
        </select>
      </div>

      {loading ? (
        <p className="text-sm text-muted-foreground">Chargement…</p>
      ) : (
        <DataTable
          columns={columns}
          data={offres}
          emptyMessage="Aucune offre publiée"
          onView={(row) => {
            const site = row.site_id ?? (siteFilter !== 'all' ? Number(siteFilter) : null);
            setLocation(site ? `/recrutement-gestion?site=${site}` : '/recrutement-gestion');
          }}
        />
      )}
    </div>
  );
}
