import { api } from '@/lib/api';
import { OffreEmploi } from '@/contexts/AppContext';

export const recrutementService = {
  getOffres: async (): Promise<OffreEmploi[]> => {
    // IT offers
    const response = await api.get('/recrutement/offers?site=recrutement');
    return response.data.data || [];
  }
};
