module API
  module V2
    class SitesController < API::V2::ApplicationController
      deserializable_resource :site, only: :update

      before_action :build_provider
      before_action :build_site, except: :index

      def index
        authorize @provider, :can_list_courses?
        authorize Site

        render jsonapi: @provider.sites
      end

      def update
        if @site.update(site_params)
          sync_courses_with_search_and_compare

          render jsonapi: @site
        else
          render jsonapi_errors: @site.errors, status: 422
        end
      end

      def show
        render jsonapi: @site
      end

    private

      def site_params
        params.require(:site).permit(
          :location_name,
          :address1,
          :address2,
          :address3,
          :address4,
          :postcode,
          :region_code
        )
      end

      def build_provider
        @provider = Provider.find_by!(provider_code: params[:provider_code].upcase)
      end

      def build_site
        @site = @provider.sites.find(params[:id])
        authorize @site
      end

      def sync_courses_with_search_and_compare
        ManageCoursesAPI::Request.sync_courses_with_search_and_compare(
          @current_user.email,
          @provider.provider_code
        )
      rescue StandardError
        false
      end
    end
  end
end
