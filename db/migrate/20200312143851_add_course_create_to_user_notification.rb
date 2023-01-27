# frozen_string_literal: true

class AddCourseCreateToUserNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :user_notification, :course_create, :boolean, default: false
  end
end
