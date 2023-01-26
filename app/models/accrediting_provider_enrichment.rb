# frozen_string_literal: true

class AccreditingProviderEnrichment
  include ActiveModel::Validations
  include ActiveModel::Model

  # Pascal cased as the original is stored like so.
  attr_accessor :UcasProviderCode, :Description

  validates :Description, words_count: { maximum: 100 }

  def initialize(attrs)
    attrs.each do |attr, value|
      send("#{attr}=", value) unless attr == "errors"
    end
  end

  class ArraySerializer
    class << self
      def load(json)
        return if json.blank?

        arr = JSON.parse json

        arr.map do |item|
          AccreditingProviderEnrichment.new(item)
        end
      end

      def dump(obj)
        obj&.to_json
      end
    end
  end
end
