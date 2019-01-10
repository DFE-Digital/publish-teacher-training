module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        @providers = Provider.all
        paginate json: @providers
      end

      def show
        render json: Provider.find(params[:id])
      end
    end
  end
end
