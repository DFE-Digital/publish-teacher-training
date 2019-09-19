module API
  module System
    class ForceSyncController < API::System::ApplicationController
      def sync
        BulkSyncCoursesToFindJob.perform_later
        render status: :accepted
      end
    end
  end
end
