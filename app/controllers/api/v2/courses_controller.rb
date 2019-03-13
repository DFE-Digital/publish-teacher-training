module API
  module V2
    class CoursesController < API::V2::ApplicationController
      def index
        provider = Provider.find_by!(provider_code: params[:provider_code])
        authorize provider, :can_list_courses?
        authorize Course

        render jsonapi: provider.courses
      end
    end
  end
end
