import { Controller } from '@hotwired/stimulus'
import accessibleAutocomplete from 'accessible-autocomplete'
import debounce from 'lodash.debounce'
import { request } from '../../utils/request_helper'

export default class extends Controller {
  static targets = ['input']
  static values = { path: String, selectNameAndCode: Boolean }

  connect () {
    if (!this.hasInputTarget) return

    const inputElement = this.inputTarget

    accessibleAutocomplete({
      element: inputElement.parentElement,
      id: inputElement.id,
      showNoOptionsFound: false,
      name: inputElement.name,
      defaultValue: inputElement.value,
      displayMenu: 'overlay',
      minLength: 3,
      source: this.fetchSuggestions(),
      templates: {
        inputValue: this.suggestionTemplate,
        suggestion: this.suggestionTemplate
      },
      confirmOnBlur: false
    })

    inputElement.remove()
  }

  fetchSuggestions () {
    return debounce((query, populateResults) => {
      if (!query) return populateResults([])

      new Promise((resolve, reject) => {
        request(this.pathValue)(query, (data) => {
          resolve(data)
        })
      })
        .then((data) => {
          const suggestions = Array.isArray(data?.suggestions) ? data.suggestions : []
          populateResults(suggestions)
        })
        .catch(() => {
          populateResults([])
        })
    }, 900)
  }

  suggestionTemplate (result) {
    if (typeof result === 'string') {
      return result
    }

    return result && typeof result.name === 'string' ? result.name : ''
  }
}
