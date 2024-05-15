# frozen_string_literal: true

class RemoveDefaultFromCourseIsSend < ActiveRecord::Migration[7.1]
  def change
    change_column_default :course, :is_send, from: false, to: nil
  end
end
