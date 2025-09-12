const findSubjects = [
  'G1', // Mathematics
  'C1', // Biology
  'F1', // Chemistry
  'F3', // Physics
  'Q3', // English
  'V1', // History
  'L1', // Geography
  'W3', // Design and technology
  '06', // Physical education
  '00', // Primary
  'DT', // Design and technology
  '14', // Art and design
  '11', // Religious education
  'F0', // Science
  'W1', // Modern Languages
  '13' // Music
]

const findLocations = [
  'London, UK',
  'Birmingham, UK',
  'Manchester, UK',
  'Leeds, UK',
  'Liverpool, UK',
  'Sheffield, UK',
  'Bristol, UK',
  'Newcastle, UK',
  'Nottingham, UK',
  'Leicester, UK'
]

const findProviders = [
  'University College London',
  'King\'s College London',
  'Birmingham City University',
  'Manchester Metropolitan University',
  'Leeds Beckett University'
]

export function getRandomSubject () {
  return findSubjects[Math.floor(Math.random() * findSubjects.length)]
}

export function getRandomLocation () {
  return findLocations[Math.floor(Math.random() * findLocations.length)]
}

export function getRandomProvider () {
  return findProviders[Math.floor(Math.random() * findProviders.length)]
}

export function getFindSubjects () {
  return findSubjects
}

export function getFindLocations () {
  return findLocations
}

export function getFindProviders () {
  return findProviders
}
