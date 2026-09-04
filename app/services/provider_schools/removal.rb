# frozen_string_literal: true

module ProviderSchools
  class Removal
    def initialize(provider:, uuid:)
      @provider = provider
      @uuid = uuid
    end

    def call
      ActiveRecord::Base.transaction do
        school.with_lock do
          destroy_records_if_removable!
        end
      end
    end

    # Removal is only ever reached by choosing one of the provider's schools,
    # so a uuid that matches no provider school is not a school we can remove.
    def school
      @school ||= provider.schools.find_by!(uuid:)
    end

    # The legacy site dual-written alongside the provider school, destroyed as
    # a by-product of removing it. Absent for schools added after the remodel.
    def site
      @site ||= provider.sites.find_by(uuid:)
    end

    # A provider is never left without any schools, so its last one cannot be
    # removed. Surfaced so the delete page can explain which reason applies.
    def only_school?
      provider.schools.one?
    end

    # Kept courses this school is attached to. Discarded courses are omitted so
    # they neither block removal nor appear on the delete page.
    def attached_courses
      @attached_courses ||= school.kept_courses.order(:name, :course_code)
    end

    # Attached kept courses that would be left with no placement school if this
    # one were removed. The delete page lists these and blocks removal.
    def sole_school_courses
      @sole_school_courses ||= attached_courses.where(id: sole_school_course_ids)
    end

    def sole_school_on_a_course?
      sole_school_course_ids.any?
    end

    # Removable unless this is the provider's last school or the only placement
    # school on a kept course. Extra attachments are detached on destroy.
    def removable?
      return false if only_school?

      !sole_school_on_a_course?
    end

  private

    attr_reader :provider, :uuid

    def destroy_records_if_removable!
      return false unless removable?

      destroy_records!
      true
    end

    def destroy_records!
      school.destroy!
      site&.destroy!
    end

    def sole_school_course_ids
      @sole_school_course_ids ||= Course::School
        .joins(:course)
        .merge(Course.kept)
        .where(course_id: school.course_schools.select(:course_id))
        .group(:course_id)
        .having("COUNT(*) = 1")
        .pluck(:course_id)
    end
  end
end
