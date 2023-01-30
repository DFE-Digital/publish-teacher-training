# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :with_publish_constraint) do
    allow_any_instance_of(PublishConstraint).to receive(:matches?).and_return(true)
  end
end
