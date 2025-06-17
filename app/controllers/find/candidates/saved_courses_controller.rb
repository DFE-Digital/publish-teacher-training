module Find
  module Candidates
    class SavedCoursesController < ApplicationController
      before_action :require_authentication

      def index
        @candidate = Current.user
      end
    end
  end
end
