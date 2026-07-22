import { Controller } from '@hotwired/stimulus'

// Applies the course list filters as soon as a checkbox changes.
//
// The form works without JavaScript through its "Apply filters" button, so that
// button is only hidden once this controller has connected and taken over.
//
// Submitting reloads the page, which would otherwise drop the reader back at
// the top with focus lost. Carrying the changed checkbox's id as the URL
// fragment asks the browser to return to it.
export default class extends Controller {
  static targets = ['applyFiltersButton']

  connect () {
    if (this.hasApplyFiltersButtonTarget) {
      this.applyFiltersButtonWrapper().hidden = true
    }
  }

  apply (event) {
    const changed = event.target

    if (!changed.matches('input[type="checkbox"]')) return

    if (changed.id) {
      this.element.action = `${this.element.action.split('#')[0]}#${changed.id}`
    }

    this.element.requestSubmit()
  }

  applyFiltersButtonWrapper () {
    return (
      this.applyFiltersButtonTarget.closest('.govuk-button-group') ||
      this.applyFiltersButtonTarget
    )
  }
}
