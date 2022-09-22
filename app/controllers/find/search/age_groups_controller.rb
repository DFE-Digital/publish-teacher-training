module Find
  module Search
    class AgeGroupsController < Find::ApplicationController
      include FilterParameters

      def index
        @age_groups_form = AgeGroupsForm.new(params: age_range_form_params)
      end

      def create
        @age_groups_form = AgeGroupsForm.new(params: age_range_form_params)

        if @age_groups_form.valid?
          redirect_to find_subjects_path(age_range_form_params)
        else
          render :index
        end
      end

    private

      def age_range_form_params
        params.reverse_merge({ find_age_groups_form: {} })[:find_age_groups_form]
          .permit(:age_group, :city_town_postcode_query, :find_courses, :school_uni_or_provider_query)
      end
    end
  end
end
