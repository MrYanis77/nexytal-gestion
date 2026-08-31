import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { coachFromApi, buildCoachFields, coachToApi } from '@/lib/mappers';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal } from '@/components/FormModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Heart, CheckCircle, XCircle, Pencil } from 'lucide-react';
import { toast } from 'sonner';

interface PendingCoach {
  id: string;
  name: string;
  title: string;
  email: string;
  site_name: string;
  site_id: number;
  location: string;
  date: string;
  status: string;
  stale: boolean;
}

export default function CoachesValidationPage() {
  const [editCoach, setEditCoach] = useState<{ item: PendingCoach; detail: Record<string, unknown> } | null>(null);
  const [rejectModal, setRejectModal] = useState<{ id: string; name: string } | null>(null);
  const [rejectMotif, setRejectMotif] = useState('');
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [actionId, setActionId] = useState<string | null>(null);

  const { data, refetch, loading } = useFetch<{
    data: Record<string, unknown>[];
    pagination?: { total?: number };
  }>('/coaching/coaches/pending');

  const { data: specialtiesData } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/specialties');
  const { data: certificationsData } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/certifications');
  const { data: languagesData } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/languages');
  const { data: citiesData } = useFetch<{ data: Record<string, unknown>[] }>('/coaching/cities');

  const specialtyOptions = useMemo(
    () => (specialtiesData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.name) })),
    [specialtiesData],
  );
  const certificationOptions = useMemo(
    () => (certificationsData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [certificationsData],
  );
  const languageOptions = useMemo(
    () => (languagesData?.data ?? []).map(l => ({ value: String(l.id), label: `${l.flag_emoji || ''} ${l.name}`.trim() })),
    [languagesData],
  );
  const cityOptions = useMemo(
    () => (citiesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [citiesData],
  );

  const coachFields = useMemo(() => {
    const fields = buildCoachFields(specialtyOptions, certificationOptions, languageOptions, cityOptions);
    return fields.map(f => (f.key === 'status'
      ? {
          ...f,
          options: [{ value: 'pending_review', label: 'En attente de validation' }],
        }
      : f));
  }, [specialtyOptions, certificationOptions, languageOptions, cityOptions]);

  const coaches = useMemo(
    () => (data?.data ?? []).map(row => {
      const c = coachFromApi(row);
      const created = String(row.created_at ?? '');
      const stale = created ? (Date.now() - new Date(created).getTime()) > 48 * 3600 * 1000 : false;
      return {
        id: c.id as string,
        name: String(c.name),
        title: String(c.title),
        email: String(c.email),
        site_name: String(row.site_name ?? 'Nexytal Coaching'),
        site_id: Number(row.site_id ?? 6),
        location: String(c.location ?? ''),
        date: created ? new Date(created).toLocaleDateString('fr-FR') : '—',
        status: String(c.status),
        stale,
      } satisfies PendingCoach;
    }),
    [data],
  );

  const pendingCount = data?.pagination?.total ?? coaches.length;

  const openEdit = async (item: PendingCoach) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/coaching/coaches/${item.id}?site_id=${item.site_id}`);
      const detail = coachFromApi(row);
      if (Array.isArray(row.specialties)) {
        detail.specialty_ids = (row.specialties as number[]).join(',');
      }
      if (Array.isArray(row.certifications)) {
        detail.certification_ids = (row.certifications as number[]).join(',');
      }
      if (Array.isArray(row.languages)) {
        detail.language_ids = (row.languages as number[]).join(',');
      }
      setEditCoach({ item, detail });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le profil.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveCoach = async (raw: Record<string, unknown>) => {
    if (!editCoach) return;
    try {
      await api.put(`/coaching/coaches/${editCoach.item.id}?site_id=${editCoach.item.site_id}`, coachToApi(raw));
      toast.success('Profil mis à jour.');
      refetch();
      const row = await fetchApiDetail<Record<string, unknown>>(
        `/coaching/coaches/${editCoach.item.id}?site_id=${editCoach.item.site_id}`,
      );
      const detail = coachFromApi(row);
      if (Array.isArray(row.specialties)) detail.specialty_ids = (row.specialties as number[]).join(',');
      setEditCoach({ item: editCoach.item, detail });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const handlePublish = async (item: PendingCoach) => {
    setActionId(item.id);
    try {
      await api.post(`/coaching/coaches/${item.id}/publish`);
      toast.success(`« ${item.name} » publié sur coaching.nexytal.com.`);
      if (editCoach?.item.id === item.id) setEditCoach(null);
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
      await api.post(`/coaching/coaches/${rejectModal.id}/reject`, {
        motif_refus: rejectMotif.trim() || null,
      });
      toast.success('Profil refusé.');
      if (editCoach?.item.id === rejectModal.id) setEditCoach(null);
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
          <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ background: 'rgba(245,158,11,0.15)' }}>
            <Heart className="w-5 h-5" style={{ color: '#F59E0B' }} />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground">Validation des profils coach</h1>
            <p className="text-sm text-muted-foreground">
              File d&apos;attente — {pendingCount} profil{pendingCount !== 1 ? 's' : ''} à examiner (coaching.nexytal.com)
            </p>
          </div>
        </div>
      </div>

      {coaches.some(c => c.stale) && (
        <div className="px-6 py-2 border-b border-border text-xs text-amber-500">
          {coaches.filter(c => c.stale).length} profil(s) en attente depuis plus de 48h
        </div>
      )}

      {loadingDetail && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className="flex-1 overflow-y-auto p-6">
        {loading && !data ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : (
          <DataTable<PendingCoach>
            data={coaches}
            accentColor="#F59E0B"
            emptyMessage="Aucun profil coach en attente de validation."
            searchKeys={['name', 'title', 'email', 'location']}
            columns={[
              {
                key: 'name',
                label: 'Coach',
                render: c => (
                  <div>
                    <p className="font-medium text-foreground flex items-center gap-2">
                      {c.name}
                      {c.stale && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-400">+48h</span>
                      )}
                    </p>
                    <p className="text-xs text-muted-foreground">{c.title}</p>
                  </div>
                ),
              },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'location', label: 'Ville', hidden: 'lg' },
              { key: 'date', label: 'Soumis le', hidden: 'lg' },
              { key: 'status', label: 'Statut', render: c => <StatusBadge statut={c.status} /> },
              {
                key: 'actions',
                label: 'Actions',
                render: c => (
                  <div className="flex items-center gap-1">
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0"
                      title="Voir / modifier"
                      disabled={actionId === c.id}
                      onClick={() => openEdit(c)}
                    >
                      <Pencil className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-emerald-500 hover:text-emerald-400"
                      title="Publier"
                      disabled={actionId === c.id}
                      onClick={() => handlePublish(c)}
                    >
                      <CheckCircle className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-red-400 hover:text-red-300"
                      title="Refuser"
                      disabled={actionId === c.id}
                      onClick={() => setRejectModal({ id: c.id, name: c.name })}
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

      <FormModal
        open={!!editCoach}
        onClose={() => setEditCoach(null)}
        onSave={saveCoach}
        wide
        title={editCoach ? `Profil — ${editCoach.item.name}` : 'Profil coach'}
        fields={coachFields}
        initialData={editCoach?.detail}
        accentColor="#F59E0B"
        footerExtra={editCoach ? (
          <div className="flex gap-2 mr-auto">
            <Button
              type="button"
              size="sm"
              className="bg-emerald-600 hover:bg-emerald-500"
              disabled={actionId === editCoach.item.id}
              onClick={() => handlePublish(editCoach.item)}
            >
              <CheckCircle className="w-4 h-4 mr-1" /> Publier
            </Button>
            <Button
              type="button"
              size="sm"
              variant="destructive"
              disabled={actionId === editCoach.item.id}
              onClick={() => setRejectModal({ id: editCoach.item.id, name: editCoach.item.name })}
            >
              <XCircle className="w-4 h-4 mr-1" /> Refuser
            </Button>
          </div>
        ) : undefined}
      />

      {rejectModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 max-w-md w-full shadow-xl">
            <h3 className="text-lg font-semibold mb-2">Refuser le profil</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Refuser « {rejectModal.name} » ? Le profil ne sera pas visible sur le site public.
            </p>
            <Input
              placeholder="Motif (optionnel, interne)"
              value={rejectMotif}
              onChange={e => setRejectMotif(e.target.value)}
              className="mb-4"
            />
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => { setRejectModal(null); setRejectMotif(''); }}>
                Annuler
              </Button>
              <Button variant="destructive" disabled={actionId === rejectModal.id} onClick={handleReject}>
                Confirmer le refus
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
