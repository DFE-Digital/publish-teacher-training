name "accredited_courses"
summary "Show courses this provider is the accredited body for"
param :code, transform: ->(code) { code.upcase }
option :f, "csv-file", "output to a file in csv format", argument: :required

run do |opts, args, _cmd|
  MCB.init_rails(opts)
  code = args[:code]
  provider = MCB.get_recruitment_cycle(opts).providers.find_by(provider_code: code)
  if provider.present?
    write_course_data(provider, opts[:"csv-file"])
  else
    error "Provider with code '#{code}' not found"
  end
end

def write_course_data(provider, output_filename = nil)
  course_data = get_course_data(provider)
  if output_filename
    write_to_csv_file(output_filename, course_data)
  else
    tp course_data
  end
end

def get_course_data(provider)
  out = provider.current_accredited_courses.map { |c| build_course_with_sites(c) }
  out.flatten!
  out.sort_by { |c| c.values_at(:provider_name, :course_name, :program_type, :site_name) }
end

def build_course_with_sites(course)
  if course.site_statuses.any?
    course.site_statuses.map do |ss|
      build_site(ss).merge(build_course(course))
    end
  else
    [build_course(course)]
  end
end

def build_course(course)
  {
    provider_code: course.provider.provider_code,
    provider_name: course.provider.provider_name,
    course_code: course.course_code,
    course_name: course.name,
    study_mode: course.study_mode,
    program_type: course.program_type,
    qualification: course.qualification,
    content_status: course.content_status,
  }
end

def build_site(site_status)
  {
    site_code: site_status.site.code,
    site_name: site_status.site.location_name,
    site_status: site_status.status,
    site_published: site_status.published_on_ucas?,
    site_vacancies: site_status.vac_status,
  }
end

def write_to_csv_file(file, data)
  # https://stackoverflow.com/questions/8183706/how-to-save-a-hash-into-a-csv/31613233#31613233
  CSV.open(file, "w", write_headers: true, headers: data.first.keys) do |csv|
    data.each do |row|
      csv << row.values
    end
    puts "#{data.length} rows written to #{file}"
  end
end
