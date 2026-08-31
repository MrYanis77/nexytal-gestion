import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import {
  buildOfferFields,
  offerDetailFromApi,
  offerFromApi,
  offerToApi,
} from '@/lib/mappers';
import { ValidationSiteFilter } from '@/components/ValidationSiteFilter';
import { useValidationSiteScope } from '@/hooks/useValidationSiteScope';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal } from '@/components/FormModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { ClipboardCheck, CheckCircle, XCircle, Pencil } from 'lucide-react';
import { toast } from 'sonner';

interface PendingOffer {
  id: string;
  titre: string;
  entreprise: string;
  site_name: string;
  site_id: number;
  recruteur_email: string;
  date: string;
  statut: string;
  type_contrat: string;
  stale: boolean;
}

export default function OffresValidationPage() {
  const { siteId, activeSite, jobSites, setSiteId } = useValidationSiteScope('/validation-offres');

  const [editOffer, setEditOffer] = useState<{ item: PendingOffer; detail: Record<string, unknown> } | null>(null);
  const [rejectModal, setRejectModal] = useState<{ id: string; titre: string; site_id: number } | null>(null);
  const [rejectMotif, setRejectMotif] = useState('');
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [actionId, setActionId] = useState<string | null>(null);
  const [contractFilter, setContractFilter] = useState('');

  const pendingUrl = siteId ? `/recrutement/offers/pending?site_id=${siteId}` : '/recrutement/offers/pending';

  const { data, refetch, loading } = useFetch<{
    data: Record<string, unknown>[];
    pagination?: { total?: number };
  }>(pendingUrl);

  const editSiteId = editOffer?.item.site_id ?? null;

  const { data: entreprisesData } = useFetch<{ data: Record<string, unknown>[] }>(
    editSiteId ? `/recrutement/entreprises?site_id=${editSiteId}` : null,
  );
  const { data: jobsData } = useFetch<{ data: Record<string, unknown>[] }>(
    editSiteId ? `/recrutement/jobs?site_id=${editSiteId}` : null,
  );
  const { data: recruteursData } = useFetch<{ data: Record<string, unknown>[] }>(
    editSiteId ? `/recrutement/recruteurs?site_id=${editSiteId}` : null,
  );

  const entrepriseOptions = useMemo(
    () => (entreprisesData?.data ?? []).map(e => ({ value: String(e.id), label: String(e.nom) })),
    [entreprisesData],
  );
  const metierOptions = useMemo(
    () => (jobsData?.data ?? []).map(j => ({ value: String(j.id), label: String(j.libelle ?? j.nom) })),
    [jobsData],
  );
  const recruteurOptions = useMemo(
    () => (recruteursData?.data ?? []).map(r => ({
      value: String(r.id),
      label: `${r.prenom} ${r.nom} (${r.entreprise_nom ?? r.nom_entreprise ?? '—'})`,
    })),
    [recruteursData],
  );

  const offerFields = useMemo(() => {
    const fields = buildOfferFields(entrepriseOptions, metierOptions, recruteurOptions, {
      includeMetier: metierOptions.length > 0,
    });
    return fields.map(f => (f.key === 'statut'
      ? {
          ...f,
          options: [
            { value: 'brouillon', label: 'En attente de validation' },
          ],
        }
      : f));
  }, [entrepriseOptions, metierOptions, recruteurOptions]);

  const offres = useMemo(
    () => (data?.data ?? []).map(row => {
      const o = offerFromApi(row);
      const created = String(row.created_at ?? '');
      const stale = created ? (Date.now() - new Date(created).getTime()) > 48 * 3600 * 1000 : false;
      return {
        id: o.id,
        titre: o.titre,
        entreprise: o.entreprise,
        site_name: String(row.site_name ?? ''),
        site_id: Number(row.site_id ?? 0),
        recruteur_email: String(row.recruteur_email ?? row.soumis_par_email ?? ''),
        date: o.date,
        statut: o.statut,
        type_contrat: String(row.type_contrat ?? ''),
        stale,
      } satisfies PendingOffer;
    }).filter(o => {
      if (contractFilter && o.type_contrat !== contractFilter) return false;
      return true;
    }),
    [data, contractFilter],
  );

  const pendingCount = data?.pagination?.total ?? offres.length;

  const openEdit = async (item: PendingOffer) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/recrutement/offers/${item.id}`);
      const detail = offerDetailFromApi(row);
      const siteId = Number(row.site_id ?? detail.site_id ?? item.site_id);
      setEditOffer({
        item: { ...item, site_id: siteId },
        detail,
      });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le détail.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveOffer = async (raw: Record<string, unknown>) => {
    if (!editOffer) return;
    try {
      await api.put(`/recrutement/offers/${editOffer.item.id}`, offerToApi(raw));
      toast.success('Offre mise à jour.');
      refetch();
      const row = await fetchApiDetail<Record<string, unknown>>(`/recrutement/offers/${editOffer.item.id}`);
      setEditOffer({
        item: editOffer.item,
        detail: offerDetailFromApi(row),
      });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const handlePublish = async (item: PendingOffer) => {
    setActionId(item.id);
    try {
      await api.post(`/recrutement/offers/${item.id}/publish`);
      toast.success(`« ${item.titre} » publiée.`);
      if (editOffer?.item.id === item.id) setEditOffer(null);
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Publication impossible.'));
    } finally {
      setActionId(null);
    }
  };

  const handleReject = async () => {
    if (!rejectModal) return;
    setActionId(rejectModal.id);
    try {
      await api.post(`/recrutement/offers/${rejectModal.id}/reject`, {
        motif_refus: rejectMotif.trim() || null,
      });
      toast.success('Offre refusée.');
      if (editOffer?.item.id === rejectModal.id) setEditOffer(null);
      setRejectModal(null);
      setRejectMotif('');
      refetch();
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Refus impossible.'));
    } finally {
      setActionId(null);
    }
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <div className="px-6 py-5 border-b border-border">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ background: 'rgba(37,99,235,0.15)' }}>
            <ClipboardCheck className="w-5 h-5" style={{ color: '#2563EB' }} />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground">Validation des offres</h1>
            <p className="text-sm text-muted-foreground">
              File d&apos;attente — {pendingCount} offre{pendingCount !== 1 ? 's' : ''} à examiner
              {activeSite ? ` (${activeSite.label})` : ' (tous sites recrutement)'}
            </p>
          </div>
        </div>
      </div>

      <ValidationSiteFilter
        jobSites={jobSites}
        siteId={siteId}
        onSiteChange={setSiteId}
        description="Offres en brouillon soumises sur le site sélectionné."
      />

      <div className="px-6 py-3 border-b border-border flex flex-wrap gap-3">
        <select
          value={contractFilter}
          onChange={e => setContractFilter(e.target.value)}
          className="text-sm rounded-lg border border-border bg-card px-3 py-1.5"
        >
          <option value="">Tous contrats</option>
          <option value="cdi">CDI</option>
          <option value="cdd">CDD</option>
          <option value="interim">Intérim</option>
          <option value="freelance">Freelance</option>
          <option value="alternance">Alternance</option>
          <option value="stage">Stage</option>
        </select>
        {offres.some(o => o.stale) && (
          <span className="text-xs text-amber-500 self-center">
            {offres.filter(o => o.stale).length} offre(s) en attente depuis plus de 48h
          </span>
        )}
      </div>

      {loadingDetail && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className="flex-1 overflow-y-auto p-6">
        {loading && !data ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : (
          <DataTable<PendingOffer>
            data={offres}
            accentColor="#2563EB"
            emptyMessage="Aucune offre en attente de validation."
            searchKeys={['titre', 'entreprise', 'site_name', 'recruteur_email']}
            columns={[
              { key: 'titre', label: 'Offre', render: o => (
                <div>
                  <p className="font-medium text-foreground flex items-center gap-2">
                    {o.titre}
                    {o.stale && (
                      <span className="text-[10px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-400">+48h</span>
                    )}
                  </p>
                  <p className="text-xs text-muted-foreground">{o.entreprise}</p>
                </div>
              )},
              { key: 'site_name', label: 'Site', hidden: 'md' },
              { key: 'type_contrat', label: 'Contrat', hidden: 'md', render: o => o.type_contrat.toUpperCase() },
              { key: 'recruteur_email', label: 'Contact recruteur', hidden: 'lg' },
              { key: 'date', label: 'Soumise le', hidden: 'lg' },
              { key: 'statut', label: 'Statut', render: o => <StatusBadge statut={o.statut} /> },
              {
                key: 'actions',
                label: 'Actions',
                render: o => (
                  <div className="flex items-center gap-1">
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0"
                      title="Voir / modifier"
                      onClick={() => openEdit(o)}
                    >
                      <Pencil className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-green-500"
                      title="Publier"
                      disabled={actionId === o.id}
                      onClick={() => handlePublish(o)}
                    >
                      <CheckCircle className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-red-400"
                      title="Refuser"
                      disabled={actionId === o.id}
                      onClick={() => setRejectModal({ id: o.id, titre: o.titre, site_id: o.site_id })}
                    >
                      <XCircle className="w-4 h-4" />
                    </Button>
                  </div>
                ),
              },
            ]}
          />
        )}
      </div>

      {editOffer && (
        <FormModal
          open
          wide
          onClose={() => setEditOffer(null)}
          onSave={saveOffer}
          title={`${editOffer.detail.titre} — ${editOffer.item.site_name}`}
          fields={offerFields}
          initialData={editOffer.detail}
          accentColor="#2563EB"
          footerExtra={(
            <>
              <Button
                variant="outline"
                disabled={!!actionId}
                onClick={() => setRejectModal({
                  id: editOffer.item.id,
                  titre: editOffer.item.titre,
                  site_id: editOffer.item.site_id,
                })}
              >
                Refuser
              </Button>
              <Button
                disabled={!!actionId}
                style={{ background: '#10B981' }}
                onClick={() => handlePublish(editOffer.item)}
              >
                <CheckCircle className="w-4 h-4 mr-2" />
                Publier
              </Button>
            </>
          )}
        />
      )}

      {rejectModal && (
        <div className="fixed inset-0 z-[70] flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 w-full max-w-md space-y-4">
            <h3 className="font-semibold text-foreground">Refuser l&apos;offre</h3>
            <p className="text-sm text-muted-foreground">{rejectModal.titre}</p>
            <div>
              <label className="text-sm text-muted-foreground">Motif (optionnel)</label>
              <Input
                value={rejectMotif}
                onChange={e => setRejectMotif(e.target.value)}
                placeholder="Raison du refus…"
                className="mt-1"
              />
            </div>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => { setRejectModal(null); setRejectMotif(''); }}>
                Annuler
              </Button>
              <Button variant="destructive" disabled={actionId === rejectModal.id} onClick={handleReject}>
                Refuser
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
