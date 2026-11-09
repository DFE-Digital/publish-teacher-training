# frozen_string_literal: true

module Support
  module Providers
    class HistoryController < ApplicationController
      def index
        @history_entries = HistoryQuery.call(provider:)
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end
    end
  end
end
