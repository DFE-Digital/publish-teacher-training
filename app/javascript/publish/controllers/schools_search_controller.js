import { Controller } from '@hotwired/stimulus'
import { dfeAutocompleteField } from 'dfe-autocomplete/src/wrapper'
import { matchingValues, optionsFromSelect } from '../schools_search'

const MIN_QUERY_LENGTH = 3
const MAX_SUGGESTIONS = 5

// The search box above a list of school checkboxes.
//
// It never touches a row. It works out which schools the provider asked for and
// says so, leaving the list to decide what that means on screen:
//
//   schools-search:filter   detail.allowed - the uuids to show, or null for all
//   schools-search:restore  no filter, and put focus back in the list
//
// Everything else here - the autocomplete, the Enter key, the announcement, the
// no results message - belongs to this half alone.
export default class extends Controller {
  static targets = ['panel', 'autocomplete', 'status', 'noResults']

  connect () {
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
    this.element.addEventListener('keydown', (event) => {
      if (event.key !== 'Enter') return

      event.preventDefault()

      if (this.input()?.getAttribute('aria-expanded') !== 'true') this.search()
    })

    this.panelTarget.hidden = false
  }

  disconnect () {
    this.instance?.destroy()
  }

  search () {
    const query = (this.input()?.value || '').trim()

    if (query === '') return this.clear()

    const allowed = matchingValues(query, this.options)

    this.noResultsTarget.hidden = allowed.length > 0
    this.dispatch('filter', { detail: { allowed } })
    this.announce(allowed.length)
  }

  clearSearch () {
    this.reset()
    this.dispatch('filter', { detail: { allowed: null } })
    this.input()?.focus()
  }

  // "Show all schools" from the no results message. The same as clearing the
  // search, except the button is about to hide itself, so focus has to move -
  // and only the list knows where its first row is.
  showAllSchools () {
    this.reset()
    this.dispatch('restore')
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
      : (count === 1 ? resultsOne : resultsOther.replace('{count}', count))
  }

  input () {
    return document.getElementById(this.inputId)
  }
}
