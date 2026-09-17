# frozen_string_literal: true

module Support
  module Providers
    class SchoolsController < ApplicationController
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(
          provider.schools.ordered_by_name.preload(:kept_courses),
          limit: PER_PAGE,
        )
      end

      def show
        render locals: { school: }
      end

      def delete
        render locals: { school:, school_removal: }
      end

      def destroy
        if school_removal.call
          redirect_to support_recruitment_cycle_provider_schools_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.deleted", resource: flash_resource) }
        else
          redirect_to school_delete_path_with_return,
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

      def school
        @school ||= school_removal.school.decorate
      end

      def reset_urn_form
        URNForm.new(provider).clear_stash
      end

      def school_removal
        @school_removal ||= ProviderSchools::Removal.new(provider:, uuid: params[:uuid])
      end

      def school_delete_return_path
        if returning_to_schools_index?
          support_recruitment_cycle_provider_schools_path(
            @provider.recruitment_cycle_year,
            @provider,
            page: params[:page],
          )
        else
          support_recruitment_cycle_provider_school_path(
            @provider.recruitment_cycle_year,
            @provider,
            school.uuid,
          )
        end
      end
      helper_method :school_delete_return_path

      def school_delete_path_with_return
        delete_support_recruitment_cycle_provider_school_path(
          @provider.recruitment_cycle_year,
          @provider,
          school.uuid,
          **school_delete_return_params,
        )
      end
      helper_method :school_delete_path_with_return

      def returning_to_schools_index?
        params[:from] == "index"
      end

      def school_delete_return_params
        params.permit(:from, :page).to_h.compact_blank.symbolize_keys
      end
    end
  end
end
