// Entry point for the build script in your package.json
import { initAll } from 'govuk-frontend'
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css'
import { initCachedProvidersAutocomplete } from 'cached-providers-autocomplete'

initAll()
initCachedProvidersAutocomplete()
