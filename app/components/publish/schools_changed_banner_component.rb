module Publish
  class SchoolsChangedBannerComponent < ViewComponent::Base
    def initialize(provider:)
      super

      @provider = provider
      @recruitment_cycle = provider.recruitment_cycle
    end

    def render?
      @recruitment_cycle.rollover_period_2026?
    end

    def title_text
      t(".header")
    end

    def heading_text
      show_minimal? ? t(".minimal_heading") : t(".content_heading")
    end

    def added_count
      @added_count ||= @provider.sites.school.register_import.count
    end

    def removed_count
      @removed_count ||= @provider
        .sites
        .school
        .with_discarded
        .where(discarded_via_script: true)
        .count
    end

    def show_added?
      added_count.positive?
    end

    def show_removed?
      removed_count.positive?
    end

    def show_minimal?
      !show_added? && !show_removed?
    end
  end
end
