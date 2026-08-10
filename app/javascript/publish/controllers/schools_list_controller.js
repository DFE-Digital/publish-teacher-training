import { Controller } from '@hotwired/stimulus'

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide rows with the `!important` display
// utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

// Owns which schools in a checkbox list are on screen.
//
// Two rules decide that. A search says which schools are allowed at all - it
// arrives as `allowed`, a set of uuids, or null when nothing is being searched
// for. The collapse threshold then decides how many of those to show. They
// interact, since a search suspends the collapse so every match is visible, so
// neither writes to the rows itself: both feed `render`, the only place
// visibility is set.
//
// Rows are only ever hidden, never removed, so a school that is ticked and then
// filtered or collapsed out of view is still submitted.
//
// Pages without a search panel simply never send `allowed`, and this stays what
// it has always been: the collapsing list.
export default class extends Controller {
  static targets = ['school', 'showAll', 'bulkSelect']
  static values = { visible: { type: Number, default: 20 } }

  connect () {
    this.allowed = null
    this.expanded = false

    this.render()
  }

  filter ({ detail }) {
    this.allowed = detail?.allowed ? new Set(detail.allowed) : null
    this.expanded = false

    this.render()
  }

  // A search was cleared by a control that is about to hide itself, so focus
  // would otherwise fall to the document root.
  restore (event) {
    this.filter(event)
    this.schoolTargets.find(checkbox => !this.row(checkbox).hidden)?.focus()
  }

  // "Show all schools" under a collapsed list.
  showAll () {
    const firstCollapsed = this.matchingSchools()[this.visibleValue]

    this.expanded = true
    this.render()

    // The button we just hid held focus, which would otherwise fall back to the
    // document root. Move focus to the first school we revealed instead.
    firstCollapsed?.focus()
  }

  render () {
    const matching = this.matchingSchools()
    const shown = new Set(this.collapsing() ? matching.slice(0, this.visibleValue) : matching)

    this.schoolTargets.forEach(checkbox => this.setRowHidden(checkbox, !shown.has(checkbox)))

    if (this.hasShowAllTarget) {
      this.showAllTarget.hidden = !(this.collapsing() && matching.length > this.visibleValue)
    }

    // Select all takes in every school, including the ones a search has filtered
    // out of view, so hide it while searching rather than leave it offering to
    // do something wider than what is on screen. It stays in the DOM, so it goes
    // on tracking the boxes ticked while filtered and is right when it returns.
    this.bulkSelectTargets.forEach(element => this.setHidden(element, this.searching()))
  }

  matchingSchools () {
    if (!this.searching()) return this.schoolTargets

    return this.schoolTargets.filter(checkbox => this.allowed.has(checkbox.value))
  }

  searching () {
    return this.allowed !== null
  }

  // A search is never collapsed: the point of searching a long list is to see
  // every match.
  collapsing () {
    return !this.searching() && !this.expanded
  }

  setRowHidden (checkbox, hidden) {
    this.setHidden(this.row(checkbox), hidden)
  }

  setHidden (element, hidden) {
    element.classList.toggle(HIDDEN_CLASS, hidden)
    element.hidden = hidden
  }

  row (checkbox) {
    return checkbox.closest('.govuk-checkboxes__item')
  }
}
