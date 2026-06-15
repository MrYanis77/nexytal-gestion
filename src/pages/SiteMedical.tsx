import { Stethoscope } from 'lucide-react';
import { RecrutementAdminPage } from './RecrutementAdminPage';

const COLOR = '#059669';

export default function SiteMedical() {
  return (
    <RecrutementAdminPage
      siteId={3}
      color={COLOR}
      title="Nexytal Médical"
      description="Gérez les offres médicales, les candidatures et le contenu du site"
      icon={<Stethoscope className="w-5 h-5" />}
      entrepriseTabLabel="Établissements"
      addEntrepriseLabel="Nouvel établissement"
      showRecruteurs={false}
    />
  );
}
