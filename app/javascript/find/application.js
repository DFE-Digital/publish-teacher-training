// Entry point for the build script in your package.json
import { initAll } from 'govuk-frontend'
import { initCrossServiceHeader } from 'govuk-one-login/service-header'

import { Application } from '@hotwired/stimulus'
import FilterSearchController from './controllers/filter_search_controller'
import SaveCourseController from './controllers/save_course_controller.js'
import SubjectsAutocompleteController from './controllers/subjects_autocomplete_controller'
import ProviderAutocompleteController from './controllers/provider_autocomplete_controller'
import RadiusQuickLinkSuggestionsController from './controllers/radius_quick_link_suggestions_controller'
import RemoteAutocompleteController from './controllers/remote_autocomplete_controller'
import LocationsAutocompleteController from './controllers/locations_autocomplete_controller'
import VisibilityController from './controllers/visibility_controller'
import DetailsComponentController from './controllers/details_component_controller'

document.body.className +=
  ' js-enabled' +
  ('noModule' in HTMLScriptElement.prototype
    ? ' govuk-frontend-supported'
    : '')

window.Stimulus = Application.start()

Stimulus.register('filter-search', FilterSearchController)
Stimulus.register('save-course', SaveCourseController)
Stimulus.register('subjects-autocomplete', SubjectsAutocompleteController)
Stimulus.register('remote-autocomplete', RemoteAutocompleteController)
Stimulus.register('locations-autocomplete', LocationsAutocompleteController)
Stimulus.register('visibility', VisibilityController)
Stimulus.register('details-component', DetailsComponentController)
Stimulus.register('provider-autocomplete', ProviderAutocompleteController)
Stimulus.register(
  'radius-quick-link-suggestions',
  RadiusQuickLinkSuggestionsController
)

initAll()
initCrossServiceHeader()
