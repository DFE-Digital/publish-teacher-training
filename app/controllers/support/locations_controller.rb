module Support
  class LocationsController < SupportController
    def index
      @sites = provider.sites.order(:location_name).page(params[:page] || 1)
      render layout: "provider_record"
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Provider not found"
      redirect_to support_providers_path
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find(params[:provider_id])
    end
  end
end
