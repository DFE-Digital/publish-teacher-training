# frozen_string_literal: true

module Courses
  # One Find result card for a group of courses from Courses::ResultCards: the
  # provider once in the heading, then each course's details underneath.
  #
  # The courses share a provider and main subject, so the first course's card
  # heading is right for all of them. A group of one is today's card.
  class ResultCardComponent < ViewComponent::Base
    attr_reader :courses

    # Off a provider search, the accredited provider only shows when it tells
    # the card's courses apart.
    def initialize(courses:, accredited_provider_conflicts: Set.new, provider_search: true, **options)
      @courses = courses
      @options = options

      mixed = mixed_accredited_providers?
      @options[:accredited_provider_names] = {} unless provider_search || mixed
      @options[:accredited_provider_conflicts] = mixed ? with_this_card(accredited_provider_conflicts) : accredited_provider_conflicts

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
    def mixed_accredited_providers?
      courses.map { |course| SummaryCardComponent.new(course:, **@options).accredited_provider_name }.uniq.many?
    end

    def with_this_card(conflicts)
      conflicts | Set[[courses.first.provider_id, courses.first.master_subject_id]]
    end
  end
end
