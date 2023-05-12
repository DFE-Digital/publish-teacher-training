import initAutocomplete from './autocomplete'

const providerTemplate = (result) => result && `${result.name} (${result.code})`
const onConfirm = (input) => (option) => (input.value = option ? option.code : '')

const options = {
  path: '/publish/providers/suggest',
  template: {
    inputValue: providerTemplate,
    suggestion: providerTemplate
  },
  minLength: 3,
  onConfirm: onConfirm,
  input_name: 'course[autocompleted_provider_code]'
}

function init () {
  initAutocomplete('provider-autocomplete', 'provider', options)
}

export default init
