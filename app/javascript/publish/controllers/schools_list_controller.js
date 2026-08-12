import { Controller } from '@hotwired/stimulus'

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide rows with the `!important` display
// utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

// Owns which schools in a checkbox list are on screen.
//
// Two rules decide that. A search narrows the list to the schools it found, and
// the collapse threshold then decides how many of those to show. They interact,
// since a search suspends the collapse so every result is visible, so neither
// writes to the rows itself: both feed `render`, the only place visibility is
// set.
//
// Whether a search is running and what it found are held apart, in `searching`
// and `searchResults`, because they answer different questions: a search that
// found nothing still hides select all and suspends the collapse.
//
// Rows are only ever hidden, never removed, so a school that is ticked and then
// filtered or collapsed out of view is still submitted.
//
// Pages without a search panel never send any of these events, and this stays
// what it has always been: the collapsing list.
export default class extends Controller {
  static targets = ['schoolCheckbox', 'showAll', 'bulkSelect']
  static values = { collapseAfter: { type: Number, default: 20 } }

  connect () {
    this.clear()
  }

  // No search: every school is back, and a list long enough to collapse does so
  // again. Also the state to start in, which is why connect asks for it.
  clear () {
    this.searching = false
    this.searchResults = new Set()
    this.expanded = false

    this.render()
  }

  render () {
    const schools = this.schoolsMatchingSearch()
    const shown = new Set(this.collapsed() ? schools.slice(0, this.collapseAfterValue) : schools)

    this.schoolCheckboxTargets.forEach(checkbox => this.setHidden(this.row(checkbox), !shown.has(checkbox)))

    if (this.hasShowAllTarget) {
      this.showAllTarget.hidden = !(this.collapsed() && schools.length > this.collapseAfterValue)
    }

    // Select all takes in every school, including the ones a search has filtered
    // out of view, so hide it while searching rather than leave it offering to
    // do something wider than what is on screen. It stays in the DOM, so it goes
    // on tracking the boxes ticked while filtered and is right when it returns.
    this.bulkSelectTargets.forEach(element => this.setHidden(element, this.searching))
  }

  // Every school when no search is running: with nothing asked for, nothing is
  // ruled out.
  schoolsMatchingSearch () {
    if (!this.searching) return this.schoolCheckboxTargets

    return this.schoolCheckboxTargets.filter(checkbox => this.searchResults.has(checkbox.value))
  }

  // A search is never collapsed: the point of searching a long list is to see
  // every result.
  collapsed () {
    return !this.searching && !this.expanded
  }

  setHidden (element, hidden) {
    element.classList.toggle(HIDDEN_CLASS, hidden)
    element.hidden = hidden
  }

  row (checkbox) {
    return checkbox.closest('.govuk-checkboxes__item')
  }

  filter ({ detail }) {
    this.searching = true
    this.searchResults = new Set(detail.results)
    this.expanded = false

    this.render()
  }

  // A search was cleared by a control that is about to hide itself, so focus
  // would otherwise fall to the document root.
  restore () {
    this.clear()
    this.schoolCheckboxTargets.find(checkbox => !this.row(checkbox).hidden)?.focus()
  }

  // "Show all schools" under a collapsed list.
  showAll () {
    const firstCollapsed = this.schoolsMatchingSearch()[this.collapseAfterValue]

    this.expanded = true
    this.render()

    // The button we just hid held focus, which would otherwise fall back to the
    // document root. Move focus to the first school we revealed instead.
    firstCollapsed?.focus()
  }
}
