import { useMemo } from 'react';
import { useLocation, useSearch } from 'wouter';
import { getRecruitmentJobSites, getSiteById, type NexytalSite } from '@/lib/nexytal-sites';

export function useValidationSiteScope(basePath: string) {
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
  const jobSites = useMemo(() => getRecruitmentJobSites(), []);

  const setSiteId = (id: number | null) => {
    const params = new URLSearchParams(search);
    if (id === null) {
      params.delete('site');
    } else {
      params.set('site', String(id));
    }
    const qs = params.toString();
    setLocation(`${basePath}${qs ? `?${qs}` : ''}`);
  };

  const siteApiQuery = siteId ? `site_id=${siteId}` : '';
  const siteApiSuffix = siteId ? `&site_id=${siteId}` : '';

  return {
    siteId,
    activeSite,
    jobSites,
    setSiteId,
    siteApiQuery,
    siteApiSuffix,
  };
}

export function validationSiteBadge(site: NexytalSite | null | undefined) {
  if (!site) return null;
  return { label: site.label, color: site.color };
}
