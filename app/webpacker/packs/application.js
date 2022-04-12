import 'babel-polyfill'
import '../scripts/govuk_assets_import'
import '../styles/application.scss'
import '../scripts/components'
import { initAutocomplete } from "../scripts/autocomplete";
import { initAll } from 'govuk-frontend'
import initLocationsMap from "../scripts/locations-map";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";

initAll()

window.initLocationsMap = initLocationsMap;

try {
  const $autocomplete = document.getElementById("provider-autocomplete");
  const $provider_input = document.getElementById("provider");
  const provider_template = result => result && `${result.name} (${result.code})`;

  if($autocomplete && $provider_input) {
    initAutocomplete($autocomplete, $provider_input, provider_template);
  }
} catch (err) {
  console.error("Failed to initialise provider autocomplete:", err);
}
