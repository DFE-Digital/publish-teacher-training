# frozen_string_literal: true

module Find
  module Search
    class NoDegreeAndRequiresVisaSponsorshipController < Find::ApplicationController
      def back_path
        find_visa_status_path(backlink_query_parameters)
      end
      helper_method :back_path

      # this controller is an exit page, so returning the latest form
      def form_name = :find_visa_status_form
    end
  end
end
