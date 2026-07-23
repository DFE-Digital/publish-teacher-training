# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      include ProviderSchoolModelReads

      before_action :load_school, only: %i[show delete destroy]
      before_action :reset_urn_form, only: %i[index]

      helper_method :provider_school_for_site

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(provider.sites.order(:location_name), limit: PER_PAGE)
      end

      def show; end

      def create
        @site = provider.sites.build
        @school_form = ::Support::SchoolForm.new(provider, @site, params: site_params(:support_school_form))
        if @school_form.stash
          redirect_to publish_provider_recruitment_cycle_schools_check_path
        else
          render :new
        end
      end

      def delete; end

      def destroy
        if provider_school_ui_uses_new_model?
          destroy_provider_school
        else
          destroy_legacy_site
        end
      end

    private

      def load_school
        if provider_school_ui_uses_new_model?
          @provider_school = provider.schools.find(params[:id]).decorate
        else
          @site = provider.sites.find(params[:id]).decorate
        end
      end

      def destroy_provider_school
        unless @provider_school.has_no_course?
          redirect_to school_delete_path
          return
        end

        legacy_site = matching_legacy_site(@provider_school.object)
        @provider_school.object.destroy!
        legacy_site&.destroy!

        flash[:success] = "School removed"
        redirect_to publish_provider_recruitment_cycle_schools_path
      end

      def destroy_legacy_site
        unless @site.has_no_course?
          redirect_to school_delete_path
          return
        end

        @site.destroy!
        matching_provider_school&.destroy!

        flash[:success] = "School removed"
        redirect_to publish_provider_recruitment_cycle_schools_path
      end

      def provider_school_for_site(site)
        provider.schools.joins(:gias_school).find_by(
          site_code: site.code,
          gias_school: { urn: site.urn },
        )
      end

      def matching_legacy_site(provider_school_record)
        provider.sites.find_by(
          code: provider_school_record.site_code,
          urn: provider_school_record.gias_school.urn,
        )
      end

      def matching_provider_school
        provider_school_for_site(@site.object)
      end

      def site_params(param_form_key)
        params.expect(param_form_key => SchoolForm::FIELDS)
      end

      def gias_school_params
        return {} unless params[:school_id]

        gias_school.school_attributes
      end

      def gias_school
        @gias_school ||= GiasSchool.find(params[:school_id])
      end

      def reset_urn_form
        URNForm.new(provider).clear_stash
      end
    end
  end
end
