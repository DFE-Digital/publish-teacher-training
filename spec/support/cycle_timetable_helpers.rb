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
  # Memoised, so every example in this process shares one instant. Parallel
  # workers are separate processes and each compute their own, which can only
  # disagree if a run straddles the midnight a cycle rolls over.
  def self.default_travel
    return @default_travel if defined?(@default_travel)

    @default_travel = Find::CycleTimetable.mid_cycle
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
