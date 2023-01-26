# frozen_string_literal: true

class AddPositionToCourseSubject < ActiveRecord::Migration[6.0]
  def change
    add_column :course_subject, :position, :integer
  end
end
