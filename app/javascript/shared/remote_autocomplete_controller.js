import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete/src/wrapper'
import { FORMATTERS } from './suggestion_formatters'

// Progressive enhancement for the app's remote-search autocompletes.
//
// dfe-autocomplete enhances a <select>, but a remote search has no fixed list
// of options. So without JavaScript the markup stays a plain text <input>
// (the server handles the search); on connect this controller swaps in an
// empty <select> for dfe-autocomplete to enhance, wired to an async source.
//
// When `idField`/`hiddenName` are set, the id of the confirmed result is
// written into a hidden field so the server receives the chosen record
// rather than just the typed text.
export default class extends Controller {
  static values = {
    path: String,
    format: { type: String, default: 'location' },
    minLength: { type: Number, default: 3 },
    debounce: { type: Number, default: 200 },
    idField: String,
    hiddenName: String
  }

  connect () {
    const input = this.element.querySelector('input:not([type="hidden"])')
    if (!input) return

    const { id, name, value } = input

    // dfe-autocomplete enhances a <select>; swap the plain text input for an
    // empty one so the enhanced combobox inherits the field's id, and keep
    // the typed value as the default.
    const select = document.createElement('select')
    select.id = id
    select.add(new Option('', ''))
    this.element.setAttribute('data-default-value', value)
    input.replaceWith(select)

    const source = (query) => this.fetchSuggestions(query)
    source.debounce = this.debounceValue

    this.instance = dfeAutocompleteField(this.element, {
      name,
      minLength: this.minLengthValue,
      displayMenu: 'overlay',
      confirmOnBlur: false,
      showNoOptionsFound: false,
      source,
      onConfirm: (selected) => this.storeSelectedId(selected)
    })
  }

  disconnect () {
    this.instance?.destroy()
  }

  async fetchSuggestions (query) {
    const response = await fetch(
      `${this.pathValue}?query=${encodeURIComponent(query)}`,
      { headers: { Accept: 'application/json' } }
    )
    if (!response.ok) {
      throw new Error(`Autocomplete request to ${this.pathValue} failed (${response.status})`)
    }

    const payload = await response.json()
    const results = Array.isArray(payload) ? payload : payload.suggestions || []
    const format = FORMATTERS[this.formatValue] || FORMATTERS.location

    return results.map(format)
  }

  // Records the chosen result's id in the hidden field so the form submits
  // the selected record, not just its display text.
  storeSelectedId (selected) {
    if (!this.hasHiddenNameValue) return

    const hiddenField = this.element
      .closest('form')
      ?.querySelector(`input[type="hidden"][name="${this.hiddenNameValue}"]`)
    if (hiddenField) {
      hiddenField.value = selected ? selected[this.idFieldValue] ?? '' : ''
    }
  }
}
