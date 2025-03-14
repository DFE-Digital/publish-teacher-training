# frozen_string_literal: true

module Support
  module Providers
    module Schools
      class CheckMultipleController < ApplicationController
        include SuccessMessage

        def show
          school_details
        end

        def update
          save
          redirect_to support_recruitment_cycle_provider_schools_path
        end

        private

        def provider
          @provider ||= recruitment_cycle.providers.find(params[:provider_id])
        end

        def save
          school_details.each(&:save!)

          schools_added_message(school_details)
        end

        def school_details
        end
      end
    end
  end
end
