module API
  module Public
    module V1
      class ApplicationController < PublicAPIController
        include PagyPagination
      end
    end
  end
end
