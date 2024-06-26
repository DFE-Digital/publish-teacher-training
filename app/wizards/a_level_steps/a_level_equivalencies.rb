# frozen_string_literal: true

module ALevelSteps
  class ALevelEquivalencies < DfE::Wizard::Step
    delegate :exit_path, to: :wizard
    attr_accessor :accept_a_level_equivalencies, :additional_a_level_equivalencies

    def self.permitted_params
      %i[accept_a_level_equivalencies additional_a_level_equivalencies]
    end

    def next_step
      :exit
    end
  end
end
