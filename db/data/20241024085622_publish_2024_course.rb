# frozen_string_literal: true

class Publish2024Course < ActiveRecord::Migration[7.2]
  def up
    current_user = User.find_by!(email: "david4.young@education.gov.uk")
    course = Course.find_by!(uuid: "b8da2ddd-d7c8-440e-ba21-67eab7eeba53")

    # Code extracted from
    # https://github.com/DFE-Digital/publish-teacher-training/blob/adbc010be7e3457a986fae93bcfead66a7aa0ef9/app/controllers/publish/courses_controller.rb#L133
    Course.transaction do
      course.publish_sites
      course.publish_enrichment(current_user)
      course.application_status_open!
      # NotificationService::CoursePublished.call(course: @course)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
