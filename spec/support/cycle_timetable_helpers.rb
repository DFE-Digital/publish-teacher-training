# frozen_string_literal: true

# Include this in RSpec and we can call
# context "when it is find opens in 2025", travel: find_opens(2025) do
#
# extending self makes the methods available outside the example and hooks
module CycleTimetableHelpers
  # Named instants for CYCLE_PERIOD, which forces every example that does not
  # set its own `travel:` into one cycle period. Use it to audit the suite for
  # specs that silently depend on whichever period the clock happens to be in:
  #
  #   CYCLE_PERIOD=find_closed bundle exec parallel_rspec -n 8
  #
  # Specs that set `travel:` keep their own instant, because they are testing a
  # period deliberately and moving them would corrupt the audit.
  #
  # The values are lambdas because this file loads before Rails, so
  # Find::CycleTimetable does not exist yet at load time. They are also relative
  # to the current cycle rather than hardcoded, so they stay correct as cycles
  # roll over.
  CYCLE_PERIODS = {
    # Find is down: after midnight on the day Find reopens, but before it does.
    # This is the window where Find::ApplicationController redirects every page
    # to the cycle-has-ended page.
    "find_closed" => -> { Find::CycleTimetable.find_reopens - 1.hour },
    # The ordinary middle of the cycle: Find open, Apply open, no banners.
    "mid_cycle" => -> { Find::CycleTimetable.mid_cycle },
    "find_opens" => -> { Find::CycleTimetable.find_opens + 1.hour },
    "apply_opens" => -> { Find::CycleTimetable.apply_opens + 1.hour },
    "apply_deadline_passed" => -> { Find::CycleTimetable.apply_deadline + 1.hour },
    "find_closes" => -> { Find::CycleTimetable.find_closes - 1.hour },
  }.freeze

  def self.included(base)
    base.extend self
  end

  # The instant named by CYCLE_PERIOD, or nil when it is unset. Memoised so the
  # whole run shares one instant rather than recomputing per example.
  def self.env_cycle_period
    return @env_cycle_period if defined?(@env_cycle_period)

    name = ENV["CYCLE_PERIOD"]
    @env_cycle_period = if name.blank?
                          nil
                        else
                          period = CYCLE_PERIODS[name]
                          raise ArgumentError, "Unknown CYCLE_PERIOD #{name.inspect}. Known periods: #{CYCLE_PERIODS.keys.join(', ')}" if period.nil?

                          period.call
                        end
  end

  %i[find_opens apply_opens mid_cycle apply_deadline apply_closes find_closes find_reopens].each do |name|
    define_method name do |year = nil|
      if year
        Find::CycleTimetable.send(name, year)
      else
        Find::CycleTimetable.send(name)
      end
    end
  end

  def first_deadline_banner
    Find::CycleTimetable.send(:first_deadline_banner)
  end
end
