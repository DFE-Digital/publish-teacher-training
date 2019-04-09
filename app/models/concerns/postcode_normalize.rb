module PostcodeNormalize
  extend ActiveSupport::Concern
  included do
    def postcode=(str)
      super UKPostcode.parse(str).to_s
    end
  end
end
