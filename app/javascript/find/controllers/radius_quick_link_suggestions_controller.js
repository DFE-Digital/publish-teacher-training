// app/javascript/controllers/radius_quick_link_suggestions_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    search: String
  }

  static targets = ['container']

  connect () {
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
      })
  }

  renderLinks (links) {
    if (!links.length) return

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
