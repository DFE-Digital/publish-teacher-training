name "sync_to_find"
summary "Send a course to Find"
usage "sync_to_find <provider_code> <course_code1> [<course_code2> ...]"

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[0])
  course_codes = args.to_a[1..-1]
  if course_codes.empty?
    raise ArgumentError, "No courses provided"
  end

  courses = provider.courses.where(course_code: course_codes)
  unless course_codes.size == courses.size
    missing_courses = course_codes - courses.pluck(:course_code)
    raise ArgumentError, "Couldn't find #{'course'.pluralize(missing_courses.size)} #{missing_courses.join(', ')}"
  end

  user = User.find_by!(email: MCB.config[:email])
  unless CoursePolicy.new(user, courses.first).show?
    puts "User #{user.email} cannot edit course #{provider.provider_code}/#{courses.first.course_code}"
    raise CriExitException.new(is_error: true)
  end

  courses.each do |course|
    ManageCoursesAPIService::Request.sync_course_with_search_and_compare(
      user.email,
      provider.provider_code,
      course.course_code,
    )
  end
end
