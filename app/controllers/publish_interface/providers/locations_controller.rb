module PublishInterface
  module Providers
    class LocationsController < PublishInterfaceController
      def index
        @locations = provider.sites.sort_by(&:location_name)
      end

    private

      def provider
        @provider ||= Provider.find_by!(recruitment_cycle: recruitment_cycle, provider_code: params[:provider_code])
      end

      def recruitment_cycle
        cycle_year = params[:recruitment_cycle_year] || params[:year] || Settings.current_recruitment_cycle_year

        @recruitment_cycle ||= RecruitmentCycle.find_by!(year: cycle_year)
      end
    end
  end
end
