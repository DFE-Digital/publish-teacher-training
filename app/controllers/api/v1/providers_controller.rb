module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        if params["changed_since"]
          @providers = Provider.changed_since(params["changed_since"])
        else
          @providers = Provider.all
        end
        paginate json: @providers
      end
    end
  end
end
