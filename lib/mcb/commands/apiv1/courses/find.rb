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

def hashes_to_ostructs(hashes)
  hashes.map { |hash| OpenStruct.new(hash) }
end

def print_course_info(course)
  campus_statuses = hashes_to_ostructs course.delete('campus_statuses')
  subjects        = hashes_to_ostructs course.delete('subjects')
  provider        = course.delete('provider')

  puts Terminal::Table.new rows: course
  puts "\n"
  puts "Provider:"
  puts Terminal::Table.new rows: provider
  puts "\n"
  puts "Subjects:"

  subjects_table = Tabulo::Table.new(subjects,
                                     :subject_code,
                                     :subject_name).pack(max_table_width: nil)
  puts subjects_table
  puts subjects_table.horizontal_rule

  puts "\n"
  puts "Campus Statuses:"
  campus_statuses_table = Tabulo::Table.new(campus_statuses,
                                            :campus_code,
                                            :name,
                                            :vac_status,
                                            :publish,
                                            :status,
                                            :course_open_date).pack(max_table_width: nil)
  puts campus_statuses_table
  puts campus_statuses_table.horizontal_rule
end
