# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      before_action :school, only: %i[show delete destroy]
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        @filter = params[:filter]
        @pagy, @schools = pagy(provider.schools.filtered_by(@filter).ordered_by_name, limit: PER_PAGE)
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
        if school_removal.call
          flash[:success] = "School removed"
          redirect_to publish_provider_recruitment_cycle_schools_path
        else
          redirect_to delete_publish_provider_recruitment_cycle_school_path(@provider.provider_code, school.recruitment_cycle.year, school.uuid),
                      flash: { warning: cannot_remove_school_message }
        end
      end

    private

      def cannot_remove_school_message
        return t(".cannot_remove_only_school") if school_removal.only_school?

        t(".cannot_remove_school")
      end

      def school_removal
        @school_removal ||= ProviderSchools::Removal.new(provider:, uuid: params[:uuid])
      end
      helper_method :school_removal

      def school
        @school ||= provider.schools.find_by!(uuid: params[:uuid]).decorate
      end
      helper_method :school

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
