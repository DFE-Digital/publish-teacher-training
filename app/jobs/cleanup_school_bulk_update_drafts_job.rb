# frozen_string_literal: true

# A bulk update draft that was never applied is not worth keeping once the
# state key in the provider's URL has stopped resolving it.
class CleanupSchoolBulkUpdateDraftsJob < ApplicationJob
  def perform
    Course::SchoolBulkUpdateDraft.expired.delete_all
  end
end
