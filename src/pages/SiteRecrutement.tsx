import { Briefcase } from 'lucide-react';
import { SiteRecruitmentBoard } from './SiteRecruitmentBoard';

const COLOR = '#2563EB';

export default function SiteRecrutement() {
  return (
    <SiteRecruitmentBoard
      siteId={2}
      color={COLOR}
      title="Nexytal Recrutement"
      description="Offres, candidatures, entreprises et actualités du site recrutement IT"
      icon={<Briefcase className="w-5 h-5" />}
      mainRoleLabel="Recruteur"
    />
  );
}
