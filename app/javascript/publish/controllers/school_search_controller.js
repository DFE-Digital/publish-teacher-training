import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "school"];

  search(event) {
    if (event) event.preventDefault();

    const query = this.inputTarget.value.trim().toLowerCase();

    this.schoolTargets.forEach((element) => {
      const text = element.dataset.searchText || "";
      element.hidden = !(query === "" || text.includes(query));
    });
  }

  clear(event) {
    if (event) event.preventDefault();

    // ✅ Clear the input
    this.inputTarget.value = "";

    // ✅ Show all schools
    this.schoolTargets.forEach((element) => {
      element.hidden = false;
    });

    // ✅ Reset pagination back to first 20
    const showMoreContainer = this.element.closest(
      '[data-controller~="show-more"]',
    );

    if (showMoreContainer) {
      showMoreContainer.dispatchEvent(new CustomEvent("show-more:reset"));
    }
  }
}
