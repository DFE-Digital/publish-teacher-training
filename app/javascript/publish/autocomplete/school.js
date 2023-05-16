import initAutocomplete from './autocomplete'

const schoolTemplate = (result) => result && `${result.name}`
const schoolSuggestionsTemplate = (result) => result && `${result.name} (${result.town}, ${result.postcode})`
const onConfirm = (input) => (option) => {
  if (option.id === undefined) {
    return
  }

  input.value = option.id
}
const options = {
  path: '/api/school_suggestions',
  template: {
    inputValue: schoolTemplate,
    suggestion: schoolSuggestionsTemplate
  },
  minLength: 3,
  onConfirm,
  inputName: 'course[autocompleted_provider_code]'
}

function init () {
  initAutocomplete('school-autocomplete', 'publish-schools-search-form-query-field', options)
}

export default init
