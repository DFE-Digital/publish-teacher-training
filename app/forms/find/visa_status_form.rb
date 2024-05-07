# frozen_string_literal: true

module Find
  class VisaStatusForm
    include ActiveModel::Model

    attr_accessor :visa_status, :university_degree_status

    validates :visa_status, presence: true
    validates :visa_status, inclusion: { in: %w[true false] }

    def require_visa_and_does_not_have_degree?
      ActiveModel::Type::Boolean.new.cast(visa_status) && !ActiveModel::Type::Boolean.new.cast(university_degree_status)
    end
  end
end
