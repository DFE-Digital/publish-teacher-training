# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < PublishController
      before_action :pundit
      before_action :site, only: %i[show delete]

      def index
        @schools = provider.sites.sort_by(&:location_name)
      end

      def show; end

      def new
        @site = provider.sites.build
        @school_form = ::Support::SchoolForm.new(provider, @site, params: gias_school_params)
        @school_form.clear_stash
      end

      def edit
        @school_form = SchoolForm.new(site)
      end

      def create
        @site = provider.sites.build
        @school_form = ::Support::SchoolForm.new(provider, @site, params: site_params(:support_school_form))
        if @school_form.stash
          redirect_to publish_provider_recruitment_cycle_check_school_path
        else
          render :new
        end
      end

      def update
        @school_form = SchoolForm.new(site, params: site_params(:publish_school_form))

        if @school_form.save!
          course_updated_message('School')

          redirect_to publish_provider_recruitment_cycle_school_path(
            @school_form.provider_code, @school_form.recruitment_cycle_year, site.id
          )
        else
          render :edit
        end
      end

      def delete; end

      def destroy
        site.destroy!
        flash[:success] = 'School removed'
        redirect_to publish_provider_recruitment_cycle_schools_path
      end

      private

      def pundit
        authorize provider, :show?
      end

      def site
        @site ||= provider.sites.find(params[:id])
      end

      def site_params(param_form_key)
        params.require(param_form_key).permit(SchoolForm::FIELDS)
      end

      def gias_school_params
        return {} unless params[:school_id]

        gias_school.school_attributes
      end

      def gias_school
        @gias_school ||= GiasSchool.find(params[:school_id])
      end
    end
  end
end
