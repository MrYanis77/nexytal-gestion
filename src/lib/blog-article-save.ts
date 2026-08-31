import { api } from '@/lib/api';
import { blogPostToApi } from '@/lib/mappers/blog';

export async function saveBlogArticle(
  raw: Record<string, unknown>,
  siteQs: string,
  articleId?: string,
): Promise<void> {
  const payload = blogPostToApi(raw);

  if (articleId) {
    await api.put(`/blog/posts/${articleId}${siteQs}`, payload);
  } else {
    await api.post(`/blog/posts${siteQs}`, payload);
  }
}
