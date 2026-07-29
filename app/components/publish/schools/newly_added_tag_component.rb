module Publish
  module Schools
    class NewlyAddedTagComponent < ::Publish::NewlyAddedTagComponent
      def initialize(school:)
        @school = school
        @recruitment_cycle = school.recruitment_cycle

        super()
      end

      def render?
        # Both models answer register_import?: Site from its own enum,
        # Provider::School through its paired legacy site. Keeping the branch
        # out of here lets the course pickers preload the association rather
        # than issuing a query per checkbox.
        @school.register_import? && @recruitment_cycle.rollover_period_2026?
      end
    end
  end
end
