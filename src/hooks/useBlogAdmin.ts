import { useMemo } from 'react';
import { useFetch } from '@/hooks/useFetch';
import {
  blogPostFromApi,
  buildBlogArticleFields,
  buildBlogCategoryFields,
  buildBlogAuthorFields,
  buildBlogTagFields,
} from '@/lib/mappers';

type ListResponse = { data: Record<string, unknown>[] };

export function useBlogAdmin(siteId: number | null, options?: { enabled?: boolean }) {
  const enabled = (options?.enabled ?? true) && siteId !== null;
  const SITE_QS = siteId ? `?site_id=${siteId}` : '';

  const { data: articlesData, refetch: refetchArticles } = useFetch<ListResponse>(enabled ? `/blog/posts${SITE_QS}` : null);
  const { data: blogCategoriesData, refetch: refetchCategories } = useFetch<ListResponse>(enabled ? `/blog/categories${SITE_QS}` : null);
  const { data: authorsData, refetch: refetchAuthors } = useFetch<ListResponse>(enabled ? `/blog/authors${SITE_QS}` : null);
  const { data: tagsData, refetch: refetchTags } = useFetch<ListResponse>(enabled ? `/blog/tags${SITE_QS}` : null);

  const categoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name ?? '') })),
    [blogCategoriesData],
  );

  const authorOptions = useMemo(
    () => (authorsData?.data ?? []).map(a => ({
      value: String(a.id),
      label: `${a.first_name ?? ''} ${a.last_name ?? ''}`.trim() || String(a.email ?? ''),
    })),
    [authorsData],
  );

  const tagOptions = useMemo(
    () => (tagsData?.data ?? []).map(t => ({ value: String(t.id), label: String(t.name ?? '') })),
    [tagsData],
  );

  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);

  const articleFields = useMemo(
    () => buildBlogArticleFields({ categoryOptions, authorOptions, tagOptions }),
    [categoryOptions, authorOptions, tagOptions],
  );

  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);
  const authorFields = useMemo(() => buildBlogAuthorFields(), []);
  const tagFields = useMemo(() => buildBlogTagFields(), []);

  return {
    SITE_QS,
    articles,
    articlesData,
    blogCategoriesData,
    authorsData,
    tagsData,
    articleFields,
    blogCategoryFields,
    authorFields,
    tagFields,
    refetchArticles,
    refetchCategories,
    refetchAuthors,
    refetchTags,
  };
}
