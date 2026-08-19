import { describe, it, expect } from 'vitest'
import { searchResults } from '../../app/javascript/publish/schools_search'

// The shape optionsFromSelect builds out of the search panel's <select>:
// the school name, and its URN and postcodes as dfe-autocomplete synonyms.
const school = (value, name, synonyms = []) => ({ name, synonyms, boost: 1, value })

const BELVIDERE = school('1', 'Belvidere School', ['123456', 'SY2 5RJ', 'SY25RJ'])
const BISHOP = school('2', 'Bishop Hope School', ['654321', 'TF1 3FA', 'TF13FA'])
const ST_MARYS = school('3', "St Mary's C of E", ['111222', 'WV16 4ER', 'WV164ER'])

const SCHOOLS = [BELVIDERE, BISHOP, ST_MARYS]

const matches = (query) => searchResults(query, SCHOOLS)

describe('searchResults', () => {
  it('returns every school when the query is blank', () => {
    expect(matches('')).toEqual(['1', '2', '3'])
    expect(matches('   ')).toEqual(['1', '2', '3'])
  })

  it('matches the start of a school name', () => {
    expect(matches('belv')).toEqual(['1'])
  })

  it('ignores case', () => {
    expect(matches('BELVIDERE')).toEqual(['1'])
  })

  it('matches a word inside the name, not just the first one', () => {
    expect(matches('hope')).toEqual(['2'])
  })

  it('matches a URN', () => {
    expect(matches('123456')).toEqual(['1'])
  })

  it('matches a partial URN', () => {
    expect(matches('1234')).toEqual(['1'])
  })

  it('matches a postcode', () => {
    expect(matches('SY2 5RJ')).toEqual(['1'])
  })

  it('matches a postcode typed without its space', () => {
    expect(matches('sy25rj')).toEqual(['1'])
  })

  it('matches the second half of a postcode', () => {
    expect(matches('3fa')).toEqual(['2'])
  })

  it('ignores apostrophes', () => {
    expect(matches("st mary's")).toEqual(['3'])
    expect(matches('st marys')).toEqual(['3'])
  })

  it('returns nothing when no school matches', () => {
    expect(matches('zzzz')).toEqual([])
  })

  it('does not match on a term that is neither name, postcode nor URN', () => {
    expect(matches('shrewsbury')).toEqual([])
  })

  it('narrows rather than widens as words are added', () => {
    expect(matches('school')).toEqual(['1', '2'])
    expect(matches('bishop school')).toEqual(['2'])
  })

  // dfe-autocomplete builds a RegExp out of the query without escaping it, so
  // anything it leaves in that means something to a regex either throws or
  // quietly changes what the search means.
  describe('a query containing regular expression punctuation', () => {
    it('searches for a school name typed with a bracket', () => {
      expect(matches('belv[')).toEqual(['1'])
      expect(matches('belv]')).toEqual(['1'])
    })

    it('searches for a school name typed with a trailing backslash', () => {
      expect(matches('belv\\')).toEqual(['1'])
    })

    it('searches for a school name typed with a leading quantifier', () => {
      expect(matches('?belv')).toEqual(['1'])
      expect(matches('+belv')).toEqual(['1'])
    })

    it('does not read a pipe as alternation', () => {
      expect(matches('belvidere|bishop')).toEqual([])
    })

    // Blanking is what clean() already does to a full stop, and a query left
    // blank matches everything. The point here is only that a bracket now lands
    // in the same place a full stop always has, rather than throwing.
    it('treats punctuation on its own the way it treats a full stop', () => {
      expect(matches('[')).toEqual(matches('.'))
    })
  })
})
