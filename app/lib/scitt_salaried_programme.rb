# frozen_string_literal: true

class SCITTSalariedProgramme < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new('salary')
    end
  end
end
