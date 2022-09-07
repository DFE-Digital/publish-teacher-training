module Publish
  class CourseSkilledWorkerVisaSponsorshipForm < BaseModelForm
    alias_method :course, :model

    FIELDS = %i[can_sponsor_skilled_worker_visa].freeze

    attr_accessor(*FIELDS)

    validates :can_sponsor_skilled_worker_visa,
      presence: true

  private

    def compute_fields
      course.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
