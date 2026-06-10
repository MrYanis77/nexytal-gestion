import { AxiosError } from 'axios';

export function getApiErrorMessage(err: unknown, fallback = 'Une erreur est survenue'): string {
  const axiosError = err as AxiosError<{ error?: string; detail?: string; errors?: Record<string, string>; message?: string }>;
  const data = axiosError.response?.data;
  if (!data) return axiosError.message || fallback;
  if (data.errors && Object.keys(data.errors).length > 0) {
    return Object.values(data.errors).join(' · ');
  }
  
  if (data.detail && data.error) {
    return `${data.error} : ${data.detail}`;
  }
  
  return data.detail || data.error || data.message || fallback;
}
