module Find
  module Search
    class SubjectsController < Find::ApplicationController
      include FilterParameters
      include DefaultVacancies
      before_action :build_backlink_query_parameters

      def new
        @subjects_form = SubjectsForm.new(subjects: params[:subjects], age_group: params[:age_group])
      end

      def create
        @subjects_form = SubjectsForm.new(subjects: form_params["subjects"], age_group: form_params[:age_group])

        if @subjects_form.valid?
          redirect_to find_results_path(form_params.merge(
            subjects: form_params[:subjects],
            has_vacancies: default_vacancies,
          ))
        else
          render :new
        end
      end

    private

      def form_params
        params.require(:find_subjects_form)
          .permit(:c, :latitude, :longitude, :loc, :lq, :radius, :sortby, :age_group, :has_vacancies, :l, :send_courses, :prev_l, :prev_lat, :prev_lng, :prev_loc, :prev_lq, :prev_query, :prev_rad, "provider.provider_name", :degree_required, :can_sponsor_visa, :funding, :subjects, qualification: [], study_type: [])
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_subjects_form)
      end
    end
  end
end
