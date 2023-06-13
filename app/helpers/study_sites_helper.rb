# frozen_string_literal: true

module StudySitesHelper
  def study_site_has_courses?(provider, study_site)
    provider.courses.includes(:study_site_placements).where(study_site_placements: { site_id: study_site.id }).any?
  end
end
