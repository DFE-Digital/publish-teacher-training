# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsCheckController < PublishController
      before_action :pundit
      before_action :new_form

      def show; end

      def update
        if @school_form.save!
          redirect_to publish_provider_recruitment_cycle_schools_path
          flash[:success] = t('support.providers.schools.added')
        else
          render template: 'publish/providers/schools/new'
        end
      end

      private

      def pundit
        authorize provider, :show?
      end

      def new_form
        @school_form = ::Support::SchoolForm.new(provider, site)
      end

      def site
        @site ||= provider.sites.build
      end

      def provider
        recruitment_cycle_id = RecruitmentCycle.find_by(year: params[:recruitment_cycle_year]).id
        @provider ||= Provider.find_by(provider_code: params[:provider_code], recruitment_cycle_id:)
      end
    end
  end
end
