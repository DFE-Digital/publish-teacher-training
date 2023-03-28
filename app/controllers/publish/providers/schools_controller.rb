# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < PublishController
      def index
        authorize provider, :can_list_sites?

        @schools = provider.sites.sort_by(&:location_name)
      end

      def new
        authorize provider, :can_create_sites?
        @school_form = SchoolForm.new(provider.sites.new)
      end

      def edit
        authorize site, :update?
        @school_form = SchoolForm.new(site)
      end

      def create
        authorize provider, :can_create_sites?

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
        authorize provider, :update?
        @school_form = SchoolForm.new(site, params: site_params)

        if @school_form.save!
          course_updated_message('School details')

          redirect_to publish_provider_recruitment_cycle_schools_path(
            @school_form.provider_code, @school_form.recruitment_cycle_year
          )
        else
          render :edit
        end
      end

      private

      def site
        @site ||= provider.sites.find(params[:id])
      end

      def site_params
        params.require(:publish_school_form).permit(SchoolForm::FIELDS)
      end
    end
  end
end
