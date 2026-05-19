import { dfeAutocompleteField } from 'dfe-autocomplete/src/wrapper'
import { DfeAutocompleteController } from 'dfe-autocomplete/src/stimulus/dfe-autocomplete-controller'

// Thin wrapper around the dfe-autocomplete-shipped Stimulus controller.
//
// It adds two things the shipped controller does not express:
//   * an explicit `name` for the visible autocomplete input (so the typed text
//     is submitted under e.g. `subject_name` while the <select> still submits
//     the chosen code), and
//   * `displayMenu` (defaults to `overlay`), and
//   * "clear the backing <select> when the input is emptied".
export default class extends DfeAutocompleteController {
  static values = {
    name: String,
    displayMenu: { type: String, default: 'overlay' }
  }

  connect () {
    const options = {
      minLength: this.minLengthValue,
      autoselect: this.autoselectValue,
      displayMenu: this.displayMenuValue
    }
    if (this.nameValue) options.name = this.nameValue
    if (this.showAllOnFocusValue) options.showAllOnFocus = true
    if (this.maxResultsValue > 0) options.maxResults = this.maxResultsValue
    if (this.highlightMatchesValue) options.highlightMatches = true

    this.instance = dfeAutocompleteField(this.element, options)
    this.bindClearSelect()
  }

  disconnect () {
    if (this.clearSelectHandler && this.inputEl) {
      this.inputEl.removeEventListener('input', this.clearSelectHandler)
    }
    super.disconnect()
  }

  bindClearSelect () {
    const selectEl = this.element.querySelector('select')
    this.inputEl = this.element.querySelector('input')
    if (!selectEl || !this.inputEl) return

    this.clearSelectHandler = () => {
      if (this.inputEl.value === '') selectEl.value = ''
    }
    this.inputEl.addEventListener('input', this.clearSelectHandler)
  }
}
