import { setupAccessibleAutoComplete } from './dfe-autocomplete'

function dfeAutocomplete (libraryOptions = {}) {
  const $allAutocompleteElements = document.querySelectorAll('[data-module="app-dfe-autocomplete"]')

  $allAutocompleteElements.forEach((element) => {
    setupAccessibleAutoComplete(element, libraryOptions)
  })
}

export default dfeAutocomplete
