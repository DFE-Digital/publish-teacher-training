# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      before_action :site, only: %i[show delete]
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(provider.sites.order(:location_name), limit: PER_PAGE)
      end

      def show
        all_courses = Publish::Courses::Query.call(provider:)

        @courses = all_courses.select do |course|
          course.sites.map(&:id).include?(@site.id)
        end
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
        flash[:success] = "School removed"
        redirect_to publish_provider_recruitment_cycle_schools_path
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
