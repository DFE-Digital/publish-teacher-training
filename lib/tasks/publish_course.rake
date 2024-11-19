# frozen_string_literal: true

namespace :app do
  desc 'We have a course from a previous cycle that we need to publish'
  task :publish_course, %i[course_uuid user_email] => :environment do |_task, args|
    course_uuid = args[:course_uuid]
    user_email = args[:user_email]

    user = User.admins.find_by!(email: user_email)
    course = Course.find_by!(uuid: course_uuid)
    Courses::PublishService.new(course:, user:).call
  end
end
