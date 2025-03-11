# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class SearchController < ApplicationController
        helper_method :query, :search_result_title_component, :recruitment_cycle

        before_action :authorize_provider

        def new
          @school_search_form = Schools::SearchForm.new
        end

        def create
          if school_id.present?
            @school_search_form = Schools::SearchForm.new(school:)

            if @school_search_form.valid?(:school)
              redirect_to_next_step
            else
              render :new
            end

            return
          end

          @school_search_form = Schools::SearchForm.new(query:)

          if @school_search_form.valid?(:query)

            @school_select_form = Schools::SelectForm.new
            @school_search = SearchService.call(query:)

            render :results
          else
            render :new
          end
        end

        def school
          @school ||= begin
            gias_school = GiasSchool.find(params[:school_id])
            @provider.sites.school.build(gias_school.school_attributes)
          end
        end

        def update
          @school_select_form = Schools::SelectForm.new(school_id: school_select_params[:school_id])

          if @school_select_form.valid?
            redirect_to support_recruitment_cycle_provider_schools_check_path(
              provider_id: provider.id,
              school_id: school_select_params[:school_id]
            )
          else
            @school_search = Schools::SearchService.call(query:)
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
          @school_search_form&.query || school_search_params[:query] || school_select_params[:query]
        end

        def school_search_params
          return {} unless params.key?(:support_providers_schools_search_form)

          params.expect(support_providers_schools_search_form: [*Schools::SearchForm::FIELDS, :school_id])
        end

        def school_select_params
          return {} unless params.key?(:support_providers_schools_select_form)

          params.expect(support_providers_schools_select_form: [*Schools::SelectForm::FIELDS, *Schools::SearchForm::FIELDS])
        end

        def search_result_title_component
          @search_result_title_component ||= SearchResultTitleComponent.new(
            query:,
            results_limit: @school_search.limit,
            results_count: @school_search.schools.unscope(:limit).count,
            return_path: search_support_recruitment_cycle_provider_schools_path,
            search_resource: 'school',
            caption_text: "Add school - #{provider.name_and_code}"
          )
        end

        def provider
          @provider ||= Provider.find(params[:provider_id])
        end

        def redirect_to_next_step
          redirect_to support_recruitment_cycle_provider_schools_check_path(
            school_id:
          )
        end
      end
    end
  end
end
