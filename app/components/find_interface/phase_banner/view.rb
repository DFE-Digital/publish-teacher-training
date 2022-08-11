# frozen_string_literal: true

module FindInterface
  class PhaseBanner::View < ViewComponent::Base
    include ViewHelper
    def initialize(no_border: false)
      super
      @no_border = no_border
    end

    def environment_label
      Settings.environment.label
    end

    def environment_colour
      {
        "development" => "grey",
        "qa" => "orange",
        "review" => "purple",
        "sandbox" => "purple",
        "staging" => "red",
        "unknown-environment" => "yellow",
      }[Settings.environment.name]
    end

    def sandbox_mode?
      Settings.environment.name == "sandbox"
    end

    def feedback_link_to
      Settings.feedback.link
    end
  end
end
