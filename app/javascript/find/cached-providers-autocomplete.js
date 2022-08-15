import accessibleAutocomplete from 'accessible-autocomplete'

export const initCachedProvidersAutocomplete = () => {
  const inputId = 'query'
  const autocompleteId = 'provider-autocomplete'

  try {
    const selectElement = document.getElementById(inputId)

    if (!selectElement) return

    // Replace "Select a ..." with empty string
    selectElement.querySelector("[value='']").innerHTML = ''

    accessibleAutocomplete.enhanceSelectElement({
      selectElement,
      autoselect: false,
      confirmOnBlur: false,
      showNoOptionsFound: true
    })
  } catch (err) {
    console.error(`Could not enhance ${autocompleteId}`, err)
  }
}
