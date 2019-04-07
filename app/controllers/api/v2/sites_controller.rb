module API
  module V2
    class SitesController < API::V2::ApplicationController
      before_action :build_provider
      before_action :build_site, except: :index

      def index
        authorize @provider, :can_list_courses?
        authorize Site

        render jsonapi: @provider.sites
      end

      def show
        render jsonapi: @site
      end

    private

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end

      def build_site
        @site = @provider.sites.find(params[:id])
        authorize @site
      end
    end
  end
end
