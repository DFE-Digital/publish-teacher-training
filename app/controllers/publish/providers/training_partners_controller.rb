# frozen_string_literal: true

module Publish
  module Providers
    class TrainingPartnersController < ApplicationController
      def index
        authorize(provider, :can_list_training_providers?)

        @training_partners = provider.training_partners.include_accredited_courses_counts(provider.provider_code).order(:provider_name)
        @course_counts = @training_partners.to_h { |p| [p.provider_code, p.accredited_courses_count] }
      end
    end
  end
end
