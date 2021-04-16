module Support
  class ProvidersController < ApplicationController
    def index
      @providers = filtered_providers.page(params[:page] || 1)
    end

    def show
      provider
      render layout: "provider_record"
    end

    def edit
      provider
    end

    def update
      if provider.update(provider_params)
        redirect_to support_provider_path(provider)
      else
        render :edit
      end
    end

    def users
      @users = provider.users.order(:last_name).page(params[:page] || 1)
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

    def provider
      @provider ||= Provider.find(params[:id])
    end

    def provider_params
      params.require(:provider).permit(:provider_name)
    end
  end
end
