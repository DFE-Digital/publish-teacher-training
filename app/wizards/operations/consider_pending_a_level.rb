module Operations
  class ConsiderPendingALevel
    attr_reader :repository, :current_step

    def initialize(repository:, step:)
      @repository = repository
      @current_step = step
    end

    def execute
      if current_step.accepting_pending_a_level?
        repository.record.update(accept_pending_a_level: true)
      else
        repository.record.update(accept_pending_a_level: false)
      end
      { success: true }
    rescue StandardError
      { success: false }
    end
  end
end
