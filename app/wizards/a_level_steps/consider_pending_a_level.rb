# frozen_string_literal: true

module ALevelSteps
  class ConsiderPendingALevel
    include DfE::Wizard::Step

    attribute :pending_a_level

    validates :pending_a_level, presence: true
    validates :pending_a_level, inclusion: { in: %w[yes no] }

    def self.permitted_params
      %i[pending_a_level]
    end

    def accepting_pending_a_level?
      pending_a_level == "yes"
    end
  end
end
