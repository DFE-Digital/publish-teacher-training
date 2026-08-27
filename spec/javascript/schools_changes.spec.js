import { describe, it, expect } from 'vitest'
import { schoolChanges } from '../../app/javascript/publish/schools_changes'

// The shape schoolsFromCheckboxes builds out of the checkbox rows.
const school = (value, name, checked = false) => ({ value, name, checked })

const ASH = school('1', 'Ash Academy')
const BEECH = school('2', 'Beech School')
const CEDAR = school('3', 'Cedar School')

// Ash and Beech are on the course; Cedar is not.
const ATTACHED = ['1', '2']

const changes = (...schools) => schoolChanges(schools, ATTACHED)

describe('schoolChanges', () => {
  it('reports nothing when the ticks match what is attached', () => {
    const result = changes({ ...ASH, checked: true }, { ...BEECH, checked: true }, CEDAR)

    expect(result.changed).toBe(false)
    expect(result.adding.names).toEqual([])
    expect(result.removing.names).toEqual([])
  })

  it('names a school ticked that was not attached', () => {
    const result = changes({ ...ASH, checked: true }, { ...BEECH, checked: true }, { ...CEDAR, checked: true })

    expect(result.changed).toBe(true)
    expect(result.adding.names).toEqual(['Cedar School'])
  })

  it('names an attached school no longer ticked', () => {
    const result = changes(ASH, { ...BEECH, checked: true }, CEDAR)

    expect(result.removing.names).toEqual(['Ash Academy'])
  })

  it('reports both halves at once', () => {
    const result = changes(ASH, { ...BEECH, checked: true }, { ...CEDAR, checked: true })

    expect(result.adding.names).toEqual(['Cedar School'])
    expect(result.removing.names).toEqual(['Ash Academy'])
  })

  it('keeps the order the schools were given in', () => {
    const result = changes(ASH, BEECH, CEDAR)

    expect(result.removing.names).toEqual(['Ash Academy', 'Beech School'])
  })

  // The end state decides, not which control got there.
  it('says all when every school ends up ticked', () => {
    const result = changes({ ...ASH, checked: true }, { ...BEECH, checked: true }, { ...CEDAR, checked: true })

    expect(result.adding.all).toBe(true)
    expect(result.removing.all).toBe(false)
  })

  it('says all when no school is left ticked', () => {
    const result = changes(ASH, BEECH, CEDAR)

    expect(result.removing.all).toBe(true)
    expect(result.adding.all).toBe(false)
  })

  it('does not say all for a partial selection', () => {
    const result = changes({ ...ASH, checked: true }, BEECH, CEDAR)

    expect(result.adding.all).toBe(false)
    expect(result.removing.all).toBe(false)
  })

  it('treats a course with nothing attached as adding only', () => {
    const result = schoolChanges([{ ...CEDAR, checked: true }, ASH], [])

    expect(result.adding.names).toEqual(['Cedar School'])
    expect(result.removing.names).toEqual([])
  })

  it('reports nothing for an empty list', () => {
    expect(schoolChanges([], []).changed).toBe(false)
  })
})
