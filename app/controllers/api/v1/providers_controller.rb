module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        @providers = Provider.changed_since(params[:changed_since])
        render json: @providers
      end
    end
  end
end
