# frozen_string_literal: true

module PostcodeNormalize
  extend ActiveSupport::Concern
  included do
    def postcode=(str)
      if str
        super(UKPostcode.parse(str).to_s)
      else
        super
      end
    end
  end
end
