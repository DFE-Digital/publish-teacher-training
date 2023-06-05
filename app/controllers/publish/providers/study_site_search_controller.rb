# frozen_string_literal: true

module Publish
  module Providers
    class StudySiteSearchController < PublishController
      helper_method :query, :search_result_title_component

      before_action :authorize_provider

      def new
        @study_site_search_form = Schools::SearchForm.new
      end

      def create
        redirect_to_next_step and return if school_id.present?

        @study_site_search_form = Schools::SearchForm.new(query:)

        if @study_site_search_form.valid?

          @study_site_select_form = Schools::SelectForm.new
          @study_site_search = Schools::SearchService.call(query:)

          render :results
        else
          render :new
        end
      end

      def update
        @study_site_select_form = Schools::SelectForm.new(study_site_id: study_site_select_params[:study_site_id])

        if @study_site_select_form.valid?
          redirect_to new_publish_provider_recruitment_cycle_study_site_path(provider_code: provider.provider_code, study_site_id: @study_site_select_form.study_site_id)
        else
          @study_site_search = Schools::SearchService.call(query:)
          render :results
        end
      end

      private

      def authorize_provider
        authorize provider, :can_create_sites?
      end

      def school_id
        params[:school_id]
      end

      def query
        # Order is important here so the query persists across each step.
        @study_site_search_form&.query || study_site_search_params[:query] || study_site_select_params[:query]
      end

      def study_site_search_params
        return {} unless params.key?(:publish_schools_search_form)

        params.require(:publish_schools_search_form).permit(*Schools::SearchForm::FIELDS, :study_site_id)
      end

      def study_site_select_params
        return {} unless params.key?(:publish_schools_select_form)

        params.require(:publish_schools_select_form).permit(*Schools::SelectForm::FIELDS, *Schools::SearchForm::FIELDS)
      end

      def search_result_title_component
        @search_result_title_component ||= SearchResultTitleComponent.new(
          query:,
          results_limit: @study_site_search.limit,
          results_count: @study_site_search.study_sites.unscope(:limit).count,
          return_path: search_publish_provider_recruitment_cycle_study_sites_path,
          search_resource: 'study_site'
        )
      end

      def redirect_to_next_step
        redirect_to new_publish_provider_recruitment_cycle_study_site_path(
          provider_code: provider.provider_code,
          study_site_id: school_id
        )
      end
    end
  end
end
