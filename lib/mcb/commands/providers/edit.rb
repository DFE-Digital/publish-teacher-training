name 'show'
summary 'Edit information about provider'
param :code

run do |opts, args, _cmd|
  MCB.init_rails(opts)

  cli = HighLine.new

  provider = Provider.find_by!(provider_code: args[:code])
  courses = provider.courses

  finished = false
  until finished do
    cli.choose do |menu|
      menu.prompt = "Choose a course"
      menu.choice(:exit) { finished = true }
      menu.choices(*courses.map(&:course_code)) do |course_code|
        command_params = ['courses', 'edit_published', args[:code], course_code] + (opts[:env].present? ? ['-E', opts[:env]] : [])
        $mcb.run(command_params)
      end
    end
  end
end
