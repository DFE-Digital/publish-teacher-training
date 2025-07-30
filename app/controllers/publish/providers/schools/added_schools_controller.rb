# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class AddedSchoolsController < ApplicationController
        def index
          @added_schools = @provider.sites.school.register_import.order(:location_name)
        end
      end
    end
  end
end
