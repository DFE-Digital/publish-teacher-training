# frozen_string_literal: true

# Flags a school whose GIAS record has closed. Shared by Publish and Support.
# Presentational only: the caller decides closedness. Provider::School pages use
# #gias_school_closed?, which is free wherever gias_school is preloaded; the
# Site-backed course schools picker has no such association, so it batches the
# lookup into a set of closed URNs.
class ClosedSchoolTagComponent < ViewComponent::Base
  def initialize(closed:)
    @closed = closed

    super()
  end

  def render?
    @closed
  end
end
