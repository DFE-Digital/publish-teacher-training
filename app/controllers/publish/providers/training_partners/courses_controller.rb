# frozen_string_literal: true

module Publish
  module Providers
    module TrainingPartners
      class CoursesController < ApplicationController
        def index
          authorize(provider, :index?)

          @courses = fetch_courses
        end

      private

        def training_partner
          @training_partner ||= provider.training_partners.find_by(provider_code: params[:training_partner_code])
        end

        def fetch_courses
          Publish::Courses::Query.call(
            provider: training_partner,
            params: { accredited_provider: provider.provider_code },
          ).map(&:decorate)
        end
      end
    end
  end
end
