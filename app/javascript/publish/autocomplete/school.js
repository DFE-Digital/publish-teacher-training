import initAutocomplete from './autocomplete'

const schoolTemplate = (result) => result && `${result.name}`
const schoolSuggestionsTemplate = (result) => result && `${result.name} (${result.town}, ${result.postcode})`
const schoolConfirmCallback = (input) =>  (schoolId) => {
  if (schoolId === undefined) {
    return
  }

  input.value = schoolId
}
const options = {
  path: '/api/school_suggestions',
  template: {
    inputValue: schoolTemplate,
    suggestion: schoolSuggestionsTemplate
  },
  onConfirm: (option) => {
    schoolConfirmCallback(option.id)
  }
}

function init () {
  initAutocomplete('school-autocomplete', 'publish-schools-search-form-query-field', options)
}

export default init
