export function randomThinkTime (min = 1, max = 5) {
  return Math.random() * (max - min) + min
}

export function getTimestamp () {
  return new Date().toISOString()
}

export function logTestEvent (message, data = {}) {
  console.log(`[${getTimestamp()}] ${message}`, JSON.stringify(data))
}
