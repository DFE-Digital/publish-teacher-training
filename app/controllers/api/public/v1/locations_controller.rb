module API
  module Public
    module V1
      class LocationsController < API::Public::V1::ApplicationController
        def index
          render json: {
            data: [
              {
                id: "123",
                type: "Location",
                attributes: {
                  code: "A",
                  name: "some school",
                  street_address_1: "some building",
                  street_address_2: "some street",
                  city: "some city",
                  county: "some county",
                  postcode: "NE1 6EE",
                  region_code: "london",
                  recruitment_cycle_year: "2020",
                },
              },
            ],
            jsonapi: {
              version: "1.0",
            },
          }
        end
      end
    end
  end
end
