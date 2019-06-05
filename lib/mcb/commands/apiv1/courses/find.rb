summary 'Find a particular provider course entry'
description <<~EODESCRIPTION
  Searches for a course with the given provider and course code by iterating
  through all the pages of results provided from the course endpoint, outputting
  the found record.
EODESCRIPTION
usage 'find [options] <provider_code> <course_code>'
param :provider_code
param :course_code
option :j, 'json', 'show the returned JSON response'
option :P, 'max-pages', 'maximum number of pages to request',
       default: 250,
       argument: :required,
       transform: method(:Integer)


run do |opts, args, _cmd|
  opts = MCB.apiv1_opts(opts)
  opts[:all] ||= true

  provider_code = args[:provider_code].upcase
  course_code = args[:course_code].upcase

  verbose "looking for provider '#{provider_code}' course '#{course_code}'"

  (course, last_context) = find_course(provider_code, course_code, opts)

  if course.nil?
    error "Provider '#{provider_code}' course '#{course_code}' not found"

    MCB::display_pages_received(page: last_context[:page],
                                max_pages: opts[:'max-pages'],
                                next_url: last_context[:next_url])

    next
  end

  if opts[:json]
    puts JSON.pretty_generate(JSON.parse(course.to_json))
  else
    print_course_info(course)
  end
end

def find_course(provider_code, course_code, opts)
  last_context = nil
  MCB.each_v1_course(opts).detect do |course, context|
    last_context = context
    course['provider']['institution_code'] == provider_code &&
      course['course_code'] == course_code
  end || [nil, last_context]
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
