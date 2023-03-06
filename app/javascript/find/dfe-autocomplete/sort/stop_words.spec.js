import removeStopWords from './stop_words'

describe('removeStopWords', () => {
  describe('text with multiple stop words', () => {
    it('removes all stop words', () => {
      expect(removeStopWords('the university of southampton')).toEqual('university southampton')
    })
  })

  describe('text has only one stop word', () => {
    it("doesn't remove it", () => {
      expect(removeStopWords('the')).toEqual('the')
    })
  })

  describe('all words are stop words', () => {
    it("doesn't remove any", () => {
      expect(removeStopWords('the and')).toEqual('the and')
    })
  })

  describe('last character has the potential to be a stop word', () => {
    it('is kept in the text', () => {
      expect(removeStopWords('bachelor o')).toEqual('bachelor o')
    })
  })
})
