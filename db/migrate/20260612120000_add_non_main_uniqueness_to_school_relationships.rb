# frozen_string_literal: true

class AddNonMainUniquenessToSchoolRelationships < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_duplicate_non_main_provider_schools
    remove_duplicate_non_main_course_schools

    add_index :provider_school,
              %i[provider_id gias_school_id],
              unique: true,
              where: "site_code <> '-'",
              name: "index_provider_school_unique_non_main",
              algorithm: :concurrently

    add_index :course_school,
              %i[course_id gias_school_id],
              unique: true,
              where: "site_code <> '-'",
              name: "index_course_school_unique_non_main",
              algorithm: :concurrently
  end

  def down
    remove_index :course_school, name: "index_course_school_unique_non_main"
    remove_index :provider_school, name: "index_provider_school_unique_non_main"
  end

private

  def remove_duplicate_non_main_provider_schools
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM provider_school
        WHERE id IN (
          SELECT id
          FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY provider_id, gias_school_id
                     ORDER BY id
                   ) AS duplicate_position
            FROM provider_school
            WHERE site_code <> '-'
          ) ranked_provider_schools
          WHERE duplicate_position > 1
        )
      SQL
    end
  end

  def remove_duplicate_non_main_course_schools
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM course_school
        WHERE id IN (
          SELECT id
          FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                     PARTITION BY course_id, gias_school_id
                     ORDER BY id
                   ) AS duplicate_position
            FROM course_school
            WHERE site_code <> '-'
          ) ranked_course_schools
          WHERE duplicate_position > 1
        )
      SQL
    end
  end
end
