# frozen_string_literal: true

module Support
  module Providers
    class SchoolsCheckController < SupportController
      before_action :new_form

      def show; end

      def update
        if @school_form.save!
          if params.keys.include?('another')
            redirect_to new_support_recruitment_cycle_provider_school_path
          else
            redirect_to support_recruitment_cycle_provider_schools_path
          end
          flash[:success] = t('support.providers.schools.added')
        else
          render template: 'support/schools/new'
        end
      end

      private

      def new_form
        @school_form = SchoolForm.new(provider, site)
      end

      def site
        @site ||= provider.sites.build
      end

      def provider
        @provider ||= Provider.find(params[:provider_id])
      end
    end
  end
end
