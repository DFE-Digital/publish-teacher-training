# frozen_string_literal: true

module Courses
  # One Find result card for a group of courses from Courses::ResultCards: the
  # provider once in the heading, then each course's details underneath.
  #
  # The courses share a provider and main subject, so the first course's card
  # heading is right for all of them. A group of one is today's card.
  class ResultCardComponent < ViewComponent::Base
    attr_reader :courses

    def initialize(courses:, **options)
      @courses = courses
      @options = options

      super()
    end

    def card
      SummaryCardComponent.new(course: courses.first, **@options)
    end

    def course_details(course)
      SummaryCardComponent.new(course:, **@options, card: false)
    end
  end
end
