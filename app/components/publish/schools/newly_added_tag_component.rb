module Publish
  module Schools
    class NewlyAddedTagComponent < ::Publish::NewlyAddedTagComponent
      def initialize(school:)
        @school = school
        @recruitment_cycle = school.recruitment_cycle

        super()
      end

      def render?
        @school.register_import? && @recruitment_cycle.rollover_period_2026?
      end
    end
  end
end
