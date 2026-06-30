# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      before_action :site, only: %i[show delete]
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        schools = provider.sites.order(:location_name)

        # Filter by search query if present
        if params[:query].present?
          q = params[:query].downcase

          schools = schools.where(
            "LOWER(location_name) LIKE :q OR LOWER(address1) LIKE :q OR CAST(urn AS TEXT) LIKE :q",
            q: "%#{q}%",
          )
        end

        @pagy, @schools = pagy(schools, limit: PER_PAGE)
      end

      def show
        @courses = Publish::Courses::Query.call(provider:)
          .joins(:site_statuses)
          .where(
            site_statuses: {
              site_id: @site.id,
              status: %i[new_status running],
            },
          )
          .uniq(&:id)
      end

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
        site.destroy!
        flash[:success] = "#{@site.location_name} has been removed from your account"
        redirect_to publish_provider_recruitment_cycle_schools_path
      end

      def remove
        @site = Site.find(params[:id])
      end

    private

      # Load associated courses with the site to prevent multiple database queries in the view (this will show courses that are connected to the school)
      def site
        @site ||= provider
          .sites
          .includes(site_statuses: :course)
          .find(params[:id])
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
