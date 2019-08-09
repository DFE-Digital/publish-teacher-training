class AccreditingProviderEnrichment
  include ActiveModel::Validations
  include ActiveModel::Model

  attr_accessor :UcasProviderCode, :Description

  validates :Description, words_count: { maximum: 100 }

  def initialize(attrs)
    attrs.each do |attr, value|
      send("#{attr}=", value) unless attr == "errors"
    end
  end

  def attributes
    %i[UcasProviderCode Description].inject({}) do |hash, attr|
      hash[attr] = send(attr)
      hash
    end
  end

  class ArraySerializer
    class << self
      def load(json)
        if json.present?
          arr = JSON.parse json

          arr.map do |item|
            AccreditingProviderEnrichment.new(item)
          end
        end
      end

      def dump(obj)
        obj.to_json if obj
      end
    end
  end
end
