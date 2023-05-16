import providerAutocompleteSetup from './provider'
import schoolAutocompleteSetup from './school'
import accreditedProviderAutocompleteSetup from './accredited_provider'

function init () {
  providerAutocompleteSetup()
  schoolAutocompleteSetup()
  accreditedProviderAutocompleteSetup()
}

export default init
