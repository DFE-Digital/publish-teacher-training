# frozen_string_literal: true

module Publish
  module ProviderSchoolModelReads
    extend ActiveSupport::Concern

    included do
      helper_method :provider_school_ui_uses_new_model?, :school_show_path, :school_delete_path
    end

    NEW_MODEL_FROM_CYCLE_YEAR = 2027

    def provider_school_ui_uses_new_model?
      recruitment_cycle.year.to_i >= NEW_MODEL_FROM_CYCLE_YEAR
    end

    def school_show_path(school_id = school_resource_id)
      publish_provider_recruitment_cycle_school_path(
        @provider.provider_code,
        @recruitment_cycle.year,
        school_id,
      )
    end

    def school_delete_path(school_id = school_resource_id)
      delete_publish_provider_recruitment_cycle_school_path(
        @provider.provider_code,
        @recruitment_cycle.year,
        school_id,
      )
    end

    def school_resource_id
      if provider_school_ui_uses_new_model?
        @provider_school.id
      else
        @site.id
      end
    end
  end
end
