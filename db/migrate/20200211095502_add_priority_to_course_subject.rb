class AddPriorityToCourseSubject < ActiveRecord::Migration[6.0]
  def change
    add_column :course_subject, :priority, :integer
  end
end
