# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "rspec"
require "config"
require "httparty"
require "active_support/time"

Config.load_and_set_settings(Config.setting_files("config", ENV.fetch("RAILS_ENV", nil)))
