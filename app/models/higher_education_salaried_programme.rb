# frozen_string_literal: true

class HigherEducationSalariedProgramme < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new('salary')
    end
  end
end
