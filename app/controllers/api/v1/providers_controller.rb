module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        @providers = Provider.changed_since(params[:changed_since])
        paginate json: @providers
      end
    end
  end
end
