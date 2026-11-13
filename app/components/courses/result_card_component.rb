# frozen_string_literal: true

module Courses
  # One Find result card for a group of courses from Courses::ResultCards: the
  # provider once in the heading, then each course's details underneath.
  #
  # The courses share a provider and main subject, so the first course's card
  # heading is right for all of them. A group of one is today's card.
  class ResultCardComponent < ViewComponent::Base
    attr_reader :courses

    def initialize(courses:, accredited_provider_conflicts: Set.new, **options)
      @courses = courses
      @options = options
      @options[:accredited_provider_conflicts] = with_mixed_accredited_providers(accredited_provider_conflicts)

      super()
    end

    def card
      SummaryCardComponent.new(course: courses.first, **@options)
    end

    def course_details(course)
      SummaryCardComponent.new(course:, **@options, card: false)
    end

  private

    # The search's conflicts leave out self-accredited courses, so a group can
    # mix them with accredited ones. The heading can only name one accredited
    # provider, so a mixed group shows each course's under its name instead.
    def with_mixed_accredited_providers(conflicts)
      names = courses.map { |course| SummaryCardComponent.new(course:, **@options).accredited_provider_name }
      return conflicts if names.uniq.size == 1

      conflicts | Set[[courses.first.provider_id, courses.first.master_subject_id]]
    end
  end
end
