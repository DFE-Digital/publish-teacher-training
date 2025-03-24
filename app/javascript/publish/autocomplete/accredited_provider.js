import initAutocomplete from './autocomplete'

const providerTemplate = (result) => result && result.provider_name
const providerSuggestionTemplate = (result) => result && `${result.provider_name} (${result.provider_code})`
const onConfirm = (input) => (option) => (input.value = option ? option.id : '')

function init () {
  const accreditedProviderSearchForm = document.querySelector('form[data-recruitment-cycle-year]')
  if (!accreditedProviderSearchForm) return

  const recruitmentCycleYear = document.querySelector('form[data-recruitment-cycle-year]').dataset.recruitmentCycleYear
  const options = {
    path: `/api/${recruitmentCycleYear}/accredited_provider_suggestions`,
    template: {
      inputValue: providerTemplate,
      suggestion: providerSuggestionTemplate
    },
    minLength: 2,
    inputName: 'accredited_provider_id',
    onConfirm
  }

  initAutocomplete('accredited-provider-autocomplete', 'accredited-provider-search-form-query-field', options)
}

export default init
