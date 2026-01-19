module Operations
  class ALevelOperation
    def initialize(repository:, step:)
      @repository = repository
      @step = step
    end

    def execute
      if @repository.record.a_level_subject_requirements << @step.attributes
        { success: true }
      else
        { success: false }
      end
    end
  end
end
