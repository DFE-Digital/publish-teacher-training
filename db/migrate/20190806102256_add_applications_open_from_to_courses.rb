class AddApplicationsOpenFromToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :course, :applications_open_from, :date

    say_with_time 'Setting applications_open_from to one held within sites' do
      Course.all.each do |course|
        if course.recruitment_cycle.current?
          applications_open_from = course.site_statuses.order("applications_accepted_from ASC").first.applications_accepted_from
          course.update!(applications_open_from: applications_open_from)
        else
          course.update!(applications_open_from: course.recruitment_cycle.application_start_date)
        end
      end
    end
  end
end
