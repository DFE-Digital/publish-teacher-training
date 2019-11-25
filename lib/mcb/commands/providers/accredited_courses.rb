name "accredited_courses"
summary "Show courses this provider is the accredited body for"
param :code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  code = args[:code]

  provider = MCB.get_recruitment_cycle(opts).providers.find_by!(provider_code: code)

  if provider.nil?
    error "Provider with code '#{code}' not found"
  else
    out = provider.current_accredited_courses.map do |c|
      {
        provider_code: c.provider.provider_code,
        provider_name: c.provider.provider_name,
        course_name: c.name,
        course_code: c.course_code,
        study_mode: c.study_mode,
        age_range_in_years: c.age_range_in_years,
        program_type: c.program_type,
        qualification: c.qualification,
      }
    end
    out = out.sort_by { |x| [x[:provider_name], x[:course_name], x[:program_type], x[:qualification]] }
    tp out
  end
end
