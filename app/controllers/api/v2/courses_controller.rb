module API
  module V2
    class CoursesController < ApplicationController
      def index
        provider = Provider.find_by!(provider_code: params[:provider_code])

        paginate json: provider.courses, each_serializer: CourseSummarySerializer
      end
    end
  end
end
