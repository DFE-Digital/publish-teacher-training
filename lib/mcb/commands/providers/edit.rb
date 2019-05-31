name 'show'
summary 'Edit information about provider'
param :code, transform: ->(code) { code.upcase }

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new

  provider = Provider.find_by!(provider_code: args[:code])

  finished = false
  chosen_course_codes = []
  until finished do
    cli.choose do |menu|
      courses = provider.courses
      if chosen_course_codes.empty?
        menu.prompt = "Choose one or multiple courses to edit."
      else
        menu.prompt = "Chosen courses: #{chosen_course_codes.join(", ")}"
      end

      unchosen_course_codes = (courses.map(&:course_code) - chosen_course_codes)

      menu.choice(:exit) { finished = true }

      all_courses_or_just_selected = chosen_course_codes.empty? ? :all_courses : :edit_selected_courses
      menu.choice(all_courses_or_just_selected) do
        command_params = ['courses', 'edit_published', args[:code], *chosen_course_codes] + (opts[:env].present? ? ['-E', opts[:env]] : [])
        $mcb.run(command_params)
        chosen_course_codes = []
      end

      unless unchosen_course_codes.empty?
        menu.choices(*unchosen_course_codes) do |course_code|
          chosen_course_codes.push(course_code)
        end
      end

      menu.choice("Create new course") do
        command_params = ['courses', 'create', args[:code]] + (opts[:env].present? ? ['-E', opts[:env]] : [])
        $mcb.run(command_params)
        chosen_course_codes = []
      end

      menu.choice("Clone a course") do
        provider_code = cli.ask("Provider code of course you want to clone? (#{provider.provider_code} if blank)  ") { |q| q.default = provider.provider_code }
        course_code = cli.ask("Code of course you want to clone?  ")
        original_course = Provider
                            .find_by!(provider_code: provider_code.upcase)
                            .courses.find_by!(course_code: course_code.upcase)

        new_course = original_course.dup
        new_course.provider = provider
        new_course.course_code = cli.ask("New course code?  ")
        new_course.subjects = original_course.subjects
        new_course.save!
      end

      menu.choice("Edit provider name") do
        puts "Current name: #{provider.provider_name}"
        new_name = cli.ask("Enter new name").strip
        provider.provider_name = new_name
        provider.save!
      end
    end
    provider.reload
  end
end
