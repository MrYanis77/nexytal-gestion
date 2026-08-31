import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { trainerDetailFromApi, buildTrainerFields, trainerToApi } from '@/lib/mappers';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal } from '@/components/FormModal';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { BookOpen, CheckCircle, XCircle, Pencil } from 'lucide-react';
import { toast } from 'sonner';

interface PendingTrainer {
  id: string;
  name: string;
  title: string;
  email: string;
  site_name: string;
  site_id: number;
  region: string;
  date: string;
  status: string;
  stale: boolean;
}

const ACCENT = '#0891B2';

function mapTrainerDetail(row: Record<string, unknown>) {
  const detail = trainerDetailFromApi(row);
  if (Array.isArray(row.expertises)) {
    detail.expertise_ids = (row.expertises as Array<{ id: number }>).map(e => String(e.id)).join(',');
    const primary = (row.expertises as Array<{ id: number; is_primary?: number }>).find(e => e.is_primary);
    if (primary) detail.primary_expertise_id = String(primary.id);
  }
  if (Array.isArray(row.skills)) {
    detail.skill_ids = (row.skills as Array<{ id: number }>).map(s => String(s.id)).join(',');
  }
  if (Array.isArray(row.certifications)) {
    detail.certification_ids = (row.certifications as Array<{ id: number }>).map(c => String(c.id)).join(',');
  }
  return detail;
}

