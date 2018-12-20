module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        @providers = Provider.all

        paginate json: @providers
      end
    end
  end
end
