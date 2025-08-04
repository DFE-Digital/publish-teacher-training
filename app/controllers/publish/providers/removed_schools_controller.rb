# frozen_string_literal: true

module Publish
  module Providers
    class RemovedSchoolsController < ApplicationController
      def index
        authorize(provider, :index?)

        @provider = provider
      end

    private

      def provider_params
        params.expect(provider: [:selectable_school])
      end
    end
  end
end
