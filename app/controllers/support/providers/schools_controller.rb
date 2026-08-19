# frozen_string_literal: true

module Support
  module Providers
    class SchoolsController < ApplicationController
      before_action :build_site, only: %i[index create]
      before_action :new_form, only: %i[index]
      before_action :reset_urn_form, only: %i[index]
      before_action :school, only: %i[show delete destroy]

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(provider.schools.ordered_by_name, limit: PER_PAGE)
      end

      def show; end

      def create
        @school_form = SchoolForm.new(provider, @site, params: site_params(:support_school_form))
        if @school_form.stash
          redirect_to support_recruitment_cycle_provider_schools_check_path
        else
          render(:new)
        end
      end

      def delete; end

      def destroy
        if school_removal.call
          redirect_to support_recruitment_cycle_provider_schools_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.deleted", resource: flash_resource) }
        else
          redirect_to delete_support_recruitment_cycle_provider_school_path(@provider.recruitment_cycle_year, @provider, school.uuid),
                      flash: { warning: cannot_remove_school_message }
        end
      end

    private

      def cannot_remove_school_message
        return t(".cannot_remove_only_school") if school_removal.only_school?

        t(".cannot_remove_school")
      end

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def flash_resource
        @flash_resource ||= "School"
      end

      def site_params(param_form_key)
        params.expect(param_form_key => SchoolForm::FIELDS)
      end

      def build_site
        @site = provider.sites.build
      end

      def new_form
        @school_form = SchoolForm.new(provider, @site)
        @school_form.clear_stash
      end

      def school
        @school ||= school_removal.school.decorate
      end
      helper_method :school

      def reset_urn_form
        URNForm.new(provider).clear_stash
      end

      def school_removal
        @school_removal ||= ProviderSchools::Removal.new(provider:, uuid: params[:uuid])
      end
      helper_method :school_removal
    end
  end
end
