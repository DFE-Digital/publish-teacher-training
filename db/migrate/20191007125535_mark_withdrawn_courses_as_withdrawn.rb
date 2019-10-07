class MarkWithdrawnCoursesAsWithdrawn < ActiveRecord::Migration[6.0]
  def up
    say_with_time "Marking all courses with site statuses that have been suspended with no vacancies" do
      courses = Course.where(site_statuses: SiteStatus.where(vac_status: "no_vacancies", status: "suspended"))
      published_courses = courses.select(&:is_published?)
      courses_with_all_suspended_no_vacancy_sites = published_courses.select do |course|
        course.site_statuses.all? do |site_status|
          site_status.vac_status == "no_vacancies" && site_status.status == "suspended"
        end
      end

      courses_with_all_suspended_no_vacancy_sites.each do |course|
        course.enrichments.latest_first.first.withdraw
      end
    end
  end

  def down; end
end
