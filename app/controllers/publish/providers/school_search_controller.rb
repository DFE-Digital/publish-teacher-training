# frozen_string_literal: true

module Publish
  module Providers
    class SchoolSearchController < PublishController
      helper_method :query, :search_result_title_component

      before_action :authorize_provider

      def new
        @school_search_form = Schools::SearchForm.new
      end

      def create
        @school_search_form = Schools::SearchForm.new(query:)

        if @school_search_form.valid?
          @school_select_form = Schools::SelectForm.new
          @school_search = Schools::SearchService.call(query:)

          if @school_search.schools.size == 1
            @school_select_form = Schools::SelectForm.new(school_id: @school_search.schools[0].id)
            if @school_select_form.valid?
              redirect_to new_publish_provider_recruitment_cycle_school_path(
                provider_code: provider.provider_code,
                school_id: @school_select_form.school_id
              ) and return
            end
          end

          render :results
        else
          render :new
        end
      end

      def update
        @school_select_form = Schools::SelectForm.new(school_id: school_select_params[:school_id])

        if @school_select_form.valid?
          redirect_to new_publish_provider_recruitment_cycle_school_path(provider_code: provider.provider_code, school_id: @school_select_form.school_id)
        else
          @school_search = Schools::SearchService.call(query:)
          render :results
        end
      end

      private

      def authorize_provider
        authorize provider, :can_create_sites?
      end

      def query
        # Order is important here so the query persists across each step.
        @school_search_form&.query || school_search_params[:query] || school_select_params[:query]
      end

      def school_search_params
        return {} unless params.key?(:publish_schools_search_form)

        params.require(:publish_schools_search_form).permit(*Schools::SearchForm::FIELDS)
      end

      def school_select_params
        return {} unless params.key?(:publish_schools_select_form)

        params.require(:publish_schools_select_form).permit(*Schools::SelectForm::FIELDS, *Schools::SearchForm::FIELDS)
      end

      def search_result_title_component
        @search_result_title_component ||= Publish::Schools::SearchResultTitleComponent.new(
          query:,
          results_limit: @school_search.limit,
          results_count: @school_search.schools.unscope(:limit).count,
          return_path: search_publish_provider_recruitment_cycle_schools_path
        )
      end
    end
  end
end
