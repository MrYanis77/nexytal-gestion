import { api } from '@/lib/api';
import { Formation } from '@/contexts/AppContext';

export const formationService = {
  getFormations: async (): Promise<Formation[]> => {
    const response = await api.get('/formation/courses');
    return response.data.data || [];
  },
  getCategories: async () => {
    const response = await api.get('/formation/categories');
    return response.data.data || [];
  }
};
