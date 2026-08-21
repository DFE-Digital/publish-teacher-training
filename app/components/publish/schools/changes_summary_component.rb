module Publish
  module Schools
    # The summary under a list of school checkboxes, shared by the course schools
    # edit page and the add course wizard's schools step: which schools the
    # provider is adding, and which they are removing, named as they tick.
    #
    # Like the search panel above the list, everything here is inert markup. The
    # summary ships hidden and empty, and the schools-changes Stimulus
    # controller is the only thing that ever fills it in, so a provider without
    # JavaScript sees - and submits - exactly what they did before.
    #
    # The wording travels as data attributes rather than being built here
    # because the counts are only known in the browser. `{count}` is substituted
    # by the controller, not by I18n.
    class ChangesSummaryComponent < ViewComponent::Base
      # The schools attached to the course when the page was served: the state
      # the provider's changes are measured against. The wizard attaches schools
      # to a course that does not exist yet, so it has none.
      def initialize(attached: [])
        @attached = attached

        super()
      end

      def attached_value
        attached.to_json
      end

    private

      attr_reader :attached
    end
  end
end
