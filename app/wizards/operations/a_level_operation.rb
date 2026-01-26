module Operations
  # This operation is a no-op placeholder.
  # The actual create/update logic is handled by ALevelSubjectRepository#transform_for_write,
  # which appends new subjects or updates existing ones based on uuid presence.
  # The Persist operation then saves the transformed data.
  class ALevelOperation
    def initialize(repository:, step:)
      @repository = repository
      @step = step
    end

    def execute
      { success: true }
    end
  end
end
