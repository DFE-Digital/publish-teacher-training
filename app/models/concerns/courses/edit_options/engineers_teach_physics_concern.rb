module Courses
  module EditOptions
    module EngineersTeachPhysicsConcern
      extend ActiveSupport::Concern
      included do
        # When changing anything here be sure to update the edit_options in the
        # courses factory in publish-teacher-training:
        #
        # https://github.com/DFE-Digital/publish-teacher-training/blob/master/spec/factories/courses.rb
        def engineers_teach_physics_options
          ["engineers_teach_physics", "no_campaign"]
        end
      end
    end
  end
end
