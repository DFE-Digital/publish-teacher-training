name 'sync_to_find'
summary 'Send a course to Find'
usage 'sync_to_find <provider_code> <course_code>'
param :provider_code
param :course_code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[:provider_code])
  course = provider.courses.find_by!(course_code: args[:course_code])
  user = User.find_by!(email: MCB.config[:email])
  unless CoursePolicy.new(user, course).show?
    puts "User #{user.email} cannot edit course #{provider.provider_code}/#{course.course_code}"
    raise CriExitException.new(is_error: true)
  end

  ManageCoursesAPIService::Request.sync_course_with_search_and_compare(
    user.email,
    provider.provider_code,
    course.course_code
  )
end
