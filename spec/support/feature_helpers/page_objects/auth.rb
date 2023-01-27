# frozen_string_literal: true

require_relative 'helper'

module FeatureHelpers
  module PageObject
    module Auth
      Helper.get_pages_to_make(name.demodulize.downcase).map do |method_name, page_object_path|
        define_method method_name do
          return instance_variable_get("@#{method_name}") if instance_variable_get("@#{method_name}").present?

          page_object = page_object_path.constantize.new

          instance_variable_set("@#{method_name}", page_object)
        end
      end
    end
  end
end
