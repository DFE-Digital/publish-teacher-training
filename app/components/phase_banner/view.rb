# frozen_string_literal: true

class PhaseBanner::View < ViewComponent::Base
  def environment_label
    Settings.environment.label
  end

  def environment_colour
    {
      "development" => "grey",
      "qa" => "orange",
      "review" => "purple",
      "rollover" => "turquoise",
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
