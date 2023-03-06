import removeStopWords from './stop_words'

const exactMatch = (word, query) => (word === query)

const startsWithRegExp = (query) => new RegExp('\\b' + query, 'i')
const startsWith = (word, query) => (word.search(startsWithRegExp(query)) === 0)

const wordsStartsWithQuery = (word, regExps) => regExps.every((regExp) => (word.search(regExp) >= 0))

const anyMatch = (words, query, evaluatorFunc) => words.some((word) => evaluatorFunc(word, query))
const synonymsExactMatch = (synonyms, query) => anyMatch(synonyms, query, exactMatch)
const synonymsStartsWith = (synonyms, query) => anyMatch(synonyms, query, startsWith)

const wordInSynonymStartsWithQuery = (synonyms, startsWithQueryWordsRegexes) =>
  anyMatch(synonyms, startsWithQueryWordsRegexes, wordsStartsWithQuery)

// NOTE: Determines how the query matches either an option's name/synonyms.
// Returns an integer ranging from 0 (no match) to 100 (exact match).
const calculateWeight = ({ name, synonyms, nameWithoutStopWords, synonymsWithoutStopWords }, query) => {
  const queryWithoutStopWords = removeStopWords(query)

  if (exactMatch(name, query)) return 100
  if (exactMatch(nameWithoutStopWords, queryWithoutStopWords)) return 95

  if (synonymsExactMatch(synonyms, query)) return 75
  if (synonymsExactMatch(synonymsWithoutStopWords, queryWithoutStopWords)) return 70

  if (startsWith(name, query)) return 60
  if (startsWith(nameWithoutStopWords, queryWithoutStopWords)) return 55

  if (synonymsStartsWith(synonyms, query)) return 50
  if (synonymsStartsWith(synonyms, queryWithoutStopWords)) return 40

  const startsWithRegExps = queryWithoutStopWords.split(/\s+/).map(startsWithRegExp)

  if (wordsStartsWithQuery(nameWithoutStopWords, startsWithRegExps)) return 25
  if (wordInSynonymStartsWithQuery(synonymsWithoutStopWords, startsWithRegExps)) return 10

  return 0
}

export {
  exactMatch,
  startsWithRegExp,
  startsWith,
  wordsStartsWithQuery,
  synonymsExactMatch,
  synonymsStartsWith,
  wordInSynonymStartsWithQuery
}

export default calculateWeight
