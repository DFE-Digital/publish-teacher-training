# frozen_string_literal: true

module FeatureHelpers
  module PageObjectMethodCreator
    raw_file_names = Dir["spec/support/page_objects/**/*.rb"]

    processed_file_names = raw_file_names.map { |raw_file_name| raw_file_name.chomp(".rb").gsub("spec/support/", "") }

    processed_file_names.each do |processed_file_name|
      file_name = processed_file_name.split("/").last

      processed_file_name.include?("/support/") ? method_name = "support_#{file_name}_page" : method_name = "#{file_name}_page"

      define_method method_name do
        return instance_variable_get("@#{file_name}") if instance_variable_get("@#{file_name}").present?

        page_object = processed_file_name.camelize.constantize

        instance_variable_set("@#{file_name}", page_object.new)
      end
    end
  end
end
