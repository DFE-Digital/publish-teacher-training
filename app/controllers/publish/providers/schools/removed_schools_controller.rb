module Publish
  module Providers
    module Schools
      class RemovedSchoolsController < ::Publish::ApplicationController
        before_action :render_not_found, unless: :schools_outcome?

        def index
          authorize(provider, :index?)

          @removed_schools = @provider
            .sites
            .school
            .with_discarded
            .where(discarded_via_script: true)
            .order(:location_name)
        end
      end
    end
  end
end
