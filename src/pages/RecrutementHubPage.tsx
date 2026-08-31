import { useMemo } from 'react';
import { Link, useLocation, useSearch } from 'wouter';
import { Briefcase, UserCheck, ShieldCheck, ClipboardCheck } from 'lucide-react';
import { RecrutementAdminPage } from './RecrutementAdminPage';
import { useFetch } from '@/hooks/useFetch';
import { getRecruitmentJobSites, getSiteById } from '@/lib/nexytal-sites';

const HUB_COLOR = '#2563EB';

/**
 * Hub recrutement central — logique bdd.sql :
 * - Recruteurs & entreprises : globaux (filtre site optionnel via recruteur_sites / offres)
 * - Offres & candidatures : filtrables par site de publication
 * - Métiers / secteurs : nécessitent un site sélectionné
 */
export default function RecrutementHubPage() {
  const search = useSearch();
  const [, setLocation] = useLocation();

  const siteId = useMemo(() => {
    const params = new URLSearchParams(search);
    const raw = params.get('site');
    if (!raw || raw === 'all') return null;
    const n = parseInt(raw, 10);
    return Number.isFinite(n) && n > 0 ? n : null;
  }, [search]);

  const activeSite = siteId ? getSiteById(siteId) : null;

  const { data: pendingRecruteurs } = useFetch<{ data?: { count: number } }>(
    siteId ? `/recrutement/recruteurs/pending-count?site_id=${siteId}` : '/recrutement/recruteurs/pending-count',
  );
  const { data: pendingOffres } = useFetch<{ pagination?: { total?: number }; data?: unknown[] }>(
    siteId ? `/recrutement/offers/pending?site_id=${siteId}` : '/recrutement/offers/pending',
  );

  const pendingRecruteursCount = pendingRecruteurs?.data?.count ?? 0;
  const pendingOffresCount = pendingOffres?.pagination?.total ?? pendingOffres?.data?.length ?? 0;

  const siteQs = siteId ? `?site=${siteId}` : '';

  const setSiteFilter = (id: number | null) => {
    const params = new URLSearchParams(search);
    if (id === null) {
      params.delete('site');
    } else {
      params.set('site', String(id));
    }
    const qs = params.toString();
    setLocation(`/recrutement-gestion${qs ? `?${qs}` : ''}`);
  };

  return (
    <div className="h-full flex flex-col min-h-0">
      <div className="px-6 py-4 border-b border-border bg-card/50 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div
            className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
            style={{ background: HUB_COLOR + '22' }}
          >
            <Briefcase className="w-5 h-5" style={{ color: HUB_COLOR }} />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground" style={{ fontFamily: 'Space Grotesk' }}>
              Recrutement
            </h1>
            <p className="text-sm text-muted-foreground">
              Offres, candidatures, recruteurs et entreprises — vue centralisée
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <label htmlFor="site-filter" className="text-xs text-muted-foreground whitespace-nowrap">
            Site de publication
          </label>
          <select
            id="site-filter"
            value={siteId ?? 'all'}
            onChange={e => {
              const v = e.target.value;
              setSiteFilter(v === 'all' ? null : parseInt(v, 10));
            }}
            className="text-sm rounded-lg border border-border bg-background px-3 py-2 min-w-[200px]"
          >
            <option value="all">Tous les sites</option>
            {getRecruitmentJobSites().map(s => (
              <option key={s.id} value={s.id}>{s.label}</option>
            ))}
          </select>
        </div>
      </div>

      {!siteId && (
        <div className="px-6 py-2 text-xs text-muted-foreground border-b border-border/50 bg-secondary/30">
          Métiers et secteurs : sélectionnez un site. Recruteurs et entreprises sont partagés entre les sites autorisés.
        </div>
      )}

      {siteId && (
        <div className="px-6 py-3 border-b border-border/50 bg-secondary/20 flex flex-wrap gap-2">
          <span className="text-xs text-muted-foreground self-center mr-1">Validations {activeSite?.label} :</span>
          <Link href={`/validation-recruteurs${siteQs}`}>
            <span className="inline-flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-full border border-border bg-card hover:bg-secondary cursor-pointer">
              <UserCheck className="w-3.5 h-3.5 text-emerald-500" />
              Recruteurs
              {pendingRecruteursCount > 0 && (
                <span className="font-semibold text-emerald-500">{pendingRecruteursCount}</span>
              )}
            </span>
          </Link>
          <Link href={`/validation-offres${siteQs}`}>
            <span className="inline-flex items-center gap-1.5 text-xs px-3 py-1.5 rounded-full border border-border bg-card hover:bg-secondary cursor-pointer">
              <ClipboardCheck className="w-3.5 h-3.5 text-blue-500" />
              Offres
              {pendingOffresCount > 0 && (
                <span className="font-semibold text-blue-500">{pendingOffresCount}</span>
              )}
            </span>
          </Link>
        </div>
      )}

      <div className="flex-1 min-h-0 overflow-hidden">
        <RecrutementAdminPage
          siteId={siteId}
          color={activeSite?.color ?? HUB_COLOR}
          title=""
          description=""
          icon={<Briefcase className="w-5 h-5" />}
          hubMode
          showRecruteurs
          showMetiers={siteId !== null}
          medicalMetiers={siteId === 3}
          entrepriseTabLabel={siteId === 3 ? 'Établissements' : 'Entreprises'}
          addEntrepriseLabel={siteId === 3 ? 'Nouvel établissement' : 'Nouvelle entreprise'}
        />
      </div>
    </div>
  );
}
