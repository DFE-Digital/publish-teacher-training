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
  const schoolSuggestionsTemplate = (result) => result && `${result.name} (${result.town}, ${result.postcode})`
  const schoolHiddenIdInput = document.getElementById('school-id')

  const schoolConfirmCallback = (schoolId) => {
    if (schoolId === undefined) {
      return
    }

    schoolHiddenIdInput.value = schoolId
  }

  if (autocomplete && providerInput) {
    initAutocomplete(autocomplete, providerInput, providerTemplate, {
      path: '/publish/providers/suggest',
      template: providerTemplate
    })
  }
  if (schoolAutocomplete && schoolInput) {
    initAutocomplete(schoolAutocomplete, schoolInput, schoolTemplate, {
      path: '/api/school_suggestions',
      template: schoolSuggestionsTemplate,
      onConfirm: (option) => {
        schoolConfirmCallback(option.id)
      }
    })
  }
} catch (err) {
  console.error('Failed to initialise provider autocomplete:', err)
}
