# frozen_string_literal: true

module ALevelSteps
  class ConsiderPendingALevel < DfE::Wizard::Step
    attr_accessor :pending_a_level

    validates :pending_a_level, presence: true

    def self.permitted_params
      %i[pending_a_level]
    end

    def next_step
      :a_level_equivalencies
    end
  end
end
