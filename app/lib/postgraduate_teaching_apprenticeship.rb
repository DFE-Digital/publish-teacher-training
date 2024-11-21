# frozen_string_literal: true

class PostgraduateTeachingApprenticeship < Program
  class << self
    def funding_type
      ActiveSupport::StringInquirer.new('apprenticeship')
    end

    def sponsors_skilled_worker_visa? = true
  end
end
