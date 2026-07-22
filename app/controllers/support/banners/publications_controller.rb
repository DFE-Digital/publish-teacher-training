# frozen_string_literal: true

module Support
  module Banners
    class PublicationsController < Support::ApplicationController
      def create
        banner = Banner.find(params[:banner_id])

        if banner.publish
          redirect_to active_support_banners_path, flash: { success: "Banner was successfully published." }
        else
          redirect_back fallback_location: support_banner_path(banner), flash: { notice: "Banner could not be published." }
        end
      end
    end
  end
end
