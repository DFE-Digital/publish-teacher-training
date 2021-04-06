import './style.scss'
import $ from 'jquery'
import { FilterToggleButton } from 'moj/all.js'

const prepareFilterToggle = () => {
  const filterContainer = $('.moj-filter-layout__filter')

  if (filterContainer.length) {
    /* eslint-disable no-new */
    new FilterToggleButton({
      bigModeMediaQuery: '(min-width: 48.063em)',
      startHidden: false,
      toggleButton: {
        container: $('.moj-action-bar__filter'),
        showText: 'Show filters',
        hideText: 'Hide filters',
        classes: 'govuk-button--secondary'
      },
      closeButton: {
        container: $('.moj-filter__header-action'),
        text: 'Close'
      },
      filter: {
        container: filterContainer
      }
    })
  }
}

prepareFilterToggle()
