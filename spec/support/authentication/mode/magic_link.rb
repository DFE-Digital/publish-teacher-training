# frozen_string_literal: true

# This is required as a workaround for failing tests when DfE sign in is down and magic links are active

RSpec.configure do |config|
  config.around do |example|
    magic_link = Settings.authentication.mode == 'magic_link'

    if magic_link == true
      old_value = Settings.authentication.mode

      Settings.authentication.mode = nil
      Rails.application.reload_routes!

      example.run

      Settings.authentication.mode = old_value
      Rails.application.reload_routes!
    else
      example.run
    end
  end
end
