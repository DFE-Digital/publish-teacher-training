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
        @school_form = SchoolForm.new(provider.sites.new)
      end

      def edit
        @school_form = SchoolForm.new(site)
      end

      def create
        @school_form = SchoolForm.new(provider.sites.new, params: site_params)
        if @school_form.save!
          flash[:success] = 'Your school has been created'
          redirect_to publish_provider_recruitment_cycle_schools_path(
            @school_form.provider_code, @school_form.recruitment_cycle_year
          )
        else
          render :new
        end
      end

      def update
        @school_form = SchoolForm.new(site, params: site_params)

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

      def site_params
        params.require(:publish_school_form).permit(SchoolForm::FIELDS)
      end
    end
  end
end
