import { api } from '@/lib/api';
import { OffreEmploi, Metier } from '@/contexts/AppContext';
import { offerFromApi, professionFromApi } from '@/lib/mappers';

export const medicalService = {
  getOffres: async (): Promise<OffreEmploi[]> => {
    const response = await api.get('/recrutement/offers?site=medical');
    return (response.data.data ?? []).map((row: Record<string, unknown>) => offerFromApi(row));
  },
  getMetiers: async (): Promise<Metier[]> => {
    const response = await api.get('/recrutement/professions?site=medical');
    const rows = response.data.data ?? response.data ?? [];
    return (Array.isArray(rows) ? rows : []).map((row: Record<string, unknown>) => professionFromApi(row));
  },
};
