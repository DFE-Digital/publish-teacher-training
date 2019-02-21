module TouchProvider
  extend ActiveSupport::Concern

private

  def touch_provider
    provider.update_changed_at
  end
end
