import accessibleAutocomplete from 'accessible-autocomplete'

const getSelectElement = elementId => document.getElementById(elementId)

const setupAutocomplete = inputId => {
  let elementId = inputId
  let selectElement = getSelectElement(elementId)
  if (!selectElement) {
    elementId += '-error'
    selectElement = getSelectElement(elementId)
  }

  try {
    selectElement.querySelector("[value='']").innerHTML = ''

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showNoOptionsFound: true
    })
  } catch (err) {
    console.error(`Could not enhance ${elementId}`, err)
  }
}

export default setupAutocomplete
