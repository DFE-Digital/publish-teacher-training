# frozen_string_literal: true

class SCITTProgramme < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new("fee")
    end

    def sponsors_student_visa? = true
  end
end
