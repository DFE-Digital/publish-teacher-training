module Api
  module V1
    class SubjectsController < V1ApplicationController
      def index
        @subjects = Subject.all
        paginate json: @subjects
      end
    end
  end
end
