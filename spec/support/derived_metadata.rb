# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new("/spec/(system|features)/find")) do |metadata|
    metadata[:find_features] = true
    metadata[:with_find_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new("/spec/(system|features)/publish")) do |metadata|
    metadata[:publish_features] = true
    metadata[:auth_features] = true

    metadata[:with_publish_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new("/spec/(system|features)/support")) do |metadata|
    metadata[:support_features] = true
    metadata[:auth_features] = true

    metadata[:with_publish_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new("/spec/(system|features)/auth")) do |metadata|
    metadata[:auth_features] = true
    metadata[:support_features] = true
    metadata[:publish_features] = true

    metadata[:with_publish_constraint] = true
  end

  config.define_derived_metadata(file_path: Regexp.new("/spec/requests/find")) do |metadata|
    metadata[:namespace] = :find
  end

  config.define_derived_metadata(file_path: Regexp.new("/spec/requests/publish")) do |metadata|
    metadata[:namespace] = :publish
  end
end
