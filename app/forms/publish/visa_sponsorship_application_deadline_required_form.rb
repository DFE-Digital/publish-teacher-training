# frozen_string_literal: true

module Publish
  class VisaSponsorshipApplicationDeadlineRequiredForm < ApplicationForm
    CURRENT_STEP = "visa_sponsorship_deadline_required"

    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :visa_sponsorship_application_deadline_required, :boolean
    attribute :course
    attribute :starting_step

    validates :visa_sponsorship_application_deadline_required, inclusion: { in: [true, false] }

    def options
      option = Struct.new(:id, :name)

      [
        option.new(id: true, name: "Yes"),
        option.new(id: false, name: "No"),
      ]
    end

    def update!
      return true if visa_sponsorship_application_deadline_required

      course.update!(visa_sponsorship_application_deadline_at: nil)
    end

    def started_at_current_step?
      starting_step == CURRENT_STEP
    end
  end
end
