import initAutocomplete from './autocomplete'

const providerTemplate = (result) =>
  result && `${result.name} (${result.code})`

const options = {
  path: '/publish/providers/suggest',
  template: {
    inputValue: providerTemplate,
    suggestion: providerTemplate
  }
}

function init () {
  initAutocomplete('provider-autocomplete', 'provider', options)
}

export default init
