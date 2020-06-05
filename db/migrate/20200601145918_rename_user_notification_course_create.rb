class RenameUserNotificationCourseCreate < ActiveRecord::Migration[6.0]
  def change
    rename_column :user_notification, :course_create, :course_publish
  end
end
