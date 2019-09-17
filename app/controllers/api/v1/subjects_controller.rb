module API
  module V1
    class SubjectsController < API::V1::ApplicationController
      def index
        @subjects = Subject.all
        paginate json: @subjects
      end
    end
  end
end
