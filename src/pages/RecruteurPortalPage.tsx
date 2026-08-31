import { useMemo, useState } from 'react';
import { useFetch } from '@/hooks/useFetch';
import { api, downloadPortalAttachment } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import ScoreBadge from '@/components/ScoreBadge';
import { StatusBadge } from '@/components/DataTable';
import { Briefcase, ChevronRight, CheckCircle, Filter, Download, FileText } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';

interface PortalOffer {
  id: number;
  titre: string;
  entreprise_nom: string;
  lieu: string | null;
  statut: string;
  created_at: string;
}

interface PortalCandidature {
  id: number;
  type?: 'external' | 'internal';
  prenom: string;
  nom: string;
  email: string | null;
  telephone: string | null;
  score_nexytal: number | null;
  note_nexytal: string | null;
  verifie_nexytal: number;
  statut: string;
  lettre_motivation: string | null;
  cv_filename?: string | null;
  has_cv?: boolean;
  has_lettre?: boolean;
  cv_download_url?: string | null;
  lettre_download_url?: string | null;
  date_candidature: string;
}

const PIPELINE_STEPS = ['recue', 'vue', 'shortlist', 'entretien', 'offre', 'refusee'] as const;
const PIPELINE_LABELS: Record<string, string> = {
  recue: 'Reçue',
  vue: 'Vue',
  shortlist: 'Shortlist',
  entretien: 'Entretien',
  offre: 'Offre',
  refusee: 'Refusée',
};

