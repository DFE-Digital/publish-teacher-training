require "logger"
require "open3"

module MCB
  LOGGER = Logger.new(STDERR)
  LOGGER.level = Logger::WARN

  LOGGER.formatter = proc do |severity, _datetime, _progname, msg|
    if severity == Logger::INFO
      msg + "\n"
    else
      "#{severity}: #{msg}\n"
    end
  end

  # Run a rails command in the correct env environment.
  #
  # Not all mcb commands require the rails env, e.g. the API ones don't. Use
  # this method in those commands that do.
  def self.rails_runner(commands, **opts)
    load_env_azure_settings(opts)

    unless defined?(Rails)
      if requesting_remote_connection?(opts)
        webapp_rails_env = MCB::Azure.configure_for_webapp(opts)

        ENV["RAILS_ENV"] = webapp_rails_env
      end

      app_root = File.expand_path(File.join(File.dirname($0), ".."))
      exec_path = File.join(app_root, "bin", "rails")

      # prevent caching of environment variables by spring
      ENV["DISABLE_SPRING"] = "true"
      ENV["MCB_AUDIT_USER"] = get_user_email(opts)

      verbose("Running #{exec_path}")

      exec(exec_path, *commands)
    end
  end

  def self.init_rails(**opts)
    # --webapp only needs to be processed on the first time through
    new_argv = remove_option_with_arg(ARGV, "--webapp", "-A")

    rails_runner(["runner", $0, *new_argv], **opts)
  end

  def self.rails_console(**opts)
    rails_runner(%w[console], **opts)
  end

  # Load commands from dir adding them to cmd
  #
  # Recursively load all the commands in a dir creating a structure of commands
  # and sub-commands. Each sub-directory must have a file in it's parent dir
  # with the same name which defines the parent command to the sub-commands in
  # that sub-directory.
  def self.load_commands(cmd, dir)
    directories = Pathname.new(dir).each_child.select(&:directory?)
    files = Pathname.new(dir).each_child.select(&:file?)

    commands = {}

    files.each do |path|
      new_cmd = Cri::Command.load_file(path.to_s, infer_name: true)
      commands[path.basename(".rb").to_s] = new_cmd
      cmd.add_command(new_cmd)
    end

    directories.each do |path|
      sub_command = commands[path.basename.to_s]
      if sub_command.nil?
        raise "Command #{path}.rb must be defined to have sub-commands #{path}"
      end

      load_commands(sub_command, path.to_s)
    end

    cmd
  end

  def self.run_command(cmd)
    verbose("Running: #{cmd}")
    `#{cmd}`
  end

  def self.exec_command(cmd, *command_args)
    verbose("Running: #{cmd} #{command_args}")
    exec(cmd, *command_args)
  end

  def self.apiv1_token(webapp: nil, rgroup: nil)
    if webapp
      verbose "getting config for webapp: #{webapp} rgroup: #{rgroup}"
      MCB::Azure.get_config(webapp: webapp, rgroup: rgroup).fetch("AUTHENTICATION_TOKEN")
    else
      Rails.application.config.authentication_token
    end
  end

  def self.generate_apiv2_token(email:, encoding:, secret: nil)
    require "jwt"

    payload = { email: email }

    if secret.nil?
      raise "Secret not provided"
    end

    JWT.encode(payload, secret, encoding)
  end

  def self.each_v1_course(opts)
    endpoint = "/api/v1/#{get_recruitment_year(opts)}/courses"

    # This method can actually be entirely driven by the args provided, it is auto-configure!
    iterate_v1_endpoint(endpoint: endpoint, **opts)
  end

  def self.each_v1_provider(opts)
    endpoint = "/api/v1/#{get_recruitment_year(opts)}/providers"

    # This method can actually be entirely driven by the args provided, it is auto-configure!
    iterate_v1_endpoint(endpoint: endpoint, **opts)
  end

  def self.get_recruitment_year(opts)
    raise RuntimeError, "Rails has not been initialised" if !defined? Rails

    opts[:'recruitment-year'] || RecruitmentCycle.current_recruitment_cycle.year
  end

  def self.get_recruitment_cycle(opts)
    raise RuntimeError, "Rails has not been initialised" if !defined? Rails

    if opts.key? :'recruitment-year'
      RecruitmentCycle.find_by(year: opts[:'recruitment-year'])
    else
      RecruitmentCycle.current_recruitment_cycle
    end
  end

  def self.config_dir=(dir)
    @config_dir = dir
  end

  def self.config_dir
    @config_dir ||= File.expand_path "~/.config/mcb-dfe/"
  end

  def self.config_file=(file)
    @config_file = file
  end

  def self.config_file
    @config_file ||= File.join config_dir, "config.yml"
  end

  def self.config
    @config ||= MCB::Config.new(config_file: config_file)
  end

  class << self
    def get_user_email(opts = {})
      email = opts.fetch(:email, config[:email])

      unless email
        error "No email set in config. You can set it like this:"
        error ""
        error "  $ #{$0} config set email <your-email-address>"
        error ""
        raise RuntimeError, "email not configured"
      end

      email
    end

    def apiv1_opts(opts)
      # the following lines are necessary to make opts work with double **splats and default values
      # See the change introduced in https://github.com/ddfreyne/cri/pull/99 (cri 2.15.8)
      opts = expose_opts_defaults_for_splat(opts, :url, :'max-pages', :token, :all)

      opts.merge! azure_env_settings_for_opts(**opts)

      if requesting_remote_connection?(**opts)
        opts[:url] = MCB::Azure.get_urls(**opts).first
        opts[:token] = MCB::Azure.get_config(**opts)["AUTHENTICATION_TOKEN"]
      end

      opts
    end

    # Return options necessary to connect to API V2.
    #
    # The opts passed in are examined determine which opts need to be added,
    # this function essentially just fills in any missing options.
    #
    #   opts = apiv2_opts(opts)
    def apiv2_opts(opts)
      opts = expose_opts_defaults_for_splat(opts, :url, :'max-pages', :token, :all)
      opts.merge! azure_env_settings_for_opts(**opts)

      if requesting_remote_connection?(**opts)
        opts[:url] ||= MCB::Azure.get_urls(**opts).first
        opts[:token] ||= MCB::Azure.get_config(**opts)["AUTHENTICATION_TOKEN"]
      end

      opts
    end

    # Return the base url to the API V2 for the given opts.
    #
    # <tt>opts</tt> should be filled-in using <tt>apiv2_opts</tt>
    def apiv2_base_url(opts)
      url = MCB::Azure.get_urls(**opts)
        .grep(/^https.*gov\.uk$/)
        .first
      "#{url}/api/v2"
    end

    def display_pages_received(page:, max_pages:, next_url:)
      # (current) page starts at 0
      pages = page + 1

      if pages == max_pages
        puts "Max of #{pages} page(s) hit, use --max-pages to increase."

        next_changed_since = extract_changed_at(next_url)

        puts(
          "To continue retrieving results use the changed-since: " +
          CGI.unescape(next_changed_since),
        )
      else
        puts "All #{pages} pages from API retrieved."
      end
    end

    def extract_changed_at(url)
      url.sub(
        /.*changed_since=(.*)(?:&.*)|$/,
        '\1',
      )
    end

    def iterate_v1_endpoint(url:, endpoint:, **opts)
      # We only need httparty for API V1 calls
      require "httparty"

      endpoint_url = add_url_params_from_opts(opts, URI.join(url, endpoint))
      token = opts.fetch(:token) { apiv1_token(opts.slice(:webapp, :rgroup)) }

      # Safeguard to ensure we don't go off the deep end.
      max_pages = opts.fetch(:'max-pages')

      Enumerator.new do |y|
        max_pages.times do |page_count|
          verbose "Requesting page #{page_count + 1}: #{endpoint_url}"
          response = HTTParty.get(
            endpoint_url.to_s,
            headers: { authorization: "Bearer #{token}" },
          )
          records = JSON.parse(response.body)
          if records.any?

            next_url = response.headers[:link].sub(/;.*/, "")

            # Send each provider to the consumer of this enumerator
            records.each do |record|
              y << [record, {
                      page: page_count,
                      url: endpoint_url,
                      next_url: next_url,
                    }]
            end

            endpoint_url = next_url
          else
            break
          end
        end
      end
    end

    def remote_connect_options
      envs = env_to_azure_map.keys.join(", ")
      Proc.new do
        option :r, "recruitment-year",
               "Set the recruitment year, defaults to the current recruitment year",
               argument: :required
        option :E, "env",
               "Connect to a pre-defined environment: #{envs}",
               argument: :required
        option :A, "webapp",
               "Connect to the database of this webapp",
               argument: :required
        option :G, "rgroup",
               "Use resource group for app (optional)",
               argument: :required
        option :S, "subscription",
               "Specify which Azure subscription to use",
               argument: :required
        option nil, "email",
               "Specify which email to connect to remote env as",
               argument: :required
      end
    end

    def requesting_remote_connection?(**opts)
      opts.key?(:webapp)
    end

    def env_to_azure_map
      {
        "qa" => {
          webapp: "s121d01-mcbe-as",
          rgroup: "s121d01-mcbe-rg",
          subscription: "s121-findpostgraduateteachertraining-development",
        },
        "staging" => {
          webapp: "s121t01-mcbe-as",
          rgroup: "s121t01-mcbe-rg",
          subscription: "s121-findpostgraduateteachertraining-test",
        },
        "production" => {
          webapp: "s121p01-mcbe-as",
          rgroup: "s121p01-mcbe-rg",
          subscription: "s121-findpostgraduateteachertraining-production",
        },
      }
    end

    def load_env_azure_settings(opts)
      if opts.key?(:env)
        env_settings = env_to_azure_map.fetch(opts[:env])
        opts[:webapp] = env_settings[:webapp] unless opts.key? :webapp
        opts[:rgroup] = env_settings[:rgroup] unless opts.key? :rgroup
        opts[:subscription] = env_settings[:subscription] unless opts.key? :subscription
      end
    end

    # Temporary re-implementation of 'load_env_azure_settings'. Altering a hash
    # that was passed in as an arg is asking for trouble (and really annoying
    # to test). I should've known better.
    #
    # TODO: Replace calls to load_env_azure_settings with calls to
    #       azure_env_settings_for_opts
    def azure_env_settings_for_opts(opts)
      new_opts = opts.dup
      load_env_azure_settings new_opts
      new_opts
    end

    def find_user_by_identifier(identifier)
      if identifier.include? "@"
        User.find_by(email: identifier)
      elsif identifier.match %r{^\d+$}
        User.find(identifier.to_i)
      else
        User.find_by(sign_in_user_id: identifier)
      end
    end

    def connecting_to_remote_db?
      ENV.key?("DB_HOSTNAME")
    end

    def configure_local_database_env
      # values to match database.yml
      ENV["DB_HOSTNAME"] = "localhost"
      ENV["DB_USERNAME"] = "manage_courses_backend"
      ENV["DB_PASSWORD"] = "manage_courses_backend"
      ENV["DB_DATABASE"] = "manage_courses_backend_development"
    end

    def pageable_output(output)
      ::Open3.pipeline_w("less -FX") do |io|
        io.puts output
      rescue Errno::EPIPE
        nil
      end
    end

    def load_history
      File.open(File.expand_path("~/.mcb_history"), "r").each do |line|
        Readline::HISTORY.push(line.chomp)
      end
    rescue Errno::ENOENT
      nil
    end

    def append_to_history(input)
      if !input.blank? && Readline::HISTORY.to_a.last != input.chomp
        Readline::HISTORY.push(input.chomp)
        File.open(File.expand_path("~/.mcb_history"), "a+") do |f|
          f.puts(input.chomp)
        end
      end
    end

    def enable_completion
      command_names = $mcb.commands.map(&:name)
      Readline.completion_proc = proc do |s|
        command_names.grep(/^#{Regexp.escape(s)}/)
      end
    end

    def start_mcb_repl(start_argv)
      $mcb_repl_mode = true
      load_history
      enable_completion
      trap("INT", "SIG_IGN")

      env = start_argv[1]
      opts = {}
      opts[:env] = env if env
      MCB.init_rails(opts)

      prompt = case env
               when "production" then Rainbow(env).red.inverse
               when "staging"    then Rainbow(env).yellow
               when "qa"         then Rainbow(env).yellow
               when nil          then Rainbow("local").green
               else                   env
               end

      while (input = Readline.readline("#{prompt}> ", false))
        append_to_history(input)
        argv = input.split

        case argv.first
        when "exit", "q", "quit"
          break
        when "h", "help"
          $mcb.commands.each do |c|
            show_all_commands(c, "#{c.name} ")
            puts
          end
        when ""
          next
        else
          begin
            $mcb.run(argv, hard_exit: false)
          rescue => e # rubocop: disable Style/RescueStandardError
            puts e.to_s
          end
        end
      end
    end

    def launch_repl?(argv)
      argv.empty? || (argv.first == "-E" && argv.length == 2)
    end

  private

    def remove_option_with_arg(argv, *options)
      argv.dup.tap do |new_argv|
        options.each do |option|
          if (index = new_argv.find_index { |o| o == option })
            new_argv.delete_at index
            # delete the argument as well as the option
            new_argv.delete_at index
          else
            new_argv.delete_if { |o| o.match %r{#{option}=} }
          end
        end
      end
    end

    def add_url_params_from_opts(opts, url)
      new_url = url.dup
      if opts.key? :'changed-since'
        changed_since = DateTime.strptime(
          CGI.unescape(opts[:'changed-since']),
          "%FT%T.%NZ",
        ) rescue nil
        changed_since ||= DateTime.parse(opts[:'changed-since'])
        changed_since_param = CGI.escape(changed_since.strftime("%FT%T.%6NZ"))
        new_url.query = "changed_since=#{changed_since_param}"
      end

      new_url
    end

    # The following utility method is necessary because without processing the
    # opts like this, default values won't be retrieved when using the splat
    # operator. See the change introduced in
    # https://github.com/ddfreyne/cri/pull/99 (cri 2.15.8)
    def expose_opts_defaults_for_splat(opts, *keys)
      keys.each do |key|
        opts[key] = opts[key]
      end
      opts
    end
  end
end
