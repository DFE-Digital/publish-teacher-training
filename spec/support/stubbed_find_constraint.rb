# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :with_find_constraint) do
    allow_any_instance_of(FindConstraint).to receive(:matches?).and_return(true)
  end
end
