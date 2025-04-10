# frozen_string_literal: true

module Support
  module Providers
    class SchoolsController < ApplicationController
      before_action :build_site, only: %i[index create]
      before_action :new_form, only: %i[index]
      before_action :reset_urn_form, only: %i[index]
      before_action :site, only: %i[show delete]

      def index
        @pagy, @sites = pagy(provider.sites.order(:location_name))
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

      def delete
        provider
      end

      def destroy
        site.destroy!

        redirect_to support_recruitment_cycle_provider_schools_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.deleted", resource: flash_resource) }
      end

    private

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

      def site
        @site ||= provider.sites.find(params[:id])
      end

      def reset_urn_form
        URNForm.new(provider).clear_stash
      end
    end
  end
end
