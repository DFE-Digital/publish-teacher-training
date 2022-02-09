class VacancyStatusDeterminationService
  attr_reader :vacancy_status_full_time,
              :vacancy_status_part_time,
              :course

  def self.call(vacancy_status_full_time:, vacancy_status_part_time:, course:)
    new(
      vacancy_status_full_time: vacancy_status_full_time,
      vacancy_status_part_time: vacancy_status_part_time,
      course: course,
    ).vacancy_status
  end

  def initialize(vacancy_status_full_time:, vacancy_status_part_time:, course:)
    @vacancy_status_full_time = vacancy_status_full_time
    @vacancy_status_part_time = vacancy_status_part_time
    @course                   = course
  end

  def vacancy_status
    return "both_full_time_and_part_time_vacancies" if full_or_part_time?
    return "full_time_vacancies" if full_time?
    return "part_time_vacancies" if part_time?

    "no_vacancies"
  end

private

  def part_time?
    (course.full_time_or_part_time? && vacancy_status_part_time?) ||
      (course.part_time? && vacancy_status_part_time?)
  end

  def full_time?
    (course.full_time_or_part_time? && vacancy_status_full_time?) ||
      (course.full_time? && vacancy_status_full_time?)
  end

  def full_or_part_time?
    course.full_time_or_part_time? &&
      (vacancy_status_full_time? && vacancy_status_part_time?)
  end

  def vacancy_status_full_time?
    vacancy_status_full_time == "1"
  end

  def vacancy_status_part_time?
    vacancy_status_part_time == "1"
  end
end
