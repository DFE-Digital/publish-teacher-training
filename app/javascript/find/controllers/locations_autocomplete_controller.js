import RemoteAutocompleteController from './remote_autocomplete_controller'

export default class extends RemoteAutocompleteController {
  suggestionTemplate (result) {
    if (typeof result === 'string') {
      return result
    }

    if (result?.formatted_name && result.formatted_name.trim() !== '') {
      return result.formatted_name
    }

    if (result?.name) {
      return result.name
    }

    return ''
  }
}
