module Support
  class ProvidersController < ApplicationController
    def index
      @pagy, @providers = pagy(Provider.order(:provider_name).includes(:courses, :users))
    end

    def show
      @provider = Provider.find(params[:id])
      render layout: "provider_record"
    end
  end
end
