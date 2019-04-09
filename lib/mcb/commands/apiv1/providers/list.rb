name 'list'
summary 'List providers'

run do |opts, _args, _cmd|
  last_context = nil

  table = Terminal::Table.new headings: %w[Code Name] do |t|
    MCB.each_v1_provider(opts).each do |provider, context|
      last_context = context
      t << provider.slice('institution_code', 'institution_name').values
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
