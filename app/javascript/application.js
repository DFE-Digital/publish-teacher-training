// Entry point for the build script in your package.json

import "babel-polyfill";
import jQuery from "jquery";
import { initAll } from "govuk-frontend";

import { initAutocomplete } from "./autocomplete";
import initLocationsMap from "./locations-map";
import FilterToggle from "./filters";
import CookieBanner from "./cookie_banner";

window.jQuery = jQuery;
window.$ = jQuery;
window.initLocationsMap = initLocationsMap;

initAll();
FilterToggle.init();
CookieBanner.init();

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
