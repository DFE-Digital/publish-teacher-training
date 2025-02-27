import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete'

export default class extends Controller {
  static targets = ['input']
  static values = {
    path: String,
    minLength: { type: Number, default: 1 }
  }

  connect () {
    const selectEl = this.element.querySelector('select')

    dfeAutocompleteField(
      this.element,
      {
        minLength: this.minLengthValue,
        displayMenu: 'overlay',
        name: 'provider_name'
      }
    )

    this.element.querySelector('input').addEventListener('input', this.clearSelect.bind(this, selectEl))
  }

  clearSelect (selectEl, event) {
    if (event.target.value === '') {
      selectEl.value = ''
    }
  }
}
