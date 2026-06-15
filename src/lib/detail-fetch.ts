import { api } from '@/lib/api';

export async function fetchApiDetail<T>(path: string): Promise<T> {
  const res = await api.get<{ data: T }>(path);
  return res.data.data;
}
