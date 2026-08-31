/**
 * Parse un montant saisi (1600, 1600,00, 1 600, 1.600 en format FR).
 */
export function parseMoneyAmount(value: unknown): number | null {
  if (value == null || value === '') return null;
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.round(value * 100) / 100;
  }

  let s = String(value).trim().replace(/\u00a0/g, '').replace(/\s/g, '');

  if (s === '') return null;

  // Format européen : 1.600 ou 1.600,50
  if (/^\d{1,3}(\.\d{3})+(,\d+)?$/.test(s)) {
    s = s.replace(/\./g, '').replace(',', '.');
  } else {
    s = s.replace(',', '.');
  }

  const n = parseFloat(s);
  if (!Number.isFinite(n) || n < 0) return null;
  return Math.round(n * 100) / 100;
}

export function formatMoneyAmount(value: unknown): string {
  const n = typeof value === 'number' ? value : parseMoneyAmount(value);
  if (n == null) return '';
  return Number.isInteger(n) ? String(n) : n.toFixed(2).replace(/\.?0+$/, '');
}
