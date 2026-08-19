import defaultSort from 'dfe-autocomplete/src/sort'
import { enhanceOption } from 'dfe-autocomplete/src/utils/options'

// Matching for the school search box.
//
// Both the suggestion dropdown and the checkbox list are ranked by
// dfe-autocomplete's own sort, so a search means the same thing in each: a
// query word has to start a word in the school's name or in one of its
// synonyms (its URN and its postcode, with and without the space).

// The option objects the sort works on, built from the search panel's <select>.
// The library's enhanceOption drops the option's value, which we need to pair a
// suggestion with its checkbox, so we put it back.
export function optionsFromSelect (selectEl) {
  return [...selectEl.options]
    .filter(option => option.value)
    .map(option => ({ ...enhanceOption(option), value: option.value }))
}

// dfe-autocomplete matches a word prefix by building `new RegExp('\\b' + query)`
// without escaping the query, and its own clean() blanks most punctuation but
// leaves these. Typing one of them therefore either throws a SyntaxError out of
// the sort - taking the whole search with it - or silently turns the query into
// an operator, as a pipe does when it reads as alternation and widens the
// search. Blank them the way clean() blanks the rest of the punctuation.
const REGEXP_PUNCTUATION = /[[\]\\|?+]/g

// The values of every option matching the query, most relevant first. A blank
// query matches everything, though the search box never asks: an empty box means
// no search rather than a search for all of them.
export function searchResults (query, options) {
  if (!/\S/.test(query)) return options.map(option => option.value)

  return defaultSort(query.replace(REGEXP_PUNCTUATION, ' '), options).map(option => option.value)
}
