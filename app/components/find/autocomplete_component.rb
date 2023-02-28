module Find
  class AutocompleteComponent < GovukComponent::Base
    def initialize(attribute_name:, form_field:, classes: [], html_attributes: {})
      @attribute_name = attribute_name
      @form_field = form_field
      super(classes: classes, html_attributes: html_attributes)
    end

    private

    attr_accessor :form_field, :attribute_name

    def default_attributes
      {
        id: attribute_name.to_s,
        'class' => %w[app-!-autocomplete--max-width-two-thirds suggestions],
        'data-module' => 'app-dfe-autocomplete',
        'data-default-value' => ''
      }
    end
  end
end
