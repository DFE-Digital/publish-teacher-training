module Find
  module Search
    class SubjectsController < Find::ApplicationController
      def index
        @subjects_form = SubjectsForm.new(subject_codes: params[:subject_codes], age_group: params[:age_group])
      end
    end
  end
end
