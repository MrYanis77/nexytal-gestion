import type { FieldDef } from '@/components/FormModal';
import { parseMoneyAmount } from '@/lib/money';

export type SitePricingPlan = {
  id: string;
  site_id: number;
  entity_type: string;
  entity_slug: string;
  plan_code: string;
  label: string;
  amount_eur: number;
  billing_unit: string;
  description?: string;
  is_active: boolean;
  sort_order: number;
};

export const PRICING_PLAN_ENTITY_TYPE_OPTIONS = [
  { value: 'formation', label: 'Formation' },
  { value: 'service', label: 'Service' },
  { value: 'coaching', label: 'Coaching' },
  { value: 'trainer', label: 'Formateur' },
  { value: 'other', label: 'Autre' },
];

export const PRICING_PLAN_BILLING_UNIT_OPTIONS = [
  { value: 'forfait', label: 'Forfait' },
  { value: 'heure', label: 'Heure' },
  { value: 'jour', label: 'Jour' },
  { value: 'mois', label: 'Mois' },
  { value: 'session', label: 'Session' },
];

export function pricingPlanBillingLabel(unit: string): string {
  return PRICING_PLAN_BILLING_UNIT_OPTIONS.find(o => o.value === unit)?.label ?? unit;
}

export function pricingPlanEntityLabel(type: string): string {
  return PRICING_PLAN_ENTITY_TYPE_OPTIONS.find(o => o.value === type)?.label ?? type;
}

export function pricingPlanFromApi(row: Record<string, unknown>): SitePricingPlan {
  return {
    id: String(row.id),
    site_id: Number(row.site_id ?? 0),
    entity_type: String(row.entity_type ?? 'service'),
    entity_slug: String(row.entity_slug ?? ''),
    plan_code: String(row.plan_code ?? 'default'),
    label: String(row.label ?? ''),
    amount_eur: parseMoneyAmount(row.amount_eur) ?? 0,
    billing_unit: String(row.billing_unit ?? 'forfait'),
    description: row.description ? String(row.description) : undefined,
    is_active: row.is_active !== 0 && row.is_active !== false,
    sort_order: Number(row.sort_order ?? 0),
  };
}

export function pricingPlanToApi(raw: Record<string, unknown>) {
  const amount = parseMoneyAmount(raw.amount_eur);
  if (amount == null) {
    throw new Error('Montant invalide');
  }

  return {
    entity_type: raw.entity_type || 'service',
    entity_slug: String(raw.entity_slug ?? '').trim(),
    plan_code: String(raw.plan_code ?? 'default').trim(),
    label: String(raw.label ?? '').trim(),
    amount_eur: amount,
    billing_unit: raw.billing_unit || 'forfait',
    description: raw.description ? String(raw.description).trim() : null,
    is_active: raw.is_active !== false && raw.is_active !== 0 ? 1 : 0,
    sort_order: raw.sort_order != null && raw.sort_order !== '' ? Number(raw.sort_order) : 0,
  };
}

export function buildPricingPlanFields(): FieldDef[] {
  return [
    { key: 'label', label: 'Libellé', type: 'text', required: true, span: true, placeholder: 'Bilan Essentiel' },
    { key: 'amount_eur', label: 'Prix (€)', type: 'text', required: true, placeholder: '1600', hint: 'Montant en euros (ex. 1600 ou 1600,00).' },
    { key: 'billing_unit', label: 'Unité de facturation', type: 'select', required: true, options: PRICING_PLAN_BILLING_UNIT_OPTIONS },
    { key: 'entity_type', label: 'Type d\'entité', type: 'select', required: true, options: PRICING_PLAN_ENTITY_TYPE_OPTIONS },
    { key: 'entity_slug', label: 'Slug entité', type: 'text', required: true, placeholder: 'bilan-competences', hint: 'Identifiant technique du service (URL ou catalogue).' },
    { key: 'plan_code', label: 'Code plan', type: 'text', required: true, placeholder: 'essentiel', hint: 'Code unique pour ce service (ex. essentiel, premium).' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'number' },
    { key: 'is_active', label: 'Actif (visible)', type: 'switch', span: true },
  ];
}
