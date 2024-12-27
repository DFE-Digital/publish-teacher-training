import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="filter-search"
export default class extends Controller {
  static targets = ['optionsList', 'searchInput', 'legend']

  static instanceCounter = 0

  connect () {
    const legend = this.element.querySelector('legend')
    legend.dataset.filterSearchTarget = 'legend'

    // This will be unique for each filter-search instance
    this.instanceId = this.constructor.instanceCounter++

    const searchInput = this.createSearchInput()
    this.optionsListTarget.before(searchInput)
  }

  createSearchInput () {
    const container = document.createElement('div')
    container.classList.add('filter-search__search')

    const inputId = `${this.identifier}-${this.instanceId}-input`
    const labelText = `${this.legendTarget.innerText}`

    container.innerHTML = `
      <label for="${inputId}" class="govuk-label govuk-visually-hidden">
        ${labelText}
      </label>
      <input type="search" id="${inputId}"
        class="govuk-input govuk-!-margin-bottom-1"
        autocomplete="off"
        placeholder="Search"
        data-action="input->${this.identifier}#search"
        data-filter-search-target="searchInput">
    `

    return container
  }

  search () {
    const optionItems = this.optionsListTarget.children
    const searchValue = this.searchInputTarget.value.toLowerCase()

    this.toggleItems(optionItems, searchValue)
  }

  toggleItems (items, searchValue) {
    Array.from(items).forEach(function (item) {
      if (item.textContent.toLowerCase().indexOf(searchValue) > -1) {
        item.style.display = ''
      } else {
        item.style.display = 'none'
      }
    })
  }
}
