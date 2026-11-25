# frozen_string_literal: true

module Publish
  # Keeps the add-user pages (new and check) on the same provider cycle.
  # Support sends its cycle under support_return; otherwise this uses the cycle
  # the user switched to in Publish (session[:cycle_year]).
  #
  # Needs ReturnToSupport in the controller for support_flow_params.
  module UsersCycleYear
  private

    def cycle_year
      @cycle_year ||= params[:recruitment_cycle_year] ||
        support_flow_params[:recruitment_cycle_year] ||
        params[:year] ||
        session[:cycle_year] ||
        Find::CycleTimetable.current_year
    end
  end
end
