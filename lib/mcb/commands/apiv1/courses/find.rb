summary 'Find a particular provider course entry'
description <<~EODESCRIPTION
  Searches for a course with the given provider and course code by iterating
  through all the pages of results provided from the course endpoint, outputing
  the found record.
EODESCRIPTION
usage 'find [options] <provider_code> <course_code>'
param :provider_code
param :course_code
option :j, 'json', 'show the returned JSON response'


run do |opts, args, _cmd|
  opts = MCB.apiv1_opts(opts)
  opts[:all] ||= true

  provider_code = args[:provider_code].upcase
  course_code = args[:course_code].upcase

  verbose "looking for provider '#{provider_code}' course '#{course_code}'"

  (course, last_context) = find_course(provider_code, course_code, opts)

  if course.nil?
    error "Provider '#{provider_code}' course '#{course_code}' not found"
    next
  end

  if opts[:json]
    puts JSON.pretty_generate(JSON.parse(course.to_json))
  else
    print_course_info(course)
  end

  if opts[:all]
    puts 'All pages searched.'
  else
    puts 'Only first page of results searched (use -a to retrieve all).'
  end
  puts "To continue searching use the url: #{last_context[:next_url]}"
end

def find_course(provider_code, course_code, opts)
  MCB.each_v1_course(opts).detect do |course, _context|
    course['provider']['institution_code'] == provider_code &&
      course['course_code'] == course_code
  end
end

def print_course_info(course)
  campus_statuses = course.delete('campus_statuses')
  subjects        = course.delete('subjects')
  provider        = course.delete('provider')

  puts MCB::Render.course_record course
  puts "\n"
  puts MCB::Render.provider_record provider
  puts "\n"
  puts MCB::Render.subjects_table subjects
  puts "\n"
  puts MCB::Render.site_statuses_table campus_statuses
end
