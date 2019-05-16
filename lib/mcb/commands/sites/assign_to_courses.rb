name 'assign_to_courses'
summary 'Assign a new site to multiple courses in db'
usage 'assign_to_courses <provider_code> <site_code<'
param :provider_code
param :site_code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  provider = Provider.find_by!(provider_code: args[:provider_code])
  site = provider.sites.find_by!(code: args[:site_code])

  cli = HighLine.new
  course_codes_string = cli.ask("Which courses do you wish to add #{site.location_name} to? (Enter comma-separated course codes)")
  course_codes = course_codes_string.split(",").map(&:strip)

  courses = provider.courses.where(course_code: course_codes)
  courses.each do |course|
    puts "Adding #{site.location_name} to course #{course.course_code}"
    course.add_site!(site: site)
  end
end
