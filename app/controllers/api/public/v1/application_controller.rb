module API
  module Public
    module V1
      class ApplicationController < ActionController::API
        include Pagy::Backend
        include ErrorHandlers::Pagy
        include PagyPagination
      end
    end
  end
end
