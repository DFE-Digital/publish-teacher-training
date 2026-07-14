# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class ChecksController < ApplicationController
        before_action :new_form

        def show; end

        def update
          saved = false

          ActiveRecord::Base.transaction do
            # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
            # TODO School data remodel removal - replace this legacy Site-backed form save when support adds Provider::School directly.
            saved = @school_form.save!
            # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

            if saved
              ::ProviderSchools::Creator.call(
                provider: provider,
                gias_school_id: params[:school_id],
                site_code: @site.code,
                uuid: @site.uuid,
              )
            end
          end

          if saved
            redirect_to support_recruitment_cycle_provider_schools_path
            flash[:success] = t(".added")
          else
            render :show
          end
        end

      private

        def new_form
          @school_form = SchoolForm.new(provider, site, params: { gias_school_id: params[:school_id] })
        end

        # rubocop:disable Style/CommentAnnotation, Lint/RedundantCopDisableDirective
        # TODO School data remodel removal - remove when support school checks build Provider::School directly.
        def site
          @site ||= begin
            gias_school = GiasSchool.find(params[:school_id])
            @provider.sites.school.build(gias_school.school_attributes)
          end
        end
        # rubocop:enable Style/CommentAnnotation, Lint/RedundantCopDisableDirective

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end
      end
    end
  end
end
