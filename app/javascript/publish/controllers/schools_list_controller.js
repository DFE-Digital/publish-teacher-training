import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete/src/wrapper'
import { matchingValues, optionsFromSelect } from '../schools_search'

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide rows with the `!important` display
// utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

const MIN_QUERY_LENGTH = 3
const MAX_SUGGESTIONS = 5

// Owns which schools in a checkbox list are on screen.
//
// Two rules decide that - the collapse threshold and the search - and they
// interact: a search suspends the collapse so that every match is shown, and
// clearing the search brings the collapsed list back. So neither rule writes to
// the rows itself; both feed `render`, which is the only place visibility is
// set.
//
// Rows are only ever hidden, never removed, so a school that is ticked and then
// filtered or collapsed out of view is still submitted.
//
// The search half only wakes up on pages that render a search panel. Without
// one this is still just the collapsing list.
export default class extends Controller {
  static targets = ['school', 'showAll', 'panel', 'autocomplete', 'status', 'noResults', 'bulkSelect']
  static values = { visible: { type: Number, default: 20 } }

  connect () {
    this.query = ''
    this.expanded = false
    this.options = []

    this.setupSearch()
    this.render()
  }

  disconnect () {
    this.instance?.destroy()
  }

  setupSearch () {
    if (!this.hasAutocompleteTarget) return

    this.selectEl = this.autocompleteTarget.querySelector('select')
    this.options = optionsFromSelect(this.selectEl)
    // The enhanced input inherits the select's id, which is how we tell it apart
    // from the hint input accessible-autocomplete renders alongside it. That one
    // comes first in the DOM and holds the autocompleted preview, so reaching for
    // the input by position - as the library's own getValue does - reads back
    // text the provider never typed.
    this.inputId = this.selectEl.id

    this.instance = dfeAutocompleteField(this.autocompleteTarget, {
      minLength: MIN_QUERY_LENGTH,
      maxResults: MAX_SUGGESTIONS,
      highlightMatches: true,
      confirmOnBlur: false,
      // Float the suggestions over the page: an inline menu pushes the Search
      // button down as you type, out from under the pointer.
      displayMenu: 'overlay'
    })

    // Choosing a suggestion only fills the box: the list changes when the
    // provider asks for it, not while they are still deciding what to search
    // for. So nothing is bound to the autocomplete's select event.

    // The panel sits inside the form that saves the schools, so Enter always
    // has to be caught here or it would submit that form. With the menu open it
    // belongs to the autocomplete, which has already confirmed the highlighted
    // suggestion by the time this fires; otherwise it searches, as it would in
    // any other search box.
    this.autocompleteTarget.addEventListener('keydown', (event) => {
      if (event.key !== 'Enter') return

      event.preventDefault()

      if (this.input()?.getAttribute('aria-expanded') !== 'true') this.search()
    })

    if (this.hasPanelTarget) this.panelTarget.hidden = false
  }

  search () {
    this.filter(this.input()?.value)
  }

  clearSearch () {
    this.reset()
    this.input()?.focus()
  }

  input () {
    return this.inputId ? document.getElementById(this.inputId) : null
  }

  // "Show all schools" from the no results message: the same reset as clearing
  // the search, but focus moves to the list because the button itself is about
  // to be hidden.
  restoreAll () {
    this.reset()
    this.visibleSchools()[0]?.focus()
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

  filter (query) {
    this.query = (query || '').trim()
    this.expanded = false

    this.render()
    this.announce()
  }

  reset () {
    const input = this.input()
    if (input) {
      input.value = ''
      // The autocomplete keeps its own copy of the query and re-renders from it,
      // so tell it the field changed rather than only clearing the DOM node.
      input.dispatchEvent(new Event('input', { bubbles: true }))
    }
    if (this.selectEl) this.selectEl.value = ''

    this.query = ''
    this.expanded = false

    this.render()

    if (this.hasStatusTarget) this.statusTarget.textContent = ''
  }

  render () {
    const matching = this.matchingSchools()
    const shown = new Set(this.collapsing() ? matching.slice(0, this.visibleValue) : matching)

    this.schoolTargets.forEach(checkbox => this.setRowHidden(checkbox, !shown.has(checkbox)))

    if (this.hasShowAllTarget) {
      this.showAllTarget.hidden = !(this.collapsing() && matching.length > this.visibleValue)
    }

    if (this.hasNoResultsTarget) {
      this.noResultsTarget.hidden = !(this.searching() && matching.length === 0)
    }

    // Select all takes in every school, including the ones a search has filtered
    // out of view, so hide it while searching rather than leave it offering to
    // do something wider than what is on screen. It stays in the DOM, so it goes
    // on tracking the boxes ticked while filtered and is right when it returns.
    this.bulkSelectTargets.forEach(element => this.setHidden(element, this.searching()))

    this.matchCount = matching.length
  }

  announce () {
    if (!this.hasStatusTarget) return

    const { resultsNone, resultsOne, resultsOther } = this.statusTarget.dataset

    this.statusTarget.textContent = this.matchCount === 0
      ? resultsNone
      : (this.matchCount === 1 ? resultsOne : resultsOther.replace('{count}', this.matchCount))
  }

  matchingSchools () {
    if (!this.searching()) return this.schoolTargets

    const values = new Set(matchingValues(this.query, this.options))

    return this.schoolTargets.filter(checkbox => values.has(checkbox.value))
  }

  visibleSchools () {
    return this.schoolTargets.filter(checkbox => !this.row(checkbox).hidden)
  }

  searching () {
    return this.query !== ''
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
