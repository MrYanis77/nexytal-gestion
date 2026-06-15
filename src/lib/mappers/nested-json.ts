/** Sérialise / parse les tableaux imbriqués saisis en JSON dans les formulaires admin */

export function parseJsonArray<T>(raw: unknown, fallback: T[] = []): T[] {
  if (Array.isArray(raw)) return raw as T[];
  if (typeof raw !== 'string' || !raw.trim()) return fallback;
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed as T[] : fallback;
  } catch {
    return fallback;
  }
}

export function stringifyJsonArray(value: unknown): string {
  if (!value) return '[]';
  if (typeof value === 'string') return value;
  try {
    return JSON.stringify(value, null, 2);
  } catch {
    return '[]';
  }
}

export function parseIdList(raw: unknown): number[] {
  if (Array.isArray(raw)) return raw.map(Number).filter(Boolean);
  if (typeof raw !== 'string') return [];
  return raw.split(',').map(s => Number(s.trim())).filter(n => !Number.isNaN(n) && n > 0);
}

export function competencesLinkFromApi(items: unknown): string {
  if (!Array.isArray(items)) return '[]';
  return stringifyJsonArray(items.map((c: Record<string, unknown>) => ({
    competence_id: c.competence_id ?? c.id,
    importance: c.importance ?? 'essentielle',
    niveau: c.niveau,
    annees: c.annees,
  })));
}

export function parseCompetencesLink(raw: unknown) {
  return parseJsonArray<Record<string, unknown>>(raw).map(c => ({
    competence_id: Number(c.competence_id),
    ...(c.importance ? { importance: String(c.importance) } : {}),
    ...(c.niveau ? { niveau: String(c.niveau) } : {}),
    ...(c.annees != null && c.annees !== '' ? { annees: Number(c.annees) } : {}),
  })).filter(c => !Number.isNaN(c.competence_id) && c.competence_id > 0);
}
