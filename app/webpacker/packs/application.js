require.context("govuk-frontend/govuk/assets");

import {initAutocomplete} from "../scripts/autocomplete";
import "../stylesheets/application.scss";
import "accessible-autocomplete/dist/accessible-autocomplete.min.css";
import { initAll } from "govuk-frontend";
import FormCheckLeave from "scripts/form-check-leave";
import initLocationsMap from "scripts/locations-map";

initAll();

window.initLocationsMap = initLocationsMap;

const $form = document.querySelector('[data-module="form-check-leave"]');
new FormCheckLeave($form).init();

try {
  const $autocomplete = document.getElementById("provider-autocomplete");
  const $accredited_body_input = document.getElementById("course_accredited_body");
  const $provider_input = document.getElementById("provider");
  const $allocation_training_provider_input = document.querySelector("#training-provider-query-field, #training-provider-query-field-error");
  const accredited_body_template = result => result && result.name;
  const provider_template = result => result && `${result.name} (${result.code})`;

  if ($autocomplete && $accredited_body_input) {
    initAutocomplete($autocomplete, $accredited_body_input, accredited_body_template, {path: "/providers/suggest_any_accredited_body"});
  }
  if($autocomplete && $provider_input) {
    initAutocomplete($autocomplete, $provider_input, provider_template);
  }
  if($autocomplete && $allocation_training_provider_input) {
    initAutocomplete($autocomplete, $allocation_training_provider_input, provider_template, {path: "/providers/suggest_any"});
  }
} catch (err) {
  console.error("Failed to initialise provider autocomplete:", err);
}
