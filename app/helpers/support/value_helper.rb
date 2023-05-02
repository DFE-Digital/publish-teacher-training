# frozen_string_literal: true

module Support
  module ValueHelper
    def value_provided?(value)
      value.presence || tag.span(t('value_not_entered'), class: 'govuk-hint').html_safe
    end
  end
end
