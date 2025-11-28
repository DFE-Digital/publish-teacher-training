import { Controller } from '@hotwired/stimulus'

// Implementation of a <details> style component
// which allows us to show the content even if the details are hidden
// This is needed for screen resizing
//
// The contents should be visible on larger screens
// even when the component is closed
// <details> doesn't allow this.
//
// The content is open by default
// On connect, it's closed
// It's open for when js is not enabled the contents are visible
export default class extends Controller {
  static targets = ['button', 'content']

  connect () {
    // When the page loads, the content is open for when js is not available
    // We close it if javascript is available
    this.toggleAriaExpanded()
  }

  toggle () {
    this.toggleAriaExpanded()
  }

  toggleAriaExpanded () {
    if (this.buttonTarget.ariaExpanded === 'true') {
      this.buttonTarget.setAttribute('aria-expanded', 'false')
    } else {
      this.buttonTarget.setAttribute('aria-expanded', 'true')
    }
  }
}
