module Publish
  module Schools
    class NewlyAddedTagComponent < ::Publish::NewlyAddedTagComponent
      def initialize(school:)
        @school = school
        @recruitment_cycle = school.recruitment_cycle

        super()
      end

      def render?
        register_import? && @recruitment_cycle.rollover_period_2026?
      end

    private

      def register_import?
        if @school.is_a?(Site)
          @school.register_import?
        else
          legacy_site&.register_import?
        end
      end

      def legacy_site
        @legacy_site ||= @school.provider.sites.find_by(uuid: @school.uuid)
      end
    end
  end
end
