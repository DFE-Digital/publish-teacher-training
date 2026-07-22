# frozen_string_literal: true

module Support
  module Banners
    class ExpirationsController < Support::ApplicationController
      def create
        banner = Banner.find(params[:banner_id])

        if banner.expire
          redirect_to active_support_banners_path, flash: { success: "Banner was successfully expired." }
        else
          redirect_back fallback_location: support_banner_path(banner), flash: { notice: "Banner could not be expired." }
        end
      end
    end
  end
end
