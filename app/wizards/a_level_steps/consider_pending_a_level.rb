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

    # Getter for initializing the radio button
    def pending_a_level
      wizard.state_store.pending_a_level
    end

    def pending_considered?
      pending_a_level == "yes"
    end
  end
end
