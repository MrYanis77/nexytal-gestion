export function frontUserToApi(raw: Record<string, unknown>) {
  return {
    email: raw.email,
    password: raw.password || undefined,
    role: raw.role || 'candidat',
    email_verifie: raw.email_verifie ? 1 : 0,
    actif: raw.actif !== false ? 1 : 0,
  };
}

export function buildFrontUserFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'email', label: 'Email', type: 'email', required: true, span: true },
    { key: 'password', label: 'Mot de passe', type: 'text', placeholder: 'Laisser vide pour ne pas changer' },
    {
      key: 'role', label: 'Rôle', type: 'select', required: true,
      options: [
        { value: 'candidat', label: 'Candidat' },
        { value: 'recruteur', label: 'Recruteur' },
        { value: 'consultant', label: 'Consultant' },
      ],
    },
    { key: 'email_verifie', label: 'Email vérifié', type: 'switch' },
    { key: 'actif', label: 'Compte actif', type: 'switch' },
  ];
}
