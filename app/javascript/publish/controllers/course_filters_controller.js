import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["applyFiltersButton"];

  connect() {
    if (this.hasApplyFiltersButtonTarget) {
      const wrapper =
        this.applyFiltersButtonTarget.closest(".govuk-button-group") ||
        this.applyFiltersButtonTarget;

      wrapper.style.display = "none";
    }

    this.element.addEventListener("change", (event) => {
      if (event.target.matches('input[type="checkbox"]')) {
        this.submit();
      }
    });
  }

  submit() {
    this.element.requestSubmit();
  }
}
