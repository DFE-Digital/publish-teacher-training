module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        @providers = if params["changed_since"]
                       Provider.changed_since(params["changed_since"])
                     else
                       Provider.all
                     end
        paginate json: @providers
      end
    end
  end
end
