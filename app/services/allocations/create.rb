module Allocations
  class Create
    attr_accessor :object

    def initialize(params)
      @object = Allocation.new(params)

      set_number_of_places
      set_codes

      object
    end

    def execute
      object.save
    end

  private

    # TODO: temporary until we implement fetching the previous
    # Allocation#number_of_places for repeat
    def set_number_of_places
      temporary_repeat_number_of_places = 42
      other_request_type_number = 0

      if object.number_of_places.nil?
        object.number_of_places = if object.repeat?
                                    temporary_repeat_number_of_places
                                  else
                                    other_request_type_number
                                  end
      end
    end

    def set_codes
      object.accredited_body_code ||= accredited_body_code
      object.provider_code ||= provider_code
    end

    def accredited_body_code
      object.accredited_body.provider_code
    end

    def provider_code
      return unless object.provider

      object.provider.provider_code
    end
  end
end
