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

    this.overflow().forEach(checkbox => this.hideRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = false
  }

  showAll () {
    this.overflow().forEach(checkbox => this.showRow(checkbox))

    if (this.hasShowAllTarget) this.showAllTarget.hidden = true
  }

  overflow () {
    return this.schoolTargets.slice(this.visibleValue)
  }

  hideRow (checkbox) {
    const row = checkbox.closest('.govuk-checkboxes__item')
    row.classList.add(HIDDEN_CLASS)
    row.hidden = true
  }

  showRow (checkbox) {
    const row = checkbox.closest('.govuk-checkboxes__item')
    row.classList.remove(HIDDEN_CLASS)
    row.hidden = false
  }
}
