module Operations
  class RemoveALevelSubject
    attr_reader :repository, :current_step

    def initialize(repository:, step:)
      @repository = repository
      @current_step = step
    end

    def execute
      if current_step.confirmation == "yes"

        updated_subjects = repository.record.a_level_subject_requirements.reject { it["uuid"] == current_step.uuid }
        repository.record.update(a_level_subject_requirements: updated_subjects)
        { success: true }
      else
        { success: false }
      end
    end
  end
end
