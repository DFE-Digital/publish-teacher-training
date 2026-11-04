# frozen_string_literal: true

module Support
  module Providers
    class SchoolsController < ApplicationController
      before_action :reset_urn_form, only: %i[index]

      PER_PAGE = 20

      def index
        @pagy, @schools = pagy(
          provider.schools.ordered_by_name.preload(:kept_courses),
          limit: PER_PAGE,
        )
      end

    private

      def provider
        @provider ||= recruitment_cycle.providers.find(params[:provider_id])
      end

      def reset_urn_form
        URNForm.new(provider).clear_stash
      end
    end
  end
end
