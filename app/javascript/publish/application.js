// Entry point for the build script in your package.json

import 'babel-polyfill'
import jQuery from 'jquery'
import { initAll } from 'govuk-frontend'

import { initAutocomplete } from './autocomplete'
import initLocationsMap from './locations-map'
import FilterToggle from './filters'
import CookieBanner from '../cookie_banner'

window.jQuery = jQuery
window.$ = jQuery
window.initLocationsMap = initLocationsMap

initAll()
FilterToggle.init()
CookieBanner.init()

try {
  const autocomplete = document.getElementById('provider-autocomplete')
  const providerInput = document.getElementById('provider')
  const providerTemplate = (result) =>
    result && `${result.name} (${result.code})`

  const schoolAutocomplete = document.getElementById('school-autocomplete')
  const schoolInput = document.getElementById('publish-schools-search-form-query-field')
  const schoolTemplate = (result) => result && `${result.name}`
  const schoolSuggestions = (result) => result && `${result.name} (${result.town}, ${result.postcode})`

  if (autocomplete && providerInput) {
    initAutocomplete(autocomplete, providerInput, providerTemplate)
  }
  if (schoolAutocomplete && schoolInput) {
    initAutocomplete(schoolAutocomplete, schoolInput, schoolTemplate, {
      path: '/publish/suggestions',
      suggestionTemplate: schoolSuggestions
    })
  }
} catch (err) {
  console.error('Failed to initialise provider autocomplete:', err)
}
