import { Controller } from '@hotwired/stimulus'
import Mustache from 'mustache'

export default class extends Controller {
  static values = {
    search: String,
    subjectName: String
  }

  static targets = ['container', 'loadingTemplate', 'contentTemplate']

  connect () {
    this.renderLoading()

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
      .then(data => this.renderLinks(data))
      .catch(error => {
        console.error('Fetch error:', error)
        this.containerTarget.innerHTML = ''
      })
  }

  renderLoading () {
    this.containerTarget.innerHTML = Mustache.render(
      this.loadingTemplateTarget.innerHTML,
      {}
    )
  }

  renderLinks (links) {
    if (!links.length) {
      this.containerTarget.innerHTML = ''
      return
    }

    this.containerTarget.innerHTML = Mustache.render(
      this.contentTemplateTarget.innerHTML,
      {
        subjectName: this.subjectNameValue,
        links
      }
    )
  }
}
