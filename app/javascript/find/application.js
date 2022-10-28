// Entry point for the build script in your package.json
import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import setupAutocomplete from './setup-autocomplete'
import { FilterToggleButton } from './filter-toggle-button'

window.jQuery = jQuery
window.$ = jQuery

initAll()
setupAutocomplete('find-courses-by-location-or-training-provider-form-school-uni-or-provider-query-field')

const filterToggleButton = new FilterToggleButton({
  bigModeMediaQuery: '(min-width: 48.063em)',
  startHidden: false,
  toggleButton: {
    container: $('.app-filter-toggle'),
    showText: 'Show filters',
    hideText: 'Hide filters',
    classes: 'govuk-button--secondary'
  },
  closeButton: {
    container: $('.app-filter__header'),
    text: 'Close'
  },
  filter: {
    container: $('.app-filter-layout__filter')
  }
})

filterToggleButton.init()
