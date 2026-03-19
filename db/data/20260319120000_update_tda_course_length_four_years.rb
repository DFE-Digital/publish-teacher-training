# frozen_string_literal: true

class UpdateTdaCourseLengthFourYears < ActiveRecord::Migration[8.0]
  def up
    CourseEnrichment
      .where(course_id: Course.teacher_degree_apprenticeship.select(:id))
      .where("json_data->>'CourseLength' = ?", "4 years")
      .update_all(Arel.sql("json_data = jsonb_set(json_data, '{CourseLength}', '\"FourYears\"')"))
  end

  def down
    CourseEnrichment
      .where(course_id: Course.teacher_degree_apprenticeship.select(:id))
      .where("json_data->>'CourseLength' = ?", "FourYears")
      .update_all(Arel.sql("json_data = jsonb_set(json_data, '{CourseLength}', '\"4 years\"')"))
  end
end
