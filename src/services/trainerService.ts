import { api } from '@/lib/api';
import { Formateur } from '@/contexts/AppContext';

export const trainerService = {
  getFormateurs: async (): Promise<Formateur[]> => {
    // There doesn't seem to be a specific module for formateurs in the API list, maybe coaching or a custom route. 
    // We'll map to a generic or mock route if it doesn't exist.
    // I will use /formation/trainers or similar.
    try {
      const response = await api.get('/formation/trainers');
      return response.data.data || [];
    } catch {
      return [];
    }
  }
};
