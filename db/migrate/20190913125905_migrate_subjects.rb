class MigrateSubjects < ActiveRecord::Migration[5.2]
  def change
    say_with_time 'populating/migrating course subjects' do
      all_subject = Subject.all
      all_course_includes_ucas_subjects = Course.includes(:ucas_subjects, :provider)
      all_course_includes_ucas_subjects.each do |course|
        course.level = course.ucas_level
        course.subjects = all_subject.where subject_name: course.dfe_subjects.map(&:to_s)
        course.save
      end
    end
  end
end
