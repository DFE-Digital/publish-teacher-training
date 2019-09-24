module API
  module V2
    class SitesController < API::V2::ApplicationController
      deserializable_resource :site,
                              only: %i[update create],
                              class: API::V2::DeserializableSite

      before_action :build_recruitment_cycle
      before_action :build_provider
      before_action :build_site, except: %i[index create]

      def index
        authorize @provider, :can_list_courses?
        authorize Site

        render jsonapi: @provider.sites
      end

      def create
        @site = @provider.sites.new(site_params)
        authorize @site

        if @site.save
          render jsonapi: @site
        else
          render jsonapi_errors: @site.errors, status: :unprocessable_entity
        end
      end

      def update
        if @site.update(site_params)
          sync_courses_with_search_and_compare

          render jsonapi: @site
        else
          render jsonapi_errors: @site.errors, status: :unprocessable_entity
        end
      end

      def show
        render jsonapi: @site
      end

    private

      def site_params
        params
          .fetch(:site, {})
          .except(:id, :type)
          .permit(
            :location_name,
            :address1,
            :address2,
            :address3,
            :address4,
            :postcode,
            :region_code,
          )
      end

      def build_provider
        @provider = @recruitment_cycle.providers.find_by!(
          provider_code: params[:provider_code].upcase,
        )
      end

      def build_recruitment_cycle
        @recruitment_cycle = RecruitmentCycle.find_by(
          year: params[:recruitment_cycle_year],
        ) || RecruitmentCycle.current_recruitment_cycle
      end

      def build_site
        @site = @provider.sites.find(params[:id])
        authorize @site
      end

      def sync_courses_with_search_and_compare
        ManageCoursesAPIService::Request.sync_courses_with_search_and_compare(
          @current_user.email,
          @provider.provider_code,
        )
      rescue StandardError
        false
      end
    end
  end
end
