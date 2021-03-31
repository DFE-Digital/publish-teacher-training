module Support
  class ProvidersController < ApplicationController
    def index
      @providers = Provider.order(:provider_name).limit(30)
    end

    def show
      @provider = Provider.find(params[:id])
    end
  end
end
