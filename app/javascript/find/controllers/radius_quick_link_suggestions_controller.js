import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    search: String,
    subjectName: String
  }

  static targets = ['container', 'heading']

  connect () {
    this.containerTarget.innerHTML = '<p class="govuk-body">Loading suggestions...</p>'

    let search = {}

    try {
      search = JSON.parse(this.searchValue)
    } catch (e) {
      console.error('Failed to parse searchValue', e)
    }

    const params = new URLSearchParams()

    Object.entries(search).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((v) => params.append(`${key}[]`, v))
      } else if (value !== null && value !== undefined) {
        params.append(key, value)
      }
    })

    fetch(`/api/radius_quick_link_suggestions?${params.toString()}`)
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok')
        return response.json()
      })
      .then(data => {
        this.renderLinks(data)
      })
      .catch(error => {
        console.error('Fetch error:', error)
        this.containerTarget.innerHTML = ''
      })
  }

  renderLinks (links) {
    if (!links.length) {
      this.containerTarget.innerHTML = ''
      this.headingTarget.innerHTML = ''
      return
    }

    const subjectName = this.subjectNameValue
    const headingText = subjectName
      ? `Try browsing for '${subjectName}' in a wider location search`
      : 'Try browsing with a wider location search'

    this.headingTarget.innerHTML = `<h3 class="govuk-heading-m">${headingText}</h3>`

    const listItems = links.map(link =>
      `<li class="govuk-list govuk-list--bullet"><a href="${link.url}" class="govuk-link">${link.text}</a></li>`
    ).join('')

    this.containerTarget.innerHTML = `
      <ul class="govuk-list govuk-list--bullet">
        ${listItems}
      </ul>
    `
  }
}
