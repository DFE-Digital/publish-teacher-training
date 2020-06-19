module Allocations
  class Create
    attr_accessor :object

    def initialize(params)
      @object = Allocation.new(params)

      set_codes
      set_recruitment_cycle
      set_number_of_places

      object
    end

    def execute
      object.save
    end

  private

    def set_number_of_places
      other_request_type_number = 0

      if object.number_of_places.nil?
        object.number_of_places = if object.repeat?
                                    object.previous&.number_of_places || 0
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

    def set_recruitment_cycle
      object.recruitment_cycle_id ||= RecruitmentCycle.find_by(year: Allocation::ALLOCATION_CYCLE_YEAR).id
    end
  end
end
