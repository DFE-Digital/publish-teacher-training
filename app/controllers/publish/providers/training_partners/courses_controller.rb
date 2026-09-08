# frozen_string_literal: true

module Publish
  module Providers
    module TrainingPartners
      class CoursesController < ApplicationController
        def index
          @courses = fetch_courses
          @visible_course_information_fields = Publish::CourseList.visible_course_information_fields(@courses)
        end

      private

        def training_partner
          @training_partner ||= provider.training_partners.find_by(provider_code: params[:training_partner_code])
        end

        # The list is unfiltered, so these courses are the whole list the
        # uniformity rule compares across: the partner's courses this accredited
        # provider ratifies, and no one else's.
        #
        # The View course column needs nothing beyond what the row already
        # carries — the content_status column and the cycle the query preloads
        # with the provider — so there is nothing extra to load here.
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
