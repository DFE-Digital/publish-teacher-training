# frozen_string_literal: true

module Find
  module Search
    class AgeGroupsController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies

      before_action :build_backlink_query_parameters

      def new
        @age_groups_form = AgeGroupsForm.new(age_group: params[:age_group])
      end

      def create
        @age_groups_form = AgeGroupsForm.new(age_group: form_params[:age_group])

        if @age_groups_form.valid?
          if form_params[:age_group] == 'further_education'
            redirect_to find_results_path(further_education_params.merge(has_vacancies: default_vacancies))
          else
            redirect_to find_subjects_path(filter_params[:find_age_groups_form])
          end
        else
          render :new
        end
      end

      private

      def further_education_params
        filter_params[:find_age_groups_form].merge(age_group: @age_groups_form.age_group, subjects: ['41'])
      end

      def form_name = :find_age_groups_form

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_age_groups_form)
      end
    end
  end
end
