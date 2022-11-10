module Find
  module Search
    class SubjectsController < Find::ApplicationController
      include FilterParameters
      before_action :build_backlink_query_parameters

      def new
        @subjects_form = SubjectsForm.new(subject_codes: params[:subject_codes], age_group: params[:age_group])
      end

      def create
        @subjects_form = SubjectsForm.new(subject_codes: sanitised_subject_codes, age_group: form_params[:age_group])

        if @subjects_form.valid?
          redirect_to find_results_path(form_params.merge(subject_codes: sanitised_subject_codes))
        else
          render :new
        end
      end

    private

      def sanitised_subject_codes
        form_params["subject_codes"].compact_blank!
      end

      def form_params
        params.require(:find_subjects_form)
          .permit(:c, :lat, :lng, :loc, :lq, :rad, :sortby, :age_group, :fulltime, :hasvacancies, :l, :parttime, :senCourses, :prev_l, :prev_lat, :prev_lng, :prev_loc, :prev_lq, :prev_query, :prev_rad, :query, :degree_required, :can_sponsor_visa, :funding, qualifications: [], subject_codes: [])
      end

      def build_backlink_query_parameters
        @backlink_query_parameters = ResultsView.new(query_parameters: request.query_parameters)
                                                .query_parameters_with_defaults
                                                .except(:find_subjects_form)
      end
    end
  end
end
