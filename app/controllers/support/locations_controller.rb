module Support
  class LocationsController < SupportController
    def index
      @sites = provider.sites.order(:location_name).page(params[:page] || 1)
      render layout: "provider_record"
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = "Provider not found"
      redirect_to support_providers_path
    end

    def new
      @site = provider.sites.build
    end

    def create
      @site = provider.sites.build(site_params)

      if @site.save
        redirect_to support_recruitment_cycle_provider_locations_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.created", resource: flash_resource) }
      else
        render :new
      end
    end

    def edit
      provider
      site
    end

    def update
      if site.update(site_params)
        redirect_to support_recruitment_cycle_provider_locations_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.updated", resource: flash_resource) }
      else
        render :edit
      end
    end

    def destroy
      site.destroy!

      redirect_to support_recruitment_cycle_provider_locations_path(provider.recruitment_cycle_year, provider), flash: { success: t("support.flash.deleted", resource: flash_resource) }
    end

  private

    def provider
      @provider ||= RecruitmentCycle.current.providers.find(params[:provider_id])
    end

    def flash_resource
      @flash_resource ||= "Location"
    end

    def site_params
      params.require(:site).permit(
        :location_name,
        :urn,
        :code,
        :address1,
        :address2,
        :address3,
        :address4,
        :postcode,
      )
    end

    def site
      @site ||= provider.sites.find(params[:id])
    end
  end
end
