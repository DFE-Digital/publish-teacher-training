# frozen_string_literal: true

module Find
  module Candidates
    class RecentSearchesController < ApplicationController
      before_action :require_authentication

      def index
        @candidate.recent_searches.stale.discard_all
        @recent_searches = @candidate.recent_searches.for_display
      end

      def clear_all
        searches = @candidate.recent_searches.active
        ids = searches.pluck(:id)
        searches.discard_all

        undo_link = render_to_string(
          partial: "find/candidates/recent_searches/undo_link",
          locals: { ids: },
        )

        flash[:success_with_body] = {
          "title" => t(".success_title"),
          "body" => t(".success_body_html", undo_link:),
        }

        redirect_to find_candidate_recent_searches_path
      end

      def undo
        ids = Array(params[:ids])
        @candidate.recent_searches.where(id: ids).find_each(&:undiscard)
        redirect_to find_candidate_recent_searches_path
      end

    private

      def reason_for_request
        :general
      end
    end
  end
end
