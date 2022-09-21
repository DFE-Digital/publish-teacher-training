module Find
  class HiddenFieldsComponent < ViewComponent::Base
    attr_reader :query_params, :form_name, :form, :exclude_keys
    # rubocop:disable Lint/MissingSuper
    def initialize(query_params:, form_name:, form:, exclude_keys: [])
      @query_params = query_params
      @form_name = form_name
      @form = form
      @exclude_keys = exclude_keys
    end
    # rubocop:enable Lint/MissingSuper

    def params
      query_params[form_name] || query_params
    end
  end
end
