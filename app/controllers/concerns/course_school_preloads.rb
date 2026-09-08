# frozen_string_literal: true

# Which school association a course page should eager-load, while the
# :course_publishing_uses_new_school_model flag decides whether schools are read
# from course_school -> gias_school or from the legacy course_site -> site.
#
# Two shapes, because the pages ask different questions: the course page only
# asks whether a course has any school, while the placements pages render every
# one of them.
#
# Study sites are not covered here: study_site_placements -> site has no
# canonical model, so anything rendering them keeps its own legacy preload.
module CourseSchoolPreloads
  extend ActiveSupport::Concern

private

  # Course#without_employing_school? only asks whether the collection is empty,
  # so nothing below the join rows is worth loading - a course can have
  # thousands of them.
  def school_preloads
    if FeatureFlag.active?(:course_publishing_uses_new_school_model)
      { schools: [] }
    else
      { site_statuses: [:site] }
    end
  end

  # CourseDecorator#preview_placement_schools walks course_school ->
  # provider_school -> gias_school for each school's name and address, so the
  # preload has to reach gias_school through provider_school. course_school's
  # own gias_school is a denormalised copy that these pages never read - the
  # public API's location serializer is what reads that one.
  def placement_school_preloads
    if FeatureFlag.active?(:course_publishing_uses_new_school_model)
      { schools: { provider_school: :gias_school } }
    else
      { site_statuses: [:site] }
    end
  end
end
