import { api } from '@/lib/api';
import { OffreEmploi, Metier } from '@/contexts/AppContext';

export const medicalService = {
  getOffres: async (): Promise<OffreEmploi[]> => {
    // Dans l'API PHP, on peut filtrer par site
    const response = await api.get('/recrutement/offers?site=medical');
    return response.data.data || [];
  },
  getMetiers: async (): Promise<Metier[]> => {
    const response = await api.get('/recrutement/professions');
    // On pourrait filtrer ici si l'API ne le fait pas
    return response.data.data || [];
  }
};
