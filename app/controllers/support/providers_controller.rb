module Support
  class ProvidersController < ApplicationController
    def index
      @providers = filtered_providers.page(params[:page] || 1)
    end

    def show
      @provider = Provider.find(params[:id])
      render layout: "provider_record"
    end

  private

    def filtered_providers
      Support::Providers::Filter.call(providers: find_providers, filters: filters)
    end

    def find_providers
      RecruitmentCycle.current.providers.order(:provider_name).includes(:courses, :users)
    end

    def filters
      @filters ||= ProviderFilter.new(params: filter_params).filters
    end

    def filter_params
      params.permit(:text_search, :page, :commit)
    end
  end
end