export default function TrainersValidationPage() {
  const [editTrainer, setEditTrainer] = useState<{ item: PendingTrainer; detail: Record<string, unknown> } | null>(null);
  const [rejectModal, setRejectModal] = useState<{ id: string; name: string } | null>(null);
  const [rejectMotif, setRejectMotif] = useState('');
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [actionId, setActionId] = useState<string | null>(null);

  const { data, refetch, loading } = useFetch<{
    data: Record<string, unknown>[];
    pagination?: { total?: number };
  }>('/trainer/trainers/pending');

  const { data: expertisesData } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/expertises');
  const { data: skillsData } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/skills');
  const { data: certificationsData } = useFetch<{ data: Record<string, unknown>[] }>('/trainer/certifications');

  const expertiseOptions = useMemo(
    () => (expertisesData?.data ?? []).map(e => ({ value: String(e.id), label: String(e.label) })),
    [expertisesData],
  );
  const skillOptions = useMemo(
    () => (skillsData?.data ?? []).map(s => ({ value: String(s.id), label: String(s.name) })),
    [skillsData],
  );
  const certificationOptions = useMemo(
    () => (certificationsData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name) })),
    [certificationsData],
  );

  const trainerFields = useMemo(() => {
    const fields = buildTrainerFields(expertiseOptions, skillOptions, certificationOptions);
    return fields.map(f => (f.key === 'statut'
      ? { ...f, options: [{ value: 'en_attente', label: 'En attente de validation' }] }
      : f));
  }, [expertiseOptions, skillOptions, certificationOptions]);

  const trainers = useMemo(
    () => (data?.data ?? []).map(row => {
      const created = String(row.created_at ?? '');
      const stale = created ? (Date.now() - new Date(created).getTime()) > 48 * 3600 * 1000 : false;
      const prenom = String(row.first_name ?? '');
      const nom = String(row.last_name ?? '');
      return {
        id: String(row.id),
        name: `${prenom} ${nom}`.trim(),
        title: String(row.title ?? ''),
        email: String(row.email ?? ''),
        site_name: String(row.site_name ?? 'Nexytal Trainer'),
        site_id: Number(row.site_id ?? 5),
        region: String(row.city_name ?? row.region ?? ''),
        date: created ? new Date(created).toLocaleDateString('fr-FR') : '—',
        status: String(row.status ?? 'pending_review'),
        stale,
      } satisfies PendingTrainer;
    }),
    [data],
  );

  const pendingCount = data?.pagination?.total ?? trainers.length;

  const openEdit = async (item: PendingTrainer) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/trainer/trainers/${item.id}?site_id=${item.site_id}`);
      setEditTrainer({ item, detail: mapTrainerDetail(row) });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger le profil.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const saveTrainer = async (raw: Record<string, unknown>) => {
    if (!editTrainer) return;
    try {
      await api.put(`/trainer/trainers/${editTrainer.item.id}?site_id=${editTrainer.item.site_id}`, trainerToApi(raw));
      toast.success('Profil mis à jour.');
      refetch();
      const row = await fetchApiDetail<Record<string, unknown>>(
        `/trainer/trainers/${editTrainer.item.id}?site_id=${editTrainer.item.site_id}`,
      );
      setEditTrainer({ item: editTrainer.item, detail: mapTrainerDetail(row) });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la sauvegarde.'));
      throw err;
    }
  };

  const handlePublish = async (item: PendingTrainer) => {
    setActionId(item.id);
    try {
      await api.post(`/trainer/trainers/${item.id}/publish`);
      toast.success(`« ${item.name} » publié sur trainer.nexytal.com.`);
      if (editTrainer?.item.id === item.id) setEditTrainer(null);
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
      await api.post(`/trainer/trainers/${rejectModal.id}/reject`, {
        motif_refus: rejectMotif.trim() || null,
      });
      toast.success('Profil refusé.');
      if (editTrainer?.item.id === rejectModal.id) setEditTrainer(null);
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
          <div className="w-10 h-10 rounded-lg flex items-center justify-center" style={{ background: 'rgba(8,145,178,0.15)' }}>
            <BookOpen className="w-5 h-5" style={{ color: ACCENT }} />
          </div>
          <div>
            <h1 className="text-lg font-semibold text-foreground">Validation des profils formateur</h1>
            <p className="text-sm text-muted-foreground">
              File d&apos;attente — {pendingCount} profil{pendingCount !== 1 ? 's' : ''} à examiner (trainer.nexytal.com)
            </p>
          </div>
        </div>
      </div>

      {trainers.some(t => t.stale) && (
        <div className="px-6 py-2 border-b border-border text-xs text-amber-500">
          {trainers.filter(t => t.stale).length} profil(s) en attente depuis plus de 48h
        </div>
      )}

      {loadingDetail && (
        <div className="px-6 py-2 text-sm text-muted-foreground">Chargement du détail…</div>
      )}

      <div className="flex-1 overflow-y-auto p-6">
        {loading && !data ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : (
          <DataTable<PendingTrainer>
            data={trainers}
            accentColor={ACCENT}
            emptyMessage="Aucun profil formateur en attente de validation."
            searchKeys={['name', 'title', 'email', 'region']}
            columns={[
              {
                key: 'name',
                label: 'Formateur',
                render: t => (
                  <div>
                    <p className="font-medium text-foreground flex items-center gap-2">
                      {t.name}
                      {t.stale && (
                        <span className="text-[10px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-400">+48h</span>
                      )}
                    </p>
                    <p className="text-xs text-muted-foreground">{t.title}</p>
                  </div>
                ),
              },
              { key: 'email', label: 'Email', hidden: 'md' },
              { key: 'region', label: 'Ville', hidden: 'lg' },
              { key: 'date', label: 'Soumis le', hidden: 'lg' },
              { key: 'status', label: 'Statut', render: t => <StatusBadge statut={t.status} /> },
              {
                key: 'actions',
                label: 'Actions',
                render: t => (
                  <div className="flex items-center gap-1">
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0"
                      title="Voir / modifier"
                      disabled={actionId === t.id}
                      onClick={() => openEdit(t)}
                    >
                      <Pencil className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-emerald-500 hover:text-emerald-400"
                      title="Publier"
                      disabled={actionId === t.id}
                      onClick={() => handlePublish(t)}
                    >
                      <CheckCircle className="w-4 h-4" />
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="h-8 w-8 p-0 text-red-400 hover:text-red-300"
                      title="Refuser"
                      disabled={actionId === t.id}
                      onClick={() => setRejectModal({ id: t.id, name: t.name })}
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
        open={!!editTrainer}
        onClose={() => setEditTrainer(null)}
        onSave={saveTrainer}
        wide
        title={editTrainer ? `Profil — ${editTrainer.item.name}` : 'Profil formateur'}
        fields={trainerFields}
        initialData={editTrainer?.detail}
        accentColor={ACCENT}
        footerExtra={editTrainer ? (
          <div className="flex gap-2 mr-auto">
            <Button
              type="button"
              size="sm"
              className="bg-emerald-600 hover:bg-emerald-500"
              disabled={actionId === editTrainer.item.id}
              onClick={() => handlePublish(editTrainer.item)}
            >
              <CheckCircle className="w-4 h-4 mr-1" /> Publier
            </Button>
            <Button
              type="button"
              size="sm"
              variant="destructive"
              disabled={actionId === editTrainer.item.id}
              onClick={() => setRejectModal({ id: editTrainer.item.id, name: editTrainer.item.name })}
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
