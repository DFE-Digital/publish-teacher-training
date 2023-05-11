import initAutocomplete from './autocomplete'

const providerTemplate = (result) => result && `${result.provider_name} (${result.provider_code})`
const onConfirm = (input) => (option) => (input.value = option ? option.id : '')
const options = {
  path: '/api/accredited_provider_suggestions',
  template: {
    inputValue: providerTemplate,
    suggestion: providerTemplate
  },
  minLength: 2,
  inputName: 'accredited_provider_id',
  onConfirm
}

function init () {
  initAutocomplete('accredited-provider-autocomplete', 'accredited-provider-search-form-query-field', options)
}

export default init
