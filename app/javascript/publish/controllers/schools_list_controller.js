import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete/src/wrapper'
import { optionsFromSelect, searchResults } from '../schools_search'

const MIN_QUERY_LENGTH = 3
const MAX_SUGGESTIONS = 5

// GOV.UK sets `display: flex` on `.govuk-checkboxes__item`, which overrides the
// `[hidden]` user-agent rule, so we hide rows with the `!important` display
// utility class as well as the `hidden` attribute.
const HIDDEN_CLASS = 'govuk-!-display-none'

// Owns which schools in a checkbox list are on screen, and the search box above
// it that decides.
//
// Two rules decide what is shown. A search narrows the list to the schools it
// found, and the collapse threshold then decides how many of those to show. They
// interact, since a search suspends the collapse so every result is visible, so
// neither writes to the rows itself: both feed `render`, the only place
// visibility is set.
//
// Whether a search is running and what it found are held apart, in `searching`
// and `searchResults`, because they answer different questions: a search that
// found nothing still hides select all and suspends the collapse.
//
// Rows are only ever hidden, never removed, so a school that is ticked and then
// filtered or collapsed out of view is still submitted.
//
// Pages without a search panel never enhance one, and this stays what it has
// always been: the collapsing list.
export default class extends Controller {
  static targets = [
    'schoolCheckbox', 'showAll', 'bulkSelect',
    'panel', 'autocomplete', 'status', 'noResults'
  ]

  static values = { collapseAfter: { type: Number, default: 20 } }

  connect () {
    this.clear()

    if (this.hasAutocompleteTarget) this.enhanceSearch()
  }

  disconnect () {
    this.instance?.destroy()
  }

  enhanceSearch () {
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

    this.panelTarget.hidden = false
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

  // The box sits inside the form that saves the schools, so Enter in it has to
  // be caught here or it would submit that form. With the menu open the key
  // belongs to the autocomplete, which has already confirmed the highlighted
  // suggestion by the time this fires; otherwise it searches, as it would in any
  // other search box.
  //
  // Only Enter in the box. The panel's own buttons are inside this element too,
  // and preventing their default is what stops a keydown becoming a click, so an
  // unscoped handler would leave them unusable from the keyboard.
  keydown (event) {
    if (event.key !== 'Enter' || event.target !== this.input()) return

    event.preventDefault()

    if (event.target.getAttribute('aria-expanded') !== 'true') this.search()
  }

  search () {
    const query = (this.input()?.value || '').trim()

    // An empty box is no search at all, which is the state clearing it leaves
    // behind. Matching on the empty query instead would allow every school while
    // still counting as a search, suspending the collapse and hiding select all.
    if (query === '') return this.clearSearch()

    const results = searchResults(query, this.options)

    this.noResultsTarget.hidden = results.length > 0

    this.searching = true
    this.searchResults = new Set(results)
    this.expanded = false

    this.render()
    this.announce(results.length)
  }

  clearSearch () {
    this.reset()
    this.clear()
    this.input()?.focus()
  }

  // "Show all schools" from the no results message. The same as clearing the
  // search, except the button is about to hide itself, so focus has to move to
  // the first row instead of back into the box.
  showAllSchools () {
    this.reset()
    this.clear()
    this.schoolCheckboxTargets.find(checkbox => !this.row(checkbox).hidden)?.focus()
  }

  reset () {
    const input = this.input()

    if (input) {
      input.value = ''
      // The autocomplete keeps its own copy of the query and re-renders from it,
      // so tell it the field changed rather than only clearing the DOM node.
      input.dispatchEvent(new Event('input', { bubbles: true }))
    }

    this.selectEl.value = ''
    this.noResultsTarget.hidden = true
    this.statusTarget.textContent = ''
  }

  announce (count) {
    const { resultsNone, resultsOne, resultsOther } = this.statusTarget.dataset

    this.statusTarget.textContent = count === 0
      ? resultsNone
      : (count === 1 ? resultsOne : resultsOther.replaceAll('{count}', count))
  }

  input () {
    return document.getElementById(this.inputId)
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
