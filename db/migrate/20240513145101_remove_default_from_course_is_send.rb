class RemoveDefaultFromCourseIsSend < ActiveRecord::Migration[7.1]
  def change
    change_column_default :course, :is_send, nil
  end
end
