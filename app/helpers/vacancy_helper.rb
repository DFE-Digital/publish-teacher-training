# frozen_string_literal: true

module VacancyHelper
  def vacancy_available_for_course_site_status?(course, site_status, vacancy_study_mode = nil)
    case course.study_mode
    when "full_time"
      site_status.full_time_vacancies?
    when "part_time"
      site_status.part_time_vacancies?
    when "full_time_or_part_time"
      vacancy_available_for_study_mode?(site_status, vacancy_study_mode)
    else
      false
    end
  end

private

  def vacancy_available_for_study_mode?(site_status, vacancy_study_mode)
    return true if site_status.both_full_time_and_part_time_vacancies?

    case vacancy_study_mode
    when :part_time
      site_status.part_time_vacancies?
    when :full_time
      site_status.full_time_vacancies?
    else
      false
    end
  end
end
