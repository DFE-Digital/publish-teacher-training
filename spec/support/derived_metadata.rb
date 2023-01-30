# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new('/spec/features/find')) do |metadata|
    metadata[:find_features] = true
    metadata[:with_find_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/features/publish')) do |metadata|
    metadata[:publish_features] = true
    metadata[:auth_features] = true

    metadata[:with_publish_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/features/support')) do |metadata|
    metadata[:support_features] = true
    metadata[:auth_features] = true

    metadata[:with_publish_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/features/auth')) do |metadata|
    metadata[:auth_features] = true
    metadata[:support_features] = true
    metadata[:publish_features] = true

    metadata[:with_publish_constraint] = true
  end
end
