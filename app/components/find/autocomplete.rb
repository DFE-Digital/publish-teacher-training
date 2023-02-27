module Find
  class Autocomplete < GovukComponent::Base
    def initialize(form, attribute_name:, form_field:, classes: [], html_attributes: {})
      @raw_attribute_value = form.object.send("#{attribute_name}_raw") if form.object.respond_to?(:"#{attribute_name}_raw")
      @attribute_value = form.object.send(attribute_name)
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
        'data-default-value' => (@raw_attribute_value || @attribute_value).to_s
      }
    end
  end
end
