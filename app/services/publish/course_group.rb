# frozen_string_literal: true

module Publish
  # Value object representing a single rendered section of the publish course
  # list: a set of courses that share an accredited (ratifying) provider, or the
  # provider's own self-accredited courses.
  #
  # A group with no accredited provider is "self-accredited" and is rendered
  # without a heading. Courses are returned sorted by name then course code and
  # decorated for display.
  class CourseGroup
    def initialize(training_provider:, accredited_provider:, courses:)
      @training_provider = training_provider
      @accredited_provider = accredited_provider
      @raw_courses = courses
    end

    attr_reader :training_provider, :accredited_provider

    def self_accredited?
      accredited_provider.nil?
    end

    def heading
      accredited_provider&.provider_name
    end

    def courses
      @courses ||= @raw_courses
        .sort_by { |course| [course.name, course.course_code] }
        .map(&:decorate)
    end
  end
end
