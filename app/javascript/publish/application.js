// Entry point for the build script in your package.json

import "core-js/stable"
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import autocompleteSetup from './autocomplete'
import FilterToggle from './filters'

window.jQuery = jQuery
window.$ = jQuery

initAll()
FilterToggle.init()

autocompleteSetup()
