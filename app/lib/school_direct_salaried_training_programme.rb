# frozen_string_literal: true

class SchoolDirectSalariedTrainingProgramme < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new('salary')
    end

    def sponsors_skilled_worker_visa? = true
  end
end
