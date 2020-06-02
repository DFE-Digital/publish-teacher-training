module Allocations
  class Update
    attr_accessor :object, :params

    def initialize(allocation, params)
      @object = allocation
      @params = params

      set_number_of_places
      set_request_type

      object
    end

    def execute
      object.save
    end

  private

    def set_number_of_places
      object.number_of_places = case params[:request_type]
                                when "declined"
                                  0
                                when "repeat"
                                  object.previous&.number_of_places || 0
                                else
                                  params[:number_of_places]
                                end
    end

    def set_request_type
      object.request_type = params[:request_type]
    end
  end
end
