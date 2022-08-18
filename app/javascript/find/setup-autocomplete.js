import accessibleAutocomplete from 'accessible-autocomplete'

const getSelectElement = inputId => document.getElementById(inputId)

const setupAutocomplete = inputId => {
  const selectElement = getSelectElement(inputId)

  try {
    selectElement.querySelector("[value='']").innerHTML = ''

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showNoOptionsFound: true
    })
  } catch (err) {
    console.error(`Could not enhance ${inputId}`, err)
  }
}

export default setupAutocomplete
