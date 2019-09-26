class MigrateSubjects < ActiveRecord::Migration[5.2]
  def up
    say_with_time "populating/migrating course subjects" do
      all_subjects = Subject.all
      all_courses_includes_ucas_subjects = Course.includes(
        :ucas_subjects,
        :subjects,
        provider: :recruitment_cycle,
      )
      all_courses_includes_ucas_subjects.each do |course|
        course.update_column(:level, course.ucas_level)

        dfe_subjects = course.dfe_subjects.map do |dfe_subject|
          dfe_subject.to_s.downcase
        end

        course.subjects = all_subjects.select do |subject|
          subject.subject_name.downcase.in? dfe_subjects
        end
      end
    end
  end

  def down
    CourseSubject.connection.truncate :course_subject
    Course.all.each { |c| c.update_column(:level, nil) }
  end
end
