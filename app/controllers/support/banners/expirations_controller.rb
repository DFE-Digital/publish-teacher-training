# frozen_string_literal: true

module Support
  module Banners
    class ExpirationsController < Support::ApplicationController
      def create
        banner = Banner.find(params[:banner_id])

        if banner.expire
          redirect_to expired_support_banners_path, flash: { success: t(".success") }
        else
          redirect_back fallback_location: support_banner_path(banner), flash: { warning: t(".failure") }
        end
      end
    end
  end
end
