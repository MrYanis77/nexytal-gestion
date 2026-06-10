import { api } from '@/lib/api';
import { OffreEmploi } from '@/contexts/AppContext';
import { offerFromApi } from '@/lib/mappers';

export const recrutementService = {
  getOffres: async (): Promise<OffreEmploi[]> => {
    const response = await api.get('/recrutement/offers?site=recrutement');
    return (response.data.data ?? []).map((row: Record<string, unknown>) => offerFromApi(row));
  },
};
