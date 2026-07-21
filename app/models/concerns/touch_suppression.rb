# frozen_string_literal: true

# Bulk copies such as rollover create thousands of child records, each of which
# fires an `after_save` touch on its parent provider or course. Suppress those
# for the duration of the copy and update each parent once at the end instead.
#
# The flag is fiber-local, so suppressing it in one Sidekiq thread leaves
# concurrent work in other threads untouched.
module TouchSuppression
  KEY = :touch_suppressed

  def self.suppress
    previously_suppressed = suppressed?
    ActiveSupport::IsolatedExecutionState[KEY] = true
    yield
  ensure
    ActiveSupport::IsolatedExecutionState[KEY] = previously_suppressed
  end

  def self.suppressed?
    ActiveSupport::IsolatedExecutionState[KEY] || false
  end
end
