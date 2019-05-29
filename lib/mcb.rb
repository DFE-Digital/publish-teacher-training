require 'logger'

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

  # Load the rails environment.
  #
  # Not all mcb commands require the rails env, e.g. the API ones don't. Use
  # this method in those commands that do.
  def self.init_rails(**opts)
    load_env_azure_settings(opts)

    if defined?(Rails)
      configure_audited_user if connecting_to_remote_db?
    else
      if requesting_remote_connection?(opts)
        webapp_rails_env = MCB::Azure.configure_for_webapp(opts)

        ENV['RAILS_ENV'] = webapp_rails_env
      end

      app_root = File.expand_path(File.join(File.dirname($0), '..'))
      exec_path = File.join(app_root, 'bin', 'rails')

      # prevent caching of environment variables by spring
      ENV['DISABLE_SPRING'] = "true"

      verbose("Running #{exec_path}")

      # --webapp only needs to be processed on the first time through
      new_argv = remove_option_with_arg(ARGV, '--webapp', '-A')
      exec(exec_path, 'runner', $0, *new_argv)
    end
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
    # This methods can actually be entirely driven by the args provided it. auto-configure!
    iterate_v1_endpoint(**opts)
  end

  def self.each_v1_provider(opts)
    # This methods can actually be entirely driven by the args provided it. auto-configure!
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
    attr_reader :current_user

    def get_user_from_config
      unless config.key? :email
        error 'No email set in config. You can set it like this:'
        error ''
        error "  $ #{$0} config set email <your-email-address>"
        error ''
        raise RuntimeError, 'email not configured'
      end

      user = User.find_by(email: MCB.config[:email])
      unless user
        error "User with email #{MCB.config[:email]} not found."
        error "For auditing purposes a user with the configured email address must exist"
        error "on the system being altered."
        raise RuntimeError, "email not found: #{MCB.config[:email]}"
      end
      user
    end

    def iterate_v1_endpoint(url:, endpoint:, **opts)
      # We only need httparty for API V1 calls
      require 'httparty'

      endpoint_url = URI.join(url, endpoint)

      token = opts.fetch(:token) { apiv1_token(opts.slice(:webapp, :rgroup)) }

      process_opt_changed_since(opts, endpoint_url)
      page_count = 0
      max_pages = opts.fetch(:'max-pages', '30').to_i
      all_pages = opts.fetch(:all, false)

      Enumerator.new do |y|
        loop do
          if page_count > max_pages
            raise "too many page requests, stopping at #{page_count}" \
                  " as a safeguard. Use --max-pages to increase max page count" \
                  " if necessary."
          end

          verbose "Requesting page #{page_count + 1}: #{url}"
          response = HTTParty.get(
            endpoint_url.to_s,
            headers: { authorization: "Bearer #{token}" }
          )
          records = JSON.parse(response.body)
          break if records.empty?

          next_url = response.headers[:link].sub(/;.*/, '')

          # Send each provider to the consumer of this enumerator
          records.each do |record|
            y << [record, {
                    page: page_count,
                    url: endpoint_url,
                    next_url: next_url
                  }]
          end

          break unless all_pages

          endpoint_url = next_url
          page_count += 1
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
      end
    end

    def requesting_remote_connection?(opts)
      opts.key?(:webapp)
    end

    def env_to_azure_map
      {
        'qa' => {
          webapp: 'bat-dev-manage-courses-backend-app',
          rgroup: 'bat-dev-linux-rgroup',
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

    def find_user_by_identifier(identifier)
      if identifier.include? '@'
        User.find_by(email: identifier)
      elsif identifier.match %r{^\d+$}
        User.find(identifier.to_i)
      else
        User.find_by(sign_in_user_id: identifier)
      end
    end

  private

    def configure_audited_user
      @current_user = get_user_from_config
      verbose "configuring user to be #{@current_user.email}"
      Audited.store[:audited_user] = @current_user
    end

    def connecting_to_remote_db?
      ENV.key?('DB_HOSTNAME')
    end

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
      if opts.key? :'changed-since'
        changed_since = DateTime.strptime(
          CGI.unescape(opts[:'changed-since']),
          '%FT%T.%NZ'
        ) rescue nil
        changed_since ||= DateTime.parse(opts[:'changed-since'])
        changed_since_param = CGI.escape(changed_since.strftime('%FT%T.%6NZ'))
        url.query = "changed_since=#{changed_since_param}"
      end
    end
  end
end
