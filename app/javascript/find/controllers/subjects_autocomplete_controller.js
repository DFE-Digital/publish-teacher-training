import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete'

export default class extends Controller {
  connect () {
    const selectEl = this.element.querySelector('select')

    dfeAutocompleteField(this.element, {
      displayMenu: 'overlay',
      minLength: 2,
      name: `${selectEl.name}_raw`
    })
  }
}
