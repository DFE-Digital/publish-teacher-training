# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class AddedSchoolsController < ApplicationController
        before_action :render_not_found, unless: :schools_outcome?

        def index
          authorize(provider, :index?)

          @added_schools = @provider.sites.school.register_import.order(:location_name)
        end
      end
    end
  end
end
