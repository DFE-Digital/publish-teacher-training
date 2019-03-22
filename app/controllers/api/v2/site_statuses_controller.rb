module API
  module V2
    class SiteStatusesController < API::V2::ApplicationController
      deserializable_resource :site_status, only: :update

      def update
        site_status = authorize SiteStatus.find(params[:id])
        site_status.update site_status_params

        render jsonapi: site_status
      end

    private

      def site_status_params
        params.require(:site_status).permit(
          :applications_accepted_from,
          :publish,
          :status,
          :vac_status
        )
      end
    end
  end
end
