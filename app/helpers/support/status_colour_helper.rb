# frozen_string_literal: true

# Helper methods for determining status colours for ProvidersOnboardingFormRequest
module Support
  module StatusColourHelper
    def status_colour(status)
      case status
      when "pending" then "blue"
      when "submitted" then "yellow"
      when "expired" then "grey"
      when "closed" then "green"
      when "rejected" then "red"
      else "grey"
      end
    end
  end
end
