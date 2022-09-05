module Courses
  module EditOptions
    module CanSponsorSkilledWorkerVisaConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def can_sponsor_skilled_worker_visa_options
          [true, false]
        end
      end
    end
  end
end
