module Api
  module V2
    class CoursesController < ApplicationController
      skip_before_action :authenticate

      def index
        provider = Provider.find(params[:provider_id])
        paginate json: provider.courses, each_serializer: CourseSummarySerializer
      end
    end
  end
end
