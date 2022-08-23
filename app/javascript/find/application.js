// Entry point for the build script in your package.json
import { initAll } from 'govuk-frontend'
import setupAutocomplete from './setup-autocomplete'

initAll()
setupAutocomplete('find-courses-by-location-or-training-provider-form-school-uni-or-provider-query-field')
