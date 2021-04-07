module Support
  class ProvidersController < ApplicationController
    def index
      @providers = RecruitmentCycle.current.providers.order(:provider_name).includes(:courses, :users).page(params[:page] || 1)
    end

    def show
      @provider = Provider.find(params[:id])
      render layout: "provider_record"
    end
  end
end
