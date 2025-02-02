// Entry point for the build script in your package.json
import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import { FilterToggleButton } from './filter-toggle-button'
import initAutocomplete from './autocomplete'

import { Application } from '@hotwired/stimulus'
import FilterSearchController from './controllers/filter_search_controller'
import SubjectsAutocompleteController from './controllers/subjects_autocomplete_controller'
import LocationsAutocompleteController from './controllers/locations_autocomplete_controller'
import ProvidersAutocompleteController from './controllers/providers_autocomplete_controller'

window.Stimulus = Application.start()
Stimulus.register('filter-search', FilterSearchController)
Stimulus.register('subjects-autocomplete', SubjectsAutocompleteController)
Stimulus.register('locations-autocomplete', LocationsAutocompleteController)
Stimulus.register('providers-autocomplete', ProvidersAutocompleteController)

window.jQuery = jQuery
window.$ = jQuery

initAll()

initAutocomplete({
  element: 'location-autocomplete',
  input: 'location',
  path: '/location-suggestions'
})

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