export default function RecruteurPortalPage() {
  const [selectedOffer, setSelectedOffer] = useState<number | null>(null);
  const [selectedOfferTitle, setSelectedOfferTitle] = useState('');
  const [candidatures, setCandidatures] = useState<PortalCandidature[]>([]);
  const [loadingCand, setLoadingCand] = useState(false);
  const [showVerifiedOnly, setShowVerifiedOnly] = useState(false);
  const [detailModal, setDetailModal] = useState<PortalCandidature | null>(null);
  const [updatingId, setUpdatingId] = useState<number | null>(null);

  const { data, loading } = useFetch<{ data: PortalOffer[] }>('/recruteur/offres');

  const offres = useMemo(() => data?.data ?? [], [data]);

  const openCandidatures = async (offerId: number, titre: string) => {
    setSelectedOffer(offerId);
    setSelectedOfferTitle(titre);
    setLoadingCand(true);
    try {
      const res = await api.get<{ data: { candidatures: PortalCandidature[] } }>(
        `/recruteur/offres/${offerId}/candidatures`,
      );
      setCandidatures(res.data.data.candidatures ?? []);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger les candidatures'));
      setCandidatures([]);
    } finally {
      setLoadingCand(false);
    }
  };

  const filteredCandidatures = useMemo(() => {
    let list = [...candidatures];
    if (showVerifiedOnly) {
      list = list.filter(c => c.verifie_nexytal);
    }
    // Tri : vérifiés en premier, puis par score décroissant
    list.sort((a, b) => {
      if (a.verifie_nexytal !== b.verifie_nexytal) return b.verifie_nexytal - a.verifie_nexytal;
      return (b.score_nexytal ?? -1) - (a.score_nexytal ?? -1);
    });
    return list;
  }, [candidatures, showVerifiedOnly]);

  const changeStatus = async (candidatureId: number, newStatus: string) => {
    setUpdatingId(candidatureId);
    try {
      await api.post(`/recrutement/externes/${candidatureId}/status`, {
        statut: newStatus,
      });
      toast.success(`Statut changé → ${PIPELINE_LABELS[newStatus]}`);
      // Mettre à jour localement
      setCandidatures(prev =>
        prev.map(c => (c.id === candidatureId ? { ...c, statut: newStatus } : c)),
      );
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Changement de statut impossible'));
    } finally {
      setUpdatingId(null);
    }
  };

  const candidatureTypeParam = (c: PortalCandidature) =>
    c.type === 'internal' ? 'interne' : 'externe';

  const downloadCv = async (c: PortalCandidature) => {
    const path =
      c.cv_download_url ??
      `/recruteur/candidatures/${c.id}/cv?type=${candidatureTypeParam(c)}`;
    try {
      await downloadPortalAttachment(path, `CV_${c.prenom}_${c.nom}.pdf`);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de télécharger le CV'));
    }
  };

  const downloadLettre = async (c: PortalCandidature) => {
    const path =
      c.lettre_download_url ??
      `/recruteur/candidatures/${c.id}/lettre?type=${candidatureTypeParam(c)}`;
    try {
      await downloadPortalAttachment(path, `Lettre_${c.prenom}_${c.nom}.txt`);
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de télécharger la lettre'));
    }
  };

  return (
    <div className="p-6 space-y-6 fade-up">
      <div>
        <h1
          className="text-2xl font-bold text-foreground flex items-center gap-2"
          style={{ fontFamily: 'Space Grotesk' }}
        >
          <Briefcase className="w-6 h-6 text-cyan-500" />
          Espace recruteur
        </h1>
        <p className="text-sm text-muted-foreground mt-1">
          Vos offres et candidatures — gérez votre pipeline de recrutement
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Liste des offres */}
        <div className="rounded-xl border border-border bg-card overflow-hidden">
          <div className="p-4 border-b border-border font-semibold text-sm">
            Mes offres ({offres.length})
          </div>
          {loading ? (
            <p className="p-4 text-sm text-muted-foreground">Chargement…</p>
          ) : offres.length === 0 ? (
            <p className="p-4 text-sm text-muted-foreground">
              Aucune offre.
            </p>
          ) : (
            <ul className="divide-y divide-border max-h-[70vh] overflow-y-auto">
              {offres.map(o => (
                <li key={o.id}>
                  <button
                    type="button"
                    className={`w-full text-left p-4 hover:bg-secondary/50 transition-colors flex items-center gap-3 ${
                      selectedOffer === o.id ? 'bg-secondary/30' : ''
                    }`}
                    onClick={() => openCandidatures(o.id, o.titre)}
                  >
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-foreground text-sm truncate">
                        {o.titre}
                      </p>
                      <div className="flex items-center gap-2 mt-0.5">
                        <p className="text-xs text-muted-foreground">
                          {o.entreprise_nom}
                        </p>
                        <StatusBadge statut={o.statut} />
                      </div>
                    </div>
                    <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0" />
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Candidatures */}
        <div className="lg:col-span-2 rounded-xl border border-border bg-card overflow-hidden">
          <div className="p-4 border-b border-border flex items-center justify-between">
            <div className="font-semibold text-sm">
              {selectedOffer
                ? `Candidatures — ${selectedOfferTitle}`
                : 'Candidatures'}
              {selectedOffer && (
                <span className="ml-2 text-xs text-muted-foreground">
                  ({filteredCandidatures.length})
                </span>
              )}
            </div>
            {selectedOffer && (
              <label className="flex items-center gap-2 cursor-pointer text-xs text-muted-foreground">
                <Filter className="w-3.5 h-3.5" />
                <input
                  type="checkbox"
                  checked={showVerifiedOnly}
                  onChange={e => setShowVerifiedOnly(e.target.checked)}
                  className="rounded border-border"
                />
                Vérifiés Nexytal uniquement
              </label>
            )}
          </div>

          {!selectedOffer ? (
            <p className="p-4 text-sm text-muted-foreground">
              Sélectionnez une offre pour voir les candidatures.
            </p>
          ) : loadingCand ? (
            <p className="p-4 text-sm text-muted-foreground">Chargement…</p>
          ) : filteredCandidatures.length === 0 ? (
            <p className="p-4 text-sm text-muted-foreground">
              Aucune candidature{showVerifiedOnly ? ' vérifiée' : ''}.
            </p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-muted-foreground border-b border-border">
                    <th className="p-3 font-medium">Candidat</th>
                    <th className="p-3 font-medium hidden md:table-cell">Score</th>
                    <th className="p-3 font-medium">Vérifié</th>
                    <th className="p-3 font-medium">Pipeline</th>
                    <th className="p-3 font-medium">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredCandidatures.map(c => (
                    <tr
                      key={c.id}
                      className="border-b border-border/50 hover:bg-secondary/20 transition-colors"
                    >
                      <td className="p-3">
                        <button
                          type="button"
                          className="text-left"
                          onClick={() => setDetailModal(c)}
                        >
                          <p className="font-medium text-foreground hover:underline">
                            {c.prenom} {c.nom}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {c.email ?? '—'}
                          </p>
                        </button>
                      </td>
                      <td className="p-3 hidden md:table-cell">
                        <ScoreBadge score={c.score_nexytal} />
                      </td>
                      <td className="p-3">
                        {c.verifie_nexytal ? (
                          <span className="inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full bg-emerald-500/15 text-emerald-400">
                            <CheckCircle className="w-3 h-3" /> Vérifié
                          </span>
                        ) : (
                          <span className="text-xs px-2 py-0.5 rounded-full bg-amber-500/15 text-amber-400">
                            En attente
                          </span>
                        )}
                      </td>
                      <td className="p-3">
                        <StatusBadge statut={c.statut} />
                      </td>
                      <td className="p-3">
                        <div className="flex items-center gap-1 flex-wrap">
                          {(c.has_cv || c.cv_filename) && (
                            <button
                              type="button"
                              onClick={() => downloadCv(c)}
                              className="text-[10px] px-2 py-0.5 rounded-full border border-cyan-500/30 text-cyan-400 hover:bg-cyan-500/10 inline-flex items-center gap-1"
                              title="Télécharger le CV"
                            >
                              <Download className="w-3 h-3" /> CV
                            </button>
                          )}
                          {(c.has_lettre || c.lettre_motivation) && (
                            <button
                              type="button"
                              onClick={() => downloadLettre(c)}
                              className="text-[10px] px-2 py-0.5 rounded-full border border-violet-500/30 text-violet-400 hover:bg-violet-500/10 inline-flex items-center gap-1"
                              title="Télécharger la lettre"
                            >
                              <FileText className="w-3 h-3" /> Lettre
                            </button>
                          )}
                          {PIPELINE_STEPS.filter(s => s !== c.statut).map(s => (
                            <button
                              key={s}
                              type="button"
                              disabled={updatingId === c.id}
                              onClick={() => changeStatus(c.id, s)}
                              className={`text-[10px] px-2 py-0.5 rounded-full border transition-colors ${
                                s === 'refusee'
                                  ? 'border-red-500/30 text-red-400 hover:bg-red-500/10'
                                  : s === 'offre'
                                    ? 'border-emerald-500/30 text-emerald-400 hover:bg-emerald-500/10'
                                    : 'border-border text-muted-foreground hover:text-foreground hover:bg-secondary'
                              }`}
                              title={`Passer à : ${PIPELINE_LABELS[s]}`}
                            >
                              {PIPELINE_LABELS[s]}
                            </button>
                          ))}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Modal détail candidature */}
      {detailModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="bg-card border border-border rounded-xl p-6 w-full max-w-lg max-h-[80vh] overflow-y-auto space-y-4">
            <h3 className="font-semibold text-lg text-foreground">
              {detailModal.prenom} {detailModal.nom}
            </h3>
            <div className="grid grid-cols-2 gap-3 text-sm">
              <div>
                <span className="text-muted-foreground">Email</span>
                <p>{detailModal.email ?? '—'}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Téléphone</span>
                <p>{detailModal.telephone ?? '—'}</p>
              </div>
              <div>
                <span className="text-muted-foreground">Score Nexytal</span>
                <p>
                  <ScoreBadge score={detailModal.score_nexytal} />
                </p>
              </div>
              <div>
                <span className="text-muted-foreground">Statut pipeline</span>
                <p>
                  <StatusBadge statut={detailModal.statut} />
                </p>
              </div>
            </div>
            {detailModal.note_nexytal && (
              <div>
                <p className="text-sm text-muted-foreground mb-1">
                  Synthèse Nexytal
                </p>
                <p className="text-sm bg-violet-500/10 rounded-lg p-3 text-foreground">
                  {detailModal.note_nexytal}
                </p>
              </div>
            )}
            {detailModal.lettre_motivation && (
              <div>
                <p className="text-sm text-muted-foreground mb-1">
                  Lettre de motivation
                </p>
                <p className="text-sm whitespace-pre-wrap bg-secondary/50 rounded-lg p-3">
                  {detailModal.lettre_motivation}
                </p>
              </div>
            )}
            <div className="flex flex-wrap gap-2 justify-end">
              {(detailModal.has_cv || detailModal.cv_filename) && (
                <Button variant="outline" size="sm" onClick={() => downloadCv(detailModal)}>
                  <Download className="w-4 h-4" /> CV
                </Button>
              )}
              {(detailModal.has_lettre || detailModal.lettre_motivation) && (
                <Button variant="outline" size="sm" onClick={() => downloadLettre(detailModal)}>
                  <FileText className="w-4 h-4" /> Lettre
                </Button>
              )}
              <Button variant="outline" onClick={() => setDetailModal(null)}>
                Fermer
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
