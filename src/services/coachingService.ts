import { api } from '@/lib/api';
import { Coach, Creneau } from '@/contexts/AppContext';

export const coachingService = {
  getCoaches: async (): Promise<Coach[]> => {
    const response = await api.get('/coaching/coaches');
    return response.data.data || [];
  },
  getCreneaux: async (): Promise<Creneau[]> => {
    const response = await api.get('/coaching/bookings'); // Assuming bookings or slots
    return response.data.data || [];
  }
};
