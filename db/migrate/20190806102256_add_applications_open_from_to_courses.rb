class AddApplicationsOpenFromToCourses < ActiveRecord::Migration[5.2]
  def up
    add_column :course, :applications_open_from, :date

    say_with_time 'Ensuring next recruitment cycle has the correct application start date' do
      RecruitmentCycle.next_recruitment_cycle.update!(application_start_date: Date.new(2019, 10, 8))
    end

    say_with_time 'Setting applications_open_from to one held within sites' do
      current_recruitment_cycle = RecruitmentCycle.current_recruitment_cycle
      current_recruitment_cycle.courses.includes(:site_statuses).includes(provider: :recruitment_cycle).all.each do |course|
        if !course.site_statuses.empty?
          applications_open_from = course.site_statuses.min_by(&:applications_accepted_from).applications_accepted_from
          course.update_column(:applications_open_from, applications_open_from)
        else
          course.update_column(:applications_open_from, current_recruitment_cycle.application_start_date)
        end
      end

      next_recruitment_cycle = RecruitmentCycle.next_recruitment_cycle
      next_recruitment_cycle.courses.update_all(applications_open_from: next_recruitment_cycle.application_start_date)
    end
  end

  def down
    remove_column :course, :applications_open_from
  end
end
