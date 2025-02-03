import { Controller } from "@hotwired/stimulus"
import accessibleAutocomplete from "accessible-autocomplete"
import debounce from "lodash.debounce"
import { request } from '../../utils/request_helper'

export default class extends Controller {
  static targets = ["input", "locationId", "locationTypes"];
  static values = { path: String };

  connect() {
    if (!this.hasInputTarget) return;

    console.log(this.inputTarget)
    console.log(this.inputTarget.value)

    accessibleAutocomplete({
      element: this.inputTarget.parentElement,
      id: this.inputTarget.id,
      showNoOptionsFound: false,
      name: this.inputTarget.name,
      defaultValue: this.inputTarget.value,
      minLength: 3,
      source: this.fetchSuggestions(),
      templates: {
        inputValue: this.inputValueTemplate,
        suggestion: this.suggestionTemplate
      },
      onConfirm: this.handleSelection.bind(this),
      confirmOnBlur: false
    });

    this.inputTarget.remove();
  }

  fetchSuggestions() {
    return debounce((query, callback) => {
      if (!query) return callback([]);

      new Promise((resolve) => {
        request(this.pathValue)(query, (data) => {
          resolve(data);
        });
      })
      .then((data) => {
        callback(data.suggestions || []);
      })
      .catch(() => {
        callback([]);
      });
    }, 900);
  }

  inputValueTemplate(result) {
    return result ? result.name : "";
  }

  suggestionTemplate(result) {
    return result ? result.name : "";
  }

  handleSelection(option) {
    if (!option) return;

    this.locationIdTarget.value = option.location_id || "";
    this.locationTypesTarget.value = option.location_types ? option.location_types.join(",") : "";
  }
}
