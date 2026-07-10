# frozen_string_literal: true

class AddProviderSchoolIdToCourseSchool < ActiveRecord::Migration[8.1]
  # course_school is only dual-written and never read in production yet,
  # so it is safe to build the index and validate the foreign key in place.
  #
  # The column starts out nullable; rows written before it existed are
  # linked by the BackfillCourseSchoolProviderSchoolIds data migration and
  # the NOT NULL constraint is added by SetCourseSchoolProviderSchoolIdNotNull.
  def change
    safety_assured do
      add_reference :course_school, :provider_school,
                    index: true,
                    foreign_key: { to_table: :provider_school, on_delete: :cascade }
    end
  end
end
