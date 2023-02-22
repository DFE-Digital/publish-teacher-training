# frozen_string_literal: true

module Courses
  module EditOptions
    module CanSponsorSkilledWorkerVisaConcern
      extend ActiveSupport::Concern
      included do
        def can_sponsor_skilled_worker_visa_options
          [true, false]
        end
      end
    end
  end
end
