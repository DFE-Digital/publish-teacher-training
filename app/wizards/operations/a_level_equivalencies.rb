module Operations
  class ALevelEquivalencies
    attr_reader :repository, :current_step

    def initialize(repository:, step:)
      @repository = repository
      @current_step = step
    end

    def execute
      if current_step.accept_a_level_equivalency?
        repository.record.update(accept_a_level_equivalency: true, additional_a_level_equivalencies: current_step.additional_a_level_equivalencies)
      else
        repository.record.update(accept_a_level_equivalency: false)
      end
      { success: true }
    rescue StandardError
      { success: false }
    end
  end
end
