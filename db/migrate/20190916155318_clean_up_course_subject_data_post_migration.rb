# rubocop:disable Metrics/BlockLength
class CleanUpCourseSubjectDataPostMigration < ActiveRecord::Migration[5.2]
  def change
    say_with_time "cleansing subject data" do
      courses = RecruitmentCycle.find_by(year: "2020").courses.includes(:subjects)

      # targetting primary courses
      primary = Subject.find_by!(subject_name: "Primary")
      primary_courses = courses.where(subject: { subject_name: "Primary" })

      primary_courses_with_two_subjects = primary_courses.select { |course| course.subjects.count == 2 }
      primary_courses_with_two_subjects.each do |course|
        course.subjects -= [primary]
      end

      geography = Subject.find_by!(subject_name: "Geography")
      pe = Subject.find_by!(subject_name: "Physical education")

      c = courses.find_by!(course_code: "3CZ2")
      c.update(level: "secondary", subjects: [pe, geography])

      modern_languages = Subject.find_by!(subject_name: "Modern Languages")

      modern_language_courses = courses.where(subject: { subject_name: ["French",
                                                                        "English as a second or other language",
                                                                        "German",
                                                                        "Italian",
                                                                        "Japanese",
                                                                        "Mandarin",
                                                                        "Russian",
                                                                        "Spanish",
                                                                        "Modern languages (other)"] })

      modern_language_courses.each do |course|
        course.subjects += [modern_languages]
      end

      balanced_science = Subject.find_by!(subject_name: "Balanced Science")
      science = Subject.find_by!(subject_name: "Science")

      balanced_science_courses = courses.where(subject: { subject_name: "Balanced Science" })
      balanced_science_courses.each do |course|
        if course.subjects.count == 4
          course.update(subjects: [science])
        else
          course.subjects -= [balanced_science]
          course.subjects += [science]
        end
      end

      history = Subject.find_by!(subject_name: "History")

      humanities_courses = courses.where(subject: { subject_name: "Humanities" })
      humanities_courses.each do |course|
        course.update(subjects: [geography, history])
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
