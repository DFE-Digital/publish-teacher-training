// Entry point for the build script in your package.json
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import { Application } from '@hotwired/stimulus'
import FilterSearchController from './controllers/filter_search_controller'
import SubjectsAutocompleteController from './controllers/subjects_autocomplete_controller'
import ProviderAutocompleteController from './controllers/provider_autocomplete_controller'
import RemoteAutocompleteController from './controllers/remote_autocomplete_controller'
import LocationsAutocompleteController from './controllers/locations_autocomplete_controller'
import VisibilityController from './controllers/visibility_controller'

window.Stimulus = Application.start()

Stimulus.register('filter-search', FilterSearchController)
Stimulus.register('subjects-autocomplete', SubjectsAutocompleteController)
Stimulus.register('remote-autocomplete', RemoteAutocompleteController)
Stimulus.register('locations-autocomplete', LocationsAutocompleteController)
Stimulus.register('visibility', VisibilityController)
Stimulus.register('v2-provider-autocomplete', ProviderAutocompleteController)

window.jQuery = jQuery
window.$ = jQuery

initAll()
