// Entry point for the build script in your package.json

import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import autocompleteSetup from './autocomplete'
import initLocationsMap from './locations-map'
import FilterToggle from './filters'

window.jQuery = jQuery
window.$ = jQuery
window.initLocationsMap = initLocationsMap

initAll()
FilterToggle.init()

autocompleteSetup()
