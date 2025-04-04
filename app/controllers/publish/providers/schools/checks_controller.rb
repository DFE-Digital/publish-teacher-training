# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class ChecksController < ApplicationController
        helper_method :school_id
        before_action :site

        def show; end

        def update
          if @site.save
            redirect_to publish_provider_recruitment_cycle_schools_path, flash: { success_with_body: { title: t(".added"), body: @site.location_name } }
          else
            render :show
          end
        end

      private

        def site
          @site ||= begin
            gias_school = GiasSchool.find(school_id)
            @provider.sites.school.build(gias_school.school_attributes)
          end
        end

        def school_id
          # params[:school_id] comes from the school search
          # site: school_id comes from the checks#show form
          params[:school_id] || params.expect(site: [:school_id])[:school_id]
        end
      end
    end
  end
end
