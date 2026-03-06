module Support
  module Candidate
    class ApplicationController < Support::ApplicationController
      before_action :set_candidate

    private

      def set_candidate
        @candidate = ::Candidate.find(params[:id])
      end
    end
  end
end
