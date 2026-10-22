# frozen_string_literal: true

module Courses
  # The course-information cell: one line per field the list has chosen to show.
  class InformationLinesComponent < ViewComponent::Base
    def initialize(course:, fields:)
      @labels = InformationLabels.new(course)
      @fields = fields
      super()
    end

  private

    attr_reader :labels, :fields

    def show?(key)
      fields.include?(key)
    end
  end
end
