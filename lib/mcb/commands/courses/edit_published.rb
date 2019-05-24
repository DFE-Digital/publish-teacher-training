name 'edit_published'
summary 'Edit publisheds course directly in the DB'

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new

  provider = Provider.find_by!(provider_code: args[0])

  all_courses_mode = args.size == 1
  courses = if all_courses_mode
              provider.courses
            else
              provider.courses.where(course_code: args.to_a)
            end

  multi_course_mode = courses.size > 1

  flow = :root
  finished = false
  until finished do
    case flow
    when :root
      cli.choose do |menu|
        courses[0..1].each { |c| puts Terminal::Table.new rows: MCB::CourseShow.new(c).to_h }
        puts "Only showing first 2 courses of #{courses.size}." if courses.size > 2

        if multi_course_mode
          menu.prompt = "Editing multiple courses"
        else
          menu.prompt = "Editing course"
        end
        menu.choice(:exit) { finished = true }
        menu.choice(:toggle_sites) { flow = :toggle_sites } unless multi_course_mode
        %i[route qualifications study_mode accredited_body english maths science start_date title].each do |attr|
          menu.choice("Edit #{attr}") { flow = attr }
        end
        menu.choice('Publish training locations (not enrichment)') { flow = :publish_sites }
        menu.choice('Sync courses to Find') { flow = :sync_to_find }
      end
    when :toggle_sites
      course = courses.first
      cli.choose do |menu|
        menu.prompt = "Toggling course sites for #{course.course_code}"
        menu.choice(:done) { flow = :root }
        provider.sites.order(:location_name).each do |site|
          if site.in?(course.sites_not_associated_with_course)
            menu.choice(site.description) { course.add_site!(site: site) }
          else
            site_status = course.site_statuses.detect { |ss| ss.site == site }
            menu.choice(site_status.description) do
              if site_status.status_running? || site_status.status_new_status?
                course.remove_site!(site: site)
              else
                course.add_site!(site: site)
              end
            end
          end
        end
      end
    when :route
      cli.choose do |menu|
        menu.prompt = "Editing course route"
        menu.choices(*Course.program_types.keys) { |value| courses.each{ |c| c.program_type = value } }
        flow = :root
      end
    when :qualifications
      cli.choose do |menu|
        menu.prompt = "Editing course qualifications"
        menu.choices(*Course.qualifications.keys) { |value| courses.each{ |c| c.qualification = value } }
        flow = :root
      end
    when :study_mode
      cli.choose do |menu|
        menu.prompt = "Editing course study mode"
        menu.choices(*Course.study_modes.keys) { |value| courses.each{ |c| c.study_mode = value } }
        flow = :root
      end
    when :accredited_body
      accredited_body_provider_code = cli.ask("What's the provider code of the new accredited body? (can't be blank)  ")
      accredited_body = Provider.find_by!(provider_code: accredited_body_provider_code)
      courses.each { |c| c.accrediting_provider = accredited_body }
      flow = :root
    when :english
      cli.choose do |menu|
        menu.prompt = "Editing course english"
        menu.choices(*Course.englishes.keys) { |value| courses.each{ |c| c.english = value } }
        flow = :root
      end
    when :maths
      cli.choose do |menu|
        menu.prompt = "Editing course maths"
        menu.choices(*Course.maths.keys) { |value| courses.each{ |c| c.maths = value } }
        flow = :root
      end
    when :science
      cli.choose do |menu|
        menu.prompt = "Editing course science"
        menu.choices(*Course.sciences.keys) { |value| courses.each{ |c| c.science = value } }
        flow = :root
      end
    when :start_date
      start_date = Date.parse(cli.ask("What's the new start date?  "))
      if cli.agree("Start date will be set to #{start_date.strftime('%d %b %Y')}. Continue? ")
        courses.each { |c| c.start_date = start_date }
      end
      flow = :root
    when :title
      current_course_names = courses.map(&:name).uniq
      name = cli.ask("Course title? (current titles: #{current_course_names.join(', ')})  ").strip
      courses.each { |c| c.name = name }
      flow = :root
    when :sync_to_find
      command_params = ['courses', 'sync_to_find', provider.provider_code, *courses.map(&:course_code)] + (opts[:env].present? ? ['-E', opts[:env]] : [])
      $mcb.run(command_params)
      flow = :root
    when :publish_sites
      courses.each do |course|
        puts "Setting the training locations to running on #{course.provider.provider_code}/#{course.course_code}"
        course.publish_sites
      end
      flow = :root
    else
      puts "Unexpected option: #{flow}"
      flow = :root
    end
    unless finished
      courses.each(&:save!)
      provider.reload
      courses.reload
      courses.first.site_statuses.reload unless multi_course_mode
    end
  end
end
