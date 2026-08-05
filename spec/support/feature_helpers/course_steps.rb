# frozen_string_literal: true

module FeatureHelpers
  module CourseSteps
    attr_reader :course

    def given_a_course_exists(*traits, **overrides)
      @course ||= create(:course, *traits, **overrides, provider: overrides.delete(:provider) || current_user.providers.first)
    end

    def given_a_site_exists(*traits, **overrides)
      course.site_statuses << build(:site_status, *traits, **overrides)
    end

    def attach_course_school_for_site(site, course: self.course)
      create(:course_school, :for_site, course:, site:)
    end

    def attach_course_schools_for_sites(sites = course.sites, course: self.course)
      sites.each { |site| attach_course_school_for_site(site, course:) }
    end
  end
end
