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
    queries(&).size
  end

  # The statements themselves, for the specs that care what a query says rather
  # than how many there were - whether a subquery is bounded, say.
  def queries(&block)
    sql = []
    counter = ->(_name, _start, _finish, _id, payload) { sql << payload[:sql] unless payload[:name].to_s =~ /SCHEMA|TRANSACTION/ }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    sql
  end
end

RSpec.configure do |config|
  config.include QueryCounting
end
