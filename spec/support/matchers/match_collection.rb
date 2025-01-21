# frozen_string_literal: true

RSpec::Matchers.define :match_collection do |expected_collection, attribute_names: []|
  match do |actual_collection|
    @expected_collection = extract_debug_info(expected_collection, attribute_names)
    @actual_collection = extract_debug_info(actual_collection, attribute_names)

    @expected_collection == @actual_collection
  end

  failure_message do
    missing_elements = diff_collections(@expected_collection, @actual_collection, :missing)
    extra_elements = diff_collections(@expected_collection, @actual_collection, :extra)

    message = <<~MESSAGE
      #{'Expected collection contained:'.colorize(:yellow)}
        #{@expected_collection.pretty_inspect.colorize(:green)}
      #{'Actual collection contained:'.colorize(:yellow)}
        #{@actual_collection.pretty_inspect.colorize(:red)}
    MESSAGE

    message += <<~MESSAGE if missing_elements.any?
      #{'The missing elements were:'.colorize(:yellow)}
        #{missing_elements.pretty_inspect.colorize(:blue)}
    MESSAGE

    message += <<~MESSAGE if extra_elements.any?
      #{'The extra elements were:'.colorize(:yellow)}
        #{extra_elements.pretty_inspect.colorize(:magenta)}
    MESSAGE

    message
  end

  def extract_debug_info(collection, attribute_names)
    collection.map do |item|
      attribute_names.each_with_object({}) do |attr, hash|
        value = item.public_send(attr) if item.respond_to?(attr)
        hash[attr] = value
        hash[attr] = value.round(2) if value.is_a? Float
      end.merge(id: item.id)
    end
  end

  def diff_collections(expected, actual, type)
    expected_ids = expected.pluck(:id)
    actual_ids = actual.pluck(:id)

    case type
    when :missing
      expected.reject { |e| actual_ids.include?(e[:id]) }
    when :extra
      actual.reject { |a| expected_ids.include?(a[:id]) }
    end
  end
end
