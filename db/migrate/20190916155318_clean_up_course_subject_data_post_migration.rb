# rubocop:disable Metrics/BlockLength
class CleanUpCourseSubjectDataPostMigration < ActiveRecord::Migration[5.2]
  def change
    say_with_time 'cleansing subject data' do
      courses = RecruitmentCycle.second.courses
      subjects = Subject.where(subject_name: ['French',
                                              'English as a Second Language',
                                              'German',
                                              'Italian',
                                              'Japanese',
                                              'Mandarin',
                                              'Russian',
                                              'Spanish',
                                              'Modern languages (other)'])

      primary = Subject.find_by!(subject_name: 'Primary')
      modern_languages = Subject.find_by!(subject_name: 'Modern Languages')
      science = Subject.find_by!(subject_name: 'Science')
      courses.each do |course|
        case course
        when course.subjects.count > 1 && course.subjects.exists?(subject_name: 'Primary')
          course.subjects -= [primary]
        when course.subjects.count == 4 && course.subjects.exists?(subject_name: ['Physics', 'Biology', 'Chemistry', 'Balanced Science'])
          course.update(subjects: [science])
        when course.subjects.count == 1 && course.subjects.exists?(subject_name: 'Balanced Science')
          course.update(subjects: [science])
        when course.subjects.exists?(subject_name: 'Humanities')
          course.update(subjects: [Subject.find_by!(subject_name: 'History'), Subject.find_by!(subject_name: 'Geography')])
        when (course.subjects & subjects).any?
          course.subjects += [modern_languages]
        end
      end

      geography = Subject.find_by!(subject_name: 'Geography')
      pe = Subject.find_by!(subject_name: 'Physical Education')

      course = c.find_by!(course_code: '3CZ2')
      course.update(level: 'primary', subjects: [pe, geography])
    end
  end
end
# rubocop:enable Metrics/BlockLength
