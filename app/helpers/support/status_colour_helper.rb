# frozen_string_literal: true

# Helper methods for determining status colours for ProvidersOnboardingFormRequest
module Support
  module StatusColourHelper
    STATUSCOLOURS = { pending: "blue", submitted: "yellow", expired: "grey", closed: "green", rejected: "red" }.freeze

    def status_colour(status)
      STATUSCOLOURS.fetch(status.to_sym, "grey")
    end
  end
end
