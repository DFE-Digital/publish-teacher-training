# frozen_string_literal: true

module Publish
  class CourseSchoolForm < BaseCourseForm
    FIELDS = %i[site_ids schools_validated].freeze

    attr_accessor(*FIELDS)

    validate :no_schools_selected

    def compute_fields
      { site_ids: course.site_ids }.merge(new_attributes)
    end

    # Every school the provider could attach, in the order they are listed.
    # Schools whose GIAS record has closed are excluded, matching the add-course
    # wizard's picker - except one already attached to this course, which stays
    # (flagged as closed) so it is not silently detached by the next save.
    def sites
      @sites ||= course
        .provider
        .sites
        .with_available_gias_school
        .or(course.provider.sites.where(id: course.site_ids))
        .sort_by(&:location_name)
    end

    # Only an already-attached school survives the filter above, so this is
    # normally empty. Resolved in one query, keyed by urn, to avoid an N+1
    # across the list.
    def closed_school?(site)
      site.urn.present? && closed_urns.include?(site.urn)
    end

    def schools_collapse_threshold
      SchoolsList::COLLAPSE_AFTER
    end

    def collapse_schools?
      sites.size > schools_collapse_threshold
    end

  private

    def closed_urns
      @closed_urns ||= begin
        urns = sites.map(&:urn).compact_blank

        urns.empty? ? Set.new : GiasSchool.closed.where(urn: urns).pluck(:urn).to_set
      end
    end

    def no_schools_selected
      return if params[:site_ids].present?
      return if ::Courses::PublishRules::SchoolPresenceExemption.applies?(course)

      if course.recruitment_cycle_rollover_period_2026?
        errors.add(:site_ids, :check_schools) if course.sites.school.present?
        errors.add(:site_ids, :enter_schools) if course.sites.school.blank?
      else
        errors.add(:site_ids, :no_schools)
      end
    end
  end
end
