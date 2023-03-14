const stopWords = ['the', 'of', 'in', 'and', 'at', '&', 'with']

const removeStopWords = (text) => {
  const isAllStopWords = text.trim().split(' ').every((word) => stopWords.includes(word))

  // We don't want to filter out stops words too early.
  // For example, the user could start off typing "the the"
  // with the intention of entering "the theatre".
  if (isAllStopWords) {
    return text
  }

  const regex = new RegExp(stopWords.map(word => `(\\s+)?${word}(\\s+)?`).join('|'), 'gi')
  return text.replace(regex, ' ').trim()
}

export default removeStopWords
