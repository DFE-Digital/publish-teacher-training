# frozen_string_literal: true

class TeacherDegreeApprenticeship < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new('apprenticeship')
    end
  end
end
