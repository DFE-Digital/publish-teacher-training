// Entry point for the build script in your package.json
import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import { FilterToggleButton } from './filter-toggle-button'
import initAutocomplete from './autocomplete'

import { Application } from '@hotwired/stimulus'
import FilterSearchController from './controllers/filter_search_controller'
import SubjectsAutocompleteController from './controllers/subjects_autocomplete_controller'
import ProvidersAutocompleteController from './controllers/providers_autocomplete_controller'
import ProviderAutocompleteController from './controllers/provider_autocomplete_controller'
import RemoteAutocompleteController from './controllers/remote_autocomplete_controller'
import LocationsAutocompleteController from './controllers/locations_autocomplete_controller'

window.Stimulus = Application.start()
Stimulus.register('filter-search', FilterSearchController)
Stimulus.register('subjects-autocomplete', SubjectsAutocompleteController)
Stimulus.register('remote-autocomplete', RemoteAutocompleteController)
Stimulus.register('locations-autocomplete', LocationsAutocompleteController)

// V1
Stimulus.register('providers-autocomplete', ProvidersAutocompleteController)

// V2
Stimulus.register('v2-provider-autocomplete', ProviderAutocompleteController)

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
  startHidden: true,
  toggleButton: {
    container: $('.app-filter-toggle'),
    showText: 'Filter results',
    hideText: 'Hide filters',
    classes: 'govuk-button--secondary govuk-!-font-weight-bold'
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
