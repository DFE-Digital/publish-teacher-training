# frozen_string_literal: true

module Publish
  module Providers
    class StudySitesCheckController < PublishController
      before_action :authorise_with_pundit
      before_action :new_form

      def show; end

      def update
        if @study_site_form.save!
          redirect_to publish_provider_recruitment_cycle_study_sites_path
          flash[:success] = t('publish.providers.study_sites.added')
        else
          render template: 'publish/providers/study_sites/new'
        end
      end

      private

      def authorise_with_pundit
        authorize provider, :show?
      end

      def new_form
        @study_site_form = ::Support::SchoolForm.new(provider, site)
      end

      def site
        @site ||= provider.study_sites.build
      end
    end
  end
end
