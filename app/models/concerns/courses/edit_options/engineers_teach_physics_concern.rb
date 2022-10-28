module Courses
  module EditOptions
    module EngineersTeachPhysicsConcern
      extend ActiveSupport::Concern
      included do
        def engineers_teach_physics_options
          %w[engineers_teach_physics no_campaign]
        end
      end
    end
  end
end
