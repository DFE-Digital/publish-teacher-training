# frozen_string_literal: true

# Both providers and courses have a UNIQUE index on `changed_at`. In tests,
# Timecop can cause multiple records to receive the same `Time.zone.now` value
# when `update_changed_at` is called in rapid succession (e.g. via TouchProvider
# callbacks). This prepend adds retry-with-savepoint logic to avoid the collision.
module ChangedAtCollisionFix
  def update_changed_at(time: Time.zone.now)
    retries = 0
    begin
      # requires_new: true creates a SAVEPOINT so a constraint violation
      # doesn't poison the outer transaction.
      self.class.transaction(requires_new: true) do
        super(time: time + Rational(retries, 1_000_000))
      end
    rescue ActiveRecord::RecordNotUnique
      retries += 1
      retry if retries < 100
      raise
    end
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    Provider.prepend(ChangedAtCollisionFix)
    Course.prepend(ChangedAtCollisionFix)
  end
end
