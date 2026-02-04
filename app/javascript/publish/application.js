// Entry point for the build script in your package.json
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import autocompleteSetup from './autocomplete'
import FilterToggle from './filters'

import { Application } from '@hotwired/stimulus'
import InputPreviewController from './courses/input_preview_controller'
import SelectAllCheckboxesController from './controllers/select_all_checkboxes_controller'
import './copy_link'

window.jQuery = jQuery
window.$ = jQuery

initAll()
FilterToggle.init()

autocompleteSetup()

window.Stimulus = Application.start()
Stimulus.register('input-preview', InputPreviewController)
Stimulus.register('select-all-checkboxes', SelectAllCheckboxesController)
