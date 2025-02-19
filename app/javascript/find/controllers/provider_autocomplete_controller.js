import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete'

export default class extends Controller {
  static targets = ['input']
  static values = {
    path: String,
    minLength: { type: Number, default: 1 }
  }

  connect () {
    dfeAutocompleteField(
      this.element,
      {
        minLength: this.minLengthValue,
        displayMenu: 'overlay',
        name: 'provider_name'
      }
    )
  }
}
