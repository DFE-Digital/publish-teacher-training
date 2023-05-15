import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'
import { request } from '../utils/request_helper'

export const initAutocomplete = ($el, $input, inputValueTemplate, options = {}) => {
  const path = options.path
  const suggestionTemplate = options.template
  const onConfirmCallback = options.onConfirm || (() => {})

  accessibleAutocomplete({
    element: $el,
    id: $input.id,
    showNoOptionsFound: true,
    name: $input.name,
    defaultValue: $input.value,
    minLength: 3,
    source: debounce(request(path), 900),
    templates: {
      inputValue: inputValueTemplate,
      suggestion: suggestionTemplate
    },
    onConfirm: (option) => {
      $input.value = option ? option.code : ''
      onConfirmCallback(option)
    },
    confirmOnBlur: false,
    autoselect: true
  })

  // Hijack the original input to submit the selected provider_code.
  $input.id = `old-${$input.id}`
  $input.name = 'course[autocompleted_provider_code]'
  $input.type = 'hidden'
}
