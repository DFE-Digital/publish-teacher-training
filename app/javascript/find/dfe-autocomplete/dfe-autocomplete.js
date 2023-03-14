import accessibleAutocomplete from 'accessible-autocomplete'
import sort from './sort'

const nullTracker = {
  sendTrackingEvent: function () { },
  trackSearch: function () { }
}

const defaultValueOption = component => component.getAttribute('data-default-value') || ''

const suggestion = (value, options) => {
  const option = options.find(o => o.name === value)
  if (option) {
    const html = option.append ? `<span>${value}</span> ${option.append}` : `<span>${value}</span>`
    return option.hint ? `${html}<br>${option.hint}` : html
  } else {
    return '<span>No results found</span>'
  }
}

const enhanceOption = (option) => {
  return {
    name: option.label,
    synonyms: (option.getAttribute('data-synonyms') ? option.getAttribute('data-synonyms').split('|') : []),
    append: option.getAttribute('data-append'),
    hint: option.getAttribute('data-hint'),
    boost: (parseFloat(option.getAttribute('data-boost')) || 1)
  }
}

export const setupAccessibleAutoComplete = (component, libraryOptions = {}) => {
  const selectEl = component.querySelector('select')
  const selectOptions = Array.from(selectEl.options)
  const options = selectOptions.map(o => enhanceOption(o))
  const inError = component.querySelector('div.govuk-form-group').className.includes('error')
  const inputValue = defaultValueOption(component)
  const tracker = libraryOptions.tracker || nullTracker

  const defaultOptions = {
    autoselect: true,
    defaultValue: inError ? '' : inputValue,
    minLength: 1,
    rawAttribute: false,
    selectElement: selectEl,
    trackerObject: tracker,
    onConfirm: (val) => {
      tracker.sendTrackingEvent(val, selectEl.name)
      const selectedOption = [].filter.call(selectOptions, option => (option.textContent || option.innerText) === val)[0]
      if (selectedOption) selectedOption.selected = true
    },
    source: (query, populateResults) => {
      if (/\S/.test(query)) {
        tracker.trackSearch(query)
        populateResults(sort(query, options))
      }
    },
    templates: { suggestion: (value) => suggestion(value, options) }
  }

  const autocompleteOptions = Object.assign({}, defaultOptions, libraryOptions)

  // We add a name which we base off the name for the select element and add "raw" to it, eg
  // if there is a select input called "course_details[subject]" we add a name to the text input
  // as "course_details[subject_raw]"
  const matches = /^(\w+)\[(\w+)\]$/.exec(selectEl.name)

  if (matches != null) {
    if (autocompleteOptions.rawAttribute) {
      autocompleteOptions.name = `${matches[1]}[${matches[2]}_raw]`
    } else {
      autocompleteOptions.name = `${matches[1]}[${matches[2]}]`
    }
  } else {
    autocompleteOptions.name = 'provider.provider_name'
  }

  accessibleAutocomplete.enhanceSelectElement(autocompleteOptions)

  if (inError) {
    component.querySelector('input').value = inputValue
  }
}
