import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete'

export default class extends Controller {
  connect () {
    const selectEl = this.element.querySelector('select')

    dfeAutocompleteField(this.element, {
      displayMenu: 'overlay',
      minLength: 2,
      name: 'subject_name'
    })

    this.element.querySelector('input').addEventListener('input', this.clearSelect.bind(this, selectEl))
  }

  clearSelect (selectEl, event) {
    if (event.target.value === '') {
      selectEl.value = ''
    }
  }
}
