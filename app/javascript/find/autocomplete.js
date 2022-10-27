import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'

export const getPath = (endpoint, query) => {
  return `${endpoint}?query=${query}`
}

export const request = endpoint => {
  let xhr = null // Hoist this call so that we can abort previous requests.

  return (query, callback) => {
    if (xhr && xhr.readyState !== XMLHttpRequest.DONE) {
      xhr.abort()
    }
    const path = getPath(endpoint, query)

    xhr = new XMLHttpRequest()
    xhr.addEventListener('load', evt => {
      let results = []
      try {
        results = JSON.parse(xhr.responseText)
      } catch (err) {
        console.error(
          `Failed to parse results from endpoint ${path}, error is:`,
          err
        )
      }
      callback(results)
    })
    xhr.open('GET', path)
    xhr.send()
  }
}

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
