class ReportingController < ActionController::API
  before_action :build_recruitment_cycle

  def reporting
    stats = {
      "Provider": {
        "All": total_providers,
        "Active": active_providers,
      },
      "Courses": {
        "All": total_courses,
        "Findable": findable_courses,
        "Findable with vacancies": findable_courses_with_vacanies,
        "Full time": full_time_courses,
        "Part time": part_time_courses,
        "Full time and part time": both_full_and_part_time_courses,
        "Subjects": {
          "Math": subject("03"),
          "Primary": subject("00"),
          "Primary with English": subject("01"),
          "Primary with geography and history": subject("02"),
          "Primary with mathematics": subject("03"),
          "Primary with modern languages": subject("04"),
          "Primary with physical education": subject("06"),
          "Primary with science": subject("07"),
          "Art and design": subject("W1"),
          "Science": subject("F0"),
          "Biology": subject("C1"),
          "Business studies": subject("08"),
          "Chemistry": subject("F1"),
          "Citizenship": subject("09"),
          "Classics": subject("Q8"),
          "Communication and media studies": subject("P3"),
          "Computing": subject("11"),
          "Dance": subject("12"),
          "Design and technology": subject("DT"),
          "Drama": subject("13"),
          "Economics": subject("L1"),
          "English": subject("Q3"),
          "Geography": subject("F8"),
          "Health and social care": subject("L5"),
          "History": subject("V1"),
          "Mathematics": subject("G1"),
          "Music": subject("W3"),
          "Philosophy": subject("P1"),
          "Physical education": subject("C6"),
          "Physics": subject("F3"),
          "Psychology": subject("C8"),
          "Religious education": subject("V6"),
          "Social sciences": subject("14"),
        },
      },
    }

    status = :ok

    render status: status, json: stats
  end

private

  def total_providers
    @recruitment_cycle.providers.uniq.count
  end

  def active_providers
    @recruitment_cycle.providers.with_findable_courses.uniq.count
  end

  def total_courses
    @recruitment_cycle.courses.count
  end

  def findable_courses
    @recruitment_cycle.courses.findable.uniq.count
  end

  def findable_courses_with_vacanies
    @recruitment_cycle.courses.findable.with_vacancies.uniq.count
  end

  def full_time_courses
    @recruitment_cycle.courses.findable.with_vacancies.with_study_modes(:full_time).uniq.count
  end

  def part_time_courses
    @recruitment_cycle.courses.findable.with_vacancies.with_study_modes(:part_time).uniq.count
  end

  def both_full_and_part_time_courses
    @recruitment_cycle.courses.findable.with_vacancies.with_study_modes(:full_time_and_part_time).uniq.count
  end

  def subject(subject_code)
    @recruitment_cycle.courses.findable.with_vacancies.with_subjects(subject_code).uniq.count
  end

  def build_recruitment_cycle
    @recruitment_cycle = RecruitmentCycle.find_by(
      year: params[:recruitment_cycle_year],
    ) || RecruitmentCycle.current_recruitment_cycle
  end
end
