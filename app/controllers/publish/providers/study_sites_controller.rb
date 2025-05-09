# frozen_string_literal: true

module Publish
  module Providers
    class StudySitesController < ApplicationController
      before_action :site, only: %i[show delete]
      before_action :build_study_site, only: %i[new create]

      def index
        @pagy, @study_sites = pagy(provider.study_sites.order(:location_name))
      end

      def show; end

      def new
        @study_site_form = ::Support::SchoolForm.new(provider, @site, params: gias_school_params)
        @study_site_form.clear_stash
      end

      def edit
        @study_site_form = ::Publish::SchoolForm.new(site)
      end

      def create
        @study_site_form = ::Support::SchoolForm.new(provider, @site, params: site_params(:support_school_form))
        if @study_site_form.stash
          redirect_to publish_provider_recruitment_cycle_check_study_site_path
        else
          render :new
        end
      end

      def update
        @study_site_form = ::Publish::SchoolForm.new(site, params: site_params(:publish_school_form))

        if @study_site_form.save!
          course_updated_message("Study site")

          redirect_to publish_provider_recruitment_cycle_study_site_path(
            @study_site_form.provider_code, @study_site_form.recruitment_cycle_year, site.id
          )
        else
          render :edit
        end
      end

      def delete; end

      def destroy
        site.destroy!
        flash[:success] = t("publish.providers.study_sites.removed")
        redirect_to publish_provider_recruitment_cycle_study_sites_path
      end

    private

      def site
        @site ||= provider.study_sites.find(params[:id])
      end

      def build_study_site
        @site = provider.study_sites.build
      end

      def site_params(param_form_key)
        params.expect(param_form_key => ::Publish::SchoolForm::FIELDS)
      end

      def gias_school_params
        return {} unless params[:school_id] || params[:study_site_id]

        gias_school.school_attributes
      end

      def gias_school
        id = params[:study_site_id] || params[:school_id]
        @gias_school ||= GiasSchool.find(id)
      end
    end
  end
end
