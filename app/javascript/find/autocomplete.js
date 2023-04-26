import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'
import { request } from '../utils/request_helper'

const inputValueTemplate = result => (typeof result === 'string' ? result : result && result.name)

const suggestionTemplate = result =>
  typeof result === 'string' ? result : result && `${result.name} (${result.code})`

const initAutocomplete = ({ element, input, path, selectNameAndCode }) => {
  let inputId = input
  let $input = document.getElementById(inputId)
  if (!$input) {
    inputId += '-error'
    $input = document.getElementById(inputId)
  }

  const $el = document.getElementById(element)
  if (!$el) return

  try {
    if ($input) {
      accessibleAutocomplete({
        element: $el,
        id: $input.id,
        showNoOptionsFound: true,
        name: $input.name,
        defaultValue: $input.value,
        minLength: 3,
        source: debounce(request(path), 900),
        templates: {
          inputValue: selectNameAndCode ? suggestionTemplate : inputValueTemplate,
          suggestion: suggestionTemplate
        },
        onConfirm: option => ($input.value = option ? option.code : ''),
        confirmOnBlur: false
      })

      $input.parentNode.removeChild($input)
    }
  } catch (err) {
    console.error(`Failed to initialise ${inputId} autocomplete:`, err)
  }
}

export default initAutocomplete
