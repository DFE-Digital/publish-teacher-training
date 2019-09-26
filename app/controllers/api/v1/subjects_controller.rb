module API
  module V1
    class SubjectsController < API::V1::ApplicationController
      def index
        @subjects = Subject.where.not(type: "DiscontinuedSubject")
          .where.not(subject_code: nil)

        paginate json: @subjects
      end
    end
  end
end
