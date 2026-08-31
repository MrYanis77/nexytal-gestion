export type SpecOfferStatus = 'pending' | 'published' | 'rejected' | 'draft' | 'filled' | 'expired' | 'archived';
export type SpecCandidatureStatus = 'new' | 'viewed' | 'shortlisted' | 'rejected' | 'interview' | 'offer' | 'withdrawn';

const OFFER_STATUS_FR: Record<SpecOfferStatus, string> = {
  pending: 'En attente',
  published: 'Publiée',
  rejected: 'Refusée',
  draft: 'Brouillon',
  filled: 'Pourvue',
  expired: 'Expirée',
  archived: 'Archivée',
};

const CAND_STATUS_FR: Record<SpecCandidatureStatus, string> = {
  new: 'Nouveau',
  viewed: 'Vu',
  shortlisted: 'Shortlisté',
  rejected: 'Refusé',
  interview: 'Entretien',
  offer: 'Offre',
  withdrawn: 'Retiré',
};

export function specOfferStatusLabel(status: string): string {
  return OFFER_STATUS_FR[status as SpecOfferStatus] ?? status;
}

export function specCandidatureStatusLabel(status: string): string {
  return CAND_STATUS_FR[status as SpecCandidatureStatus] ?? status;
}

export interface RecrutementStats {
  offers_this_month: { pending: number; published: number; rejected: number };
  applications_today: number;
  average_affinity_score: number;
  offers_per_site: { site_id: number; site_name: string; count: number }[];
  period_days?: number;
}

export interface ScoringWeights {
  competences: number;
  experience: number;
  localisation: number;
  diplome: number;
  langues: number;
  bonus_champs_site: number;
}

export interface ScoringConfigResponse {
  site_id: number | null;
  weights: ScoringWeights;
  total_main: number;
}

export function scoringWeightsTotal(w: ScoringWeights): number {
  return w.competences + w.experience + w.localisation + w.diplome + w.langues;
}
