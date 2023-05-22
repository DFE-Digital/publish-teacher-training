# frozen_string_literal: true

namespace :course_migrate do
  desc 'Migrate courses to use application status'
  task migrate_course_to_use_application_status: :environment do
    total_bm = Benchmark.measure do
      all_open_courses = Course.all.published.findable.with_vacancies.ids.uniq

      Course.all.where.not(id: all_open_courses).update_all(application_status: :closed)

      Course.all.where(id: all_open_courses).update_all(application_status: :open)
    end
    puts total_bm.real
  end
end
