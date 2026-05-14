import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "school",
    "noResults",
    "selectAllSection",
    "showMoreButton",
  ];

  search(event) {
    if (event) event.preventDefault();

    const query = this.inputTarget.value.trim().toLowerCase();
    let visibleCount = 0;

    this.schoolTargets.forEach((element) => {
      const text = element.dataset.searchText || "";
      const matches = query === "" || text.includes(query);

      element.hidden = !matches;

      if (matches) {
        visibleCount += 1;
      }
    });

    const hasResults = visibleCount > 0;

    // No results message
    this.noResultsTarget.hidden = hasResults;

    // Select all section
    this.selectAllSectionTarget.hidden = !hasResults;

    const hasSearchTerm = query.length > 0;

    // Hide "Show 20 more schools" whenever a search is active
    this.showMoreButtonTarget.hidden = hasSearchTerm;

    // Reset pagination only when search is cleared
    if (!hasSearchTerm) {
      const showMoreContainer = this.element.querySelector(
        '[data-controller~="show-more"]',
      );

      if (showMoreContainer) {
        showMoreContainer.dispatchEvent(
          new CustomEvent("show-more:reset", { bubbles: true }),
        );
      }
    }
  }

  clear(event) {
    if (event) event.preventDefault();

    // Clear the search input
    this.inputTarget.value = "";

    // Re-run the search logic with an empty query
    this.search();
  }
}
