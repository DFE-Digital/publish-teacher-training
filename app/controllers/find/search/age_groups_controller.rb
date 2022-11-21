module Find
  module Search
    class AgeGroupsController < Find::ApplicationController
      include FilterParameters

      before_action :build_backlink_query_parameters

      def new
        @age_groups_form = AgeGroupsForm.new(age_group: params[:age_group])
      end

      def create
        @age_groups_form = AgeGroupsForm.new(age_group: form_params[:age_group])

        if @age_groups_form.valid?
          if form_params[:age_group] == "further_education"
            redirect_to find_results_path(further_education_params)
          else
            redirect_to find_subjects_path(filter_params[:find_age_groups_form])
          end
        else
          render :new
        end
      end

    private

      def further_education_params
        filter_params[:find_age_groups_form].merge(age_group: @age_groups_form.age_group, subject_codes: ["41"])
      end

      def form_params
        params
          .require(:find_age_groups_form)
          .permit(:age_group, :c, :fulltime, :hasvacancies, :l, :lat, :lng, :loc, :lq, :parttime, :rad, :senCourses, :sortby, :prev_l, :prev_lat, :prev_lng, :prev_loc, :prev_lq, :prev_query, :prev_rad, :query, :degree_required, :can_sponsor_visa, :funding, subject_codes: [], qualification: [])
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_age_groups_form)
      end
    end
  end
end
