name 'show'
summary 'Edit information about provider'
param :code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new

  provider = Provider.find_by!(provider_code: args[:code])
  courses = provider.courses

  finished = false
  chosen_course_codes = []
  until finished do
    cli.choose do |menu|
      if chosen_course_codes.empty?
        menu.prompt = "Choose one or multiple courses to edit."
      else
        menu.prompt = "Chosen courses: #{chosen_course_codes.join(", ")}"
      end

      menu.choice(:exit) { finished = true }

      unchosen_course_codes = (courses.map(&:course_code) - chosen_course_codes)
      unless unchosen_course_codes.empty?
        menu.choices(:all_courses) { chosen_course_codes = courses.map(&:course_code) }
      end

      unless chosen_course_codes.empty?
        menu.choice(:edit_selected_courses) do
          command_params = ['courses', 'edit_published', args[:code], *chosen_course_codes] + (opts[:env].present? ? ['-E', opts[:env]] : [])
          $mcb.run(command_params)
          chosen_course_codes = []
        end
      end

      unless unchosen_course_codes.empty?
        menu.choices(*unchosen_course_codes) do |course_code|
          chosen_course_codes.push(course_code)
        end
      end

    end
  end
end
