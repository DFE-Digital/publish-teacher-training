# frozen_string_literal: true

module Support
  module Providers
    class HistoryController < ApplicationController
      PER_PAGE = 50

      def index
        query = HistoryQuery.for(provider)
        @pagy, audits = pagy(query.audits_scope, limit: PER_PAGE)
        @history_entries = query.entries_for(audits)
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end
    end
  end
end
