import initAutocomplete from './autocomplete'

const providerTemplate = (result) => result && result.provider_name
const providerSuggestionTemplate = (result) => result && `${result.provider_name} (${result.provider_code})`
const onConfirm = (input) => (option) => (input.value = option ? option.id : '')
const recruitment_cycle_year = document.getElementById('accredited_provider_search_form_recruitment_cycle_year').value
const options = {
  path: `/api/${recruitment_cycle_year}/accredited_provider_suggestions`,
  template: {
    inputValue: providerTemplate,
    suggestion: providerSuggestionTemplate
  },
  minLength: 2,
  inputName: 'accredited_provider_id',
  onConfirm
}

function init () {
  initAutocomplete('accredited-provider-autocomplete', 'accredited-provider-search-form-query-field', options)
}

export default init
