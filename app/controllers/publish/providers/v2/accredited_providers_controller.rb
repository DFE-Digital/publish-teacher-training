# frozen_string_literal: true

module Publish
  module Providers
    module V2
      class AccreditedProvidersController < PublishController
        def index; end

        private

        def provider
          @provider = recruitment_cycle.providers.find_by(provider_code: params[:provider_code])
        end
      end
    end
  end
end
