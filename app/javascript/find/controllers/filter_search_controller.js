import { Controller } from '@hotwired/stimulus'
import Mustache from 'mustache'

// Connects to data-controller="filter-search"
export default class extends Controller {
  static targets = ['optionsList', 'searchInputContainer', 'legend', 'template', 'searchInput']

  static instanceCounter = 0

  connect () {
    const legend = this.element.querySelector('legend')
    legend.dataset.filterSearchTarget = 'legend'

    // Assign a unique ID for input/label association
    this.instanceId = this.constructor.instanceCounter++

    const template = this.templateTarget.innerHTML
    const html = Mustache.render(template, {
      id: `${this.identifier}-${this.instanceId}-input`,
      label: this.legendTarget.innerText
    })

    this.searchInputContainerTarget.innerHTML = html
  }

  search () {
    const optionItems = this.optionsListTargets
    const searchValue = this.searchInputTarget.value.toLowerCase()

    this.toggleItems(optionItems, searchValue)
  }

  toggleItems (items, searchValue) {
    Array.from(items).forEach(item => {
      item.style.display = item.textContent.toLowerCase().includes(searchValue) ? '' : 'none'
    })
  }
}
