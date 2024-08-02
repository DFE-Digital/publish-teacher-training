# frozen_string_literal: true

module Find
  class VisaStatusForm
    include ActiveModel::Model

    attr_accessor :visa_status

    validates :visa_status, presence: true
    validates :visa_status, inclusion: { in: %w[true false] }
  end
end
