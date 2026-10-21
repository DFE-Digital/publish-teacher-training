# frozen_string_literal: true

RSpec.configure do |config|
  # Untyped examples (including lib and service specs) do not get Rails' reset.
  config.before { Current.reset }
end
