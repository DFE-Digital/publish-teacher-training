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
        @subjects_form = SubjectsForm.new(subjects: sanitised_subject_codes, age_group: form_params[:age_group])

        if @subjects_form.valid?
          redirect_to find_results_path(form_params.merge(
            subjects: sanitised_subject_codes,
            has_vacancies: default_vacancies,
          ))
        else
          @subjects_form.errors.clear
          @subjects_form.primary? ? @subjects_form.errors.add(:subjects, :primary_subject) : @subjects_form.errors.add(:subjects, :secondary_subject)
          render :new
        end
      end

    private

      def sanitised_subject_codes
        form_params["subjects"].compact_blank!
      end

      def form_params
        params.require(:find_subjects_form)
          .permit(:c, :latitude, :longitude, :loc, :lq, :radius, :sortby, :age_group, :has_vacancies, :l, :send_courses, :prev_l, :prev_lat, :prev_lng, :prev_loc, :prev_lq, :prev_query, :prev_rad, "provider.provider_name", :degree_required, :can_sponsor_visa, :funding, qualification: [], subjects: [], study_type: [])
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_subjects_form)
      end
    end
  end
end
