// Entry point for the build script in your package.json
import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import { FilterToggleButton } from './filter-toggle-button'
import initAutocomplete from './autocomplete'
import dfeAutocomplete from './dfe-autocomplete'
import CookieBanner from '../cookie_banner'
import '@hotwired/turbo-rails'

// eslint-disable-next-line no-undef
Turbo.session.drive = false

window.jQuery = jQuery
window.$ = jQuery

initAll()

dfeAutocomplete({ rawAttribute: false, confirmOnBlur: false })

CookieBanner.init()

initAutocomplete({
  element: 'location-autocomplete',
  input: 'location',
  path: '/location-suggestions'
})

initAutocomplete({
  element: 'location-autocomplete',
  input: 'pre_filter_lq',
  path: '/location-suggestions'
})

const filterToggleButton = new FilterToggleButton({
  bigModeMediaQuery: '(min-width: 48.063em)',
  startHidden: false,
  toggleButton: {
    container: $('.app-filter-toggle'),
    showText: 'Show filters',
    hideText: 'Hide filters',
    classes: 'govuk-button--secondary secondary-button-filter'
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
