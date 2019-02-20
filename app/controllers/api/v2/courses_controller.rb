module API
  module V2
    class CoursesController < ApplicationController
      def index
        provider = Provider.find_by!(provider_code: params[:provider_code])
        authorize provider

        render jsonapi: provider.courses,
               class: SERIALIZABLE_CLASSES
      end
    end
  end
end
