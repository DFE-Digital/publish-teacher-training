# frozen_string_literal: true

class InitializeProviderChangedAt < ActiveRecord::Migration[5.2]
  def change
    # Initialize all the changed_at data to make it unique, the ucas api relies on unique values for paging.
    # This assumes that the updated_at values are unique which they were last time we checked.
    Provider.update_all('changed_at=updated_at')
  end
end
