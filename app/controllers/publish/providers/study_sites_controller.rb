# frozen_string_literal: true

module Publish
  module Providers
    class StudySitesController < PublishController
      before_action :pundit
      before_action :site, only: %i[show delete]

      def index
        @study_sites = provider.study_sites.sort_by(&:location_name)
      end

      def show; end

      def new
        @site = provider.sites.build(site_type: 'study_site')
        @study_site_form = ::Support::SchoolForm.new(provider, @site, params: gias_school_params)
        @study_site_form.clear_stash
      end

      def edit
        @study_site_form = SchoolForm.new(site)
      end

      def create
        @site = provider.sites.build(site_type: 'study_site')
        @study_site_form = ::Support::SchoolForm.new(provider, @site, params: site_params(:support_school_form))
        if @study_site_form.stash
          redirect_to publish_provider_recruitment_cycle_check_study_site_path
        else
          render :new
        end
      end

      def update
        @study_site_form = SchoolForm.new(site, params: site_params(:publish_study_site_form))

        if @study_site_form.save!
          course_updated_message('Study site')

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
        flash[:success] = 'School removed'
        redirect_to publish_provider_recruitment_cycle_study_sites_path
      end

      private

      def pundit
        authorize provider, :show?
      end

      def site
        @site ||= provider.study_sites.find(params[:id])
      end

      def site_params(param_form_key)
        params.require(param_form_key).permit(SchoolForm::FIELDS)
      end

      def gias_school_params
        return {} unless params[:school_id] || params[:study_site_id]

        gias_school.school_attributes
      end

      def gias_school
        @gias_school ||= GiasSchool.find(params[:study_site_id])
      end
    end
  end
end
