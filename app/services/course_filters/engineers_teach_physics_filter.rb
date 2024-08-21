# frozen_string_literal: true

module CourseFilters
  class EngineersTeachPhysicsFilter < BaseFilter
    def call(scope)
      scope.engineers_teach_physics
    end

    def add_filter?
      filter[:engineers_teach_physics].to_s.downcase == 'true' ||
        filter[:campaign_name] == 'engineers_teach_physics'
    end
  end
end
