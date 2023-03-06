# frozen_string_literal: true

module Find
  class AutocompleteComponent < GovukComponent::Base
    def initialize(form_field:, classes: [], html_attributes: {})
      @form_field = form_field
      super(classes:, html_attributes:)
    end

    private

    attr_accessor :form_field

    def default_attributes
      {
        'class' => %w[app-!-autocomplete--max-width-two-thirds suggestions],
        'data-module' => 'app-dfe-autocomplete',
        'data-default-value' => ''
      }
    end
  end
end
