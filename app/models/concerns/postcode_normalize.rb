module PostcodeNormalize
  extend ActiveSupport::Concern
  included do
    def postcode=(str)
      if str
        super UKPostcode.parse(str).to_s
      else
        super str
      end
    end
  end
end
