summary 'List courses'

run do |opts, _args, _cmd|
  opts = MCB.apiv1_opts(opts)
  last_context = nil

  table = Terminal::Table.new headings: %w[Code Name Provider\ Code Provider\ Name] do |t|
    MCB.each_v1_provider(opts).each do |course, context|
      last_context = context
      provider_info = course['provider']
                        .slice('institution_code', 'institution_name')
      t << course.slice('course_code', 'name').values + provider_info.values
    end
  end

  puts table

  if last_context
    if opts[:all]
      puts 'All pages retrieved.'
    else
      puts 'Only first page of results retrieved (use -a to retrieve all).'
    end
    next_changed_since = last_context[:next_url].sub(/.*changed_since=(.*)(&.*)|$/, '\1')
    puts(
      "To continue retrieving results use the changed-since: " +
      CGI.unescape(next_changed_since)
    )
  end
end
