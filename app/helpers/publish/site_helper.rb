# frozen_string_literal: true

module Publish
  module SiteHelper
    def site_has_no_course?(site)
      Course.includes(:sites).where(sites: { id: site.id }).count.zero?
    end
  end
end
