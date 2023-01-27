# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new('/spec/features/publish')) do |metadata|
    metadata[:with_publish_constraint] = true
  end

  config.before(:each, :with_publish_constraint) do
    allow_any_instance_of(PublishConstraint).to receive(:matches?).and_return(true)
  end
end
