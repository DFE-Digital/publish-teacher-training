# frozen_string_literal: true

module Publish
  module ValueHelper
    def value_provided?(value)
      value.presence || tag.span(t("value_not_entered"), class: "govuk-hint").html_safe
    end

    # For a field where having nothing is an answer rather than an omission.
    # Reads the same as a course with no placement schools - see
    # Publish::Schools::AttachedSchoolsSummaryComponent.
    def value_none
      tag.span("None", class: "app-!-colour-muted")
    end
  end
end
