# frozen_string_literal: true

module Support
  class AutomatedBannersController < ApplicationController
    def show
      @banner = AutomatedBanner.find(params[:id])

      render "support/banners/show"
    end
  end
end
