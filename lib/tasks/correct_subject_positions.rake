namespace :correct_subject_positions do
  desc "Flip subject position of incorrect courses"
  task flip_subjects: :environment do |_task, _args|
    incorrect_course_ids = [12961064, 12965012, 12959155, 12967294, 12958088, 12957580, 12966949, 12958520, 12968910, 12961946, 12960955, 12966226, 12962223, 12963101, 12963100, 12968676, 12957029, 12963084, 12968508, 12968055, 12960926, 12963105, 12959891, 12968271, 12957706, 12965139, 12959109, 12961976, 12968191, 12959929, 12963964, 12964636, 12963103, 12965902, 12965498, 12959910, 12961660, 12966539, 12966275, 12962607, 12963107, 12965263, 12957009, 12960084, 12964549, 12966653, 12964903, 12967192, 12961478, 12967945, 12969557, 12963106, 12960232, 12958474, 12957707]

    RecruitmentCycle.current.courses.where(id: incorrect_course_ids).each do |course|
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
