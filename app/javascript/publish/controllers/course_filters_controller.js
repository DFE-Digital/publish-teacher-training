import { Controller } from '@hotwired/stimulus'

// Applies the course list filters as soon as a checkbox changes.
//
// The form works without JavaScript through its "Apply filters" button, so that
// button is only hidden once this controller has connected and taken over.
//
// Submitting reloads the page, which lands at the top like any GET form — the
// reload deliberately does not scroll or focus the filter that was changed.
export default class extends Controller {
  static targets = ['applyFiltersButton']

  connect () {
    if (this.hasApplyFiltersButtonTarget) {
      // Hidden rather than removed, so it comes back if this controller ever
      // fails to connect. The stylesheet makes the attribute stick over the
      // display the design system gives buttons.
      this.applyFiltersButtonWrapper().hidden = true
    }
  }

  apply (event) {
    if (!event.target.matches('input[type="checkbox"]')) return

    this.element.requestSubmit()
  }

  applyFiltersButtonWrapper () {
    return (
      this.applyFiltersButtonTarget.closest('.govuk-button-group') ||
      this.applyFiltersButtonTarget
    )
  }
}
