import { api } from '@/lib/api';
import { BlogArticle } from '@/contexts/AppContext';
import { blogPostFromApi } from '@/lib/mappers';

export const trainerService = {
  getArticles: async (): Promise<BlogArticle[]> => {
    const response = await api.get('/blog/posts?site=trainer');
    return (response.data.data ?? []).map((row: Record<string, unknown>) => blogPostFromApi(row));
  },
};
