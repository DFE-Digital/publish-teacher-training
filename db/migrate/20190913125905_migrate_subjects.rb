class MigrateSubjects < ActiveRecord::Migration[5.2]
  def up
    say_with_time 'populating/migrating course subjects' do
      all_subject = Subject.all
      all_course_includes_ucas_subjects = Course.includes(
        :ucas_subjects,
        :subjects,
        provider: :recruitment_cycle
      )
      all_course_includes_ucas_subjects.each do |course|
        course.update_column(:level, course.ucas_level)
        course.subjects = all_subject.select { |s| s.subject_name.in? course.dfe_subjects.map(&:to_s) }
      end
    end
  end

  def down
    CourseSubject.connection.truncate :course_subject
    Course.all.each { |c| c.update_column(:level, nil) }
  end
end
