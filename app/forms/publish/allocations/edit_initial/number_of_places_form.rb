module Publish
  module Allocations
    module EditInitial
      class NumberOfPlacesForm
        include ActiveModel::Model

        attr_accessor :number_of_places

        validates :number_of_places,
                  presence: { message: "You must enter a number" },
                  numericality: { message: "You must enter a number", other_than: 0, only_integer: true }
      end
    end
  end
end
