import { Stethoscope } from 'lucide-react';
import { SiteRecruitmentBoard } from './SiteRecruitmentBoard';

const COLOR = '#059669';

export default function SiteMedical() {
  return (
    <SiteRecruitmentBoard
      siteId={3}
      color={COLOR}
      title="Nexytal Médical"
      description="Offres, candidatures, établissements et actualités du site médical"
      icon={<Stethoscope className="w-5 h-5" />}
      medicalMetiers
      entrepriseTabLabel="Établissements"
      addEntrepriseLabel="Nouvel établissement"
      mainRoleLabel="Recruteur"
    />
  );
}
