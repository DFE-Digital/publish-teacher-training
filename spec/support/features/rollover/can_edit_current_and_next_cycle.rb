# frozen_string_literal: true

# This is required as a workaround for failing tests when the `can_edit_current_and_next_cycles` feature flag is active

RSpec.configure do |config|
  config.around do |example|
    can_edit_current_and_next_cycles = example.metadata[:can_edit_current_and_next_cycles]

    if can_edit_current_and_next_cycles == false
      old_value = Settings.features.rollover.can_edit_current_and_next_cycles
      Settings.features.rollover.can_edit_current_and_next_cycles = false
      Rails.application.reload_routes!

      example.run

      Settings.features.rollover.can_edit_current_and_next_cycles = old_value
      Rails.application.reload_routes!
    else
      example.run
    end
  end
end
