# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new('/spec/features/find')) do |metadata|
    metadata[:with_find_constraint] = true
  end

  config.before(:each, :with_find_constraint) do
    allow_any_instance_of(FindConstraint).to receive(:matches?).and_return(true)
  end
end
