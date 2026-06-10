import { api } from '@/lib/api';
import { BlogArticle } from '@/contexts/AppContext';

export const blogService = {
  getArticles: async (site?: string): Promise<BlogArticle[]> => {
    const url = site ? `/blog/posts?site=${site}` : '/blog/posts';
    const response = await api.get(url);
    return response.data.data || [];
  }
};
