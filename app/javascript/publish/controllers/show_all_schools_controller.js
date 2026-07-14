import { Controller } from '@hotwired/stimulus'

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide overflow rows with the `!important`
// display utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

export default class extends Controller {
  static targets = ['school', 'showAll']
  static values = { visible: { type: Number, default: 20 } }

  connect () {
    if (this.schoolTargets.length <= this.visibleValue) return

    const hideable = this.hideable()
    if (hideable.length === 0) return

    hideable.forEach(checkbox => this.hideRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = false
  }

  showAll () {
    const revealed = this.overflow().filter(checkbox => this.isHidden(checkbox))

    revealed.forEach(checkbox => this.showRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = true

    // The button we just hid held focus, which would otherwise fall back to the
    // document root. Move focus to the first school we revealed instead.
    if (revealed.length > 0) revealed[0].focus()
  }

  overflow () {
    return this.schoolTargets.slice(this.visibleValue)
  }

  // A selected school is never hidden: it would render checked but invisible, so
  // the user could not see or undo a selection that still gets submitted.
  hideable () {
    return this.overflow().filter(checkbox => !checkbox.checked)
  }

  isHidden (checkbox) {
    return this.row(checkbox).hidden
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
