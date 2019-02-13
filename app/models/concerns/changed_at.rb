module ChangedAt
  extend ActiveSupport::Concern

  class_methods do
  private

    def timestamp_attributes_for_update
      super + %w[changed_at]
    end
  end
end
