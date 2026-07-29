# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      before_action :school, only: %i[show delete destroy]
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(ProviderSchools::Identity.ordered_school_scope(provider:), limit: PER_PAGE)
        @closed_urns = closed_urns_for(@schools)
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
                      flash: { warning: t(".cannot_remove_school") }
        end
      end

    private

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

      # Resolve which of the listed schools point at a closed GIAS record in a
      # single query, keyed by URN (shared by Site and Provider::School rows).
      def closed_urns_for(schools)
        urns = schools.map(&:urn).compact_blank
        return Set.new if urns.empty?

        GiasSchool.closed.where(urn: urns).pluck(:urn).to_set
      end
    end
  end
end
