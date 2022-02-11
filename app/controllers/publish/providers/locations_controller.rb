module Publish
  module Providers
    class LocationsController < PublishController
      def index
        authorize provider, :can_list_sites?

        @locations = provider.sites.sort_by(&:location_name)
      end

      def new
        authorize provider, :can_create_sites?
        @location_form = LocationForm.new(provider.sites.new)
      end

      def create
        authorize provider, :can_create_sites?

        @location_form = LocationForm.new(provider.sites.new, params: site_params)
        if @location_form.save!
          flash[:success] = "Your location has been created"
          redirect_to publish_provider_recruitment_cycle_locations_path(
            @location_form.provider_code, @location_form.recruitment_cycle_year
          )
        else
          render :new
        end
      end

      def edit
        authorize site, :update?
        @location_form = LocationForm.new(site)
      end

      def update
        authorize provider, :update?
        @location_form = LocationForm.new(site, params: site_params)

        if @location_form.save!
          flash[:success] = I18n.t("success.published")
          redirect_to publish_provider_recruitment_cycle_locations_path(
            @location_form.provider_code, @location_form.recruitment_cycle_year
          )
        else
          render :edit
        end
      end

    private

      def provider
        @provider ||= Provider.find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end

      def site
        @site ||= provider.sites.find(params[:id])
      end

      def site_params
        params.require(:publish_location_form).permit(LocationForm::FIELDS)
      end
    end
  end
end
