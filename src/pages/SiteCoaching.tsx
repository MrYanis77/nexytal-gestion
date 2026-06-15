import { Target } from 'lucide-react';
import { BlogSitePage } from './BlogSitePage';

export default function SiteCoaching() {
  return (
    <BlogSitePage
      siteId={6}
      color="#F59E0B"
      title="Nexytal Coaching"
      description="Articles et actualités pour le site coaching"
      icon={<Target className="w-5 h-5" />}
    />
  );
}
