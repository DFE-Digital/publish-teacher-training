name 'edit_published'
summary 'Edit publisheds course directly in the DB'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    cli = HighLine.new

    provider_code = cli.ask("Provider code?  ")
    provider = Provider.find_by!(provider_code: provider_code)

    course_code = cli.ask("Course code?  ")
    course = provider.courses.find_by!(course_code: course_code)

    puts Terminal::Table.new rows: MCB::CourseShow.new(course).to_h

    if course.new?
      puts "This course is new, meaning the provider can edit them directly"
      break
    end

    puts "Course status: #{course.ucas_status}"

    finished = false
    until finished do
      cli.choose do |menu|
        existing_sites = course.site_statuses.map(&:site)
        new_sites_to_add = provider.sites - existing_sites
        site_status_choices = course.site_statuses.map {|ss| "#{ss.site.location_name} (code: #{ss.site.code}) – #{ss.status}/#{ss.publish}" }
        new_site_choices = new_sites_to_add.map {|s| "#{s.location_name} (code: #{s.code})" }
        menu.choices(*(site_status_choices + new_site_choices + ['exit'])) do |cmd|
          if cmd == 'exit'
            finished = true
          else
            # either tweak the site status or add new site here
          end
        end
      end
    end
  end
end
