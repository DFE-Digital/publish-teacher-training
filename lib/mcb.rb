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
    MCB::Azure.configure_for_webapp(opts) if opts.key? :webapp

    unless defined?(Rails)
      app_root = File.expand_path(File.join(File.dirname($0), '..'))
      exec_path = File.join(app_root, 'bin', 'rails')

      # prevent caching of environment variables by spring
      ENV["DISABLE_SPRING"] = "true"

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
      MCB::Azure.get_config(webapp, rgroup: rgroup).fetch('AUTHENTICATION_TOKEN')
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
    # We only need httparty for API V1 calls
    require 'httparty'

    url = URI.join(opts[:url], opts[:endpoint])

    token = opts.fetch(:token) { apiv1_token(opts.slice(:webapp, :rgroup)) }

    process_opt_changed_since(opts, url)
    page_count = 0
    max_pages = 30
    all_pages = opts.fetch(:all, false)

    Enumerator.new do |y|
      loop do
        if page_count > max_pages
          raise "too many page requests, stopping at #{page_count}" \
                " as a safeguard. Increase max page_count if necessary."
        end

        verbose "Requesting page #{page_count + 1}: #{url}"
        response = HTTParty.get(
          url.to_s,
          headers: { authorization: "Bearer #{token}" }
        )
        courses_list = JSON.parse(response.body)
        break if courses_list.empty?

        next_url = response.headers[:link].sub(/;.*/, '')

        # Send each provider to the consumer of this enumerator
        courses_list.each do |course|
          y << [course, {
                  page: page_count,
                  url: url,
                  next_url: next_url
                }]
        end

        break unless all_pages

        url = next_url
        page_count += 1
      end
    end
  end

  def self.each_v1_provider(opts)
    # We only need httparty for API V1 calls
    require 'httparty'

    url = URI.join(opts[:url], opts[:endpoint])

    token = opts.fetch(:token) { apiv1_token(opts.slice(:webapp, :rgroup)) }

    process_opt_changed_since(opts, url)
    page_count = 0
    max_pages = 30
    all_pages = opts.fetch(:all, false)

    Enumerator.new do |y|
      loop do
        if page_count > max_pages
          raise "too many page requests, stopping at #{page_count}" \
                " as a safeguard. Increase max page_count if necessary."
        end

        verbose "Requesting page #{page_count + 1}: #{url}"
        response = HTTParty.get(
          url.to_s,
          headers: { authorization: "Bearer #{token}" }
        )
        providers_list = JSON.parse(response.body)
        break if providers_list.empty?

        next_url = response.headers[:link].sub(/;.*/, '')

        # Send each provider to the consumer of this enumerator
        providers_list.each do |provider|
          y << [provider, {
                  page: page_count,
                  url: url,
                  next_url: next_url
                }]
        end

        break unless all_pages

        url = next_url
        page_count += 1
      end
    end
  end

  class << self
  private # rubocop: disable Layout/IndentationWidth

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
