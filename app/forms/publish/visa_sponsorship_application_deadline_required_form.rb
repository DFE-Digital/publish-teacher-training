# frozen_string_literal: true

module Publish
  class VisaSponsorshipApplicationDeadlineRequiredForm < ApplicationForm
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :visa_sponsorship_application_deadline_required, :boolean

    validates :visa_sponsorship_application_deadline_required, inclusion: { in: [true, false] }

    def options
      option = Struct.new(:id, :name)

      [
        option.new(id: true, name: 'Yes'),
        option.new(id: false, name: 'No')
      ]
    end
  end
end
