import { Controller } from '@hotwired/stimulus'

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide overflow rows with the `!important`
// display utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

export default class extends Controller {
  static targets = ['school', 'showAll']
  static values = { visible: { type: Number, default: 20 } }

  connect () {
    if (this.overflow().length === 0) return

    this.overflow().forEach(checkbox => this.hideRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = false
  }

  showAll () {
    this.overflow().forEach(checkbox => this.showRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = true

    // The button we just hid held focus, which would otherwise fall back to the
    // document root. Move focus to the first school we revealed instead.
    const firstRevealed = this.overflow()[0]
    if (firstRevealed) firstRevealed.focus()
  }

  // The rows past the visible threshold. Hidden rows stay in the DOM and keep
  // their checked state, so a selected-but-hidden school is still submitted.
  overflow () {
    return this.schoolTargets.slice(this.visibleValue)
  }

  hideRow (checkbox) {
    const row = this.row(checkbox)
    row.classList.add(HIDDEN_CLASS)
    row.hidden = true
  }

  showRow (checkbox) {
    const row = this.row(checkbox)
    row.classList.remove(HIDDEN_CLASS)
    row.hidden = false
  }

  row (checkbox) {
    return checkbox.closest('.govuk-checkboxes__item')
  }
}
