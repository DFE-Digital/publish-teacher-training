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
  courses = provider.current_accredited_courses.map do |c|
    {
      provider_code: c.provider.provider_code,
      provider_name: c.provider.provider_name,
      course_code: c.course_code,
      course_name: c.name,
      study_mode: c.study_mode,
      program_type: c.program_type,
      qualification: c.qualification,
      content_status: c.content_status,
      sites: c.site_statuses.map do |ss|
        {
          site_code: ss.site.code,
          site_name: ss.site.location_name,
          site_status: ss.status,
          site_published: ss.published_on_ucas?,
          site_vacancies: ss.vac_status,
        }
      end,
    }
  end
  course_data = courses.select { |c| c[:sites].any? } # they aren't on "Find" or "Apply" if they have no sites
  course_data = flatten_sites(course_data)
  course_data.sort_by do |x|
    [
      x[:provider_name],
      x[:course_name],
      x[:program_type],
      x[:qualification],
      x[:site_name],
    ]
  end
end

def flatten_sites(courses)
  course_data = []
  courses.each do |c|
    c[:sites].each do |s|
      course_data << c.except(:sites).merge(s)
    end
  end
  course_data
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
