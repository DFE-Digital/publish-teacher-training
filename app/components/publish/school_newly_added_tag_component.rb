class Publish::SchoolNewlyAddedTagComponent < Publish::NewlyAddedTagComponent
  def initialize(school:)
    @school = school
    @recruitment_cycle = school.recruitment_cycle

    super()
  end

  def render?
    @school.register_import? && @recruitment_cycle.rollover_period_2026?
  end
end
