summary 'List courses'

option :P, 'max-pages', 'maximum number of pages to request',
       default: 1,
       argument: :required,
       transform: method(:Integer)

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

  MCB::display_pages_received(page: last_context[:page],
                              max_pages: opts[:'max-pages'],
                              next_url: last_context[:next_url])
end
