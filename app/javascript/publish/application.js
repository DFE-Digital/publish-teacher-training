// Entry point for the build script in your package.json
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import autocompleteSetup from './autocomplete'
import initLocationsMap from './locations-map'
import FilterToggle from './filters'

import { Application } from '@hotwired/stimulus'
import InputPreviewController from './courses/input_preview_controller'

window.jQuery = jQuery
window.$ = jQuery
window.initLocationsMap = initLocationsMap

initAll()
FilterToggle.init()

autocompleteSetup()

window.Stimulus = Application.start()
Stimulus.register('input-preview', InputPreviewController)
