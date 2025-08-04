# frozen_string_literal: true

module Publish
  module Providers
    module Schools
      class AddedSchoolsController < ::Publish::ApplicationController
        before_action :render_not_found, unless: :rollover_period_2026?

        def index
          authorize(provider, :index?)

          @added_schools = @provider.sites.school.register_import.order(:location_name)
        end
      end
    end
  end
end
