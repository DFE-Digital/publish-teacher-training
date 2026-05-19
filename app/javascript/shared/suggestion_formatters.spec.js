import { describe, it, expect } from 'vitest'
import { FORMATTERS } from './suggestion_formatters'

describe('remote autocomplete suggestion FORMATTERS', () => {
  it('provider: appends the code to the name', () => {
    expect(FORMATTERS.provider({ name: 'Big School', code: 'A01' }))
      .toEqual({ name: 'Big School (A01)', code: 'A01' })
  })

  it('school: keeps the name and adds the town and postcode as append', () => {
    expect(FORMATTERS.school({ id: 1, name: "Enda's", town: 'Damonmouth', postcode: 'NW1 5WS' }))
      .toEqual({ id: 1, name: "Enda's", town: 'Damonmouth', postcode: 'NW1 5WS', append: '(Damonmouth, NW1 5WS)' })
  })

  it('accredited: builds the name from the provider name and code', () => {
    expect(FORMATTERS.accredited({ id: 2, provider_name: 'UCL', provider_code: 'U80' }))
      .toEqual({ id: 2, provider_name: 'UCL', provider_code: 'U80', name: 'UCL (U80)' })
  })

  it('location: wraps a plain string result', () => {
    expect(FORMATTERS.location('London')).toEqual({ name: 'London' })
  })

  it('location: passes an object result through unchanged', () => {
    expect(FORMATTERS.location({ name: 'London' })).toEqual({ name: 'London' })
  })
})
