module API
  module V2
    class SiteStatusesController < API::V2::ApplicationController
      deserializable_resource :site_status, only: :update

      def update
        site_status = authorize SiteStatus.find(params[:id])

        site_status.assign_attributes(site_status_params)

        site_status.save!

        render jsonapi: site_status
      end

    private

      def site_status_params
        params
          .require(:site_status)
          .except(:id, :type, :site_id, :site_type, :has_vacancies?, :recruitment_cycle_year)
          .permit(
            :publish,
            :status,
            :vac_status,
          )
      end
    end
  end
end
