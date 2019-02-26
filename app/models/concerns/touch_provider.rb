module TouchProvider
  extend ActiveSupport::Concern

  included do
    after_save :touch_provider
  end

private

  def touch_provider
    provider.update_changed_at
  end
end
