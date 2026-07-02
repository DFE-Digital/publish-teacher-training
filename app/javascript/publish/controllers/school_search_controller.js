import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "school",
    "noResults",
    "selectAllSection",
    "showMoreButton",
    "pagination",
    "table",
  ];

  search(event) {
    if (event) event.preventDefault();

    const query = this.inputTarget.value.trim().toLowerCase();
    const hasSearchTerm = query.length > 0;

    let matchCount = 0;

    this.schoolTargets.forEach((element) => {
      const text = element.dataset.searchText || "";
      const matches = query === "" || text.includes(query);

      element.style.display = matches ? "" : "none";

      if (matches) matchCount += 1;
    });

      const hasResults = matchCount > 0;

      // No results message
      if (this.hasNoResultsTarget) {
        this.noResultsTarget.hidden = hasResults;
      }


      // Hide pagination when searching
      if (this.hasPaginationTarget) {
        this.paginationTarget.style.display = hasSearchTerm ? "none" : "";
      }

      // Hide table when no results
      if (this.hasTableTarget) {
        this.tableTarget.hidden = !hasResults;
      }

    // Select all section
    this.selectAllSectionTarget.hidden = !hasResults;

    const showMoreContainer = this.element.querySelector(
      '[data-controller~="show-more"]',
    );

    if (hasSearchTerm && hasResults) {
      // SEARCH MODE: show ALL matching schools after a search, even if more than 20
      showMoreContainer?.dispatchEvent(
        new CustomEvent("show-more:showAll", { bubbles: true }),
      );
    }

    if (!hasSearchTerm) {
      // DEFAULT MODE: back to 20 schools after clearing search
      showMoreContainer?.dispatchEvent(
        new CustomEvent("show-more:reset", { bubbles: true }),
      );
    }
  }

  showMore(event) {
    if (event) event.preventDefault();
    // No-op: show-more controller handles expanding
  }

  clear(event) {
    if (event) event.preventDefault();
    this.inputTarget.value = "";
    this.search();
  }
}
