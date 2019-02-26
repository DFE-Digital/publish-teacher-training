module ChangedAt
  extend ActiveSupport::Concern

  class_methods do
  private

    # Hook into Rails' built-in mechanism to update `updated_at` by adding to
    # it's list of columns that get updated when an object changes (by default
    # this is 'updated_at' and 'updated_on'). This is simpler than using a
    # before/after save hook and should allow our 'changed_at' to behave in
    # exactly the same way as 'updated_at'.
    def timestamp_attributes_for_update
      super + %w[changed_at]
    end
  end
end
