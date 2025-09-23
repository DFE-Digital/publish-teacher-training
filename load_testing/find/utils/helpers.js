import { URLSearchParams } from 'https://jslib.k6.io/url/1.0.0/index.js'

export function buildFindSearchParams (params) {
  const searchParams = new URLSearchParams()

  if (params.subjects) {
    params.subjects.forEach(subject => {
      searchParams.append('subjects[]', subject)
    })
  }

  if (params.study_types) {
    params.study_types.forEach(type => {
      searchParams.append('study_types[]', type)
    })
  }

  if (params.location) {
    searchParams.append('location', params.location)
  }

  if (params.radius) {
    searchParams.append('radius', params.radius)
  }

  if (params.order) {
    searchParams.append('order', params.order)
  }

  if (params.page) {
    searchParams.append('page', params.page)
  }

  if (params.visa_sponsorship) {
    searchParams.append('can_sponsor_visa', 'true')
  }

  if (params.qualifications) {
    params.qualifications.forEach(qual => {
      searchParams.append('qualifications[]', qual)
    })
  }

  if (params.funding_types) {
    params.funding_types.forEach(type => {
      searchParams.append('funding_types[]', type)
    })
  }

  searchParams.append('utm_source', 'load_test')
  searchParams.append('utm_medium', 'k6_testing')

  return searchParams.toString()
}

export function extractFindCourseLinks (htmlBody) {
  // Extract course links specific to Find service format
  const linkRegex = /href="(\/course\/[^"]+)"/g
  const links = []
  let match

  while ((match = linkRegex.exec(htmlBody)) !== null) {
    links.push(match[1])
  }

  return links
}

export function findRandomThinkTime (min = 1, max = 5) {
  return Math.random() * (max - min) + min
}
