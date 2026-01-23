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
      if wizard.state_store.pending_a_level.nil?
        attributes["pending_a_level"]
      else
        wizard.state_store.pending_a_level
      end
    end

    # Operations methods
    def accepting_pending_a_level?
      attributes["pending_a_level"] == "yes"
    end
  end
end
