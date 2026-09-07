# frozen_string_literal: true

# Counts the SQL a block issues, for the specs that hold a page or a query to a
# constant number of them. Bullet is enabled in test but does not raise
# (config/environments/test.rb), so a query count is what actually fails a build
# when a preload stops matching what the code reads.
#
# SCHEMA and TRANSACTION statements are left out: they are column lookups and
# savepoints the harness itself issues, and they do not move with the row count
# under test.
module QueryCounting
  def count_queries(&)
    count = 0
    counter = ->(_name, _start, _finish, _id, payload) { count += 1 unless payload[:name].to_s =~ /SCHEMA|TRANSACTION/ }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCounting
end
