# frozen_string_literal: true

module Publish
  class AccreditedProvidersController < PublishController
    def index
      authorize :provider, :index?
      provider
    end

    def provider
      @provider ||= recruitment_cycle.providers.find_by(provider_code: params[:provider_code] || params[:code])
    end
  end
end
