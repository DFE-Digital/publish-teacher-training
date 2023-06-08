# frozen_string_literal: true

class MarkWithdrawnCoursesAsWithdrawn < ActiveRecord::Migration[6.0]
  def up
    say_with_time 'Marking all courses with site statuses that have been suspended with no vacancies' do
      courses = Course.where(site_statuses: SiteStatus.where(status: 'suspended'))
      published_courses = courses.select(&:is_published?)
      courses_with_all_suspended_sites = published_courses.select do |course|
        course.site_statuses.all? do |site_status|
          site_status.status == 'suspended'
        end
      end

      courses_with_all_suspended_sites.each do |course|
        course.enrichments.most_recent.first.withdraw
      end
    end
  end

  def down; end
end
