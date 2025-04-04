# frozen_string_literal: true

module PublishConsole
  def start
    show_warning_message_about_environments
    set_attributes_for_inspect
    super
  end

  # https://api.rubyonrails.org/classes/ActiveRecord/Core.html#method-i-inspect
  def set_attributes_for_inspect
    ActiveRecord::Base.attributes_for_inspect = :all unless Rails.env.production?
  end

  def show_warning_message_about_environments
    if Rails.env.production?
      Rails.logger.debug ("*" * 50).red
      Rails.logger.debug "** You are in the Rails console for PRODUCTION! **".red
      Rails.logger.debug ("*" * 50).red
    else
      Rails.logger.debug ("-" * 65).blue
      Rails.logger.debug "-- This is the Rails console for the #{Rails.env} environment. --".blue
      Rails.logger.debug ("-" * 65).blue
    end
  end
end

Rails::Console.prepend(PublishConsole) if defined?(Rails::Console)
