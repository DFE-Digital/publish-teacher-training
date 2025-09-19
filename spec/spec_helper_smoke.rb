# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "json"
require "rspec"
require "config"
require "httparty"
require "active_support"
require "active_support/time"
require "active_support/core_ext/time/zones"
Time.zone = "Europe/London"
load "app/services/find/cycle_timetable.rb"

Config.load_and_set_settings(Config.setting_files("config", ENV.fetch("RAILS_ENV", nil)))
