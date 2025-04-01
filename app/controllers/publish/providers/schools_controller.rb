# frozen_string_literal: true

module Publish
  module Providers
    class SchoolsController < ApplicationController
      before_action :site, only: %i[show delete]
      before_action :reset_urn_form, only: %i[index]

      def index
        @pagy, @schools = pagy(provider.sites.order(:location_name))
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
        site.destroy!
        flash[:success] = 'School removed'
        redirect_to publish_provider_recruitment_cycle_schools_path
      end

      private

      def site
        @site ||= provider.sites.find(params[:id])
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
