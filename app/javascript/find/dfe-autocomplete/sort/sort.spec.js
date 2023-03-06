import sort, {
  addWeightWithBoost,
  cleanseOption,
  hasWeight,
  byWeightThenAlphabetically,
  optionName
} from './'

describe('sort', () => {
  it('returns an empty array for no matches', () => {
    const options = [{ name: 'flower' }]
    expect(sort('cat', options)).toEqual([])
  })

  it('sorts alphabetically if weights are equal', () => {
    const options = [
      { name: 'flower a' },
      { name: 'flower b' }
    ]
    expect(sort('flower', options)).toEqual(['flower a', 'flower b'])
  })

  it('prioritises exact name matches over synyonm matches', () => {
    const options = [
      { name: 'flower' },
      { name: 'rose', synonyms: ['flower'] }
    ]
    expect(sort('flower', options)).toEqual(['flower', 'rose'])
  })

  it('prioritises exact synonym matches over name starts with', () => {
    const options = [
      { name: 'pretty flower' },
      { name: 'cat', synonyms: ['pretty'] }
    ]

    expect(sort('pretty', options)).toEqual(['cat', 'pretty flower'])
  })

  it('prioritises name starts with over synonym starts with', () => {
    const options = [
      { name: 'plant', synonyms: ['flower'] },
      { name: 'flower' }
    ]
    expect(sort('flo', options)).toEqual(['flower', 'plant'])
  })

  it('prioritises synonym starts with over word in name starts with', () => {
    const options = [
      { name: 'pretty flower' },
      { name: 'plant', synonyms: ['flower'] }
    ]
    expect(sort('flo', options)).toEqual(['plant', 'pretty flower'])
  })

  it('prioritises word in name starts with over word in synonym starts with', () => {
    const options = [
      { name: 'the pretty flower' },
      { name: 'pretty the flower' },
      { name: 'rose', synonyms: ['pretty the flower'] },
      { name: 'lily', synonyms: ['the flower pretty'] }
    ]
    expect(sort('the pre', options)).toEqual(['the pretty flower', 'pretty the flower', 'rose', 'lily'])
    expect(sort('the pretty', options)).toEqual(['the pretty flower', 'pretty the flower', 'rose', 'lily'])
    expect(sort('the pretty flo', options)).toEqual(['the pretty flower', 'pretty the flower', 'lily', 'rose'])
  })

  it('requires all parts of the query to be matched in either name or synonym', () => {
    const options = [
      { name: 'flower', synonyms: [] },
      { name: 'cat', synonyms: ['pretty'] },
      { name: 'tulip', synonyms: ['pretty flower'] },
      { name: 'rose', synonyms: ['pretty flower', 'gesture'] }
    ]

    expect(sort('pretty flower', options)).toEqual(['rose', 'tulip'])
  })

  it('allows custom boosting of results', () => {
    const options = [
      { name: 'plant a' },
      { name: 'plant b', boost: 2 }
    ]
    expect(sort('plant', options)).toEqual(['plant b', 'plant a'])
  })

  it('can handle multiple synonyms - must match all parts', () => {
    const options = [
      { name: 'plant a', synonyms: ['flower thing', 'leaf'] },
      { name: 'plant b', synonyms: ['nice bear', 'rose plant'] }
    ]
    // Doesn't search across synonyms
    expect(sort('leaf flower', options)).toEqual([])
    // Doesn't count partial matches in separate synonyms
    expect(sort('rose bear', options)).toEqual([])
    // Returns correct match
    expect(sort('flower thi', options)).toEqual(['plant a'])
  })

  it('can handle query with extra punctuation', () => {
    const options = [
      { name: 'plants' }
    ]
    expect(sort('plant’s', options)).toEqual(['plants'])
    expect(sort('(plants)', options)).toEqual(['plants'])
  })

  it('can handle query with missing punctuation', () => {
    const options = [
      { name: "plant's leaf" },
      { name: 'flower', synonyms: ["plant's leaf"] },
      { name: 'flower/rose' }
    ]
    expect(sort('plants leaf', options)).toEqual(["plant's leaf", 'flower'])
    expect(sort('flower rose', options)).toEqual(['flower/rose'])
  })
})

describe('addWeightWithBoost', () => {
  it('returns options with weight', () => {
    expect(addWeightWithBoost({
      name: 'abc',
      clean: {
        name: 'abc',
        synonyms: [],
        boost: 1
      }
    }, 'abc')).toEqual({
      name: 'abc',
      clean: {
        name: 'abc',
        synonyms: [],
        boost: 1
      },
      weight: 100
    })
  })

  it('returns options with weight with boost', () => {
    expect(addWeightWithBoost({
      name: 'abc',
      clean: {
        name: 'abc',
        synonyms: [],
        boost: 10
      }
    }, 'abc')).toEqual({
      name: 'abc',
      clean: {
        name: 'abc',
        synonyms: [],
        boost: 10
      },
      weight: 1000
    })
  })
})

describe('cleanseOption', () => {
  it('returns default clean values', () => {
    expect(cleanseOption({
      name: 'abc'
    })).toEqual({
      name: 'abc',
      clean: {
        name: 'abc',
        nameWithoutStopWords: 'abc',
        synonyms: [],
        synonymsWithoutStopWords: [],
        boost: 1
      }
    })
  })

  it('returns cleanse values', () => {
    expect(cleanseOption({
      name: 'aBc',
      synonyms: ['xyZ'],
      boost: 2
    })).toEqual({
      name: 'aBc',
      synonyms: ['xyZ'],
      boost: 2,
      clean: {
        name: 'abc',
        nameWithoutStopWords: 'aBc',
        synonymsWithoutStopWords: ['xyz'],
        synonyms: ['xyz'],
        boost: 2
      }
    })
  })
})

describe('hasWeight', () => {
  it('returns false', () => {
    expect(hasWeight({ weight: 0 })).toEqual(false)
  })

  it('returns true', () => {
    expect(hasWeight({ weight: 1 })).toEqual(true)
  })
})

describe('byWeightThenAlphabetically', () => {
  it('returns -1', () => {
    expect(byWeightThenAlphabetically({ weight: 1 }, { weight: 0 })).toEqual(-1)
    expect(byWeightThenAlphabetically({ weight: 0, name: 'abc' }, { weight: 0, name: 'xzy' })).toEqual(-1)
  })

  it('returns 1', () => {
    expect(byWeightThenAlphabetically({ weight: 0 }, { weight: 1 })).toEqual(1)
    expect(byWeightThenAlphabetically({ weight: 0, name: 'xzy' }, { weight: 0, name: 'abc' })).toEqual(1)
  })

  it('returns 0', () => {
    expect(byWeightThenAlphabetically({ weight: 0, name: 'abc' }, { weight: 0, name: 'abc' })).toEqual(0)
  })
})

describe('optionName', () => {
  it('returns name', () => {
    expect(optionName({ name: 'abc' })).toEqual('abc')
  })
})
