import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { ValidationSiteFilter } from '@/components/ValidationSiteFilter';
import { useValidationSiteScope } from '@/hooks/useValidationSiteScope';
import { getRecruitmentJobSites, siteLabelFromCode } from '@/lib/nexytal-sites';
import { Button } from '@/components/ui/button';
import { CheckCircle, Eye } from 'lucide-react';
import { toast } from 'sonner';

interface PendingRecruteur {
  id: string;
  email: string;
  nom_entreprise: string;
  prenom: string;
  nom: string;
  telephone: string;
  fonction: string;
  status: string;
  created_at: string;
  sites_autorises?: Array<{ site: string }>;
  sites_detectes?: string[];
}

interface RecruteursValidationPanelProps {
  /** Page hub autonome avec filtre site */
  mode?: 'page' | 'embedded';
  siteId?: number;
  accentColor?: string;
}

export function RecruteursValidationPanel({
  mode = 'page',
  siteId: fixedSiteId,
  accentColor = '#10B981',
}: RecruteursValidationPanelProps) {
  const scope = useValidationSiteScope('/validation-recruteurs');
  const siteId = mode === 'embedded' ? (fixedSiteId ?? null) : scope.siteId;
  const activeSite = mode === 'embedded' && fixedSiteId
    ? getRecruitmentJobSites().find(s => s.id === fixedSiteId) ?? null
    : scope.activeSite;
  const jobSites = scope.jobSites;

  const [detailModal, setDetailModal] = useState<PendingRecruteur | null>(null);
  const [validateModal, setValidateModal] = useState<PendingRecruteur | null>(null);
  const [actionId, setActionId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState(mode === 'embedded' ? '' : 'pending');

  const listUrl = useMemo(() => {
    const params = new URLSearchParams();
    if (statusFilter) params.set('status', statusFilter);
    if (siteId) params.set('site_id', String(siteId));
    const qs = params.toString();
    return `/recrutement/recruteurs${qs ? `?${qs}` : ''}`;
  }, [statusFilter, siteId]);

  const { data, refetch, loading } = useFetch<{ data: PendingRecruteur[] }>(listUrl);

  const recruteurs = useMemo(
    () => (data?.data ?? []).map(r => ({
      ...r,
      id: String(r.id),
      prenom: r.prenom ?? '',
      nom: r.nom ?? '',
    })),
    [data],
  );


  const handleValidate = async () => {
    if (!validateModal) return;
    setActionId(validateModal.id);
    try {
      await api.post(`/recrutement/recruteurs/${validateModal.id}/validate`, {});
      toast.success(`Recruteur « ${validateModal.prenom} ${validateModal.nom} » validé.`);
      setValidateModal(null);
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Validation impossible.'));
    } finally {
      setActionId(null);
    }
  };

  const formatSites = (r: PendingRecruteur) => {
    const detected = (r.sites_detectes ?? []).filter(Boolean);
    const allowed = (r.sites_autorises ?? []).map(s => s.site).filter(Boolean);
    const codes = detected.length ? detected : allowed;
    return codes.length ? codes.map(siteLabelFromCode).join(', ') : (activeSite?.label ?? 'A déterminer');
  };

  return (
    <div className={mode === 'page' ? 'h-full flex flex-col' : 'flex flex-col min-h-0'}>
      {mode === 'page' && (
        <ValidationSiteFilter
          jobSites={jobSites}
          siteId={scope.siteId}
          onSiteChange={scope.setSiteId}
          description="Recruteurs liés au site via inscription ou offres déposées."
        />
      )}

      <div className={`${mode === 'embedded' ? 'py-2' : 'px-6 py-3'} border-b border-border flex flex-wrap gap-2`}>
        {[
          { value: 'pending', label: 'En attente' },
          { value: 'actif', label: 'Actifs' },
          { value: 'suspendu', label: 'Suspendus' },
          { value: '', label: 'Tous' },
        ].map(f => (
          <button
            key={f.value || 'all'}
            type="button"
            onClick={() => setStatusFilter(f.value)}
            className={`text-xs px-3 py-1.5 rounded-full border transition-colors ${
              statusFilter === f.value
                ? 'border-transparent text-white'
                : 'border-border text-muted-foreground hover:text-foreground'
            }`}
            style={statusFilter === f.value ? { background: accentColor } : undefined}
          >
            {f.label}
          </button>
        ))}
      </div>

      <div className={`flex-1 overflow-y-auto ${mode === 'page' ? 'p-6' : 'pt-4'}`}>
        {loading && !data ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : (
          <DataTable<PendingRecruteur>
            data={recruteurs}
            accentColor={accentColor}
            emptyMessage="Aucun recruteur dans cette catégorie."
            searchKeys={['email', 'nom_entreprise', 'prenom', 'nom']}
            columns={[
              {
                key: 'nom',
                label: 'Recruteur',
                render: r => (
                  <div>
                    <p className="font-medium text-foreground">{r.prenom} {r.nom}</p>
                    <p className="text-xs text-muted-foreground">{r.email}</p>
                  </div>
                ),
              },
              { key: 'nom_entreprise', label: 'Entreprise' },
              { key: 'sites', label: 'Site(s)', hidden: 'md', render: r => formatSites(r) },
              { key: 'status', label: 'Statut', render: r => <StatusBadge statut={r.status} /> },
              {
                key: 'actions',
                label: 'Actions',
                render: r => (
                  <div className="flex items-center gap-1">
                    <Button size="sm" variant="ghost" className="h-8 w-8 p-0" onClick={() => setDetailModal(r)}>
                      <Eye className="w-4 h-4" />
                    </Button>
                    {r.status === 'pending' && (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="h-8 w-8 p-0 text-green-500"
                        disabled={actionId === r.id}
                        onClick={() => {
                          setValidateModal(r);
                        }}
                      >
                        <CheckCircle className="w-4 h-4" />
                      </Button>
                    )}
                  </div>
                ),
              },
            ]}
          />
        )}
      </div>

      {detailModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 w-full max-w-lg space-y-4">
            <h3 className="font-semibold">{detailModal.prenom} {detailModal.nom}</h3>
            <p className="text-sm text-muted-foreground">Sites : {formatSites(detailModal)}</p>
            <Button variant="outline" onClick={() => setDetailModal(null)}>Fermer</Button>
          </div>
        </div>
      )}

      {validateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 w-full max-w-md space-y-4">
            <h3 className="font-semibold">Valider le recruteur</h3>
            <p className="text-sm text-muted-foreground">
              {validateModal.prenom} {validateModal.nom} — {validateModal.nom_entreprise}
            </p>
            <div className="rounded-md border border-border bg-secondary/40 p-3 text-sm">
              <p className="font-medium text-foreground">Site attribué automatiquement</p>
              <p className="text-muted-foreground mt-1">{formatSites(validateModal)}</p>
            </div>            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setValidateModal(null)}>Annuler</Button>
              <Button disabled={actionId === validateModal.id} onClick={handleValidate} style={{ background: accentColor }}>
                Valider
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
