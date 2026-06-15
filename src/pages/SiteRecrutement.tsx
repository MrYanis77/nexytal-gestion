import { Briefcase } from 'lucide-react';
import { RecrutementAdminPage } from './RecrutementAdminPage';

const COLOR = '#2563EB';

export default function SiteRecrutement() {
  return (
    <RecrutementAdminPage
      siteId={2}
      color={COLOR}
      title="Nexytal Recrutement"
      description="Gérez les offres d'emploi, les candidatures et le contenu du site"
      icon={<Briefcase className="w-5 h-5" />}
    />
  );
}
