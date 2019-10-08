class RemoveApplicationsAcceptedFromFromCourseSite < ActiveRecord::Migration[6.0]
  def up
    remove_column :course_site, :applications_accepted_from
  end

  def down
    # There no going back
  end
end
