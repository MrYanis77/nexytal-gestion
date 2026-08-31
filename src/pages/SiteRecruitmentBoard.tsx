import type { ReactNode } from 'react';
import { RecrutementAdminPage } from './RecrutementAdminPage';

interface SiteRecruitmentBoardProps {
  siteId: number;
  color: string;
  title: string;
  description: string;
  icon: ReactNode;
  medicalMetiers?: boolean;
  entrepriseTabLabel?: string;
  addEntrepriseLabel?: string;
  mainRoleLabel?: string;
  showSitePricing?: boolean;
}

export function SiteRecruitmentBoard({
  siteId,
  color,
  title,
  description,
  icon,
  medicalMetiers = false,
  entrepriseTabLabel,
  addEntrepriseLabel,
  mainRoleLabel,
  showSitePricing = false,
}: SiteRecruitmentBoardProps) {
  return (
    <RecrutementAdminPage
      siteId={siteId}
      color={color}
      title={title}
      description={description}
      icon={icon}
      showRecruteurs
      showMetiers
      medicalMetiers={medicalMetiers}
      entrepriseTabLabel={entrepriseTabLabel}
      addEntrepriseLabel={addEntrepriseLabel}
      mainRoleLabel={mainRoleLabel}
      showSitePricing={showSitePricing}
    />
  );
}
