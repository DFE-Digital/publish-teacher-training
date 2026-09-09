import { FilterToggleButton } from '@ministryofjustice/frontend'

export default class FilterToggle {
  static init () {
    const filterContainer = document.querySelector('.moj-filter-layout__filter')

    if (filterContainer) {
      return new FilterToggleButton(filterContainer, {
        bigModeMediaQuery: '(min-width: 48.063em)',
        startHidden: false,
        toggleButton: {
          showText: 'Show filters',
          hideText: 'Hide filters',
          classes: 'govuk-button--secondary'
        },
        toggleButtonContainer: {
          selector: '.moj-action-bar__filter'
        },
        closeButton: {
          text: 'Close'
        },
        closeButtonContainer: {
          selector: '.moj-filter__header-action'
        }
      })
    }
  }
}
