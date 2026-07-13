# frozen_string_literal: true

class AddProviderSchoolIdToCourseSchool < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_reference :course_school, :provider_school,
                    null: false, # rubocop:disable Rails/NotNullColumn
                    index: true,
                    foreign_key: { to_table: :provider_school, on_delete: :cascade }
    end
  end
end
