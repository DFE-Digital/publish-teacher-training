import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "input",
    "school",
    "noResults",
    "selectAllSection",
    "showMoreButton",
  ];

  connect() {
    this.searchResultLimit = 20;
    this.lastQuery = "";
  }

  search(event) {
    if (event) event.preventDefault();

    const query = this.inputTarget.value.trim().toLowerCase();
    const hasSearchTerm = query.length > 0;
    let matchCount = 0;
    const matchedSchools = [];

    if (hasSearchTerm && query !== this.lastQuery) {
      this.searchResultLimit = 20;
    }

    this.lastQuery = query;

    this.schoolTargets.forEach((element) => {
      const text = element.dataset.searchText || "";
      const matches = query === "" || text.includes(query);

      if (matches) {
        matchedSchools.push(element);
        matchCount += 1;
      }

      element.hidden = true;
    });

    if (hasSearchTerm) {
      matchedSchools.slice(0, this.searchResultLimit).forEach((element) => {
        element.hidden = false;
      });
    } else {
      matchedSchools.forEach((element) => {
        element.hidden = false;
      });
    }

    const hasResults = matchCount > 0;

    // No results message
    this.noResultsTarget.hidden = hasResults;

    // Select all section
    this.selectAllSectionTarget.hidden = !hasResults;

    // During search, keep link visible only when there are more matches to reveal
    if (hasSearchTerm) {
      this.showMoreButtonTarget.hidden = matchCount <= this.searchResultLimit;
    }

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

  showMore(event) {
    if (!event) return;

    const query = this.inputTarget.value.trim();
    if (query.length === 0) return;

    event.preventDefault();
    event.stopImmediatePropagation();
    this.searchResultLimit += 20;
    this.search();
  }

  clear(event) {
    if (event) event.preventDefault();

    // Clear the search input
    this.inputTarget.value = "";

    // Re-run the search logic with an empty query
    this.search();
  }
}
