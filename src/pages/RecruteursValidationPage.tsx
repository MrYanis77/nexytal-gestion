import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { ValidationSiteFilter } from '@/components/ValidationSiteFilter';
import { useValidationSiteScope } from '@/hooks/useValidationSiteScope';
import { siteLabelFromCode } from '@/lib/nexytal-sites';
import { Button } from '@/components/ui/button';
import { UserCheck, CheckCircle, XCircle, Eye } from 'lucide-react';
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

export default function RecruteursValidationPage() {
  const { siteId, activeSite, jobSites, setSiteId } = useValidationSiteScope('/validation-recruteurs');

  const [detailModal, setDetailModal] = useState<PendingRecruteur | null>(null);
  const [validateModal, setValidateModal] = useState<PendingRecruteur | null>(null);
  const [actionId, setActionId] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState('pending');

  const listUrl = useMemo(() => {
    const params = new URLSearchParams();
    if (statusFilter) params.set('status', statusFilter);
    if (siteId) params.set('site_id', String(siteId));
    const qs = params.toString();
    return `/recrutement/recruteurs${qs ? `?${qs}` : ''}`;
  }, [statusFilter, siteId]);

  const { data, refetch, loading } = useFetch<{ data: PendingRecruteur[] }>(listUrl);

  const recruteurs = useMemo(
    () =>
      (data?.data ?? []).map(r => ({
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

  const handleSuspend = async (item: PendingRecruteur) => {
    setActionId(item.id);
    try {
      await api.post(`/recrutement/recruteurs/${item.id}/suspend`);
      toast.success('Recruteur suspendu.');
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Suspension impossible.'));
    } finally {
      setActionId(null);
    }
  };


  const formatSites = (r: PendingRecruteur) => {
    const detected = (r.sites_detectes ?? []).filter(Boolean);
    const allowed = (r.sites_autorises ?? []).map(s => s.site).filter(Boolean);
    const codes = detected.length ? detected : allowed;
    if (codes.length === 0) return activeSite ? activeSite.label : 'A déterminer';
    return codes.map(siteLabelFromCode).join(', ');
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <div className="px-6 py-5 border-b border-border">
        <div className="flex items-center gap-3">
          <div
            className="w-10 h-10 rounded-lg flex items-center justify-center"
            style={{ background: 'rgba(16,185,129,0.15)' }}
          >
            <UserCheck className="w-5 h-5" style={{ color: '#10B981' }} />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground">Validation des recruteurs</h1>
            <p className="text-sm text-muted-foreground">
              {activeSite
                ? `Comptes recruteurs — ${activeSite.label}`
                : 'Comptes recruteurs en attente d\'activation (tous sites recrutement)'}
            </p>
          </div>
        </div>
      </div>

      <ValidationSiteFilter
        jobSites={jobSites}
        siteId={siteId}
        onSiteChange={setSiteId}
        description="Recruteurs liés au site via inscription ou offres déposées."
      />

      <div className="px-6 py-3 border-b border-border flex flex-wrap gap-2">
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
                ? 'border-transparent text-white bg-emerald-600'
                : 'border-border text-muted-foreground hover:text-foreground'
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto p-6">
        {loading && !data ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : (
          <DataTable<PendingRecruteur>
            data={recruteurs}
            accentColor="#10B981"
            emptyMessage={
              siteId
                ? 'Aucun recruteur pour ce site dans cette catégorie.'
                : 'Aucun recruteur dans cette catégorie.'
            }
            searchKeys={['email', 'nom_entreprise', 'prenom', 'nom']}
            columns={[
              {
                key: 'nom',
                label: 'Recruteur',
                render: r => (
                  <div>
                    <p className="font-medium text-foreground">
                      {r.prenom} {r.nom}
                    </p>
                    <p className="text-xs text-muted-foreground">{r.email}</p>
                  </div>
                ),
              },
              { key: 'nom_entreprise', label: 'Entreprise' },
              {
                key: 'sites',
                label: 'Site(s)',
                hidden: 'md',
                render: r => (
                  <span className="text-sm text-muted-foreground">{formatSites(r)}</span>
                ),
              },
              { key: 'fonction', label: 'Fonction', hidden: 'lg' },
              {
                key: 'status',
                label: 'Statut',
                render: r => <StatusBadge statut={r.status} />,
              },
              {
                key: 'created_at',
                label: 'Inscrit le',
                hidden: 'lg',
                render: r =>
                  r.created_at
                    ? new Date(r.created_at).toLocaleDateString('fr-FR')
                    : '—',
              },
              {
                key: 'actions',
                label: 'Actions',
                render: r => (
                  <div className="flex items-center gap-1">
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0"
                      title="Voir détail"
                      onClick={() => setDetailModal(r)}
                    >
                      <Eye className="w-4 h-4" />
                    </Button>
                    {r.status === 'pending' && (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="h-8 w-8 p-0 text-green-500"
                        title="Valider"
                        disabled={actionId === r.id}
                        onClick={() => {
                          setValidateModal(r);
                        }}
                      >
                        <CheckCircle className="w-4 h-4" />
                      </Button>
                    )}
                    {r.status === 'actif' && (
                      <Button
                        size="sm"
                        variant="ghost"
                        className="h-8 w-8 p-0 text-red-400"
                        title="Suspendre"
                        disabled={actionId === r.id}
                        onClick={() => handleSuspend(r)}
                      >
                        <XCircle className="w-4 h-4" />
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
            <h3 className="font-semibold text-lg text-foreground">
              {detailModal.prenom} {detailModal.nom}
            </h3>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <span className="text-muted-foreground">Email</span>
                <p>{detailModal.email}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Entreprise</span>
                <p>{detailModal.nom_entreprise}</p>
              </div>
              <div className="col-span-2">
                <span className="text-muted-foreground">Sites</span>
                <p>{formatSites(detailModal)}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Statut</span>
                <p><StatusBadge statut={detailModal.status} /></p>
              </div>
            </div>
            <div className="flex justify-end">
              <Button variant="outline" onClick={() => setDetailModal(null)}>Fermer</Button>
            </div>
          </div>
        </div>
      )}

      {validateModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 w-full max-w-md space-y-4">
            <h3 className="font-semibold text-foreground">Valider le recruteur</h3>
            <p className="text-sm text-muted-foreground">
              {validateModal.prenom} {validateModal.nom} — {validateModal.nom_entreprise}
            </p>
            {activeSite && (
              <p className="text-xs text-emerald-600">
                Contexte : {activeSite.label} (pré-sélectionné)
              </p>
            )}

            <div className="rounded-md border border-border bg-secondary/40 p-3 text-sm">
              <p className="font-medium text-foreground">Site attribué automatiquement</p>
              <p className="text-muted-foreground mt-1">{formatSites(validateModal)}</p>
            </div>

            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setValidateModal(null)}>
                Annuler
              </Button>
              <Button
                disabled={actionId === validateModal.id}
                onClick={handleValidate}
                className="bg-emerald-600 hover:bg-emerald-700 text-white"
              >
                Valider le compte
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
