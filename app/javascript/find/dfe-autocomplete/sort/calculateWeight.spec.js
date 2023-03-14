import calculateWeight, {
  exactMatch,
  startsWithRegExp,
  startsWith,
  wordsStartsWithQuery,
  synonymsExactMatch,
  synonymsStartsWith,
  wordInSynonymStartsWithQuery
} from './calculateWeight'

describe('calculateWeight', () => {
  const option = {
    name: 'ab cd',
    synonyms: ['abc ghi'],
    nameWithoutStopWords: 'ab cd',
    synonymsWithoutStopWords: ['abc ghi']
  }

  it('returns 100', () => {
    expect(calculateWeight(option, 'ab cd')).toEqual(100)
  })

  it('returns 95', () => {
    expect(calculateWeight(option, 'ab cd in')).toEqual(95)
  })

  it('returns 75', () => {
    expect(calculateWeight(option, 'abc ghi')).toEqual(75)
  })

  it('returns 70', () => {
    expect(calculateWeight(option, 'abc ghi and')).toEqual(70)
  })

  it('returns 60', () => {
    expect(calculateWeight(option, 'a')).toEqual(60)
    expect(calculateWeight(option, 'ab')).toEqual(60)
    expect(calculateWeight(option, 'ab c')).toEqual(60)
  })

  it('returns 50', () => {
    expect(calculateWeight(option, 'abc g')).toEqual(50)
    expect(calculateWeight(option, 'abc gh')).toEqual(50)
  })

  it('returns 25', () => {
    expect(calculateWeight(option, 'a c')).toEqual(25)
    expect(calculateWeight(option, 'a cd')).toEqual(25)
    expect(calculateWeight(option, 'cd a')).toEqual(25)
    expect(calculateWeight(option, 'cd ab')).toEqual(25)
    expect(calculateWeight(option, 'c ab')).toEqual(25)
  })

  it('returns 10', () => {
    expect(calculateWeight(option, 'a g')).toEqual(10)
    expect(calculateWeight(option, 'ab g')).toEqual(10)
    expect(calculateWeight(option, 'ab gh')).toEqual(10)
    expect(calculateWeight(option, 'ab ghi')).toEqual(10)

    expect(calculateWeight(option, 'g abc')).toEqual(10)
    expect(calculateWeight(option, 'gh abc')).toEqual(10)
    expect(calculateWeight(option, 'ghi abc')).toEqual(10)
  })

  it('returns 0', () => {
    expect(calculateWeight(option, 'abcd')).toEqual(0)
  })
})

describe('exactMatch', () => {
  it('returns false', () => {
    expect(exactMatch('abc', 'xyz')).toEqual(false)
  })

  it('returns true', () => {
    expect(exactMatch('abc', 'abc')).toEqual(true)
  })
})

describe('startsWithRegExp', () => {
  it('returns reg exp', () => {
    expect(startsWithRegExp('xyz')).toEqual(/\bxyz/i)
  })
})

describe('startsWith', () => {
  it('returns false', () => {
    expect(startsWith('abc', 'b')).toEqual(false)
  })

  it('returns true', () => {
    expect(startsWith('abc', 'a')).toEqual(true)
  })
})

describe('wordsStartsWithQuery', () => {
  it('returns false', () => {
    expect(wordsStartsWithQuery('abc', [/\bb/i])).toEqual(false)
  })

  it('returns true', () => {
    expect(wordsStartsWithQuery('abc', [/\ba/i])).toEqual(true)
  })
})

describe('synonymsExactMatch', () => {
  it('returns false', () => {
    expect(synonymsExactMatch(['abc', 'def'], 'xyz')).toEqual(false)
  })

  it('returns true', () => {
    expect(synonymsExactMatch(['abc', 'def'], 'abc')).toEqual(true)
  })
})

describe('synonymsStartsWith', () => {
  it('returns false', () => {
    expect(synonymsStartsWith(['abc', 'def'], 'b')).toEqual(false)
  })

  it('returns true', () => {
    expect(synonymsStartsWith(['abc', 'def'], 'a')).toEqual(true)
  })
})

describe('wordInSynonymStartsWithQuery', () => {
  it('returns false', () => {
    expect(wordInSynonymStartsWithQuery(['abc', 'def'], [/\bb/i])).toEqual(false)
  })

  it('returns true', () => {
    expect(wordInSynonymStartsWithQuery(['abc', 'def'], [/\ba/i])).toEqual(true)
  })
})
