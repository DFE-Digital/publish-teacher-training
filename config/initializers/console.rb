# frozen_string_literal: true

module PublishConsole
  def start
    show_warning_message_about_environments
    super
  end

  def show_warning_message_about_environments
    if Rails.env.production_aks?
      puts ('*' * 50).red
      puts '** You are in the Rails console for PRODUCTION! **'.red
      puts ('*' * 50).red
    else
      puts ('-' * 65).blue
      puts "-- This is the Rails console for the #{Rails.env} environment. --".blue
      puts ('-' * 65).blue
    end
  end
end

Rails::Console.prepend(PublishConsole) if defined?(Rails::Console)
