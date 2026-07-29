# frozen_string_literal: true

# Flags a school whose GIAS record has closed. Shared by Publish and Support.
# Presentational only: the caller decides closedness, batching the lookup on
# list pages (a set of closed URNs) and using Site/Provider::School
# #gias_school_closed? on the single-record show pages.
class ClosedSchoolTagComponent < ViewComponent::Base
  def initialize(closed:)
    @closed = closed

    super()
  end

  def render?
    @closed
  end
end
