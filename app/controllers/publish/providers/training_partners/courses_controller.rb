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
        # The View course column asks each row whether it is running, which reads
        # site statuses, and whether it may publish without schools, which reads
        # schools for the few courses support has exempted. The provider's own
        # course list never asks, so the preload belongs here rather than in the
        # query. preload rather than includes: the relation carries a custom
        # SELECT and a lateral join that eager_load would have to fold into.
        def fetch_courses
          Publish::Courses::Query.call(
            provider: training_partner,
            params: { accredited_provider: provider.provider_code },
          ).preload(:site_statuses, :schools).map(&:decorate)
        end
      end
    end
  end
end
