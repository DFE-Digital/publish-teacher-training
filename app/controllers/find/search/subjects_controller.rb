module Find
  module Search
    class SubjectsController < Find::ApplicationController
      def index
        @subjects_form = SubjectsForm.new
      end

      def create
        @subjects_form = SubjectsForm.new(subject_codes: sanitised_subject_codes)

        if @subjects_form.valid?
          redirect_to course_results_path # TODO:
        else
          render :index
        end
      end

    private

      def sanitised_subject_codes
        subjects_form_params['subject_codes'].compact_blank!
      end

      def subjects_form_params
        params.require(:find_subjects_form)
          .permit(subject_codes: [])
      end
    end
  end
end
