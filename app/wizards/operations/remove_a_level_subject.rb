module Operations
  # This operation is a no-op placeholder.
  # The actual removal logic is handled by ALevelSubjectRemovalRepository#transform_for_write,
  # which filters out the subject with the matching uuid when confirmation is "yes".
  # When confirmation is "no", no changes are made.
  # The Persist operation then saves the transformed data.
  class RemoveALevelSubject
    def initialize(repository:, step:)
      @repository = repository
      @step = step
    end

    def execute
      { success: true }
    end
  end
end
