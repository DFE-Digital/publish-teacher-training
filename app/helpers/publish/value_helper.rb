# frozen_string_literal: true

module Publish
  module ValueHelper
    def value_provided?(value)
      value.presence || tag.span(t("value_not_entered"), class: "govuk-hint").html_safe
    end

    # A field with nothing in it yet: a blue-bordered prompt linking to the page
    # that fills it in. Every incomplete field reads the same way, whether or not
    # it is the one stopping the course publishing - see DegreeRowContent and
    # GcseRowContent, which have always done this. It turns red when the field
    # has an error.
    def value_prompt(text, href, error: false)
      govuk_inset_text(classes: "app-inset-text--narrow-border #{error ? 'app-inset-text--error' : 'app-inset-text--important'}") do
        govuk_link_to(text, href)
      end
    end

    # For a field where having nothing is an answer rather than an omission.
    # Reads the same as a course with no placement schools - see
    # Publish::Schools::AttachedSchoolsSummaryComponent.
    def value_none
      tag.span("None", class: "app-!-colour-muted")
    end
  end
end
