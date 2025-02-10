import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete'

export default class extends Controller {
  connect () {
    dfeAutocompleteField(this.element)
  }
}
