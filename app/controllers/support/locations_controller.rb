# frozen_string_literal: true

module Support
  class LocationsController < SupportController
    def index
      @sites = provider.sites.order(:location_name).page(params[:page] || 1)
      render layout: 'provider_record'
      # check this is correct
      @site = provider.sites.build
      @location_form = LocationForm.new(provider, @site)
      @location_form.clear_stash
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = 'Provider not found'
      redirect_to support_providers_path
    end

    def new
      @site = provider.sites.build
      provider
      @location_form = LocationForm.new(provider, @site)
      @location_form.clear_stash
    end

    def edit
      site
      provider
      # @location_form = LocationForm.new(provider, site)
    end

    def create
      provider
      @site = provider.sites.build

      @location_form = LocationForm.new(provider, @site, params: site_params)
      if @location_form.stash
        redirect_to support_recruitment_cycle_provider_check_location_path
      else
        render(:new)
      end
    end

    def update
      if site.update(edit_site_params)
        redirect_to support_recruitment_cycle_provider_locations_path(provider.recruitment_cycle_year, provider), flash: { success: t('support.flash.updated', resource: flash_resource) }
      else
        render :edit
      end
    end

    def destroy
      site.destroy!

      redirect_to support_recruitment_cycle_provider_locations_path(provider.recruitment_cycle_year, provider), flash: { success: t('support.flash.deleted', resource: flash_resource) }
    end

    private

    def provider
      @provider ||= recruitment_cycle.providers.find(params[:provider_id])
    end

    def flash_resource
      @flash_resource ||= 'Location'
    end

    def site_params
      params.require(:support_location_form).permit(
        :location_name,
        :urn,
        :code,
        :address1,
        :address2,
        :address3,
        :address4,
        :postcode
      )
    end

    # TODO: remove this when we align the edit form
    def edit_site_params
      params.require(:site).permit(
        :location_name,
        :urn,
        :code,
        :address1,
        :address2,
        :address3,
        :address4,
        :postcode
      )
    end

    def site
      @site ||= provider.sites.find(params[:id])
    end
  end
end
