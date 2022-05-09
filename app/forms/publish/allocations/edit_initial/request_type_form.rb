module Publish
  module Allocations
    module EditInitial
      class RequestTypeForm
        include ActiveModel::Model

        attr_accessor :request_type

        validates :request_type, presence: { message: "Select one option" }
      end
    end
  end
end
