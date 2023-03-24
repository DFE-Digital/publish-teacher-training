# frozen_string_literal: true

module Support
  class LocationsController < SupportController
    before_action :build_site, only: %i[index new create]
    before_action :new_form, only: %i[index new]
    before_action :reset_csv_schools_forms, only: %i[index]

    def index
      @sites = provider.sites.order(:location_name).page(params[:page] || 1)
      render layout: 'provider_record'
    rescue ActiveRecord::RecordNotFound
      flash[:warning] = 'Provider not found'
      redirect_to support_providers_path
    end

    def new; end

    def edit
      site
      provider
    end

    def confirm
      site
      provider
    end

    def create
      # TODO: revert site_params when we align the edit form
      @location_form = LocationForm.new(provider, @site, params: site_params(:support_location_form))
      # binding.pry
      if @location_form.stash
        redirect_to support_recruitment_cycle_provider_check_location_path
      else
        render(:new)
      end
    end

    def update
      # @location_form = LocationForm.new(provider, site, params: site_params(:site))
      # binding.pry
      if site.update(site_params(:site))
        redirect_to confirm_support_recruitment_cycle_provider_location_path
      else
        render(:edit)
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

    # TODO: revert this when we align the edit form
    def site_params(param_form_key)
      params.require(param_form_key).permit(
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

    def build_site
      @site = provider.sites.build
    end

    def new_form
      @location_form = LocationForm.new(provider, @site)
      @location_form.clear_stash
    end

    def site
      @site ||= provider.sites.find(params[:id])
    end

    def reset_csv_schools_forms
      [ParsedCSVSchoolsForm.new(provider), RawCSVSchoolsForm.new(provider)].each(&:clear_stash)
    end
  end
end
