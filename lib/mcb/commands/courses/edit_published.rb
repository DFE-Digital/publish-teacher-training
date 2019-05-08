name 'edit_published'
summary 'Edit publisheds course directly in the DB'

def vacancy_status(course)
  case course.study_mode
  when "full_time"
    :full_time_vacancies
  when "part_time"
    :part_time_vacancies
  when "full_time_or_part_time"
    :both_full_time_and_part_time_vacancies
  else
    raise "Unexpected study mode #{course.study_mode}"
  end
end

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  Provider.connection.transaction do
    cli = HighLine.new

    provider_code = cli.ask("Provider code?  ")
    provider = Provider.find_by!(provider_code: provider_code)

    course_code = cli.ask("Course code?  ")
    course = provider.courses.find_by!(course_code: course_code)

    puts Terminal::Table.new rows: MCB::CourseShow.new(course).to_h

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
            site_code = cmd.match(/\(code: (.*)\)/)[1]
            if site_status = course.site_statuses.detect { |ss| ss.site.code == site_code }
              puts "Toggling #{site_status}"
              site_status.toggle!
            else
              is_course_new = course.new? # persist this before we create the site status
              site_status = SiteStatus.create!(
                course: course,
                site: new_sites_to_add.detect { |s| s.code == site_code },
                vac_status: vacancy_status(course),
                status: :new_status,
                applications_accepted_from: Date.today,
                publish: :unpublished,
              )
              site_status.start! unless is_course_new
            end
          end
        end
      end
      course.reload
      course.site_statuses.reload
    end
  end
end
