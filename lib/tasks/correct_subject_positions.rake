namespace :correct_subject_positions do
  desc "Flip incorrect subject position of courses"
  task :flip_subjects, [:course_ids] => :environment do |_task, args|
    course_ids = args[:course_ids].split.map(&:to_i)
    RecruitmentCycle.current.courses.where(id: course_ids).each do |course|
      course.course_subjects.each_with_index do |course_subject, index|
        case index
        when 0
          course_subject.position = 1
        when 1
          course_subject.position = 0
        end
        course_subject.save
      end
    end
  end
end
