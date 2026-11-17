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
      SummaryCardComponent.new(course: courses.first, **@options, show_age_range: show_age_range?(courses.first))
    end

    def course_details(course)
      SummaryCardComponent.new(course:, **@options, card: false, show_age_range: show_age_range?(course))
    end

  private

    # Secondary age ranges are nearly all 11 to 16 or 11 to 18, so with grouped
    # results they only show when they tell a card's courses apart.
    def show_age_range?(course)
      return true unless FeatureFlag.active?(:group_search_results) && course.secondary_course?

      courses.many? && courses.map(&:age_range_in_years).uniq.many?
    end

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
