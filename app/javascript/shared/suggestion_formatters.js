// Turns a suggestion endpoint's raw result into the shape dfe-autocomplete
// renders. `name` is shown in the input and as the suggestion's main text;
// `append` is extra context shown only in the dropdown.
export const FORMATTERS = {
  provider: (result) => ({ ...result, name: `${result.name} (${result.code})` }),
  school: (result) => ({ ...result, append: `(${result.town}, ${result.postcode})` }),
  accredited: (result) => ({ ...result, name: `${result.provider_name} (${result.provider_code})` }),
  location: (result) => (typeof result === 'string' ? { name: result } : { ...result })
}
