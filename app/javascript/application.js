// Entry point for the build script in your package.json

import "babel-polyfill";
import { initAutocomplete } from "./autocomplete";
import { initAll } from "govuk-frontend";
import initLocationsMap from "./locations-map";

initAll();

window.initLocationsMap = initLocationsMap;

try {
  const $autocomplete = document.getElementById("provider-autocomplete");
  const $provider_input = document.getElementById("provider");
  const provider_template = (result) =>
    result && `${result.name} (${result.code})`;

  if ($autocomplete && $provider_input) {
    initAutocomplete($autocomplete, $provider_input, provider_template);
  }
} catch (err) {
  console.error("Failed to initialise provider autocomplete:", err);
}
