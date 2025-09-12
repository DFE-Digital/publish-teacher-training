# Include this in RSpec and we can call
# context "when it is find opens in 2025", travel: find_opens(2025) do
#
# extending self makes the methods available outside the example and hooks
module CycleTimetableHelpers
  def self.included(base)
    base.extend self
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
