# frozen_string_literal: true

# Include this in RSpec and we can call
# context "when it is find opens in 2025", travel: find_opens(2025) do
#
# extending self makes the methods available outside the example and hooks
module CycleTimetableHelpers
  def self.included(base)
    base.extend self
  end

  # The instant an example runs at when it sets no `travel:` of its own.
  #
  # Without it an unpinned example inherits whatever cycle period the machine
  # happens to be in, so it asserts a different thing depending on the date.
  # mid_cycle is the ordinary state: Find open, Apply open, no banners, deadline
  # not passed, and the 30-day rollover grace window after Find opens is over.
  # Anchored on apply_opens, so it cannot drift into the pre-Apply week however
  # long that week becomes.
  #
  # This pins the period but NOT the cycle year. `mid_cycle` resolves through
  # `current_year`, which reads the real clock, so on the day a cycle rolls over
  # the default jumps forward a year and every unpinned example moves with it.
  # A spec that depends on a particular year must say so with `travel:`.
  #
  # TEST_CYCLE_YEAR moves the default to mid cycle of that year instead, so the
  # suite can be run as it will behave after the next rollover.
  #
  # Memoised, so every example in this process shares one instant. Parallel
  # workers are separate processes and each compute their own, which can only
  # disagree if a run straddles the midnight a cycle rolls over.
  def self.default_travel
    return @default_travel if defined?(@default_travel)

    @default_travel = if target_year
                        Find::CycleTimetable.mid_cycle(target_year)
                      else
                        Find::CycleTimetable.mid_cycle
                      end
  end

  # The cycle year from TEST_CYCLE_YEAR, or nil when it is not set.
  def self.target_year
    return @target_year if defined?(@target_year)

    @target_year = resolve_target_year(ENV["TEST_CYCLE_YEAR"])
  end

  # Takes a year, or "next" for the year after the current cycle.
  def self.resolve_target_year(value)
    return if value.blank?

    year = if value == "next"
             Find::CycleTimetable.next_year
           elsif value.match?(/\A\d{4}\z/)
             value.to_i
           else
             raise ArgumentError, %(TEST_CYCLE_YEAR=#{value} is not a year or "next")
           end

    unless Find::CycleTimetable::CYCLE_DATES.key?(year)
      raise ArgumentError, "TEST_CYCLE_YEAR=#{value}: #{year} is not a year in Find::CycleTimetable::CYCLE_DATES"
    end

    year
  end

  # With TEST_CYCLE_YEAR set, move the clock to the default instant. It is
  # called before the spec files load, so that `travel:` metadata with no year,
  # such as `travel: 1.day.after(find_opens)`, resolves in the target year. It
  # is called again after each example, so that code outside an example, such
  # as `before(:all)`, does not fall back to the real year.
  def self.travel_to_target_year
    Timecop.travel(default_travel) if target_year
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
