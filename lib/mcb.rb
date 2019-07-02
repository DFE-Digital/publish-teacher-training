require 'logger'
require 'open3'

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

        ENV['RAILS_ENV'] = webapp_rails_env
      end

      app_root = File.expand_path(File.join(File.dirname($0), '..'))
      exec_path = File.join(app_root, 'bin', 'rails')

      # prevent caching of environment variables by spring
      ENV['DISABLE_SPRING'] = "true"
      ENV['MCB_AUDIT_USER'] = get_user_email(opts)

      verbose("Running #{exec_path}")

      exec(exec_path, *commands)
    end
  end

  def self.init_rails(**opts)
    # --webapp only needs to be processed on the first time through
    new_argv = remove_option_with_arg(ARGV, '--webapp', '-A')

    rails_runner(['runner', $0, *new_argv], **opts)
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
      commands[path.basename('.rb').to_s] = new_cmd
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

  def self.exec_command(cmd)
    verbose("Running: #{cmd}")
    exec(cmd)
  end

  def self.apiv1_token(webapp: nil, rgroup: nil)
    if webapp
      verbose "getting config for webapp: #{webapp} rgroup: #{rgroup}"
      MCB::Azure.get_config(webapp: webapp, rgroup: rgroup).fetch('AUTHENTICATION_TOKEN')
    else
      Rails.application.config.authentication_token
    end
  end

  def self.generate_apiv2_token(email:, encoding:, secret: nil)
    require 'jwt'

    payload = { email: email }

    if secret.nil?
      raise 'Secret not provided'
    end

    JWT.encode(payload, secret, encoding)
  end

  def self.each_v1_course(opts)
    # This method can actually be entirely driven by the args provided, it is auto-configure!
    iterate_v1_endpoint(**opts)
  end

  def self.each_v1_provider(opts)
    # This method can actually be entirely driven by the args provided, it is auto-configure!
    iterate_v1_endpoint(**opts)
  end

  def self.config_dir=(dir)
    @config_dir = dir
  end

  def self.config_dir
    @config_dir ||= File.expand_path '~/.config/mcb-dfe/'
  end

  def self.config_file=(file)
    @config_file = file
  end

  def self.config_file
    @config_file ||= File.join config_dir, 'config.yml'
  end

  def self.config
    @config ||= MCB::Config.new(config_file: config_file)
  end

  class << self
    def get_user_email(opts = {})
      email = opts.fetch(:email, config[:email])

      unless email
        error 'No email set in config. You can set it like this:'
        error ''
        error "  $ #{$0} config set email <your-email-address>"
        error ''
        raise RuntimeError, 'email not configured'
      end

      email
    end

    def apiv1_opts(opts)
      # the following lines are necessary to make opts work with double **splats and default values
      # See the change introduced in https://github.com/ddfreyne/cri/pull/99 (cri 2.15.8)
      opts[:url] = opts[:url]
      opts[:endpoint] = opts[:endpoint]
      opts[:'max-pages'] = opts[:'max-pages']
      opts[:token] = opts[:token]
      opts[:all] = opts[:all]

      opts.merge! azure_env_settings_for_opts(**opts)

      if requesting_remote_connection?(**opts)
        opts[:url] = MCB::Azure.get_urls(**opts).first
        opts[:token] = MCB::Azure.get_config(**opts)['AUTHENTICATION_TOKEN']
      end

      opts
    end

    def display_pages_received(page:, max_pages:, next_url:)
      # (current) page starts at 0
      pages = page + 1

      if pages == max_pages
        puts "Max of #{pages} page(s) hit, use --max-pages to increase."

        next_changed_since = extract_changed_at(next_url)

        puts(
          'To continue retrieving results use the changed-since: ' +
          CGI.unescape(next_changed_since)
        )
      else
        puts "All #{pages} pages from API retrieved."
      end
    end

    def extract_changed_at(url)
      url.sub(
        /.*changed_since=(.*)(?:&.*)|$/,
        '\1'
      )
    end

    def iterate_v1_endpoint(url:, endpoint:, **opts)
      # We only need httparty for API V1 calls
      require 'httparty'

      endpoint_url = process_opt_changed_since(opts, URI.join(url, endpoint))
      token = opts.fetch(:token) { apiv1_token(opts.slice(:webapp, :rgroup)) }

      # Safeguard to ensure we don't go off the deep end.
      max_pages = opts.fetch(:'max-pages')

      Enumerator.new do |y|
        max_pages.times do |page_count|
          verbose "Requesting page #{page_count + 1}: #{endpoint_url}"
          response = HTTParty.get(
            endpoint_url.to_s,
            headers: { authorization: "Bearer #{token}" }
          )
          verbose "Response headers:"
          verbose response.headers
          verbose "Response body:"
          verbose response.body
          records = JSON.parse(response.body)
          if records.any?

            next_url = response.headers[:link].sub(/;.*/, '')

            # Send each provider to the consumer of this enumerator
            records.each do |record|
              y << [record, {
                      page: page_count,
                      url: endpoint_url,
                      next_url: next_url
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
      envs = env_to_azure_map.keys.join(', ')
      Proc.new do
        option :E, 'env',
               "Connect to a pre-defined environment: #{envs}",
               argument: :required
        option :A, 'webapp',
               'Connect to the database of this webapp',
               argument: :required
        option :G, 'rgroup',
               'Use resource group for app (optional)',
               argument: :required
        option :S, 'subscription',
               'Specify which Azure subscription to use',
               argument: :required
        option nil, 'email',
               'Specify which email to connect to remote env as',
               argument: :required
      end
    end

    def requesting_remote_connection?(**opts)
      opts.key?(:webapp)
    end

    def env_to_azure_map
      {
        'qa' => {
          webapp: 'bat-qa-mcbe-as',
          rgroup: 'bat-qa-mcbe-rg',
          subscription: 'DFE BAT Development'
        },
        'staging' => {
          webapp: 'bat-staging-manage-courses-backend-app',
          rgroup: 'bat-staging-linux-rgroup',
          subscription: 'DFE BAT Development'
        },
        'production' => {
          webapp: 'bat-prod-manage-courses-backend-app',
          rgroup: 'bat-prod-linux-rgroup',
          subscription: 'DFE BAT Production'
        }
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
      if identifier.include? '@'
        User.find_by(email: identifier)
      elsif identifier.match %r{^\d+$}
        User.find(identifier.to_i)
      else
        User.find_by(sign_in_user_id: identifier)
      end
    end

    def connecting_to_remote_db?
      ENV.key?('DB_HOSTNAME')
    end

    def configure_local_database_env
      # values to match database.yml
      ENV["DB_HOSTNAME"] = "localhost"
      ENV["DB_USERNAME"] = "manage_courses_backend"
      ENV["DB_PASSWORD"] = "manage_courses_backend"
      ENV["DB_DATABASE"] = "manage_courses_backend_development"
    end

    def pageable_output(output)
      ::Open3.pipeline_w('less -FX') do |io|
        io.puts output
      rescue Errno::EPIPE
        nil
      end
    end

    def start_mcb_repl(start_argv)
      $mcb_repl_mode = true

      trap("INT", "SIG_IGN")

      env = start_argv[1]
      opts = {}
      opts[:env] = env if env
      MCB.init_rails(opts)

      prompt = case env
               when 'production' then Rainbow(env).red.inverse
               when 'staging'    then Rainbow(env).yellow
               when 'qa'         then Rainbow(env).yellow
               when nil          then Rainbow(env).green
               else                   env
               end
      while (input = Readline.readline("#{prompt}> ", true))
        argv = input.split

        case argv.first
        when 'exit', 'q', 'quit'
          break
        when 'h', 'help'
          $mcb.commands.each do |c|
            show_all_commands(c, "#{c.name} ")
            puts
          end
        when ''
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

    def process_opt_changed_since(opts, url)
      new_url = url.dup
      if opts.key? :'changed-since'
        changed_since = DateTime.strptime(
          CGI.unescape(opts[:'changed-since']),
          '%FT%T.%NZ'
        ) rescue nil
        changed_since ||= DateTime.parse(opts[:'changed-since']) # rubocop:disable Rails/TimeZone
        changed_since_param = CGI.escape(changed_since.strftime('%FT%T.%6NZ'))
        new_url.query = "changed_since=#{changed_since_param}"
      end
      new_url
    end
  end
end
