import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'
import { request } from '../../utils/request_helper'

const initAutocomplete = (elementId, inputId, options = {}) => {
  try {
    const element = document.getElementById(elementId)
    const input = document.getElementById(inputId)

    if (element && input) {
      const { path, template, minLength, onConfirm, inputName } = options
      const { inputValue, suggestion } = template

      accessibleAutocomplete({
        element,
        id: input.id,
        showNoOptionsFound: true,
        name: input.name,
        defaultValue: input.value,
        minLength,
        source: debounce(request(path), 900),
        templates: {
          inputValue,
          suggestion
        },
        onConfirm: onConfirm(input),
        confirmOnBlur: false,
        autoselect: true
      })

      // Hijack the original input to submit the selected value.
      input.id = `old-${input.id}`
      input.name = inputName
      input.type = 'hidden'
    }
  } catch (err) {
    console.error(`Failed to initialise autocomplete for ${elementId}:`, err)
  }
}

export default initAutocomplete
